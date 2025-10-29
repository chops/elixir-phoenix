# Phase 10 — Observability & SLOs

Metrics, tracing, and monitoring with OpenTelemetry and Prometheus.

## Books
- **Adopting Elixir** — production, metrics, operations

## Docs
- **OpenTelemetry for Erlang/Elixir**
  https://hexdocs.pm/opentelemetry/readme.html and https://opentelemetry.io/docs/instrumentation/erlang/

- **PromEx (Telemetry → Prometheus)**
  https://hexdocs.pm/prom_ex/readme.html

## Supplements
- **Telemetry vs OpenTelemetry thread**
  https://elixirforum.com/t/difference-between-telemetry-and-opentelemetry/44835---

================================================================================

Phase 10 extracted. See below.

Adopting Elixir — Production, Metrics, and Operations Summary

Outline
	•	Telemetry events and handlers.  
	•	OpenTelemetry and Prometheus exporter across web/Ecto/Oban/Broadway.  
	•	Golden signals dashboards per service: RPS, p95, error rate, saturation.  
	•	SLOs with burn-rate alerts; mailbox and ETS gauges.  
	•	Profiling with mix profile.fprof and :eprof on small repros; load testing; Benchee microbenches.  
	•	Production readiness: logging, crash reports, tracing, incident playbooks.  

Chapter/Section Summaries

Metrics & Performance

Key Concepts
	•	Instrument first. Optimize second.  
	•	Use Telemetry from Phoenix and Ecto; profile and load test; benchmark hot paths.  

Essential Code Snippets

# Telemetry handler
:telemetry.attach("log-http", [:phoenix, :endpoint, :stop], fn _e, m, meta, _ ->
  Logger.info("http", duration: m.duration, path: meta.conn.request_path)
end, nil)

Ecto emits Telemetry timing events you can subscribe to.  

# Bench
Benchee.run(%{"map" => fn -> Enum.map(1..10_000, & &1*&1) end})

Use for microbenchmarks before and after changes.  

Tips & Pitfalls
	•	Track latencies, queue sizes, error rates; attach labels such as tenant and route.  
	•	Use mix profile.fprof or :eprof only on controlled, small runs.  

Exercises Application
	•	Add Telemetry handlers for Phoenix and Ecto; export to logs or metrics.
	•	Create a load test and a Benchee microbench; capture before/after chart.  

Diagrams

Observability flow:
Telemetry → handler → logs/metrics → dashboard/alerts



Observability & SLOs

Key Concepts
	•	Targets: Telemetry events, OpenTelemetry export, metrics for latency, saturation, errors, traffic, plus cost.  
	•	One dashboard per service with four graphs: RPS, p95, errors, saturation.  

Essential Code/Setup
	•	Add OpenTelemetry across web/Ecto/Oban/Broadway and wire Prometheus exporter.
	•	Define SLOs and burn-rate alerts as code; expose mailbox and ETS gauges.  

Tips & Pitfalls
	•	Avoid logging in hot loops.
	•	Avoid high-cardinality labels.  

Exercises Application
	•	SLOs with burn alerts; dashboards populate under k6 load tests.  

Diagrams

Per-service dashboards:
[RPS] [p95 latency] [Error rate] [Saturation]



Production Readiness

Key Concepts
	•	Structured logging, error reports, SASL crash reports, tracing, incident playbooks.  

Essential Code Snippets

# Structured logging
require Logger
Logger.metadata(service: :orders)
Logger.error("failed", order_id: id, reason: inspect(reason))

Simple tracing with :dbg for targeted debugging:

:dbg.tracer()
:dbg.p(self(), [:s, :m])



Tips & Pitfalls
	•	Log at edges, not inside hot loops. Add correlation IDs. Pre-write incident checklists.  

Exercises Application
	•	Ship structured logs, wire a crash reporter, and write an incident runbook for a failing GenServer.  

Cross-Chapter Checklist
	•	Instrument before tuning; load test; benchmark with Benchee.  
	•	Keep callbacks fast; supervise; set mailbox gauges and alarms.  
	•	Define inputs, invariants, SLOs, and telemetry labels up front; ship runbook and SLI dashboards.  

Quick Reference Crib

Event names
- [:phoenix, :endpoint, :stop]  # HTTP stop; includes duration and conn meta
- Ecto query events via Telemetry # timings for DB ops

Label patterns
- tenant, route, actor, result, queue, shard
- mailbox_depth, ets_size gauges

Dashboards
- Traffic (RPS), Latency (p50/p95/p99), Error rate, Saturation (CPU/Mem/DB/queues)

Profiling
- mix profile.fprof / :eprof on small repros only

Bench
- Benchee.run(%{"name" => fn -> work() end})







Notes on exporter and traces
	•	Add OTel across apps; expose Prometheus; verify with k6 that dashboards populate and SLO burn alerts fire when latency is induced.  


Where this lives in your repo
	•	/observability/grafana/*.json, /docs/slo/*.md, /tools/k6/* for artifacts.  

Done.


---

## Drills


Phase 10 Drills

Core Skills to Practice
	•	Add Telemetry handlers for Phoenix and Ecto; export metrics.    
	•	Define SLOs and burn-rate alerts; manage dashboards as code.    
	•	Build one per-service dashboard with RPS, p95 latency, error rate, and saturation.  
	•	Trace hot paths; use profilers only on small, controlled reproductions.    

Exercises
	1.	Instrument Phoenix and Ecto
	•	Attach endpoint stop handler and confirm Ecto query timings emit via Telemetry.

:telemetry.attach("log-http", [:phoenix, :endpoint, :stop], fn _e, m, meta, _ ->
  Logger.info("http", duration: m.duration, path: meta.conn.request_path)
end, nil)

Expected: HTTP and query events visible in logs or metrics sink.  

	2.	Define SLOs with burn alerts
	•	Set availability and latency targets; create multi-window burn-rate alerts that fire before breach.
Expected: Synthetic load triggers burn alerts while dashboards show degradation.  
	3.	Dashboards: RPS / p95 / Errors / Saturation
	•	Build a per-service Grafana dashboard with four graphs: request rate, p95 latency, error rate %, and resource saturation (CPU, memory, DB pool, mailbox gauges).
Expected: All four graphs populate under k6 load.      
	4.	Trace hot paths
	•	Use tracing and profilers to identify slow functions; keep runs minimal and isolated.
Expected: Hot path identified; remediation PR links trace evidence.    

Common Pitfalls
	•	Logging in hot loops; inflates latency and cost.  
	•	High-cardinality labels; explode metric series count.  

Success Criteria
	•	Phoenix and Ecto Telemetry events attached and verified.  
	•	SLOs defined and burn-rate alerts trigger under induced latency.  
	•	Dashboard shows RPS, p95, error rate, and saturation during load.  
	•	Hot path traced with profiler evidence and scoped fix proposed.    

