# Phase 9 — Distribution (Clustering, PubSub, Horde)

Scale across multiple nodes with clustering and distributed processes.

## Books
- **Designing for Scalability with Erlang/OTP** — distribution chapters

## Docs
- **libcluster**
  https://hexdocs.pm/libcluster/readme.html

- **Phoenix.PubSub**
  https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html

- **Horde**
  https://hexdocs.pm/horde/readme.html

## Supplements
- **Clustering on Fly.io (practical guide)**
  https://fly.io/phoenix-files/clustering/---

================================================================================

Designing for Scalability with Erlang/OTP — Distribution Summary

Outline
	•	Erlang nodes, naming, and visibility.  
	•	Distributed Erlang: fully meshed clusters, scaling limits, RPC and net_kernel bottlenecks, hidden nodes.  
	•	Node types, families, and distributed architectural patterns; SD Erlang and Riak Core.  
	•	Remote shell and safe ops over distribution.  
	•	Monitor nodes and connectivity.  

Chapter/Section Summaries

Node Connections and Visibility

Key Concepts
	•	Location transparency. Processes behave the same across nodes.  
	•	Elasticity by adding/removing nodes at runtime.  
	•	Hidden nodes for isolation and scalability.  

Essential Code Snippets

# Start named IEx nodes with a shared cookie
# Terminal 1
iex --sname a --cookie secret -S mix
# Terminal 2
iex --sname b --cookie secret -S mix

# Connect and list nodes
Node.connect(:"a@host")      # => true | false
Node.list()                  # => [:"a@host"]

Tips & Pitfalls
	•	Fully meshed clusters scale roughly to ~70–100 nodes; beyond that, overhead from TCP links, heartbeats, rex, and net_kernel grows.  
	•	Prefer registered names over raw PIDs across nodes; monitor remote nodes to avoid PID reuse hazards after restarts.  

Exercises Application
	•	Spin up two local nodes, connect, and verify Node.list/0. Add a third as hidden and observe visibility changes.

Diagrams

Node A (@host1)  <—— TCP + heartbeat ——>  Node B (@host2)
         ^  rex RPC, net_kernel spawn  v
          \——— message passing (mailboxes) ——/

Distributed Erlang: Mesh and Scaling

Key Concepts
	•	Fully connected mesh by default; connection metadata propagates to new nodes that share a cookie.  
	•	Scaling trade-offs; when to consider hidden nodes or frameworks like Riak Core / SD Erlang.  

Essential Code Snippets

# Detect cluster membership changes
:net_kernel.monitor_nodes(true)
flush()
# => {:nodeup, :"a@host"} | {:nodedown, :"a@host"}

Tips & Pitfalls
	•	Heartbeat congestion and RPC bottlenecks manifest under heavy traffic. Plan topology, not only code paths.  

Exercises Application
	•	Add churn: start/stop nodes; capture {:nodeup, _}/{:nodedown, _} events and reconcile shard ownership.

Diagrams

           Fully Meshed (3 nodes)
     A <————> B
      \       ^
       v     /
         C
TCP links = 3 total; heartbeats on each link

Remote Ops and Remsh

Key Concepts
	•	Safe remote shell to troubleshoot nodes; commands execute on remote VM.  

Essential Code Snippets

erl -sname bar -remsh foo@ramone -setcookie abc123
# All commands run on foo@ramone. Exit with Ctrl-C a, not q().

Tips & Pitfalls
	•	Never halt() from remsh unless you intend to terminate the remote node.  

Exercises Application
	•	Use -remsh to attach to a failing node; inspect nodes() and app status.

Diagrams

Local shell (bar@ramone)  ——— remsh ———>  Remote node (foo@ramone)
           commands execute here           results printed back

Node Types, Families, and Patterns

Key Concepts
	•	Classify nodes by role; compose clusters for services, sharding, and scale.  
	•	SD Erlang s_groups reduce connectivity and namespace scope.  

Essential Code Snippets

# Process discovery via global name (simple baseline)
:global.register_name({:worker, 42}, self())
:global.whereis_name({:worker, 42})

Tips & Pitfalls
	•	Choose naming scope deliberately. Global registries replicate across visible nodes; consider topology size and failure modes.  

