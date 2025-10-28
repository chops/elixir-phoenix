# Apps Directory

This directory contains all umbrella applications for the Elixir Systems Mastery project.

## Structure

### Labs Apps (`labs_*`)
Isolated mini-apps demonstrating a single concept per phase:

- `labs_gatekeeper` (M0) - Tooling, CI/CD setup
- `labs_csv_stats` (M1) - Pure functions, Stream processing
- `labs_mailbox_kv` (M2) - Processes and mailboxes
- `labs_counter_ttl` (M3) - GenServer + supervision
- `labs_session_workers` (M4) - Registry + DynamicSupervisor
- `labs_orders_db` (M5) - Ecto schemas, Multi, constraints
- `labs_orders_web` (M6) - Phoenix, LiveView, Channels
- `labs_ingest` (M7) - Broadway ingestion
- `labs_jobs` (M7) - Oban jobs/backoff
- `labs_cache` (M8) - ETS read-through cache
- `labs_cluster` (M9) - libcluster + sharding
- `labs_telemetry` (M10) - OpenTelemetry + Prometheus
- `labs_authz_audit` (M11) - Authorization + audit logging
- `labs_release_runner` (M12) - Mix releases + health checks
- `labs_incident_cli` (M14) - Incident drills CLI

### Pulse Apps (`pulse_*`)
Evolving production application built incrementally:

- `pulse_core` - Pure domain logic
- `pulse_cart` - GenServer cart with TTL
- `pulse_fleet` - Per-user cart workers (Registry/DynSup)
- `pulse_data` - Ecto repo/schemas/migrations
- `pulse_web` - Phoenix/LiveView/Channels
- `pulse_ingest` - Broadway pipelines
- `pulse_jobs` - Oban workers
- `pulse_cache` - ETS cache services
- `pulse_cluster` - Clustering + sharding
- `pulse_obs` - Telemetry wiring and exporters

## Creating New Apps

Apps are created as you progress through each phase. Each app should:

1. Have its own `README.md` linking back to the relevant phase
2. Follow the project's quality standards (format, credo, dialyzer)
3. Include comprehensive tests
4. Document key design decisions in ADRs when appropriate

## Running Apps

```bash
# Run a specific app
cd apps/labs_csv_stats
mix test
mix run

# Run from root (all apps)
mix test
```

## Dependencies

Each app manages its own dependencies in its `mix.exs`. Common dependencies for the umbrella are in the root `mix.exs`.
