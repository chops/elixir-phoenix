# Phase 12 — Delivery & Ops (Releases, Health, Graceful Shutdown)

Production deployments with mix releases, health checks, and operational excellence.

## Books
- **Adopting Elixir** — deployments, runtime config

## Docs
- **mix release**
  https://hexdocs.pm/mix/Mix.Tasks.Release.html

- **Phoenix “Deploying with Releases”**
  https://hexdocs.pm/phoenix/releases.html

## Supplements
- **Graceful shutdowns**
  https://fly.io/phoenix-files/graceful-shutdowns/---

================================================================================

Adopting Elixir — Delivery & Ops (Deployment Chapters) Summary

Outline
	•	Mix release basics and commands
	•	Runtime vs compile-time configuration
	•	Health and readiness checks
	•	Graceful shutdown and stop timeouts
	•	Rolling vs blue-green deployments
	•	systemd integration and artifacts
	•	run_erl and heart auto-restart
	•	Hot upgrades: appup/relup flow
	•	Feature flags for safe changes.        

Chapter/Section Summaries

Coordinating Deployments

Key Concepts
	•	mix release builds self-contained artifacts.
	•	run_erl and heart keep a node running across crashes.
	•	Prefer rolling restarts. Use hot upgrades only when strict uptime requires.
	•	Configure at runtime to avoid compile-time env bleed.  

Essential Code Snippets

MIX_ENV=prod mix release
_build/prod/rel/app/bin/app start
_build/prod/rel/app/bin/app rpc "App.Health.ok?"

Health check is callable via RPC as shown.  

Tips & Pitfalls
	•	Runtime config via env; do not leak compile-time env.
	•	Prefer rolling restarts; reserve hot upgrades for strict SLOs.  

Exercises Application
	•	Produce a release, set runtime env, add a health check, and an RPC one-off task.
	•	Try heart auto-restart in a sandbox.  

Diagrams

Deployment:
mix release → start → rpc/eval → stop



⸻

Hot Upgrades: appup/relup Flow

Key Concepts
	•	Build new app version + .appup, then build release + relup.
	•	Install with release_handler functions on a running node.  

Tips & Pitfalls
	•	Prefer rolling restarts if relups add undue complexity. Use hot upgrades only when uptime requires.  

Exercises Application
	•	Create a small app, write a trivial .appup, generate a relup, and install it live.  

Diagrams

old release + appup -> systools:make_relup -> relup -> release_handler



⸻

Delivery & Ops Milestone (M12)

Key Concepts
	•	Goals: mix release, /health and /ready, graceful shutdown, rollout strategy.
	•	Work: release config, runtime env, systemd unit, blue-green or rolling via compose, migration gate, stop timeouts.
	•	Acceptance: start/stop/restart via systemd/compose, zero-downtime rollout demo, rollback < 2 min.
	•	Artifacts: /ops/systemd/*.service, /ops/docker-compose.app.yml, /docs/runbook/deploy.md.  

Drills
	•	Ship a release. Add /health and /ready. Kill a node mid-load and keep SLO. Roll back safely.
	•	Watch for: compile-time env leakage, missing stop timeout, missing migrations gate.  

Diagrams

Clustered rollout (concept):
blue-green or rolling  →  readiness gate  →  zero-downtime switch



⸻

Production Readiness Hooks

Key Concepts
	•	Structured logging with metadata.
	•	Crash reports and tracing basics.
	•	Pre-written incident checklists (restart, rollback, feature flag).  

Essential Code Snippets

# structured logging
require Logger
Logger.metadata(service: :orders)
Logger.error("failed", order_id: id, reason: inspect(reason))



Exercises Application
	•	Ship structured logs, wire a crash reporter, create an incident runbook for a failing GenServer.  

⸻

Cross-Chapter Checklist
	•	Release with runtime config; prefer rolling restarts; document playbooks.
	•	Instrument before tuning; load test; benchmark with Benchee.
	•	Assume partial failure; add retries with backoff and idempotency.  

Quick Reference Crib

# Build + run + check
MIX_ENV=prod mix release
_build/prod/rel/app/bin/app start
_build/prod/rel/app/bin/app rpc "App.Health.ok?"

# Lifecycle
mix release → start → rpc/eval → stop

  

Notes tied to Phase 12 drills
	•	Implement /health and /ready, systemd unit, graceful stop timeouts, and safe rollout/rollback.  


---

## Drills


Phase 12 Drills

Core Skills to Practice
	•	Produce a mix release with runtime config.  
	•	Add /health and /ready HTTP endpoints.  
	•	Kill a node under load and keep SLO.  
	•	Roll back safely after a bad deploy.  

Exercises
	1.	Release with runtime config
	•	Build and boot:

MIX_ENV=prod mix release
_build/prod/rel/app/bin/app start
_build/prod/rel/app/bin/app rpc "App.Health.ok?"

	•	Expected: release boots; RPC health check returns truthy.  

	•	Add config/runtime.exs:

import Config
config :app, App.Repo, url: System.fetch_env!("DATABASE_URL")
config :app, AppWeb.Endpoint, server: true, http: [port: String.to_integer(System.get_env("PORT") || "4000")]

	•	Expected: values read at runtime, no compile-time env bleed.  

	2.	/health and /ready endpoints
	•	Router:

scope "/", AppWeb do
  pipe_through :api
  get "/health", HealthController, :show
  get "/ready",  HealthController, :ready
end


	•	Controller:

defmodule AppWeb.HealthController do
  use AppWeb, :controller
  def show(conn, _),  do: json(conn, %{ok: true})
  def ready(conn, _) do
    case Ecto.Adapters.SQL.query(App.Repo, "SELECT 1") do
      {:ok, _} -> json(conn, %{ready: true})
      _ -> conn |> put_status(503) |> json(%{ready: false})
    end
  end
end


	•	Expected: /health returns 200 when node is up; /ready returns 200 only when dependencies respond.  

	3.	Kill node mid-load, keep SLO
	•	Drive load with your k6 script; start two instances or rely on systemd/compose to restart.
	•	Kill one node:

_build/prod/rel/app/bin/app stop   # or: pkill -TERM -f 'app'


	•	Observe dashboards; verify SLO holds during restart window. Target: web p95 within agreed SLO.  
	•	Architecture SLO reference: p95 < 150 ms, 99.9% uptime.  

	4.	Rollback safely
	•	Keep previous release on disk. If new release misbehaves:

_build/prod/rel/app/bin/app stop || true
_build/prod/rel/app/releases/OLD_VSN/app/bin/app start


	•	With docker compose: docker compose rollback pattern or re-point tag to previous image and up -d.
	•	Acceptance: rollback completed in under 2 minutes; service healthy post-rollback.  

Common Pitfalls
	•	Compile-time env leakage instead of runtime config.  
	•	No stop timeout or graceful shutdown, leading to dropped requests.  
	•	Skipping a migrations gate during rollout.  

Success Criteria
	•	Release boots from artifact; runtime config verified via RPC check.  
	•	/health and /ready return correct status across restarts.  
	•	During kill-under-load drill, SLO remains within target window.  
	•	Rollback executed end-to-end in < 2 minutes with service restored.  