Exercises Application
	•	Register cross-node workers; simulate a node crash; confirm re-registration on recovery.

Diagrams

G1: [A, B, C]   G2: [C, D, E]
C is a gateway between s_groups G1 and G2



Cross-Chapter Checklist
	•	Use named nodes and shared cookies for connectivity. Monitor node up/down.  
	•	Keep meshes modest; consider hidden nodes or frameworks when > ~70–100 nodes.  
	•	Avoid remote PID reliance without monitoring; prefer names plus monitors.  
	•	Troubleshoot with -remsh; exit safely.  

Quick Reference Crib

# Start nodes
iex --sname a --cookie secret
iex --sname b --cookie secret

# Connect + list
Node.connect(:"a@host")
Node.list()

# Monitor cluster
:net_kernel.monitor_nodes(true)
# => {:nodeup, n} | {:nodedown, n}

# Global discovery
:global.register_name(:svc, self())
:global.whereis_name(:svc)

Adopting Elixir — Distributed Elixir (Ops View) Summary

Outline
	•	Distributed Erlang connectivity: TCP, cookies, full mesh, optional encryption.  
	•	Heartbeats (ticktime) and overload cautions.  
	•	Node naming, EPMD lookup, port planning.  
	•	Securing and operating clusters without EPMD; fixed port approach.  
	•	Integrating non-BEAM nodes (JInterface example).  

Chapter/Section Summaries

Connectivity, Cookies, and Mesh

Key Concepts
	•	Nodes connect over TCP and require the same cookie. Full mesh by default; add encryption when needed.  

Essential Code Snippets

# Remote calls and spawns
:rpc.call(:"b@host", :erlang, :node, [])  # remote node() via rex
Node.spawn(:"b@host", fn -> IO.puts("hi from B") end)

(rex handles RPC; net_kernel handles remote spawns.)  

Tips & Pitfalls
	•	Large payloads can delay heartbeats; throttle cross-node bulk transfers.  

Exercises Application
	•	Benchmark :rpc.call/4 vs local calls; measure impact under network load.

Diagrams

A (cookie=K)  <—— TCP ——>  B (cookie=K)
        heartbeat/ticktime over same socket



Naming, EPMD, and Ports

Key Concepts
	•	Node names may use hostnames or IPs; require proper name resolution.  
	•	EPMD maps names→ports on 4369; cookie not used for EPMD queries; plan exposure.  
	•	Constrain dynamic distribution ports or fix one port and skip EPMD.  

Essential Code Snippets

# Constrain Erlang distribution ports
elixir --erl "-kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200"



Tips & Pitfalls
	•	Public EPMD leaks names and ports; enforce network policy and cookie secrecy.  

Exercises Application
	•	Run with fixed ports; verify epmd -names; connect from a second host.

Diagrams

Client → EPMD@host:4369 → {name,port}
                ↓
          Node accepts if cookie matches



Integrating External Runtimes

Key Concepts
	•	Non-BEAM nodes (Java) can participate via JInterface and the common cookie.  

Essential Code Snippets

# From IEx connect to a Java node
Node.connect(:"java@macbook")
send {:echo, :"java@macbook"}, {self(), "hello"}
flush()  # => {#PID<...>, "hello"}



Tips & Pitfalls
	•	Ensure JVM node registers with EPMD and shares cookie file.  

Exercises Application
	•	Build a Java echo server; exchange messages from IEx.

Diagrams

Elixir node ——— TCP/EPMD ——— Java node
 cookie K                        cookie K

Cross-Chapter Checklist
	•	Same cookie, planned ports, optional TLS.  
	•	Keep heartbeats reliable; avoid saturating the link.  
	•	Document EPMD exposure; pin distribution ports in ops.  

Quick Reference Crib

# Nodes and EPMD
epmd -names
iex --sname a --cookie K
Node.connect(:"b@host")
:rpc.call(:"b@host", Mod, :fun, [args])

Phase 9 Focus Addenda

Process Discovery Across Nodes

# Cross-node name via :global (baseline)
:global.register_name({:svc, key}, self())
:global.whereis_name({:svc, key})   # -> pid | :undefined

Use monitors with remote names; re-register on restart to avoid stale routes.  

