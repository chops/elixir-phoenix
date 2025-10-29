
Streaming Ingestion Architecture

Overview

High-throughput ingestion with Broadway reading from Kafka or SQS, applying idempotent handlers, enforcing backpressure, and persisting via a DB/S3 sink with an outbox table for exactly-once semantics at system boundaries. Diagram and core elements come from the reference architectures section.  

When to Use This Pattern
	•	Event or file streams requiring ordered, scalable processing.
	•	At-least-once sources where you must enforce idempotency and deliver exactly-once effects at the sink boundary.
	•	Pipelines that need automatic backpressure and observable health metrics.

Components

Sources (Kafka or SQS)

Purpose: Provide at-least-once delivery of messages to the pipeline.
Technology: Kafka topics or SQS queues.
Key Responsibilities:
	•	Retain messages until acknowledged by consumers.
	•	Allow horizontal scaling via partitions or multiple inflight messages.  

Broadway Producers

Purpose: Pull from Kafka/SQS and translate into Broadway demand.
Technology: Broadway (GenStage under the hood).
Key Responsibilities:
	•	Manage offsets/receipts and visibility timeouts.
	•	Apply backpressure from downstream by modulating demand.  

Broadway Processors

Purpose: Execute business logic per message.
Technology: Broadway processors, pure helpers.
Key Responsibilities:
	•	Idempotent transformations and validations.
	•	Emit telemetry for latency and failures.  

Broadway Batchers

Purpose: Group processed messages for efficient writes.
Technology: Broadway batchers.
Key Responsibilities:
	•	Form batches by size or time.
	•	Respect backpressure by controlling batch sizes and concurrency.  

Sink (DB/S3)

Purpose: Persist results and commit side effects.
Technology: Postgres (Ecto) and/or S3-compatible storage.
Key Responsibilities:
	•	Atomic writes of batches.
	•	Emit success/failure signals for acknowledgements.  

Outbox Table

Purpose: Provide exactly-once semantics at the boundary.
Technology: Postgres outbox table + transactional write + outbox relay.
Key Responsibilities:
	•	Write domain change + outbox record in the same DB transaction.
	•	Relay outbox entries idempotently to external systems; mark delivered.  

Metrics + Alerts

Purpose: Observe health and enforce SLOs.
Technology: Telemetry → Prometheus/Grafana.
Key Responsibilities:
	•	Track lag, throughput, errors, saturation, and backpressure status.  

Architecture Diagram

Topic → Broadway Producers → Processors → Batchers → Sink(DB/S3)
   backpressure ←———————————— metrics+alerts



Data Flow
	1.	Ingest: Producers pull from Kafka/SQS and emit events according to downstream demand. Offsets or receipts are held until success.  
	2.	Process: Processors run idempotent handlers. Use deterministic keys to detect duplicates and make handlers side-effect free until the sink.  
	3.	Batch: Batchers group messages by size/time for efficient writes and to control concurrency.  
	4.	Persist: Sink writes batches. If using a DB, perform a single transaction that writes state changes and outbox rows. Commit acts as the “exactly-once” boundary.  
	5.	Acknowledge: On success, commit Kafka offsets or delete SQS messages. On failure, do not ack; messages are retried according to source semantics.
	6.	Observe: Emit metrics at each stage for rate, latency, errors, and saturation.  

Key Design Decisions

Use Broadway with Kafka/SQS

Choice: Broadway as the ingestion framework.
Rationale: Built-in backpressure, batching, and concurrency controls.
Tradeoffs: Requires careful handler idempotency and tuning.  

Idempotent Handlers

Choice: All processor logic is idempotent.
Rationale: Sources are at-least-once; duplicates must not create double effects.
Tradeoffs: Additional complexity for dedupe keys and conflict handling.  

Outbox for Exactly-Once at the Boundary

Choice: Outbox table with transactional write + relay.
Rationale: Guarantees each logical event is applied once at the sink boundary even with retries.
Tradeoffs: Extra table, relay process, and monitoring.  

Backpressure Propagation

Choice: Let demand flow control pace from sink → batchers → processors → producers.
Rationale: Prevents overload and protects the sink; natural fit with GenStage demand model.
Tradeoffs: Requires tuning max demand, concurrency, and batch sizes.  

Failure Modes & Handling
	•	Handler error: Do not ack. Retry with exponential backoff. Escalate to DLQ if supported by source, or mark failed with reason.  
	•	Sink contention/timeouts: Reduce batch size and concurrency. Backpressure will slow upstream automatically.  
	•	Duplicate delivery: Dedupe by idempotency key before side effects. Conflicts resolved by upsert or unique constraints.  
	•	Outbox relay crash: Relay restarts and resumes; delivered flags prevent re-sending.

Observability & SLOs

Metrics to Track
	•	Source lag: Kafka consumer lag or SQS oldest-message age. Alert if rising steadily.  
	•	Throughput: Messages/sec per stage; batch size distribution.  
	•	Latency: End-to-end p50/p95/p99; handler and sink latency.
	•	Error rate: Processor errors, batch write failures, relay failures.
	•	Saturation: Concurrency utilization, mailbox depth, batcher queue depth.
	•	Backpressure signals: Demand drops, paused producers, requeued count.  
	•	Outbox health: Pending rows, relay lag, duplicate-key conflicts.  

SLO Targets
	•	Freshness: 99% of messages processed within 60s of arrival.
	•	Reliability: <0.1% failed messages without DLQ disposition per day.
	•	Capacity: Consumer lag returns to baseline within 10m after a 2× traffic spike.

Scaling Considerations
	•	Producer scaling: Increase partitions (Kafka) or concurrency (SQS). Tune max_demand and concurrency in Broadway.  
	•	Sink scaling: Use batch sizing, connection pooling, and staged writes.
	•	Hot shards: Rebalance partitions or add consumer instances.

Related Phases
	•	Phase 7 — Jobs & Ingestion: Backpressure, idempotency, “exactly-once illusions vs at-least-once reality.”  
	•	Phase 10 — Observability: Telemetry, metrics, dashboards, SLOs for Broadway.  

Example Implementation
	•	labs_ingest: Broadway with backpressure and idempotency.
	•	labs_jobs: Oban jobs with retry/backoff/DLQ.  

Further Reading
	•	Broadway behaviour and GenStage docs; “Jobs & ingestion” materials in the curriculum references.  

================================================================================
END OF EXTRACTED CONTENT
================================================================================
