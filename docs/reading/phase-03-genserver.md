# Phase 3 — GenServer + Supervision

Build fault-tolerant stateful services with GenServer and supervisors.

## Books
- **Designing for Scalability with Erlang/OTP** (Cesarini & Vinoski)

## Docs
- **DynamicSupervisor**
  https://hexdocs.pm/elixir/DynamicSupervisor.html

- **OTP behaviours/supervision**
  https://www.erlang.org/doc/design_principles/des_princ.html#behaviours and https://www.erlang.org/doc/design_principles/sup_princ.html

## Supplements
- **Boot patterns with DynamicSupervisor (discussion)**
  https://elixirforum.com/t/dynamicsupervisor-best-practices/15062---

================================================================================

Designing for Scalability with Erlang/OTP — Summary

Outline
	•	Foundations: processes, message passing, links, monitors, failure semantics.
	•	OTP behaviours: behaviours primer → gen_server → FSM (gen_statem) → gen_event.
	•	Fault-tolerance scaffolding: supervisors and strategies.
	•	Packaging and ops: applications, releases, hot upgrades.

Chapter/Section Summaries

Behaviours primer

Key Concepts
	•	Behaviours separate generic server logic from your callbacks; you implement init/handle_* while OTP supplies the shell.

Essential Code Snippets

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

Tips & Pitfalls
	•	Keep callbacks small and deterministic; prefer synchronous call only when a reply is needed.

Exercises Application
	•	Migrate hand-rolled servers into a behaviour with a thin API.

Diagrams

Proc A -> message -> Proc B   |   links/monitors define failure relationships


⸻

gen_server (client–server workhorse)

Key Concepts
	•	Encapsulates state; supports sync call, async cast, info messages; handles timeouts/system messages.

Essential Code Snippets

%%% api
start_link(Init) -> gen_server:start_link({local, ?MODULE}, ?MODULE, Init, []).
get(Key)         -> gen_server:call(?MODULE, {get, Key}).
put(Key, Val)    -> gen_server:cast(?MODULE, {put, Key, Val}).

%%% callbacks
init(Init) -> {ok, Init}.
handle_call({get, K}, _From, State) ->
  {reply, maps:get(K, State, undefined), State};
handle_cast({put, K, V}, State) ->
  {noreply, maps:put(K, V, State)};
handle_info(_Msg, State) -> {noreply, State}.

Tips & Pitfalls
	•	Do not perform long work in callbacks; watch mailbox growth and push backpressure to system edges.

Exercises Application
	•	Convert a service (e.g., frequency allocator) to gen_server with API, timeouts, error handling.

Diagrams

Client -> gen_server:call -> Server(state) -> reply


⸻

Supervisors (fault-tolerant trees)

Key Concepts
	•	Strategies: one_for_one, rest_for_one, one_for_all; restart intensity limits; isolate failures.

Essential Code Snippets

-behaviour(supervisor).
init(_) ->
  Children = [
    #{id => store, start => {store, start_link, []}, restart => permanent, type => worker},
    #{id => fsm,   start => {fsm_srv, start_link, []}, restart => transient, type => worker}
  ],
  {ok, {{one_for_one, 3, 10}, Children}}.

Tips & Pitfalls
	•	Don’t link workers directly; choose restart type intentionally: temporary | transient | permanent.

Exercises Application
	•	Build a supervision tree; simulate crashes; verify restart behavior.

Diagrams

Supervisor
 ├─ gen_server(store)
 └─ gen_statem(fsm_srv)


⸻

Cross-Chapter Checklist
	•	Pure helpers first; behaviours call them.
	•	Keep servers fast; move heavy work to workers; watch mailboxes.
	•	Design explicit state transitions; test illegal events.
	•	Build supervision trees; pick restart strategies intentionally.

Quick Reference Crib

[Pure funcs] -> [Callbacks]
gen_server/gen_statem/gen_event
     |
[Supervisor tree] --strategies--> recover
     |
[Application] -> [Release] -> [Hot upgrade via appup/relup]


⸻

Elixir in Action — OTP Chapters Summary

Outline
	•	Registering servers with via tuples and a process registry.
	•	Dynamic supervision for on-demand children.
	•	DynamicSupervisor basics: start_link, :one_for_one, start_child.

Chapter/Section Summaries

Registering servers with via tuples

Key Concepts
	•	Name GenServers through a ProcessRegistry using via tuples to avoid collisions across subsystems.

Essential Code Snippets

defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(name) do
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end

Tips & Pitfalls
	•	Use module-scoped keys in via tuples to prevent key collisions across different server types.

Exercises Application
	•	Register per-tenant or per-aggregate servers; fetch pids via a cache module before API calls.

Diagrams

Client -> Cache.server_process(name) -> via(Registry,{Server,name}) -> Server


⸻

Dynamic supervision for demand-driven children

Key Concepts
	•	Use DynamicSupervisor when child count is not known up front; start children with start_child/2.

Essential Code Snippets

defmodule Todo.Cache do
  def start_link() do
    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end
end

children = [
  {Registry, keys: :unique, name: My.Registry},
  {DynamicSupervisor, name: My.Dynamic, strategy: :one_for_one}
]
Supervisor.start_link(children, strategy: :one_for_one, name: My.Supervisor)

Tips & Pitfalls
	•	Do not name children that have multiple instances; rely on registry keys.

Exercises Application
	•	Convert a per-key cache to dynamic children; prove restart behavior by crashing one child.

Diagrams