libcluster Autodiscovery Patterns

# mix.exs deps
{:libcluster, "~> 3.3"}

# config/runtime.exs
config :libcluster,
  topologies: [
    gossip: [strategy: Cluster.Strategy.Gossip],
    k8s: [
      strategy: Cluster.Strategy.Kubernetes,
      config: [mode: :dns, kubernetes_selector: "app=myapp"]
    ]
  ]

Use gossip for bare-metal or simple LAN. Use Kubernetes strategy with headless Services for DNS-based discovery.

Consistent Hashing for Sharding

def pick_node(key, nodes) do
  i = :erlang.phash2(key, length(nodes))
  nodes |> Enum.sort() |> Enum.at(i)
end

Pair with monitors to redistribute keys on {:nodedown, n}. Measure rebalancing.

Network Partition Handling and Split-Brain
	•	Monitor nodes; degrade writes or switch to quorum paths on :nodedown.  
	•	Mesh clusters have scaling and heartbeat costs; consider hidden nodes as gateways or layered topologies.  
	•	Plan for cloud partitions; expect slower instances and busier networks.  

Remote Calls and Spawns

:rpc.call(:"b@host", MyRPC, :do, [arg1])      # via rex
Node.spawn(:"b@host", fn -> MySrv.ping() end) # via net_kernel

RPCs and remote spawns centralize on single subsystems; profile under load.  

Diagrams: Node A ↔ Node B

+-----------+                               +-----------+
|  Node A   |==== TCP (cookie K, ticktime)====|  Node B   |
|           |<——— messages / RPC / monitors ——>|           |
+-----------+                               +-----------+
   ^   ^                                          ^   ^
   |   |__ rex (RPC)                              |   |__ net_kernel (spawn/monitor)

Done.


---

## Drills


Phase 9 Drills

Core Skills to Practice
	•	Start two BEAM nodes with the same cookie and verify connectivity.  
	•	Dispatch work across nodes by consistent hash.  
	•	Lose a node and reconcile shard ownership on heal.  
	•	Measure message sizes and per-second rates between nodes.  
	•	Handle split-brain behavior during partitions.  

Exercises
	1.	Two-node cluster smoke test
	•	Start: iex --sname n1 --cookie demo -S mix, iex --sname n2 --cookie demo -S mix.
	•	Connect: Node.connect(:"n2@host") → true; :rpc.call(:"n2@host", Node, :self, []) returns a PID.
	•	Expected: Node.list() shows the peer; Node.ping(:"n2@host") == :pong.  
	2.	Consistent-hash dispatcher
	•	Build a ring mapping shard = :erlang.phash2(key, n_shards) → owner node.
	•	Route via {:via, Registry, {My.Registry, {shard, key}}} to shard workers.
	•	Expected: Stable key→node mapping; same key always hits same shard until membership changes.  
	3.	Node loss and reconciliation
	•	Kill one node. Reassign affected shards to survivors and drain in-flight work.
	•	On node return, rebalance to restore even ownership.
	•	Expected: Service continues during loss; ownership reconciles cleanly on heal.  
	4.	Measure wire load
	•	Wrap cross-node sends with a helper that records byte_size(:erlang.term_to_binary(msg)) and increments per-topic counters.
	•	Emit Telemetry events per message and per second; chart rates.
	•	Expected: Collected averages and p95 sizes; messages/sec per channel.  
	5.	Split-brain drill
	•	Induce partition between nodes (e.g., block traffic); keep both sides running.
	•	Enforce single-writer via quorum fencing or lease token; buffer reads or serve stale.
	•	On heal, reconcile by source-of-truth recheck and idempotent replay.
	•	Expected: No double writes during partition; deterministic reconciliation after heal.  

Common Pitfalls
	•	Chatty protocols increase latency and cost.  
	•	Assuming the network is reliable.  
	•	Non-idempotent cross-node calls.  

Success Criteria
	•	Two nodes connect and exchange RPC calls.  
	•	Requests are sharded by consistent hash with stable routing.  
	•	Killing a node does not interrupt service; shards reassign; on heal, ownership reconciles.  
	•	Message sizes and rates are measured and charted.  
	•	Split-brain scenario handled without double writes; reconciliation is deterministic.  

