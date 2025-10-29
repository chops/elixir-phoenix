# Roadmap: Elixir Systems Mastery

A comprehensive learning path from tooling to production operations, organized into 15 phases with books, docs, and supplements.

## Phase Overview

| Phase | Focus Area | Reading Notes | Apps |
|-------|------------|---------------|------|
| **Phase 0** | Tooling foundation | [phase-00-tooling.md](reading/phase-00-tooling.md) | `labs_gatekeeper` |
| **Phase 1** | Elixir core | [phase-01-core.md](reading/phase-01-core.md) | `labs_csv_stats`, `pulse_core` |
| **Phase 2** | Processes & mailboxes | [phase-02-mailboxes.md](reading/phase-02-mailboxes.md) | `labs_mailbox_kv` |
| **Phase 3** | GenServer + supervision | [phase-03-genserver.md](reading/phase-03-genserver.md) | `labs_counter_ttl`, `pulse_cart` |
| **Phase 4** | Naming & fleets | [phase-04-fleets.md](reading/phase-04-fleets.md) | `labs_session_workers`, `pulse_fleet` |
| **Phase 5** | Data & Ecto | [phase-05-ecto.md](reading/phase-05-ecto.md) | `labs_orders_db`, `pulse_data` |
| **Phase 6** | Phoenix web | [phase-06-web.md](reading/phase-06-web.md) | `labs_orders_web`, `pulse_web` |
| **Phase 7** | Jobs & ingestion | [phase-07-dataflow.md](reading/phase-07-dataflow.md) | `labs_ingest`, `labs_jobs`, `pulse_ingest`, `pulse_jobs` |
| **Phase 8** | Caching & ETS | [phase-08-ets.md](reading/phase-08-ets.md) | `labs_cache`, `pulse_cache` |
| **Phase 9** | Distribution | [phase-09-cluster.md](reading/phase-09-cluster.md) | `labs_cluster`, `pulse_cluster` |
| **Phase 10** | Observability & SLOs | [phase-10-observability.md](reading/phase-10-observability.md) | `labs_telemetry`, `pulse_obs` |
| **Phase 11** | Testing strategy | [phase-11-testing.md](reading/phase-11-testing.md) | All apps (test suite) |
| **Phase 12** | Delivery & ops | [phase-12-delivery.md](reading/phase-12-delivery.md) | `labs_release_runner` |
| **Phase 13** | Capstone integration | [phase-13-capstone.md](reading/phase-13-capstone.md) | Full system integration |
| **Phase 14** | CTO track | [phase-14-cto.md](reading/phase-14-cto.md) | Security & ops practice |
| **Phase 15** | AI/ML Integration | [phase-15-ai-ml.md](reading/phase-15-ai-ml.md) | `labs_ai_classifier`, `pulse_ai_recommender` |

---

## Mastery Proof Matrix

| Phase | Labs app            | Pulse feature(s)     | Why it proves mastery                        |
|------:|---------------------|----------------------|----------------------------------------------|
| M0    | labs_gatekeeper     | repo gates           | CI + quality bars                            |
| M1    | labs_csv_stats      | pulse_core           | pure funcs, Stream, properties               |
| M2    | labs_mailbox_kv     | pulse_cart (loop)    | mailbox, timeouts, monitors                  |
| M3    | labs_counter_ttl    | pulse_cart (GenServer)| callbacks, periodic work, supervision      |
| M4    | labs_session_workers| pulse_fleet          | Registry, DynamicSupervisor, churn           |
| M5    | labs_orders_db      | pulse_data           | changesets, constraints, Multi               |
| M6    | labs_orders_web     | pulse_web            | LiveView, JSON, Channels + Presence          |
| M7    | labs_ingest + jobs  | pulse_ingest + jobs  | backpressure, idempotency, retries           |
| M8    | labs_cache          | pulse_cache          | ETS, writer/reader, benches                  |
| M9    | labs_cluster        | pulse_cluster        | clustering, sharding, reconciliation         |
| M10   | labs_telemetry      | pulse_obs            | OTEL, Prom, dashboards, SLOs                 |
| M11   | labs_authz_audit    | pulse_* contexts     | least privilege, audit trail                 |
| M12   | labs_release_runner | releases for pulse   | health/readiness, graceful rollout           |
| M13   | — integrate         | full pulse stack     | gameday: kill nodes, spike, recover          |
| M14   | labs_incident_cli   | ops docs             | drills and runbooks as code                  |
| M15   | labs_ai_classifier  | pulse_ai_recommender | Nx/Axon/Bumblebee integration, serving models |

---

## Weekly Cadence

- **Mon–Tue**: Book chapters
- **Wed**: Official docs
- **Thu**: Supplements/community threads
- **Fri**: Commit "what changed" notes and link PRs

Open one PR per phase titled **Reading: Phase N** with a summary and links to applied changes.

---

## Progress Tracking

