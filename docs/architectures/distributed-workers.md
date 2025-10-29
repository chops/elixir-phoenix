
Distributed Workers

Overview

Per-key workers handle stateful tasks without global locks. Names route requests to the correct process. Workers start on demand and recover under supervision. Shared reads hit ETS to reduce database load. A periodic reconciler heals drift.  

When to Use This Pattern
	•	Per-tenant or per-entity state machines.
	•	Chat sessions, carts, device twins, or long-running tasks keyed by ID.
	•	Systems with churn where idle workers should not consume resources.  

Components

Registry

Purpose: Name and locate workers by key.
Technology: Registry (unique keys).
Key Responsibilities:
	•	Resolve via(Registry, key) to a PID.
	•	Ensure names are released on crash.    

DynamicSupervisor

Purpose: Start workers on demand and restart them on failure.
Technology: DynamicSupervisor.
Key Responsibilities:
	•	start_child/2 when a key is first seen.
	•	Apply restart strategy and intensity.  

Worker (GenServer)

Purpose: Hold per-key state and serve requests.
Technology: GenServer.
Key Responsibilities:
	•	Process calls routed by via/1.
	•	Read mostly from ETS, write through to Repo when needed.  

ETS Table

Purpose: Fast shared, read-only cache for hot lookups.
Technology: :ets with read concurrency.
Key Responsibilities:
	•	Serve hot reads.
	•	Periodic TTL or sweeps out of band.  

Repo

Purpose: Durable storage for authoritative state.
Technology: Ecto + Postgres.
Key Responsibilities:
	•	Persist writes from workers.
	•	Source of truth on reconciliation.  

Reconciliation Task

Purpose: Heal naming/state drift after crashes or deploys.
Technology: Periodic job (GenServer timer or job runner).
Key Responsibilities:
	•	Scan for orphaned names, restart or retire workers.
	•	Warm ETS from Repo for active keys.  

Architecture Diagram

Request → via(Registry,key) → Worker(key) → Repo/ETS
DynamicSupervisor spawns on demand. Supervisor restarts.



Data Flow
	1.	Caller computes key and sends to via(Registry, key). Registry resolves or returns :undefined.  
	2.	If missing, the coordinator asks DynamicSupervisor to start_child for key, which registers itself.  
	3.	Worker serves the request. It checks ETS for hot read paths, otherwise hits Repo, then updates ETS if appropriate.  
	4.	On worker crash, the supervisor restarts it. Name is re-registered. Caller retries via Registry.  
	5.	The reconciler periodically compares Registry, ETS, and Repo to restart missing workers, drop stale ETS entries, and rehydrate hot keys.  

Key Design Decisions

Name resolution via Registry

Choice: Registry unique keys with via/1.
Rationale: Avoid global atoms and enable per-key routing.
Tradeoffs: Requires disciplined registration and cleanup.  

On-demand processes

Choice: DynamicSupervisor spawns workers only when used.
Rationale: Saves memory and scheduler time during idle periods.
Tradeoffs: First-hit latency includes spawn + init.  

Shared reads through ETS

Choice: Central ETS table for read-heavy data.
Rationale: Reduce DB pressure and tail latency.
Tradeoffs: Cache invalidation and coherence handled by workers/reconciler.  

Periodic reconciliation

Choice: Timer or scheduled job to verify Registry↔ETS↔Repo consistency.
Rationale: Heals after crashes, deploys, or churn.
Tradeoffs: Background load; must be bounded and observable.  

Failure Modes & Handling
	•	Worker crash: Supervisor restarts; name rebinds; pending callers retry.  
	•	Name leak after crash: Reconciler releases old entries; ensure Registry unique semantics.  
	•	Stale ETS: Reconciler rehydrates from Repo or expires by TTL sweeps.  
	•	Thundering first-hit: Warm selected keys during reconciliation window.  

Observability & SLOs

Metrics to Track
	•	Registry lookup latency and failures.
	•	Workers: active count, spawn rate, restarts, mailbox depth.
	•	ETS: hit ratio, table size, sweep duration.
	•	DB: read/write latency for worker code paths.  

SLO Targets
	•	Worker dispatch p95 < 25 ms under nominal load.
	•	Registry resolution error rate < 0.1%.
	•	ETS hit ratio ≥ 80% for designated hot keys.
	•	Restarted worker ready < 2 s after crash.  

Scaling Considerations
	•	Bottleneck: ETS contention. Use read_concurrency, shard by table if needed.  
	•	Bottleneck: Single node capacity. Distribute by consistent hash and run one fleet per node; reconcile on membership changes.  

Related Phases
	•	Phase 4 — Naming & Fleets: Registry, via/1, DynamicSupervisor.  
	•	Phase 8 — Caching & ETS: Read-through, TTL sweeps, benches.  
	•	Phase 3 — GenServer + Supervision: Thin callbacks, restart semantics.  

Example Implementation
	•	labs_session_workers proves Registry + DynamicSupervisor.  
	•	pulse_fleet integrates per-user workers in the product.  

Further Reading
	•	Docs: Registry, DynamicSupervisor.  
	•	Book: Designing for Scalability with Erlang/OTP (supervision strategies).  

