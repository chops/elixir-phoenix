# Phase 13 — Capstone Integration

Bring together all phases into a fully integrated, production-ready system.

## Books
None new.

## Supplements
- **Distributed Phoenix: deployment and scaling**
  https://fly.io/phoenix-files/---

================================================================================

Phase 13 — Capstone Integration content extracted.

Scope
	•	Integrate all subsystems into a small real-time SaaS: LiveView UI, background jobs, ingestion feed, ETS cache, cluster, full observability with SLOs, security, and releases.    

GameDay chaos scenarios
	•	Kill a node, verify service continuity, then reconcile ownership on return.  
	•	Spike latency until SLO burn alerts fire.  
	•	Drop the database, follow runbook to recover.  
	•	Record outcomes and artifacts in docs/runbook/gameday.md.  

Integration testing across phases
	•	End-to-end tests over HTML, JSON, and Channels; Presence with two clients.  
	•	Duplicate ingestion inputs processed once; bounded concurrency; metrics confirm demand control.  
	•	Constraint tests pass; indexes used; idempotent upserts.  

Performance testing under load
	•	k6 load tests populate dashboards; induce latency to trigger burn alerts. Artifacts under /tools/k6/* and Grafana JSON.    

Failure-mode tests
	•	Node loss during clustered operation; verify continued service and rebalancing.  
	•	Release rollback completes in under two minutes.  
	•	Readiness gates migrations before traffic.  

Recovery procedures
	•	Use delivery runbooks and systemd/compose controls: start/stop/restart without downtime; blue-green or rolling deployment with rollback < 2 min.  
	•	Store runbooks at /docs/runbook/*.md.  

Demo script requirements
	•	30-minute recorded demo that exercises every subsystem; GameDay must pass. Keep docs/demo/script.md current; tag release v2.0-m13-capstone.    

“PulseShop” evolution (integrated system)
	•	M0 Init umbrella, CI, ADR template → repo gates enforce quality.
	•	M1 Pure core: totals, taxes, CSV import, price rules → pure functions + property tests.
	•	M2 Mailbox Cart loop with timeout → message passing and timeouts.
	•	M3 Cart → GenServer with TTL; supervised → thin callbacks, periodic sweeps, recovery.
	•	M4 One Cart worker per user via Registry/DynamicSupervisor → fleets, safe naming, churn safe.
	•	M5 Postgres: Users/Orders/Payments; Ecto.Multi checkout with idempotency key → constraints and transactions.
	•	M6 Phoenix: LiveView cart/checkout; JSON API; Channel orders:* + Presence → web edges + real-time.
	•	M7 Ingestion: order events (Broadway) + email/receipt jobs (Oban) → backpressure, retries, DLQ.
	•	M8 ETS cache: product catalog and user prefs, read-through → hot-path speedup with TTL sweeps.
	•	M9 Cluster: shard carts by user id; rebalance on node changes → scale-out and failover.
	•	M10 Observability: OTEL, Prometheus, Grafana; SLOs/alerts → measurable reliability.
	•	M11 Security: role scopes, audit log, scanners, SBOM → least privilege and traceability.
	•	M12 Delivery: mix release, health/readiness, blue-green, systemd → safe rollouts and rollback.
	•	M13 Capstone: run chaos drills; record demo → operational excellence.
	•	M14 CTO docs: annual plan, hiring loop, risk register, unit economics → leadership readiness.  

Acceptance
	•	“Real-time Orders SaaS” integrates M1–M12.
	•	Pass: 30-min demo + GameDay chaos script.  

Artifacts to produce
	•	docs/demo/script.md, docs/runbook/gameday.md, release notes and tags.  