- [ ] Phase 0: Tooling foundation
- [ ] Phase 1: Elixir core
- [ ] Phase 2: Processes & mailboxes
- [ ] Phase 3: GenServer + supervision
- [ ] Phase 4: Naming & fleets
- [ ] Phase 5: Data & Ecto
- [ ] Phase 6: Phoenix web
- [ ] Phase 7: Jobs & ingestion
- [ ] Phase 8: Caching & ETS
- [ ] Phase 9: Distribution
- [ ] Phase 10: Observability & SLOs
- [ ] Phase 11: Testing strategy
- [ ] Phase 12: Delivery & ops
- [ ] Phase 13: Capstone integration
- [ ] Phase 14: CTO track
- [ ] Phase 15: AI/ML Integration

---

## Phase Details

### Phase 0 — Tooling Foundation

**Mastery Definition:** You can enforce repository-wide CI quality gates for an Elixir umbrella. Format, Credo, Dialyzer, Sobelow, and mix_audit all run locally and in CI, and any violation fails the build. CI is wired with a job matrix. Acceptance is "make check" green on CI.

**Learning Objectives:**
- Add CI gates for format, credo, dialyzer, sobelow, and deps audit
- Provide Makefile targets that compose these checks
- Bootstrap a CI workflow and matrix for OTP/Elixir versions
- Scaffold docs and an ADR template for decisions

**Apps to Build:**

**Labs App:** `labs_gatekeeper`
- **Scope:** CI + quality bars for an umbrella repo
- **Key Features:**
  - GitHub Actions pipeline runs format, credo --strict, dialyzer, sobelow --exit, mix deps.audit
  - Makefile with check target that aggregates gates
  - ADR template and docs scaffold committed
- **Success Criteria:**
  - [ ] Build fails on any gate violation
  - [ ] `make check` is green on CI

**Pulse Feature:** repo gates
- **Integration:** Apply the same CI gates to the PulseShop product from the start
- **Dependencies:** None
- **Success Criteria:**
  - [ ] Pulse repos use the shared CI workflow and pass all gates
  - [ ] First Pulse milestone initialized under CI

**Why This Proves Mastery:** This phase proves repository hygiene and the ability to codify non-negotiable quality bars. It isolates the leverage point for all later phases; the tiny app exists only to enforce these invariants.

**Time Estimate:**
- Reading: 0.5 days
- Labs Implementation: 1–1.5 days
- Pulse Integration: 0.5–1 day
- **Total: 2–3 days**

**Prerequisites:**
- [ ] Elixir installed (no other prerequisites)

**Deliverables:**
- [ ] Reading notes in `docs/reading/phase-00-tooling.md`
- [ ] Labs app with tests (>80% coverage)
- [ ] Pulse feature integrated (repo gates)
- [ ] ADR documenting key design decisions
- [ ] Demo script or video

**References:**
- Phase 0 docs list: Credo, Dialyxir, mix_audit, Sobelow
- Minimal Makefile targets: fmt, credo, dialyzer, audit, sobelow, test
- CI matrix and workflow starter

**Mastery Gate:**
```bash
# All gates must pass before advancing
make ci
```

**Performance Targets:**
- [ ] CI pipeline completes in < 5 minutes
- [ ] All 6 quality gates pass (format, credo, dialyzer, sobelow, deps.audit, test)
- [ ] Zero warnings from any tool

**Can Advance When:**
- [ ] `make ci` green on main branch
- [ ] Pre-commit hook configured and passing locally
- [ ] Team can explain purpose of each gate

---

### Phase 1 — Elixir Core

**Mastery Definition:** You can write pure functional code using pattern matching, recursion, and the pipe operator. You understand immutability, tagged tuples for errors, and can process data with Enum and Stream.

**Learning Objectives:**
- Master pattern matching and guards
- Write tail-recursive functions
- Use Enum and Stream for data transformation
- Handle errors with tagged tuples {:ok, _} | {:error, _}
- Apply property-based testing with StreamData

**Apps to Build:**

**Labs App:** `labs_csv_stats`
- **Scope:** CSV parser and statistics calculator using pure functions
- **Key Features:**
  - Parse CSV files using binary pattern matching
  - Calculate statistics (mean, median, mode, stddev) with Enum
  - Stream large files without loading into memory
  - Property-based tests for edge cases
- **Success Criteria:**
  - [ ] Handles 1M+ row CSV files via Stream
  - [ ] All functions are pure (no side effects)
  - [ ] 100+ property-based tests passing

**Pulse Feature:** `pulse_core`
- **Integration:** Pure domain logic for product catalog and pricing
- **Dependencies:** None
- **Success Criteria:**
  - [ ] All business rules in pure functions
  - [ ] Comprehensive property tests
  - [ ] Zero Dialyzer warnings

