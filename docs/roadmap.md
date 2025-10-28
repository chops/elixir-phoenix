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
