
GenServer Design Checklist

Overview

Use for any new or modified GenServer before code review and before merging to main. Based on “GenServer hardening” lines 2993–2999.

Performance
	•	Callback budget < 5 ms average and < 20 ms p95 (measure with Telemetry timings on handle_call|cast|info)
	•	No blocking I/O in callbacks (File, HTTP, DB). Offload via Task.Supervisor or job queue (e.g., Oban)
	•	Heavy CPU work delegated to worker pool or Task.async_stream/3 with max_concurrency
	•	Periodic work uses timeouts with jitter (e.g., :timer.send_after/3), each run < 50 ms
	•	Backpressure applied on inbound requests (bounded queue or reject when mailbox > threshold)

Reliability
	•	All external processes are monitored (Process.monitor/1) and handled in :DOWN
	•	Mailbox depth exported as a gauge and alerted when > 1 000 msgs for > 60 s (PromEx/Grafana)
	•	Process registered via Registry/via tuple, not global atoms
	•	Supervisor strategy and restart intensity documented; crash is recoverable without manual steps
	•	State can be rebuilt from source of truth after restart (no fragile in-memory only data)

Testing
	•	Kill test passes: Process.exit(pid, :kill) under supervisor triggers restart and healthy state
	•	Recovery test: post-restart init/1 + handle_continue/2 restore state and accept traffic
	•	Timeout behavior covered: call/3 timeouts and periodic handle_info/2 paths
	•	Concurrency test: overlapping calls do not deadlock; mailbox growth stays < 1 000 under load

Code Quality
	•	Thin callbacks: all business logic in pure “core” module; callbacks only translate messages and update state
	•	Public API has typespecs; state struct has typed fields; @behaviour GenServer enforced
	•	Dialyzer clean (no warnings); Credo --strict clean; no unused handle_info clauses
	•	Telemetry events emitted for start/stop/exception with consistent names and labels
	•	No work in init/1 that can fail; expensive init moved to handle_continue/2

Common Mistakes to Avoid
	•	Doing I/O or long work in callbacks → offload or async with supervision
	•	Using cast where confirmation is required → use call with explicit timeout
	•	Unbounded mailboxes → add gauges, drop or shed when above threshold
	•	Hidden inter-GenServer deps → always monitor and handle :DOWN
	•	Relying on in-memory state only → ensure rebuild from DB or cache on restart

Further Reading
	•	Phase 3 notes: GenServer + Supervision patterns
	•	“GenServer hardening” (lines 2993–2999)
	•	Elixir in Action, ch. 6–9
	•	OTP Design Principles: gen_server behavior