**Time Estimate:**
- Reading: 3-4 days
- Labs Implementation: 2-3 days
- Pulse Integration: 1-2 days
- **Total: 6-9 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-01-gate.js
```

**Performance Targets:**
- [ ] CSV parsing: p95 < 50ms for 10K rows
- [ ] Statistics calculation: p95 < 100ms for 100K numbers
- [ ] Memory usage: < 50MB for 1M row streaming
- [ ] All property tests pass in < 10 seconds

**Failure Drills:**
- [ ] Handle malformed CSV (missing columns, invalid encoding)
- [ ] Process empty files without crashing
- [ ] Recover from invalid numeric data

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can refactor imperative code to functional in < 30 min
- [ ] Comfortable writing recursive solutions without Stack Overflow

---

### Phase 2 — Processes & Mailboxes

**Mastery Definition:** You understand processes, message passing, and the actor model. You can write receive loops with timeouts, monitor processes, and handle process exits gracefully.

**Learning Objectives:**
- Spawn processes and send messages
- Write receive loops with pattern matching
- Use monitors and links for fault detection
- Handle timeouts and flush mailboxes
- Debug with :sys.get_state and Process.info

**Apps to Build:**

**Labs App:** `labs_mailbox_kv`
- **Scope:** Key-value store using raw processes and receive loops
- **Key Features:**
  - Store/retrieve/delete operations via message passing
  - TTL support with timeout-based cleanup
  - Process monitoring for client failures
  - Mailbox overflow detection
- **Success Criteria:**
  - [ ] Handles 1000 concurrent clients
  - [ ] Mailbox depth stays < 100 messages
  - [ ] Monitors clean up orphaned data

**Pulse Feature:** `pulse_cart` (loop version)
- **Integration:** Shopping cart as a process loop
- **Dependencies:** `pulse_core`
- **Success Criteria:**
  - [ ] Cart survives client disconnects via monitors
  - [ ] Automatic cleanup after 30min timeout

**Time Estimate:**
- Reading: 2-3 days
- Labs Implementation: 2-3 days
- Pulse Integration: 1-2 days
- **Total: 5-8 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-02-gate.js
```

**Performance Targets:**
- [ ] Message passing: p95 < 1ms per send/receive
- [ ] Process spawn: p95 < 0.5ms
- [ ] Mailbox scan: < 10ms for 1000 messages
- [ ] Monitor setup: < 0.1ms overhead

**Failure Drills:**
- [ ] Kill client during operation - verify cleanup via monitor
- [ ] Flood mailbox with 10K messages - verify backpressure
- [ ] Timeout on receive - verify graceful degradation

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can debug mailbox issues using Process.info
- [ ] Understand when to use monitors vs. links

---

### Phase 3 — GenServer + Supervision

**Mastery Definition:** You can design GenServers with proper state management, implement supervision trees, and handle process crashes with restart strategies.

**Learning Objectives:**
- Write GenServer callbacks (init, handle_call, handle_cast, handle_info)
- Design supervision trees with different strategies
- Implement periodic work with Process.send_after
- Handle process state recovery after crashes
- Use Dialyzer specs for GenServer types

**Apps to Build:**

**Labs App:** `labs_counter_ttl`
- **Scope:** Counter with TTL that auto-resets using GenServer
- **Key Features:**
  - Increment/decrement/get operations
  - Auto-reset after configurable TTL
  - Supervision with :one_for_one strategy
  - State export for testing
- **Success Criteria:**
  - [ ] Survives kill -9 (supervisor restarts)
  - [ ] Callback budget < 5ms p95
  - [ ] No blocking I/O in callbacks

**Pulse Feature:** `pulse_cart` (GenServer version)
- **Integration:** Replace process loop with GenServer
- **Dependencies:** `pulse_core`
- **Success Criteria:**
  - [ ] 10K concurrent carts under supervision
  - [ ] Crash recovery without data loss

**Time Estimate:**
- Reading: 3-4 days
- Labs Implementation: 2-3 days
- Pulse Integration: 2-3 days
- **Total: 7-10 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-03-gate.js
```

**Performance Targets:**
- [ ] GenServer call: p95 < 5ms, p99 < 20ms
- [ ] GenServer cast: p95 < 1ms
- [ ] Throughput: 500+ calls/sec per GenServer
- [ ] Mailbox depth: < 100 messages under load
- [ ] Restart time: < 100ms after crash

**Failure Drills:**
- [ ] Kill GenServer with :kill - verify supervisor restart < 100ms
- [ ] Flood with 10K casts - verify mailbox backpressure alerts
- [ ] Inject exception in callback - verify crash recovery

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can design supervision trees for 3+ process types
- [ ] Understand trade-offs between call vs. cast vs. info

---

### Phase 4 — Naming & Fleets

**Mastery Definition:** You can dynamically spawn and manage fleets of processes using Registry and DynamicSupervisor. You understand process naming strategies and worker lifecycle management.

**Learning Objectives:**
- Use Registry for process lookup
- Spawn workers on-demand with DynamicSupervisor
- Implement worker pooling patterns
- Handle high churn (frequent start/stop)
- Monitor worker health and cleanup

**Apps to Build:**

**Labs App:** `labs_session_workers`
- **Scope:** Per-session worker pool with Registry lookup
- **Key Features:**
  - Start worker per session on first access
  - Registry-based process naming
  - TTL-based worker cleanup
  - DynamicSupervisor management
- **Success Criteria:**
  - [ ] 10K workers spawned/stopped in < 10 sec
  - [ ] Registry lookup < 1ms p95
  - [ ] No orphaned workers after cleanup

**Pulse Feature:** `pulse_fleet`
- **Integration:** Per-user cart workers with dynamic spawning
- **Dependencies:** `pulse_core`, `pulse_cart`
- **Success Criteria:**
  - [ ] Support 100K concurrent user carts
  - [ ] Worker churn rate: 1000 start/stop per sec

**Time Estimate:**
- Reading: 2-3 days
- Labs Implementation: 3-4 days
- Pulse Integration: 2-3 days
- **Total: 7-10 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-04-gate.js
```

