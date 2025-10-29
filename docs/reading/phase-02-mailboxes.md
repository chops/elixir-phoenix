# Phase 2 — Processes & Mailboxes

Understand message-passing concurrency with raw processes.

## Books
- **Elixir in Action, 2nd ed.** (Saša Jurić) — processes and message passing

## Docs
- **Erlang gen_server manpage**
  https://www.erlang.org/doc/man/gen_server.html

- **OTP Design Principles overview**
  https://www.erlang.org/doc/design_principles/des_princ.html

- **Task.async_stream/3**
  https://hexdocs.pm/elixir/Task.html#async_stream/3

## Supplements
- **OTP Design Principles (PDF aggregate)**
  https://www.erlang.org/doc/design_principles/part_frame.html---

================================================================================

Elixir in Action, 2nd ed. (Saša Jurić) Summary

Outline
	•	Processes and failure semantics: spawn, links, monitors (lines 1418, 1456–1457).
	•	Message passing: send/receive, selective receive (lines 1451–1453, 2681–2683).
	•	Timeouts and after clauses (lines 1760–1763, 2050–2053, 2380–2381).
	•	Process state loops and server patterns (lines 1431–1439).
	•	Mailbox management and backpressure (lines 1080, 1241, 1271, 2836–2845).

Chapter/Section Summaries

Process creation and failure semantics

Key Concepts
	•	spawn/1, spawn_link/1, spawn_monitor/1. Links propagate exits. Monitors send :DOWN messages one-way (lines 1418, 1456–1457).
	•	Capture parent PID before spawning (lines 1425–1427, 1460–1461).

Essential Code Snippets

# spawn and reply (lines 1425–1427)
parent = self()
spawn(fn -> send(parent, 6*7) end)
receive do x -> IO.puts("#{x}") end  # 42

# linked worker loop (lines 1431–1441)
defmodule Worker do
  def do_work do
    receive do
      {:compute, x, pid} -> send(pid, {:result, x*x})
      {:exit, reason} -> exit(reason)
    end
    do_work()
  end
end
pid = spawn_link Worker, :do_work, []

# monitor instead of link (lines 1444–1445)
{pid, ref} = spawn_monitor(fn -> :timer.sleep(500) end)
receive do {:DOWN, ^ref, :process, ^pid, reason} -> reason end

Tips & Pitfalls
	•	Never call self() inside the spawned function to mean the parent. Capture it first (lines 1460–1461).

Exercises Application
	•	Heartbeat monitor and work pool walkthroughs (lines 1464–1466).

Diagrams

Link vs monitor (lines 1456–1457)
link:    Parent ⇆ Child  (errors propagate)
monitor: Parent ← Child (one-way DOWN message)

Message passing mechanics

Key Concepts
	•	Plain send/receive flow and reply patterns (lines 1451–1453).
	•	Selective receive via pattern and pin operator (lines 2681–2683).

Essential Code Snippets

# message flow (lines 1451–1453)
# Parent ──send({:compute,x,parent})──> Worker
# Parent <──receive({:result, x*x})──── Worker

# selective receive on a specific Port and pinned ref (lines 2681–2683)
port = Port.open({:spawn, "python worker.py"}, [:binary, packet: 2])
receive do {^port, {:data, bin}} -> decode(bin) end

Tips & Pitfalls
	•	Use monitors when you only need notifications, not failure propagation (lines 1461, 1456–1457).

Exercises Application
	•	Build mailbox-driven workers; observe ordering and CPU under load (lines 1464–1466).

Diagrams

Parent ─send→ Child
Parent ←recv─ Child
(link/monitor variants at lines 2066–2068)

Timeouts and after clauses

Key Concepts
	•	Use after to bound waits and implement abandonment semantics (lines 1762, 2052, 2380–2381).

Essential Code Snippets

# receive with timeout (lines 2050–2053)
parent = self()
pid = spawn(fn -> send(parent, {:result, 6*7}) end)
receive do {:result, r} -> r after 1000 -> :timeout end

Tips & Pitfalls
	•	Avoid sleeps to synchronize. Prefer timeouts and monitors (lines 1774–1776, 2061–2062).

Exercises Application
	•	KV loop with timeouts; prove timeout paths in tests (lines 3142–3146).

Diagrams

receive … after t -> :timeout

Process state loops

Key Concepts
	•	Tail-recursive receive loops hold state and re-enter on each message (lines 1431–1439).

Essential Code Snippets

# stateful loop (lines 1431–1439)
def do_work do
  receive do
    {:compute, x, pid} -> send(pid, {:result, x*x})
    {:exit, reason} -> exit(reason)
  end
  do_work()
end

Tips & Pitfalls
	•	Keep server loops fast. Push heavy work to workers (line 1271).

