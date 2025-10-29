# Phase 7 — Jobs & Ingestion (Oban, GenStage, Broadway)

Process data streams and background jobs with Broadway and Oban.

## Books
- **Adopting Elixir** — reliability and ops chapters

## Docs
- **Oban overview**
  https://hexdocs.pm/oban/Oban.html

- **Oban.Job**
  https://hexdocs.pm/oban/Oban.Job.html

- **Broadway behaviour**
  https://hexdocs.pm/broadway/Broadway.html

- **GenStage**
  https://hexdocs.pm/gen_stage/GenStage.html

## Supplements
- **Broadway learning hub**
  https://github.com/dashbitco/broadway#learn---

================================================================================

Phase 7 extracted. Book: Adopting Elixir — reliability & ops.

Adopting Elixir — Reliability & Ops Summary

Outline
	•	Durable jobs and backoff
	•	GenStage/Broadway ingestion with producer → processor → batcher flow
	•	Idempotency and “exactly-once” vs “at-least-once” reality
	•	Backpressure at system boundaries; mailbox limits and gauges
	•	Retry with backoff; resilience under netsplits
	•	Dead-letter queues (DLQ) as sink when retries exhaust

Chapter/Section Summaries

Durable Jobs with Oban

Key Concepts
	•	Durable, DB-backed jobs for reliability and recovery. Queues, plugins, backoff, retries.

Essential Code Snippets
(No Oban snippet present in transcript; see linked docs.)

Tips & Pitfalls
	•	Explicit backoff; avoid unbounded concurrency. Monitor mailbox depth.

Exercises Application
	•	Build jobs for slow/IO work; prove recovery on crash; verify retry schedule.

Diagrams

(n/a – job system diagram not in transcript)

Broadway for Data Ingestion (GenStage patterns)

Key Concepts
	•	Producer → Processors → Batchers → Sink(DB/S3). Backpressure propagates upstream. Idempotent handlers. Metrics + alerts.

Essential Code Snippets
(No Broadway snippet present in transcript; see linked docs.)

Tips & Pitfalls
	•	Enforce idempotency at handlers or via outbox. Avoid non-idempotent side effects.

Exercises Application
	•	Ingest from S3/Kafka. Enforce backpressure. Prove idempotency with dedupe keys.

Diagrams

Topic → Broadway Producers → Processors → Batchers → Sink(DB/S3)
   backpressure ←———————————— metrics+alerts

Backpressure Management

Key Concepts
	•	Regulate work at edges, not per message. Measure and alarm on mailbox depth.

Essential Code Snippets

Task.async_stream(urls, &fetch/1, max_concurrency: 8) |> Enum.to_list()

Tips & Pitfalls
	•	Do not block servers; push heavy work out of callbacks.

Exercises Application
	•	Demonstrate throughput stability under load with bounded concurrency.

Diagrams

backpressure ←— from sink/batcher to processors to producers

Idempotency Patterns

Key Concepts
	•	Treat “exactly-once” as an illusion; implement idempotent handlers and dedupe keys. Use outbox at boundaries.

Essential Code Snippets

with {:ok, a} <- parse(s),
     {:ok, b} <- validate(a),
     {:ok, c} <- persist(b) do
  {:ok, c}
else
  err -> err
end

Tips & Pitfalls
	•	Ensure external effects are safe to repeat. Persist dedupe tokens.

Exercises Application
	•	Prove deduping by replaying the same message without double effects.

Diagrams

Producer (msg + key) → Handler (check key store) → Sink
           ↑——————————— reject duplicate ———————————↑

Retry Strategies with Backoff

Key Concepts
	•	Use exponential backoff on transient errors; cap retries. Expect netsplits. Recover gracefully.

Essential Code Snippets
(Strategy described; no retry code present in transcript.)

Tips & Pitfalls
	•	Avoid tight retry loops. Emit telemetry for retry counts.

Exercises Application
	•	Configure backoff and show decreasing error rate with transient failures.

Diagrams

try → fail → backoff(t) → try … → DLQ after N attempts

Dead Letter Queues (DLQ)

Key Concepts
	•	Route messages to DLQ after max retries for inspection and manual remediation. Tie into alerts.

Essential Code Snippets
(Not present in transcript.)

Tips & Pitfalls
	•	Ensure DLQ visibility with dashboards and runbooks.

Exercises Application
	•	Show DLQ population and create a remediation script.

Diagrams

… → Batchers → Sink
          ↘
           DLQ (inspect + replay)

Cross-Chapter Checklist
	•	Define inputs, invariants, SLOs, quotas, and data retention before coding.
	•	Backpressure at boundaries; alert on mailbox growth.
	•	Idempotent handlers; store dedupe keys or use outbox.
	•	Retries with capped exponential backoff; plan for netsplits.
	•	Telemetry events and labels; dashboards for rate, latency, errors, saturation.

Quick Reference Crib

Flow: Topic → Producers → Processors → Batchers → Sink
Backpressure: sink→batcher→processor→producer (propagates upstream)
Jobs: durable + retries + backoff; measure mailbox; alert early
Idempotency: dedupe key or outbox; side effects safe to repeat
Reality: at-least-once delivery; “exactly-once” ≈ orchestration illusion
DLQ: after N retries → inspect, replay, or purge with audit trail


---

## Drills


Phase 7 Drills

Core Skills to Practice
	•	Build a Broadway pipeline that reads from S3 or Kafka.  
	•	Enforce backpressure with bounded demand and max concurrency.    
	•	Prove idempotency using dedupe keys.  
	•	Implement retries with exponential backoff using a durable job mechanism.    

Exercises
	1.	Ingest from S3/Kafka
Create apps/ingest with a Broadway pipeline that consumes either S3 objects or a Kafka topic and writes to the DB. Show messages flowing end-to-end. Expected: stable consumption without drops.  
	2.	Backpressure proof
Stress the processors. Set max demand and concurrency so upstream producers slow when processors saturate. Capture a run where producer rate falls as processor work time increases. Expected: visible upstream backpressure, no queue blowup.    
	3.	Idempotency with dedupe keys
Add a dedupe key (e.g., message UUID) and a unique DB constraint. Re-inject duplicates and verify only one side effect occurs. Expected: at-least-once delivery tolerated, duplicates ignored, budgets respected.    
	4.	Exponential backoff retries
On handler failure, enqueue a durable retry that increases delay per attempt (e.g., exponential). Show attempts 1..N with growing delays and eventual success or dead-letter. Expected: retry cadence follows exponential backoff.    

Common Pitfalls
	•	Unbounded concurrency causing resource exhaustion.  
	•	Non-idempotent handlers producing duplicate effects.  

Success Criteria
	•	Broadway pipeline reads from S3 or Kafka and persists records.  
	•	Backpressure verified by producer slow-down under load with bounded demand.  
	•	Duplicate injections create one effect due to dedupe key and unique constraint.  
	•	Failed messages retry with exponential backoff and either succeed or land in DLQ.  

