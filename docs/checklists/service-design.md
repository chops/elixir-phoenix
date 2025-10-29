
Service Design Checklist

Overview

Use when designing or reviewing any new or changed service before coding. Derived from the “Design a service” checklist and related ops/obs sections.  

Requirements
	•	Inputs, outputs, and invariants are enumerated and documented; peer-reviewed.  
	•	SLOs set and published: availability ≥ 99.9%; latency targets include p95 < 150 ms (and p99 defined).  
	•	Quotas/rate limits specified per actor and IP with default and burst values; enforced at ingress.  
	•	Data retention policy defined per entity (hot, warm, archive windows) and legal hold path.  
	•	ADR written and approved before implementation begins.  

Data Model
	•	All invariants enforced with DB constraints and verified via *_constraint/3 in changesets.  
	•	Indexes match top query shapes; load-test confirms benefit before merge.  
	•	Multi-step writes wrapped in Ecto.Multi; steps are small and deterministic.  
	•	Retention and purge jobs scheduled and observable (counts deleted per run).  

Failure Modes
	•	Backpressure strategy documented and tested (ingress gate, bounded queues, pools).  
	•	Circuit-breaker policy defined: open on error-rate or latency threshold with fixed cooldown and half-open probe; fallbacks specified.
	•	Timeouts for all downstream calls; retries are bounded and idempotent-only.  
	•	Dependency health is monitored; alarms trigger on saturation or mailbox growth.  

Observability
	•	Telemetry events and labels defined for the service API and critical internals; label cardinality reviewed.  
	•	One dashboard per service with the four golden signals: RPS, p95 latency, error rate, saturation.  
	•	SLO burn-rate alerts configured; alert thresholds and paging policy documented.  
	•	Trace key paths end-to-end; logs are structured with correlation IDs.  

Operations
	•	Runbook authored: deploy, restart, rollback, incident steps; verified via GameDay.  
	•	SLIs implemented and exported: request_duration histogram, request_total, error_total, saturation gauges.  
	•	CI gates in place: format, Credo, Dialyzer, tests (DB sandbox), Sobelow, mix_audit.  
	•	On-call rotation and escalation defined; dashboards and alerts linked in the runbook.  

Common Mistakes to Avoid
	•	Coding before ADR approval; requirements drift later.  
	•	No explicit failure or backpressure plan; services collapse under burst.  
	•	Relying on app logic instead of DB constraints; race conditions persist.  
	•	Shipping without dashboards and burn alerts; SLOs become aspirational.  

Further Reading
	•	Reference Architecture: Real-time SaaS SLO targets and components.  
	•	Observability phase: Telemetry, dashboards, burn alerts.  
	•	Database checklist: constraints, indexes, Ecto.Multi.  

