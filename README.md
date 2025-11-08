# Elixir Systems Mastery

A comprehensive Elixir/OTP learning project structured as an umbrella application, covering production-grade systems design from fundamentals to deployment.

## 🎯 Project Structure

This repository contains two parallel learning tracks:

### 1. **Labs Apps** (`labs_*`)
Isolated, focused mini-apps demonstrating a single concept per phase:

- **M0**: `labs_gatekeeper` - Tooling, CI/CD setup
- **M1**: `labs_csv_stats` - Pure functions, Stream processing
- **M2**: `labs_mailbox_kv` - Processes and mailboxes
- **M3**: `labs_counter_ttl` - GenServer + supervision
- **M4**: `labs_session_workers` - Registry + DynamicSupervisor
- **M5**: `labs_orders_db` - Ecto schemas, Multi, constraints
- **M6**: `labs_orders_web` - Phoenix, LiveView, Channels
- **M7**: `labs_ingest` - Broadway ingestion / `labs_jobs` - Oban
- **M8**: `labs_cache` - ETS read-through cache
- **M9**: `labs_cluster` - libcluster + sharding
- **M10**: `labs_telemetry` - OpenTelemetry + Prometheus
- **M11**: `labs_authz_audit` - Authorization + audit logging
- **M12**: `labs_release_runner` - Mix releases + health checks
- **M14**: `labs_incident_cli` - Incident drills CLI

### 2. **Pulse Apps** (`pulse_*`)
An evolving production application built incrementally:

- `pulse_core` - Pure domain logic
- `pulse_cart` - GenServer-based shopping cart
- `pulse_fleet` - Per-user cart workers
- `pulse_data` - Database layer (Ecto)
- `pulse_web` - Web interface (Phoenix/LiveView)
- `pulse_ingest` - Data ingestion (Broadway)
- `pulse_jobs` - Background jobs (Oban)
- `pulse_cache` - Caching layer (ETS)
- `pulse_cluster` - Clustering & sharding
- `pulse_obs` - Observability & telemetry

## 🚀 Quick Start

```bash
# Install dependencies
make setup

# Run tests
make test

# Start database
make db-up

# Format code
make fmt
```

## 📓 Getting Started with Livebook

Interactive learning notebooks are available in `livebooks/`.

```bash
# Install dependencies (includes Kino for Livebook)
mix deps.get

# Start Livebook server
make livebook

# Open your browser to http://localhost:8080
# Navigate to setup.livemd to begin
```

**What's in Livebook?**

- **Interactive exercises** - Run code directly in your browser
- **7 Phase 1 checkpoints** - Pattern matching, recursion, Enum/Stream, error handling, property testing, and more
- **Progress tracking** - Monitor your completion across all 15 phases
- **Visualizations** - See benchmarks and performance comparisons
- **Self-assessments** - Check your understanding at each step

See `livebooks/README.md` for more details.

## 📚 Documentation

- **[Roadmap](docs/roadmap.md)** - Learning phases and milestones
- **[Reading Notes](docs/reading/)** - Per-phase study notes
- **[ADRs](docs/adr/)** - Architecture decision records
- **[Checklists](docs/checklists/)** - Design & review checklists
- **[Runbook](docs/runbook/)** - Operations procedures
- **[SLOs](docs/slo/)** - Service level objectives
- **[Demos](docs/demos/)** - Example scripts and outputs

## 🛠️ Tools & Operations

```bash
# Load testing
make load        # k6 load tests
make smoke       # k6 smoke tests

# Benchmarking
make bench       # Run Elixir benchmarks

# Cluster operations
make cluster-up  # Start local cluster
make cluster-down
```

## 📊 Observability

- **Grafana dashboards**: `observability/grafana/`
- **OpenTelemetry collector**: `observability/otel-collector.yaml`

## 🏗️ Development

Each app in `apps/` can be developed independently:

```bash
cd apps/labs_csv_stats
mix test
mix run
```

## 📖 Learning Path

1. Review `docs/roadmap.md` for the overall learning progression
2. Read phase-specific notes in `docs/reading/`
3. Implement labs apps to practice isolated concepts
4. Build corresponding features in pulse apps
5. Use checklists for design reviews
6. Write ADRs for architectural decisions

## 🧪 Testing

```bash
# All tests
mix test

# Specific app
cd apps/pulse_web && mix test

# With coverage
mix test --cover
```

## 📦 Release

```bash
# Build release
MIX_ENV=prod mix release

# Run release
_build/prod/rel/elixir_systems_mastery/bin/elixir_systems_mastery start
```
