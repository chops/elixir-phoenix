# Elixir Systems Mastery — Critical Review

## High-risk blockers
- **Umbrella skeleton without apps**: `apps/` only holds `README.md`, yet the roadmap, Mix config, and tooling all assume concrete `labs_*` / `pulse_*` applications. Until at least `labs_gatekeeper` and one Pulse app exist, every learning milestone is theoretical and none of the CI/delivery automation can be exercised.
- **Mix aliases reference missing Ecto stack**: `mix.exs:33-37` calls `mix ecto.*` and seeds `apps/pulse_data/priv/repo/seeds.exs`, but there is no configured Repo module, no `:ecto_sql` / `:phoenix_ecto` dependency, and no seeds file. Running `mix setup` or `mix test` currently fails immediately.
- **Formatter imports undeclared deps**: `.formatter.exs:2` imports `:ecto`, `:ecto_sql`, and `:phoenix`, none of which are present in `mix.exs:17-27`. `mix format` will crash until the dependencies (and umbrella apps that use them) are added.
- **Release runbook references non-existent code**: `docs/runbook/deployment.md:20-52` expects an `ElixirSystemsMastery.Release` module with `migrate/0` & `rollback/0`, but the module is absent. Anyone following the runbook will hit a runtime error during the very first deployment attempt.

## Operational & tooling gaps
- **CI gates are aspirational**: `.github/workflows/ci.yml:63-97` marks Credo and Dialyzer `continue-on-error: true`, so lint/type failures do not block merges—the opposite of the “gates fail hard” goal. Tighten the workflow once real code exists.
- **Compose files depend on missing artifacts**: `ops/docker-compose.app.yml:5-7` references `ops/Dockerfile`, but the repository does not ship one. Prometheus config in `observability/prometheus.yml:11-25` also scrapes `otel-collector`, `postgres-exporter`, and `alertmanager`, yet those services are absent from every compose file. The OTEL collector config (`observability/otel-collector.yaml:29-47`) exports to `jaeger:4317`, but no Jaeger container is defined anywhere.
- **Make targets break immediately**: `Makefile:6-21` runs `mix ecto.setup` / `mix format --check-formatted`. With the Ecto tooling missing, `make setup` and `make check` fail, so there is no working “baseline green” loop.
- **Load test thresholds overridden**: `tools/k6/load.js:17-20` declares `http_req_duration` twice; only the `p(99)` threshold survives, so the intended `p(95)` guard never runs. Use distinct keys (e.g. `http_req_duration{p95}`) or consolidate thresholds.

## Documentation mismatches
- **Demo catalog is fictional**: `docs/demos/README.md:7-13` lists six demo scripts that do not exist. Either add the scripts or trim the README to avoid setting false expectations.
- **Roadmap & reading notes drift**: `docs/roadmap.md` promises apps like `labs_ingest`, `pulse_jobs`, and even `labs_ai_classifier`, yet there are zero ADRs, migrations, or modules backing them. The duplicate “Phase 01” reading files (`phase-00-tooling.md` vs `phase-01-tooling.md`) also confuse the chronology.
- **CODEOWNERS placeholder**: `CODEOWNERS:13-33` still uses `@YOUR_GITHUB_USERNAME`. If this is meant to enforce accountability, assign real handles before opening the repo to collaborators.

## Suggested next moves
1. Deliver `labs_gatekeeper` for real: scaffold one umbrella app (`mix new labs_gatekeeper --app labs_gatekeeper`) that only ensures `mix format`, `credo`, `dialyzer`, `sobelow`, and `mix_audit` all pass locally and in CI (with `continue-on-error` removed). This proves the “quality gates first” philosophy.
2. Wire Ecto from the ground up: add `:ecto_sql`, `:postgrex`, and a minimal Repo (e.g. `PulseData.Repo`) with `config/{dev,test}.exs` so that `mix ecto.*` aliases and the Makefile succeed.
3. Reconcile ops tooling: add the missing `ops/Dockerfile`, OTEL collector, Jaeger, and exporters referenced by configs—or simplify the configs until you have services to back them.
4. Keep docs honest: prune or stub anything not yet implemented (demo scripts, roadmap items) and capture the actual next milestone in `docs/roadmap.md` so future diffs show concrete progress.