**Performance Targets:**
- [ ] Registry lookup: p95 < 1ms
- [ ] Worker spawn: p95 < 5ms via DynamicSupervisor
- [ ] Worker churn: 1000+ start/stop per second
- [ ] Registry memory: < 1MB per 10K workers
- [ ] Cleanup sweep: < 500ms for 1000 TTL workers

**Failure Drills:**
- [ ] Kill random worker - verify DynamicSupervisor restarts
- [ ] Spawn 50K workers rapidly - verify memory bounds
- [ ] Registry crash - verify all workers still reachable after restart

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can design worker fleet for multi-tenant app
- [ ] Understand Registry vs. :global vs. via tuples

---

### Phase 5 — Data & Ecto

**Mastery Definition:** You can design database schemas, write changesets with validations, compose queries, and handle transactions with Ecto.Multi.

**Learning Objectives:**
- Design normalized schemas with associations
- Write changesets with validations and constraints
- Compose complex queries with Ecto.Query
- Use Ecto.Multi for atomic transactions
- Implement migrations and rollback strategies
- Handle database connection pooling

**Apps to Build:**

**Labs App:** `labs_orders_db`
- **Scope:** Order management with products, line items, inventory
- **Key Features:**
  - Schema design with has_many/belongs_to
  - Changesets with cross-field validations
  - Inventory decrement in Ecto.Multi transaction
  - Query optimization with preloads and joins
- **Success Criteria:**
  - [ ] All constraints enforced at DB level
  - [ ] Concurrent order placement without race conditions
  - [ ] Query performance < 50ms p95

**Pulse Feature:** `pulse_data`
- **Integration:** Database layer for products, users, orders
- **Dependencies:** `pulse_core`
- **Success Criteria:**
  - [ ] All changesets have comprehensive tests
  - [ ] Migrations reversible with down()
  - [ ] Connection pool sized for load

**Time Estimate:**
- Reading: 4-5 days
- Labs Implementation: 3-4 days
- Pulse Integration: 3-4 days
- **Total: 10-13 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-05-gate.js
```

**Performance Targets:**
- [ ] Simple query: p95 < 10ms
- [ ] Complex query (3+ joins): p95 < 50ms
- [ ] Insert: p95 < 20ms
- [ ] Transaction (Multi): p95 < 30ms
- [ ] Throughput: 500+ writes/sec sustained
- [ ] Connection pool: checkout < 1ms p95

**Failure Drills:**
- [ ] Database restart - verify connection pool recovery < 5 sec
- [ ] Concurrent updates - verify optimistic locking prevents lost updates
- [ ] Constraint violation - verify changeset errors returned

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can design schema for multi-tenant SaaS
- [ ] Understand when to use Multi vs. nested changesets

---

### Phase 6 — Phoenix Web

**Mastery Definition:** You can build real-time web applications with Phoenix, including LiveView for reactive UIs, Channels for WebSocket communication, and Presence for tracking user state.

**Learning Objectives:**
- Build Phoenix controllers and JSON APIs
- Create reactive UIs with LiveView
- Implement real-time features with Channels
- Track user presence across nodes
- Handle authentication and authorization
- Optimize LiveView performance

**Apps to Build:**

**Labs App:** `labs_orders_web`
- **Scope:** Phoenix web interface for order management
- **Key Features:**
  - LiveView product catalog with filtering
  - Real-time cart updates via LiveView
  - Admin dashboard with Channel subscriptions
  - Presence tracking for active users
- **Success Criteria:**
  - [ ] 1000 concurrent LiveView connections
  - [ ] LiveView patch < 50ms p95
  - [ ] WebSocket latency < 100ms p95

**Pulse Feature:** `pulse_web`
- **Integration:** Full web interface for PulseShop
- **Dependencies:** `pulse_data`, `pulse_fleet`
- **Success Criteria:**
  - [ ] All CRUD operations via LiveView
  - [ ] Real-time inventory updates
  - [ ] User presence in admin dashboard

**Time Estimate:**
- Reading: 4-5 days
- Labs Implementation: 4-5 days
- Pulse Integration: 3-4 days
- **Total: 11-14 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-06-gate.js
```

**Performance Targets:**
- [ ] HTTP request: p95 < 50ms
- [ ] JSON API: p95 < 100ms
- [ ] LiveView mount: p95 < 150ms
- [ ] LiveView patch: p95 < 50ms
- [ ] WebSocket messages: p95 < 100ms
- [ ] Concurrent connections: 1000+ LiveView, 5000+ WebSocket
- [ ] Memory per LiveView: < 50KB