Exercises Application
	•	Work pool: queue → scheduler → workers → replies (lines 1477–1479).

Diagrams

Work pool (lines 1477–1479)
Queue → Scheduler → [Worker1 | Worker2 | …] → replies to client

Mailbox management

Key Concepts
	•	Watch mailbox growth; apply backpressure at boundaries (lines 1080, 1238–1243).
	•	Bounded mailboxes and admission control patterns (line 1241).

Essential Code Snippets

# checklist cues (lines 1270–1273)
# Keep servers fast; move heavy work to workers; watch mailboxes.

Tips & Pitfalls
	•	Pitfalls: sleeping to sync, unbounded mailboxes, blocking in a server (lines 2843–2844).

Exercises Application
	•	Mailbox KV server with crash/timeout behaviors; tests for :DOWN, selective receive, after paths (lines 3139–3146, 3938–3946).

Diagrams

Mailbox pressure → regulate at ingress (queues/pools) (lines 1238–1243)

Cross-Chapter Checklist
	•	Capture parent PID before spawn (lines 1425–1427, 1460–1461).
	•	Use monitors for notifications, links for shared fate (lines 1456–1457).
	•	Bound all waits with after (lines 2050–2053).
	•	Keep loops fast; offload heavy work; watch mailboxes (lines 1271, 1080).
	•	Apply backpressure at edges; use pools and bounded queues (line 1241).

Quick Reference Crib

Spawn         : pid = spawn(fun) | spawn_link | spawn_monitor
Send/Receive  : send(pid, msg) ; receive do pattern -> action after t -> :timeout end
Selective recv: receive do {^port, {:data, bin}} -> decode(bin) end
Link vs Monitor:
  link    → Parent ⇆ Child
  monitor → Parent ←DOWN Child
State loop   : receive → handle → tail-call loop()
Mailbox tips : avoid sleeps; bound mailboxes; regulate at ingress

Learning Elixir — Chapter 6: Processes Summary

Outline
	•	Lightweight processes and mailboxes; flush/0 in IEx (lines 1418–1421, 1419).
	•	spawn, spawn_link, spawn_monitor usage (lines 1418, 1429–1441, 1444–1445).
	•	Message passing patterns and diagrams (lines 1451–1453).
	•	Links vs monitors diagram and semantics (lines 1456–1457).
	•	Timeouts with after (lines 1760–1763).
	•	Process loops, KV example, work pool visual (lines 1420, 1431–1439, 1477–1479).

Chapter/Section Summaries

Processes and mailboxes

Key Concepts
	•	Processes are lightweight. Use send/receive mailboxes. flush/0 helps in IEx (lines 1418–1421, 1419).

Essential Code Snippets

# spawn and reply (lines 1425–1427)
parent = self()
spawn(fn -> send(parent, 6*7) end)
receive do x -> IO.puts("#{x}") end  # 42

Tips & Pitfalls
	•	Capture parent PID first (line 1460).

Exercises Application
	•	Build simple KV server loop (line 1420).

Diagrams

Message flow (lines 1451–1453)
Parent ──send({:compute,x,parent})──> Worker
Parent <──receive({:result, x*x})──── Worker

Links and monitors

Key Concepts
	•	Linked processes share fate. Monitors notify one-way with :DOWN (lines 1456–1457).

Essential Code Snippets

# linked worker loop (lines 1429–1441)
defmodule Worker do
  def do_work do
    receive do
      {:compute, x, pid} -> send(pid, {:result, x*x})
      {:exit, reason} -> exit(reason)
    end
    do_work()
  end
end
pid = spawn_link Worker, :do_work, []

# monitored process (lines 1444–1445)
{pid, ref} = spawn_monitor(fn -> :timer.sleep(500) end)
receive do {:DOWN, ^ref, :process, ^pid, reason} -> reason end

Tips & Pitfalls
	•	Use monitors when you need notifications but not cascading exits (line 1461).

Exercises Application
	•	Heartbeat monitor and work pool (lines 1464–1466).

Diagrams

Link vs monitor (lines 1456–1457)
link:    Parent ⇆ Child
monitor: Parent ← Child

Timeouts and selective receive

Key Concepts
	•	after clause prevents indefinite waits (lines 1760–1763).
	•	Selective receive by pattern and pinning (lines 2681–2683).

Essential Code Snippets

# timeout (lines 1760–1763)
parent = self()
pid = spawn(fn -> send(parent, {:result, 6*7}) end)
receive do {:result, r} -> r after 1000 -> :timeout end

# selective receive on ^port (lines 2681–2683)
port = Port.open({:spawn, "python worker.py"}, [:binary, packet: 2])
receive do {^port, {:data, bin}} -> decode(bin) end

Tips & Pitfalls
	•	Avoid :timer.sleep to sync. Prefer monitors and timeouts (lines 1774–1776).

