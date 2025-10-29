# Phase 4 — Naming & Fleets

Manage dynamic process pools with Registry and DynamicSupervisor.

## Books
- **Adopting Elixir** (Marx, Valim, Tate)

## Docs
- **Registry**
  https://hexdocs.pm/elixir/Registry.html

- **DynamicSupervisor child specs/strategy**
  https://hexdocs.pm/elixir/DynamicSupervisor.html#module-child-processes

## Supplements
- **Registry explainer**
  https://elixirschool.com/en/lessons/advanced/otp-dispatch---

================================================================================

Adopting Elixir — Phase 4 (Naming & Fleets) Summary

Outline
	•		1.	Team changes for functional adoption【 】
	•		2.	Code for consistency【 】
	•		3.	Legacy systems【 】
	•		4.	Making the functional transition【 】
	•		5.	Distributed Elixir【 】
	•		6.	Integrating with external code【 】
	•		7.	Coordinating deployments【 】
	•		8.	Metrics and performance【 】
	•		9.	Production readiness【 】

Chapter/Section Summaries

4) Making the Functional Transition

Key Concepts
	•	Use Registry for process names, not global atoms. Route by key with via tuples.【 】【 】
	•	Spawn on demand with DynamicSupervisor; keep fleets stable under churn.【 】【 】
	•	Keep GenServer callbacks thin and fast; delegate to pure core.【 】【 】
	•	Avoid global names. It is a review rubric item.【 】

Essential Code Snippets

def via(id), do: {:via, Registry, {My.Registry, id}}

【 】

children = [
  {Registry, keys: :unique, name: My.Registry},
  {DynamicSupervisor, name: My.Dynamic, strategy: :one_for_one}
]
Supervisor.start_link(children, strategy: :one_for_one, name: My.Supervisor)

【 】

defmodule Islands.GameServer do
  use GenServer

  def start_link(game_id),
    do: GenServer.start_link(__MODULE__, %Game{id: game_id}, name: via(game_id))

  @impl GenServer
  def init(game), do: {:ok, game}

  def place_island(id, player, type, origin),
    do: GenServer.call(via(id), {:place, player, type, origin})

  @impl GenServer
  def handle_call({:place, p, t, origin}, _from, game) do
    case Game.place_island(game, p, t, origin) do
      {:ok, g} -> {:reply, :ok, g}
      {:error, r} -> {:reply, {:error, r}, game}
    end
  end
end

【 】

# start a game on demand
DynamicSupervisor.start_child(Islands.GameSupervisor, {Islands.GameServer, game_id})

【 】

Tips & Pitfalls
	•	Keep callbacks thin; push logic to pure modules.【 】
	•	Keep callbacks fast; offload heavy work.【 】
	•	Do not use global names; always Registry + via.【 】

Exercises Application
	•	Build apps/fleet with unique Registry, per-kind DynamicSupervisors, and via(id) routing. Names must release on crash; lookups stable under churn.【 】【 】

Diagrams

Supervisor
 ├─ Registry
 └─ DynamicSupervisor
     └─ GameServer(game_id)*

【 】

⸻

5) Distributed Elixir

Key Concepts
	•	Prepare for sharding by consistent hash; remote calls continue to use {via, Registry, …}. Reconcile ownership after node events.【 】

Essential Code Snippets

def via(id), do: {:via, Registry, {My.Registry, id}}

【 】

Tips & Pitfalls
	•	Avoid chatty cross-node protocols; ensure idempotency for distributed calls.【 】

Exercises Application
	•	Later, shard per user_id by hash ring and route via Registry across nodes. Add reconciliation on netsplit heal.【 】

Diagrams

Request → via(Registry,key) → Worker(key) → Repo/ETS
DynamicSupervisor spawns on demand. Supervisor restarts.

【 】

Cross-Chapter Checklist
	•	Register all workers with {:via, Registry, {My.Registry, key}}; never global atoms.【 】【 】
	•	Use DynamicSupervisor for on-demand fleets; one per worker kind if needed.【 】
	•	Acceptance: names release on crash; lookups stable under churn. Prove with soak tests.【 】
	•	Route all client API through via(key) helpers; keep public API small.【 】
	•	Plan for consistent hashing when moving to clusters; add reconciliation tasks.【 】【 】