**Failure Drills:**
- [ ] Kill Phoenix node - verify Channel reconnect < 5 sec
- [ ] Spike to 5000 connections - verify graceful degradation
- [ ] Slow database query - verify LiveView timeout handling

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can debug LiveView state issues
- [ ] Understand LiveView vs. Channel trade-offs

---

### Phase 7 — Jobs & Ingestion

**Mastery Definition:** You can design fault-tolerant data pipelines with Broadway for ingestion and Oban for background jobs. You understand backpressure, idempotency, and retry strategies.

**Learning Objectives:**
- Build Broadway pipelines with stages
- Implement backpressure with GenStage
- Design idempotent job handlers
- Configure retry strategies and dead letter queues
- Monitor pipeline throughput and lag
- Handle poison messages

**Apps to Build:**

**Labs App:** `labs_ingest`
- **Scope:** Broadway pipeline for event ingestion
- **Key Features:**
  - Kafka/SQS consumer with Broadway
  - Rate limiting with GenStage demand
  - Duplicate detection (idempotency)
  - Dead letter queue for poison messages
- **Success Criteria:**
  - [ ] Throughput: 10K events/sec
  - [ ] Backpressure prevents OOM
  - [ ] Zero duplicate processing

**Labs App:** `labs_jobs`
- **Scope:** Oban background job processing
- **Key Features:**
  - Job scheduling with cron
  - Retry with exponential backoff
  - Job uniqueness constraints
  - Monitoring with Telemetry
- **Success Criteria:**
  - [ ] Job latency: p95 < 5 sec
  - [ ] Retry succeeds after transient failures
  - [ ] Poison jobs quarantined after max attempts

**Pulse Feature:** `pulse_ingest` + `pulse_jobs`
- **Integration:** Event ingestion and async order processing
- **Dependencies:** `pulse_data`
- **Success Criteria:**
  - [ ] Order confirmation emails sent via Oban
  - [ ] Inventory sync via Broadway pipeline

**Time Estimate:**
- Reading: 3-4 days
- Labs Implementation: 4-5 days
- Pulse Integration: 2-3 days
- **Total: 9-12 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-07-gate.js
```

**Performance Targets:**
- [ ] Broadway throughput: 10K events/sec sustained
- [ ] Broadway latency: p95 < 100ms per event
- [ ] Oban job latency: p95 < 5 sec from enqueue to start
- [ ] Oban throughput: 1000+ jobs/sec
- [ ] Memory usage: < 500MB for 100K queued jobs
- [ ] Backpressure activated: 0 OOM under max load

**Failure Drills:**
- [ ] Kill worker node - verify job redistribution < 10 sec
- [ ] Inject poison message - verify DLQ quarantine
- [ ] Database down - verify retry with backoff

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can design pipeline for 100K events/sec
- [ ] Understand idempotency vs. uniqueness

---

### Phase 8 — Caching & ETS

**Mastery Definition:** You can design high-performance caching layers using ETS with proper cache invalidation, concurrency control, and benchmarking.

**Learning Objectives:**
- Create ETS tables with different types (set, bag, ordered_set)
- Implement cache-aside and write-through patterns
- Handle cache stampede and thundering herd
- Use :ets.select for efficient queries
- Benchmark cache hit rates and latency
- Coordinate cache invalidation across nodes

**Apps to Build:**

**Labs App:** `labs_cache`
- **Scope:** Multi-layer cache with ETS and process dictionary
- **Key Features:**
  - Cache-aside pattern with TTL
  - Stampede protection with locks
  - Hit rate and latency metrics
  - Benchee performance tests
- **Success Criteria:**
  - [ ] Read latency: p95 < 1ms
  - [ ] Hit rate: > 90% in benchmarks
  - [ ] Zero stampede under load

**Pulse Feature:** `pulse_cache`
- **Integration:** Product catalog and session cache
- **Dependencies:** `pulse_data`
- **Success Criteria:**
  - [ ] Database load reduced by 80%
  - [ ] Cache invalidation < 100ms across nodes

**Time Estimate:**
- Reading: 2-3 days
- Labs Implementation: 3-4 days
- Pulse Integration: 2-3 days
- **Total: 7-10 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-08-gate.js
```

**Performance Targets:**
- [ ] ETS read: p95 < 0.5ms, p99 < 1ms
- [ ] ETS write: p95 < 1ms
- [ ] Throughput: 100K+ reads/sec per table
- [ ] Hit rate: > 90% under steady load
- [ ] Memory: < 100MB for 1M cached entries
- [ ] Stampede protection: 0 duplicate loads during cache miss

**Failure Drills:**
- [ ] Flush entire cache - verify reload without stampede
- [ ] Concurrent updates - verify no lost writes
- [ ] Node restart - verify cache rebuild < 10 sec

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can design cache strategy for multi-tier app
- [ ] Understand ETS vs. Redis trade-offs

---

### Phase 9 — Distribution

**Mastery Definition:** You can build distributed systems with libcluster, implement consistent hashing for sharding, and handle network partitions gracefully.

**Learning Objectives:**
- Configure clustering with libcluster
- Implement global process registry
- Design sharding strategies with consistent hashing
- Handle network partitions (split brain)
- Coordinate state across nodes with CRDTs
- Monitor cluster health and topology