Exercises Application
	•	Tests for after paths and selective patterns (lines 3144–3146).

Diagrams

receive … after t -> :timeout

Process loops and work pools

Key Concepts
	•	Tail-recursive loops hold state and re-enter after each message (lines 1431–1439).
	•	Work pools distribute compute and reply to clients (lines 1477–1479).

Essential Code Snippets

# loop skeleton (lines 1431–1439)
def do_work do
  receive do
    {:compute, x, pid} -> send(pid, {:result, x*x})
    {:exit, reason} -> exit(reason)
  end
  do_work()
end

Tips & Pitfalls
	•	Keep loops fast; avoid blocking in server code (lines 1271, 2844).

Exercises Application
	•	Build FIFO scheduler + workers. Queue Fibonacci jobs. Observe ordering (lines 1464–1466).

Diagrams

Work pool (lines 1477–1479)
Queue → Scheduler → [Worker1 | Worker2 | …] → replies to client

Cross-Chapter Checklist
	•	spawn, spawn_link, spawn_monitor used appropriately (lines 1418, 1429–1445).
	•	All receives have a timeout or monitor (after, :DOWN) (lines 1760–1763, 1444–1445).
	•	Loops are tail-recursive and fast; heavy work delegated (lines 1431–1439, 1271).
	•	Mailbox growth watched; no sleeps; backpressure at edges (lines 1080, 1241, 2844).

Quick Reference Crib

Parent PID    : parent = self()
Spawn         : spawn(fn -> send(parent, msg) end)
Link/Monitor  : spawn_link mod, fun, args | {pid, ref} = spawn_monitor(fun)
Receive       : receive do pat -> action after t -> :timeout end
Selective recv: receive do {^port, {:data, bin}} -> decode(bin) end
Loop          : receive → handle → recurse
Diagrams      :
  Parent ⇆ Child   (link)
  Parent ←DOWN Child  (monitor)
  Queue → Scheduler → [W1|W2|…] → replies


---

## Drills


Phase 2 Drills

Core Skills to Practice
	•	Build a mailbox-driven KV server loop with receive ... after timeouts. Prove invariants and handle crashes.    
	•	Use spawn, spawn_link, and spawn_monitor; understand links vs monitors and :DOWN messages.    
	•	Practice selective receive patterns and timeouts.    
	•	Manage process lifecycle with tail-recursive state loops and explicit exits.  
	•	Reference patterns: heartbeat monitor and work pool.    

Exercises
	1.	Mailbox KV with timeouts
	•	Implement start/0, put/3, get/2 using a loop that stores state in a map; add idle after to return :timeout. Crash the server intentionally and observe behavior.
	•	Expected: No lost put/get under interleavings; timeout path covered by tests.    
	2.	Selective receive scheduler
	•	Send mixed messages {:job, ...}, {:prio_job, ...}, :tick. Handle priority first via selective receive, then normal queue, with after for idle work.
	•	Expected: Priority jobs always handled first; idle ticks fire reliably.  
	3.	Link vs monitor demo
	•	Write a worker that can be started linked or monitored. Kill it with different exit reasons. Capture :EXIT propagation when linked and {:DOWN, ref, ...} when monitored.
	•	Expected: Linked parent exits on crash; monitored parent stays up and logs :DOWN.    
	4.	Spawn patterns and parent capture
	•	Show incorrect self() usage inside the spawned function, then fix by capturing parent = self() before spawn. Add test proving messages reach the parent.
	•	Expected: Fixed version delivers all replies to parent; no stray messages.    
	5.	Heartbeat monitor
	•	Process A sends {:heartbeat, now} every 250 ms. Process B monitors A and also expects heartbeats; if no heartbeat within 1 s or if it receives :DOWN, raise an alert.
	•	Expected: B detects both silent stalls and process death via monitor.  
	6.	Mini work pool
	•	Build FIFO queue + N workers. Scheduler does selective receive to prefer {:job, ...} over :tick. Collect results and verify ordering and throughput.
	•	Expected: All jobs processed; ordering and CPU behavior match pool diagram.  

Common Pitfalls
	•	Sleeping to synchronize; allow messages and timeouts to drive flow.  
	•	Unbounded mailboxes; introduce backpressure or admission control.  
	•	Blocking work inside a server loop. Offload heavy work.  
	•	Calling self() inside spawned functions instead of capturing the parent PID first.  

Success Criteria
	•	Mailbox KV passes invariants: no lost put/get under interleavings; timeout path covered.  
	•	Demonstrated selective receive and after handling under load.  
	•	Clear understanding of link vs monitor with proof via :EXIT and {:DOWN, ...} cases.  
	•	Implemented heartbeat monitor and a working FIFO work pool per examples.    