App
 └─ Supervisor
     ├─ Registry
     └─ DynamicSupervisor
         └─ GenServer(worker_id)*


⸻

Thin callbacks + pure core pattern

Key Concepts
	•	Route GenServer calls to pure core and return new state; keep callbacks thin.

Essential Code Snippets

@impl GenServer
def handle_call({:place, p, t, origin}, _from, game) do
  case Game.place_island(game, p, t, origin) do
    {:ok, g}   -> {:reply, :ok, g}
    {:error, r}-> {:reply, {:error, r}, game}
  end
end

Diagrams

Client -> GenServer.call/cast -> pure core -> new_state -> reply


⸻

Timeouts and periodic work

Key Concepts
	•	Schedule periodic work by returning {:noreply, state, timeout}; avoid sleeps.

Essential Code Snippets

def handle_info(:tick, s), do: {:noreply, rotate(s), 5_000}


⸻

Supervision strategies, restart intensity, child specs

Key Concepts
	•	Strategy and intensity tune failure containment; pick restart type per child.

Essential Code Snippets

{ok, {{one_for_one, 3, 10}, Children}}.

Diagrams

Supervisor
 ├─ Registry
 └─ DynamicSupervisor
     └─ GameServer(game_id)*


⸻

Cross-Chapter Checklist
	•	Pure core, explicit outcomes; fast callbacks; supervise all stateful parts.
	•	Registry + DynamicSupervisor for fleets; monitor partial failure; retry idempotently.
	•	Instrument before tuning; releases use runtime config; document playbooks.

Quick Reference Crib

Functional Core  →  OTP Shell
Pure funcs       →  GenServer callbacks (thin)

Process naming:
client → via(Registry,id) → worker(id)

Supervision:
App
 └─ Supervisor
     ├─ Registry
     └─ DynamicSupervisor
         └─ GenServer*


---

## Drills


Phase 3 Drills

Core Skills to Practice
	•	Write thin GenServer callbacks that delegate to a pure core.
	•	Choose call vs cast correctly and set timeouts.
	•	Define child specs and restart intensity.
	•	Build supervision trees with :one_for_one and :rest_for_one.
	•	Implement :idle_timeout self-pruning.

Exercises
	1.	Port an ad-hoc loop to GenServer
Convert a receive loop server into a GenServer with a public API.

defmodule KvServer do
  use GenServer

  ## API
  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, %{}, opts)
  def get(pid, k),           do: GenServer.call(pid, {:get, k})
  def put(pid, k, v),        do: GenServer.cast(pid, {:put, k, v})

  ## Callbacks  (lines 2853–2854)
  def handle_call({:get, k}, _from, s),  do: {:reply, Map.get(s, k), s}
  def handle_cast({:put, k, v}, s),      do: {:noreply, Map.put(s, k, v)}
end

Expected: Same behavior as the loop version, with synchronous get/2, async put/3.

	2.	Add :idle_timeout self-pruning
Auto-stop when inactive for N ms.

def init(s), do: {:ok, Map.put(s, :touched_at, System.monotonic_time(:millisecond)), 5_000}

def handle_info(:timeout, s) do
  {:stop, :normal, s}  # idle → terminate under supervisor
end

def handle_call(req, from, s) do
  s = %{s | touched_at: System.monotonic_time(:millisecond)}
  handle_call_impl(req, from, s)
end

def handle_cast(msg, s) do
  s = %{s | touched_at: System.monotonic_time(:millisecond)}
  handle_cast_impl(msg, s)
end

Expected: Process exits normally after inactivity; any supervisor restarts per strategy.

	3.	Supervision trees: :one_for_one vs :rest_for_one
Build both and observe differences.

defmodule TreeOneForOne do
  use Supervisor
  def start_link(a), do: Supervisor.start_link(__MODULE__, a, name: __MODULE__)
  def init(_),
    do: Supervisor.init(
          [
            {KvServer, name: :a},
            {KvServer, name: :b}
          ],
          strategy: :one_for_one, max_restarts: 3, max_seconds: 5
        )
end

defmodule TreeRestForOne do
  use Supervisor
  def start_link(a), do: Supervisor.start_link(__MODULE__, a, name: __MODULE__)
  def init(_),
    do: Supervisor.init(
          [
            {KvServer, name: :a},  # upstream
            {KvServer, name: :b}   # downstream
          ],
          strategy: :rest_for_one, max_restarts: 3, max_seconds: 5
        )
end

Expected:
	•	In :one_for_one, crashing :a restarts only :a.
	•	In :rest_for_one, crashing :a restarts :a and then :b.

	4.	Crash and observe restart behavior
Add a deliberate crash path and watch supervisor policy apply.

def handle_cast(:crash, s), do: 1/0 && {:noreply, s}

Steps:
	•	Start each tree.
	•	GenServer.cast(:a, :crash).
	•	Verify which children restart under each strategy and that restart intensity limits are honored.
Expected: Correct child restarts per strategy; supervisor stops if restart frequency exceeds limits.

Common Pitfalls
	•	Heavy work inside callbacks.
	•	Missing restart intent (wrong child :restart type).
	•	No backoff on restarts.
(lines 2857)

Success Criteria
	•	GenServer wraps the former loop with thin callbacks and pure core.
	•	:idle_timeout causes clean self-prune without orphan resources.
	•	Supervision trees run with documented child specs and restart intensity.
	•	Demonstrated difference between :one_for_one and :rest_for_one by crashing a child and recording observed restarts.
	•	No blocking I/O or long CPU in callbacks; long work is offloaded.