**Apps to Build:**

**Labs App:** `labs_cluster`
- **Scope:** Distributed key-value store with sharding
- **Key Features:**
  - libcluster auto-discovery
  - Consistent hashing for key distribution
  - Partition tolerance with vector clocks
  - Health monitoring with :net_kernel
- **Success Criteria:**
  - [ ] 10-node cluster forms in < 10 sec
  - [ ] Partition recovery without data loss
  - [ ] Request routing: p95 < 10ms

**Pulse Feature:** `pulse_cluster`
- **Integration:** Distributed cart fleet across nodes
- **Dependencies:** `pulse_fleet`
- **Success Criteria:**
  - [ ] 100K carts distributed across 5 nodes
  - [ ] Node failure: < 1% error rate during failover

**Time Estimate:**
- Reading: 4-5 days
- Labs Implementation: 5-6 days
- Pulse Integration: 3-4 days
- **Total: 12-15 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-09-gate.js
```

**Performance Targets:**
- [ ] Cluster formation: < 10 sec for 10 nodes
- [ ] RPC call: p95 < 20ms cross-node
- [ ] Shard lookup: p95 < 5ms via consistent hashing
- [ ] Failover: < 5 sec to detect node down and reroute
- [ ] Throughput: 10K+ cross-node messages/sec
- [ ] Error rate during node kill: < 1%

**Failure Drills:**
- [ ] Kill node during load - verify error rate < 1%, recovery < 5 sec
- [ ] Network partition - verify partition tolerance, recovery on heal
- [ ] Rolling restart - verify zero downtime

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can design sharding strategy for 100-node cluster
- [ ] Understand CAP theorem trade-offs in practice

---

### Phase 10 — Observability & SLOs

**Mastery Definition:** You can instrument applications with Telemetry, export metrics to Prometheus, build Grafana dashboards, and define SLOs with error budgets.

**Learning Objectives:**
- Attach Telemetry handlers for metrics
- Export to OpenTelemetry/Prometheus
- Build Grafana dashboards for golden signals
- Define SLOs (latency, availability, error rate)
- Calculate error budgets
- Set up alerting rules

**Apps to Build:**

**Labs App:** `labs_telemetry`
- **Scope:** Telemetry instrumentation and metrics export
- **Key Features:**
  - Custom Telemetry events
  - Prometheus exporter
  - Grafana dashboard templates
  - SLO definitions with alerts
- **Success Criteria:**
  - [ ] All services instrumented
  - [ ] Dashboard shows golden signals
  - [ ] Alerts fire when SLO breached

**Pulse Feature:** `pulse_obs`
- **Integration:** Full observability for PulseShop
- **Dependencies:** All pulse apps
- **Success Criteria:**
  - [ ] SLOs defined for all critical paths
  - [ ] Error budget tracking
  - [ ] Runbook links in alerts

**Time Estimate:**
- Reading: 3-4 days
- Labs Implementation: 3-4 days
- Pulse Integration: 2-3 days
- **Total: 8-11 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-10-gate.js
```

**Performance Targets:**
- [ ] Metrics export: < 5ms overhead per operation
- [ ] Dashboard refresh: < 2 sec for 1000 metrics
- [ ] Alert evaluation: < 10 sec latency
- [ ] SLO tracking: 99.9% availability, p95 < 150ms, < 0.1% error rate
- [ ] Telemetry memory: < 50MB overhead

**Failure Drills:**
- [ ] Inject latency - verify SLO breach alert fires < 1 min
- [ ] Prometheus down - verify buffering prevents data loss
- [ ] Dashboard query timeout - verify graceful degradation

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can define SLOs for multi-tier service
- [ ] Understand error budget calculations

---

### Phase 11 — Testing Strategy

**Mastery Definition:** You can design comprehensive test strategies including unit, integration, property-based, and contract tests. You understand test coverage trade-offs and can measure test effectiveness.

**Learning Objectives:**
- Write property-based tests with StreamData
- Use Mox for behavior mocking
- Implement SQL Sandbox for concurrent tests
- Design contract tests for APIs
- Measure and optimize test coverage
- Build test helpers and factories

**Apps to Build:**

**Labs App:** All apps (test suite enhancement)
- **Scope:** Comprehensive test coverage across all labs
- **Key Features:**
  - Property tests for all pure functions
  - Integration tests with SQL Sandbox
  - Contract tests for HTTP APIs
  - Test coverage > 90%
- **Success Criteria:**
  - [ ] All apps have > 90% coverage
  - [ ] Test suite runs in < 30 sec
  - [ ] Zero flaky tests

**Pulse Feature:** All pulse apps (test suite)
- **Integration:** Full test coverage for PulseShop
- **Dependencies:** All pulse apps
- **Success Criteria:**
  - [ ] Critical paths have property tests
  - [ ] Factories for all schemas
  - [ ] CI test time < 5 min

**Time Estimate:**
- Reading: 3-4 days
- Labs Implementation: 5-6 days
- Pulse Integration: 4-5 days
- **Total: 12-15 days**

**Mastery Gate:**
```bash
mix test && mix coveralls
```

