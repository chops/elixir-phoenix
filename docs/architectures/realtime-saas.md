
Realtime-SaaS Architecture

Overview

Phoenix + LiveView front end with Ecto + Postgres as the source of truth. Oban runs background jobs. ETS provides a read-through cache. Nodes form a cluster with libcluster. Telemetry exports to Prometheus. SLOs: p95 < 150 ms, 99.9% uptime, cost guardrails.

When to Use This Pattern
	•	Multi-tenant SaaS with interactive dashboards and forms.
	•	Real-time UI updates without a SPA front end.
	•	CRUD systems that need background processing and low read latency.

Components

Clients

Purpose: Browser or API consumer.
Technology: WebSockets + HTTP(S).
Key Responsibilities:
	•	Maintain LiveView socket.
	•	Send events and receive diffs.

Phoenix + LiveView

Purpose: Real-time UI and request handling.
Technology: Phoenix, LiveView.
Key Responsibilities:
	•	Mount views and handle events quickly.
	•	Push minimal diffs over WebSocket.
	•	Emit Telemetry for requests and LiveView lifecycle.

Contexts

Purpose: Business logic boundary.
Technology: Plain Elixir modules.
Key Responsibilities:
	•	Validate invariants and orchestrate reads/writes.
	•	Decide cache usage and job enqueueing.

Ecto Repo + Postgres

Purpose: Durable system of record.
Technology: Ecto, PostgreSQL.
Key Responsibilities:
	•	Run queries and transactions.
	•	Enforce constraints and indexes.

ETS Read-Through Cache

Purpose: Hot-path low-latency reads.
Technology: ETS (set/ordered_set with read_concurrency).
Key Responsibilities:
	•	Serve cache hits in-memory.
	•	On miss: fetch via Repo, populate with TTL.
	•	Invalidate or refresh on writes.

Oban Jobs

Purpose: Durable background work.
Technology: Oban.
Key Responsibilities:
	•	Queue non-interactive tasks (emails, webhooks, fan-out).
	•	Retry with backoff; track success/failure metrics.

libcluster

Purpose: Node discovery and clustering.
Technology: libcluster.
Key Responsibilities:
	•	Form BEAM cluster across Node A/B/C.
	•	Enable cross-node PubSub and distribution.

Telemetry → Prometheus (Metrics/Logs)

Purpose: Observability and SLO tracking.
Technology: :telemetry, Prometheus exporter, structured logs.
Key Responsibilities:
	•	Emit Phoenix/Ecto/Oban/VM metrics.
	•	Expose /metrics; ship logs for analysis.

Architecture Diagram

[Clients] → Phoenix/LiveView → Contexts → Repo
                        ↓                ↘
                    Oban jobs          ETS cache
Cluster: Node A ↔ Node B ↔ Node C   Telemetry → Metrics/Logs

Data Flow
	1.	Client connects to Phoenix; LiveView mounts over WebSocket.
	2.	LiveView calls a context to load data. Context checks ETS:
	•	Hit: Return cached data.
	•	Miss: Repo fetch → write to ETS with TTL → return data.
	3.	LiveView renders and pushes diffs to the client. Keep callback work under budget to meet p95 < 150 ms.
	4.	User events trigger context actions:
	•	Read path: Prefer ETS → fall back to Repo → populate ETS.
	•	Write path: Use Ecto changesets and Repo.transaction/1. On success, update or invalidate ETS entries.
	5.	Non-interactive or slow work enqueues an Oban job. LiveView returns immediately. Jobs run out-of-band, retry on failure, and write results back to Postgres. If needed, refresh ETS.
	6.	Telemetry from Phoenix/Ecto/Oban/VM exports to Prometheus. Logs are structured for correlation.
	7.	Clustering: libcluster connects nodes. Phoenix.PubSub works across nodes. Load balancer may use sticky sessions for LiveView sockets. Horizontal scale is achieved by adding nodes.

Key Design Decisions

LiveView over SPA

Choice: LiveView for real-time UI.
Rationale: Less client code, server-driven diffs, fast iteration.
Tradeoffs: Requires socket longevity and careful callback budgets.

Read-Through ETS

Choice: Per-node ETS cache with TTL.
Rationale: Sub-millisecond reads and reduced DB load.
Tradeoffs: Per-node coherence; rely on TTL + write-through/invalidations.

Oban for Background Work

Choice: Durable jobs with backoff and concurrency controls.
Rationale: Keeps interactive paths fast; reliability under failure.
Tradeoffs: Operational overhead for queues and dead letters.

libcluster for Horizontal Scale

Choice: Auto-discovered BEAM cluster.
Rationale: Simple node joins, distributed PubSub, better CPU utilization.
Tradeoffs: Consider partitions; design for DB as the source of truth.

Telemetry → Prometheus

Choice: Native Telemetry with Prometheus scraping.
Rationale: Low overhead, standard dashboards and alerts.
Tradeoffs: Cardinality control on labels is required.

Failure Modes & Handling
	•	DB outage or slow queries: Circuit-break long calls; degrade to cached reads; alert on pool saturation.
	•	ETS staleness: TTLs plus explicit invalidation on writes. Prefer correctness over stale speed for critical reads.
	•	Job failures: Oban retries with exponential backoff; move poison jobs to DLQ; surface queue depth and failure rate.
	•	Node loss: Remaining nodes continue; jobs use unique keys for idempotency; replace capacity automatically.
	•	Network partition: Treat Postgres as source of truth; avoid cross-node mutable state; reconcile via periodic tasks.

Observability & SLOs

Metrics to Track
	•	Latency: Phoenix request and LiveView event duration p50/p95/p99 (target p95 < 150 ms).
	•	Errors: HTTP 5xx rate < 0.1%; LiveView disconnects.
	•	Saturation: DB pool usage < 80%; scheduler utilization; Oban queue latency and size; ETS hit rate > 90% for hot keys.
	•	Traffic: RPS, concurrent LiveView sessions, WebSocket connects/disconnects.

SLO Targets
	•	Latency: p95 < 150 ms for interactive actions.
	•	Availability: 99.9% uptime.
	•	Cost guardrails: Cost per request and per tenant within budget envelopes; alert on variance.

Scaling Considerations
	•	DB bottleneck: Add read replicas for heavy reads; optimize indexes; batch writes via jobs.
	•	LiveView CPU: Add nodes; optimize diff sizes; keep callbacks < 5 ms average.
	•	ETS memory pressure: Key TTLs and size limits; shard tables per domain.
	•	Jobs backlog: Increase Oban queues/workers; split hot queues; cap concurrency by resource.

Related Phases
	•	Phase 5: Ecto + Postgres patterns.
	•	Phase 6: Phoenix + LiveView.
	•	Phase 7: Oban jobs and backpressure.
	•	Phase 8: ETS caching.
	•	Phase 9: Distribution + libcluster.
	•	Phase 10: Telemetry and SLOs.

Example Implementation
	•	labs_orders_web (LiveView CRUD)
	•	labs_cache (ETS read-through)
	•	labs_jobs (Oban queues)
	•	pulse_web, pulse_cache, pulse_jobs integrated in a clustered dev stack

Further Reading
	•	Phoenix LiveView guides.
	•	Ecto and Postgres constraints and indexes.
	•	Oban docs for retries and isolation.
	•	libcluster and distribution guides.
	•	Telemetry + Prometheus exporter and dashboarding.