Quick Reference Crib

# Name lookup
def via(id), do: {:via, Registry, {My.Registry, id}}

# Supervision
children = [
  {Registry, keys: :unique, name: My.Registry},
  {DynamicSupervisor, name: My.Dynamic, strategy: :one_for_one}
]

# Route calls
GenServer.call(via(user_id), {:op, args})

# Fleet diagram
App
 └─ Supervisor
    ├─ Registry
    └─ DynamicSupervisor
        └─ GenServer(worker_id)*

【 】【 】【 】


---

## Drills


Phase 4 Drills

Core Skills to Practice
	•	Start N workers keyed by user_id under Registry + DynamicSupervisor.  
	•	Route calls using via/1 tuples.  
	•	Crash a worker and prove the name is released and lookups stay stable under churn.  
	•	Implement consistent hashing to shard user_id to worker keys.  

Exercises
	1.	Fleet bootstrap: Registry + DynamicSupervisor
	•	Create a unique registry and a dynamic supervisor. Start N user workers.

# application tree
children = [
  {Registry, keys: :unique, name: My.Registry},
  {DynamicSupervisor, strategy: :one_for_one, name: My.Dynamic}
]
Supervisor.start_link(children, strategy: :one_for_one, name: My.Supervisor)

defmodule My.UserWorker do
  use GenServer
  def start_link(user_id),
    do: GenServer.start_link(__MODULE__, user_id, name: via(user_id))

  defp via(id), do: {:via, Registry, {My.Registry, id}}
  # callbacks elided
end

def start_users(user_ids) do
  Enum.each(user_ids, fn id ->
    DynamicSupervisor.start_child(My.Dynamic, {My.UserWorker, id})
  end)
end

	•	Expected: N processes registered by user_id and addressable by via/1.  

	2.	Routing via via/1
	•	Implement a public API that resolves the target by via/1.

defmodule My.Users do
  def via(id), do: {:via, Registry, {My.Registry, id}}
  def ping(id), do: GenServer.call(via(id), :ping)
end

	•	Expected: Calls succeed without tracking PIDs.  

	3.	Restart cleans names
	•	Test that a crash frees the name and re-registration occurs on restart.

# get pid from Registry, then kill
[{pid, _}] = Registry.lookup(My.Registry, user_id)
Process.exit(pid, :kill)

# await cleanup
Process.sleep(50)
assert Registry.lookup(My.Registry, user_id) == []

# supervisor restarts child with same name
Process.sleep(100)
assert match?([{_new_pid, _}], Registry.lookup(My.Registry, user_id))

	•	Expected: Lookup empty after crash, then exactly one registration after restart.  

	4.	Consistent hashing for sharding
	•	Map user_id to one of K shard keys with Rendezvous hashing. Use shard key as the via/1 id or as a prefix for per-shard workers.

def pick_shard(user_id, shard_ids) do
  Enum.max_by(shard_ids, fn sid -> :erlang.phash2({user_id, sid}) end)
end

def route(user_id) do
  shard = pick_shard(user_id, 0..(K-1))
  {:via, Registry, {My.Registry, {:shard, shard}}}
end

	•	Expected: Stable routing with minimal movement when K changes; calls go to the shard worker chosen by hash.  

Common Pitfalls
	•	Using global atoms for names instead of Registry unique keys.  
	•	Forgetting to supervise the Registry before workers.  
	•	Manual Registry.register/3 while also naming via {:via, Registry, …}. Use one pattern consistently.  
	•	Naive modulo hashing causing high churn when shard count changes; prefer Rendezvous.  

Success Criteria
	•	N workers started and registered by user_id under Registry + DynamicSupervisor.  
	•	All public calls resolve via via/1 without PID handling.  
	•	Crash test proves names are released; soak test shows stable lookups under churn.  
	•	Consistent hashing in place; routing stable across shard changes.  