**Performance Targets:**
- [ ] Test suite runtime: < 30 sec for labs, < 5 min for pulse
- [ ] Test coverage: > 90% for critical paths
- [ ] Property test shrinking: < 10 sec to find minimal case
- [ ] Parallel execution: 4x speedup on 4-core machine
- [ ] Flake rate: 0% over 100 runs

**Failure Drills:**
- [ ] Inject bug - verify tests fail within 1 iteration
- [ ] Database rollback failure - verify SQL Sandbox recovery
- [ ] Async process leak - verify cleanup in teardown

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can write property tests for complex domains
- [ ] Understand test pyramid trade-offs

---

### Phase 12 — Delivery & Ops

**Mastery Definition:** You can build releases with mix release, implement health checks, design blue-green deployments, and handle graceful shutdown.

**Learning Objectives:**
- Build releases with mix release
- Implement health and readiness endpoints
- Design zero-downtime deployment strategies
- Handle graceful shutdown and connection draining
- Configure hot upgrades with relup
- Manage secrets and environment config

**Apps to Build:**

**Labs App:** `labs_release_runner`
- **Scope:** Release orchestration and health monitoring
- **Key Features:**
  - Health check endpoints (liveness, readiness)
  - Graceful shutdown with connection draining
  - Blue-green deployment script
  - Secret management with runtime config
- **Success Criteria:**
  - [ ] Health checks return in < 100ms
  - [ ] Graceful shutdown completes in < 30 sec
  - [ ] Zero dropped connections during deploy

**Pulse Feature:** Releases for all pulse apps
- **Integration:** Full deployment pipeline for PulseShop
- **Dependencies:** All pulse apps
- **Success Criteria:**
  - [ ] Automated release to staging/prod
  - [ ] Rollback completes in < 2 min
  - [ ] Deploy checklist automated

**Time Estimate:**
- Reading: 3-4 days
- Labs Implementation: 4-5 days
- Pulse Integration: 3-4 days
- **Total: 10-13 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-12-gate.js
# Run during rolling deployment
```

**Performance Targets:**
- [ ] Health check: p95 < 100ms
- [ ] Readiness check: p95 < 200ms (includes DB ping)
- [ ] Graceful shutdown: < 30 sec to drain all connections
- [ ] Release build: < 5 min
- [ ] Deploy time: < 10 min for rolling update
- [ ] Downtime during deploy: 0 sec (blue-green)

**Failure Drills:**
- [ ] Kill during startup - verify health checks prevent traffic
- [ ] Deploy bad release - verify rollback < 2 min
- [ ] Drain timeout - verify forced shutdown after 30 sec

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can execute zero-downtime deploy
- [ ] Understand hot upgrade trade-offs

---

### Phase 13 — Capstone Integration

**Mastery Definition:** You can integrate all system components, execute GameDay drills, and demonstrate end-to-end system resilience under failure scenarios.

**Learning Objectives:**
- Integrate all components into cohesive system
- Design GameDay failure scenarios
- Execute chaos engineering drills
- Measure system-wide SLOs during incidents
- Document incident response playbooks
- Calculate blast radius for failures

**Apps to Build:**

**Integration:** Full PulseShop stack
- **Scope:** All pulse apps running as integrated system
- **Key Features:**
  - End-to-end request tracing
  - Circuit breakers between services
  - Chaos engineering automation
  - Incident response runbooks
- **Success Criteria:**
  - [ ] Complete customer journey under load
  - [ ] Survive node kills, DB failures, network partitions
  - [ ] Recover within SLO budgets

**Time Estimate:**
- Reading: 2-3 days
- Integration: 5-6 days
- GameDay drills: 3-4 days
- **Total: 10-13 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-13-gate.js
# Simultaneously run chaos drills
bash tools/gameday/kill-node.sh
bash tools/gameday/partition-network.sh
bash tools/gameday/spike-traffic.sh
```

**Performance Targets:**
- [ ] End-to-end latency: p95 < 200ms, p99 < 500ms
- [ ] Availability: 99.9% during normal operation
- [ ] Error rate: < 0.1% during steady state
- [ ] Throughput: 1000 RPS sustained for 1 hour
- [ ] Recovery time: < 5 min for node failure
- [ ] Error budget: 43 min downtime/month remaining

**Failure Drills:**
- [ ] Kill node during peak traffic - error rate < 1%, recovery < 5 min
- [ ] Database primary failure - failover < 10 sec, 0 data loss
- [ ] Network partition - partition tolerance, recovery on heal < 30 sec
- [ ] Spike to 10x traffic - graceful degradation, no cascading failures
- [ ] Rollback bad deploy - complete in < 2 min, < 10 failed requests

**Can Advance When:**
- [ ] All performance targets met under chaos
- [ ] All GameDay drills pass
- [ ] Incident runbooks validated
- [ ] Error budgets tracked and managed

---

### Phase 14 — CTO Track

**Mastery Definition:** You can design production operations, create security policies, implement compliance controls, and build incident response procedures.

**Learning Objectives:**
- Design threat models and security controls
- Implement AuthN/AuthZ with least privilege
- Create audit logging and compliance reports
- Generate SBOM and scan dependencies
- Design disaster recovery procedures
- Build incident response playbooks

**Apps to Build:**

**Labs App:** `labs_incident_cli`
- **Scope:** Incident response automation
- **Key Features:**
  - Runbook execution engine
  - Incident timeline tracking
  - Postmortem template generation
  - Chaos drill orchestration
- **Success Criteria:**
  - [ ] Runbooks execute in < 2 min
  - [ ] All incidents logged with timeline
  - [ ] Postmortems auto-generated

**Pulse Feature:** Ops docs and security controls
- **Integration:** Security hardening for PulseShop
- **Dependencies:** All pulse apps
- **Success Criteria:**
  - [ ] Threat model documented
  - [ ] SBOM generated and scanned
  - [ ] Audit log for all mutations
  - [ ] DR tested quarterly

**Time Estimate:**
- Reading: 4-5 days
- Labs Implementation: 4-5 days
- Pulse Integration: 4-5 days
- **Total: 12-15 days**

**Mastery Gate:**
```bash
# Execute security and compliance checks
bash tools/security/threat-model-review.sh
bash tools/security/generate-sbom.sh
bash tools/security/audit-scan.sh
bash tools/gameday/disaster-recovery.sh
```

**Performance Targets:**
- [ ] Audit log write: < 5ms overhead per mutation
- [ ] SBOM generation: < 2 min for full scan
- [ ] Vulnerability scan: < 5 min for all dependencies
- [ ] DR backup: < 1 hour for full system
- [ ] DR recovery: < 4 hours to production-ready
- [ ] Secrets rotation: < 10 min, zero service disruption

**Compliance Checks:**
- [ ] All mutations logged with user ID and timestamp
- [ ] Secrets rotated within 90 days
- [ ] Zero high/critical vulnerabilities in dependencies
- [ ] SBOM includes all transitive dependencies
- [ ] Backup tested monthly, restores validated

**Can Advance When:**
- [ ] All compliance checks pass
- [ ] DR drill succeeds
- [ ] Security controls documented and tested
- [ ] Incident playbooks validated in drill

---

### Phase 15 — AI/ML Integration

**Mastery Definition:** You can integrate AI/ML models into Elixir applications using Nx, Axon, and Bumblebee. You understand model serving patterns, inference latency optimization, and telemetry for ML systems.

**Learning Objectives:**
- Use Nx for tensor operations
- Load and serve models with Bumblebee
- Optimize inference latency and throughput
- Implement model versioning and A/B testing
- Monitor model performance and drift
- Design feedback loops for model improvement

**Apps to Build:**

**Labs App:** `labs_ai_classifier`
- **Scope:** Text classification service with ML model
- **Key Features:**
  - Model loading with Bumblebee
  - Batch inference for throughput
  - Model versioning and rollback
  - Inference telemetry and tracing
- **Success Criteria:**
  - [ ] Inference latency: p95 < 200ms
  - [ ] Throughput: 100+ inferences/sec
  - [ ] Model swap without downtime

**Pulse Feature:** `pulse_ai_recommender`
- **Integration:** Product recommendation engine
- **Dependencies:** `pulse_data`, `pulse_web`
- **Success Criteria:**
  - [ ] Real-time recommendations in LiveView
  - [ ] A/B testing framework for models
  - [ ] Feedback loop for retraining

**Time Estimate:**
- Reading: 4-5 days
- Labs Implementation: 5-6 days
- Pulse Integration: 4-5 days
- **Total: 13-16 days**

**Mastery Gate:**
```bash
k6 run tools/k6/phase-15-gate.js
```

**Performance Targets:**
- [ ] Inference latency: p95 < 200ms, p99 < 500ms
- [ ] Batch inference: 100+ items/sec throughput
- [ ] Model load time: < 10 sec on startup
- [ ] Memory per model: < 500MB
- [ ] CPU utilization: < 70% during peak inference
- [ ] Model swap: < 1 sec, zero dropped requests

**Failure Drills:**
- [ ] Model load failure - verify fallback to previous version
- [ ] Inference timeout - verify graceful degradation
- [ ] Memory spike - verify backpressure on batch queue

**Can Advance When:**
- [ ] All performance targets met
- [ ] Can serve multiple models concurrently
- [ ] Understand batch vs. streaming inference trade-offs

> **Note:** Other phases (1-15) will follow a similar detailed format. Template structure established with Phase 0.

---

## App Structure

### Labs Apps (`labs_*`)
Isolated mini-apps demonstrating a single concept per phase.

### Pulse Apps (`pulse_*`)
Evolving product built incrementally across phases:
- `pulse_core` - Pure domain logic
- `pulse_cart` - GenServer cart with TTL
- `pulse_fleet` - Per-user cart workers
- `pulse_data` - Database layer
- `pulse_web` - Phoenix/LiveView interface
- `pulse_ingest` - Broadway pipelines
- `pulse_jobs` - Oban workers
- `pulse_cache` - ETS cache services
- `pulse_cluster` - Clustering & sharding
- `pulse_obs` - Observability & telemetry
