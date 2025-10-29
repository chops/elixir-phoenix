# Phase 6 — Phoenix Web (LiveView + Channels + Presence)

Build interactive web applications with Phoenix, LiveView, and real-time features.

## Books
- **Functional Web Development with Elixir, OTP, and Phoenix** (Lance Halvorsen)

## Docs
- **LiveView welcome + behaviour**
  https://hexdocs.pm/phoenix_live_view/welcome.html and https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html

- **Phoenix Channels guide**
  https://hexdocs.pm/phoenix/channels.html

- **Phoenix Presence**
  https://hexdocs.pm/phoenix/Phoenix.Presence.html

## Supplements
- **LiveView getting-started tutorial**
  https://github.com/phoenixframework/phoenix_live_view/tree/main/guides/introduction---

================================================================================

Functional Web Development with Elixir, OTP, and Phoenix — Summary

Outline
	•	Part I. Functional core in Elixir: 1) Model data and behavior; 2) Finite State Machine (FSM).  
	•	Part II. OTP for concurrency and fault-tolerance: 3) GenServer; 4) Supervision and recovery.  
	•	Part III. Phoenix interface: 5) Phoenix app without Ecto; 6) Channels, Presence, auth; 7) “Phoenix is not your app.”  

Chapter/Section Summaries

1) Model data and behavior (pure Elixir)

Key Concepts
	•	Functional core first. No DB. Domain as structs and pure functions.  
	•	Game: two-player “Islands,” 10×10 boards, place islands, guess, win when opponent’s islands are forested.  

Essential Code Snippets

defmodule Islands.Coordinate do
  @enforce_keys [:row, :col]
  defstruct [:row, :col]
end

defmodule Islands.Game do
  def place_island(game, player, type, origin), do: ...
  def guess(game, player, coord), do: ...
  def winner?(game), do: ...
end



Tips & Pitfalls
	•	Keep functions total and side-effect free. Return {:ok, new_state} | {:error, reason}. Validate near inputs.  

Exercises Application
	•	Implement board, island shapes, placement rules, hit/forested checks. Test as pure functions.  

Diagrams

attrs -> validate -> transform(old_state) -> new_state



⸻

2) Manage state with a finite state machine (FSM)

Key Concepts
	•	Legal phases: :initialized → :players_set → :playing → :game_over. Keep rules explicit.  

Essential Code Snippets

def next(%Game{phase: :initialized}=g, {:set_islands, p}) when ready?(g, p),
  do: {:ok, %{g | phase: maybe_advance(g)}}

def next(%Game{phase: :playing}=g, {:guess, p, coord}),
  do: apply_guess(g, p, coord)



Tips & Pitfalls
	•	Reject illegal events by phase. Prefer guards and pattern matches. Keep FSM pure.  

Exercises Application
	•	Code next/2 transitions. Add per-phase tests. Assert illegal events error.  

Diagrams

initialized -> players_set -> playing -> game_over
      event: set_islands      event: both_set   event: win



⸻

3) Wrap the core in a GenServer

Key Concepts
	•	Hold game state in a process. Provide a small public API. Hide internals.  

Essential Code Snippets

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

  

Tips & Pitfalls
	•	Keep callbacks thin. Delegate to pure core. Use Registry or via tuples for names.  

Exercises Application
	•	Expose API for place/guess/set/winner. Add named per-game processes.  

Diagrams

Client -> GenServer.call/cast -> pure core -> new_state -> reply



⸻

4) Supervise for recovery

Key Concepts
	•	Supervision tree restarts crashed games. Use DynamicSupervisor for on-demand workers.  

Essential Code Snippets

children = [
  {Registry, keys: :unique, name: Islands.Registry},
  {DynamicSupervisor, name: Islands.GameSupervisor, strategy: :one_for_one}
]

DynamicSupervisor.start_child(Islands.GameSupervisor, {Islands.GameServer, game_id})



Tips & Pitfalls
	•	Persist minimal checkpoints only if required; otherwise reinitialize on restart.  

Exercises Application
	•	Build DynamicSupervisor. Start/stop games. Crash and verify restart.  

Diagrams

Supervisor
 ├─ Registry
 └─ DynamicSupervisor
     └─ GameServer(game_id)*



⸻

5) Generate a Phoenix interface (no Ecto)

Key Concepts
	•	Phoenix is just the interface. Core app is a separate dependency.  

Essential Code Snippets

mix phx.new islands_web --no-ecto
# islands_web/mix.exs
{:islands, path: "../islands"}  # or hex/git if split

# Ensure engine app starts under supervision boundary



Tips & Pitfalls
	•	Keep controllers/views thin. Call only GameServer public API. Do not leak %Plug.Conn{} into core.  

Exercises Application
	•	Wire routes and actions to start game, place islands, make guesses. Render JSON or minimal HTML.  

Diagrams

[Phoenix router/controller/view] -> [GameServer API] -> [pure core]



⸻

6) Phoenix Channels, Presence, authorization

Key Concepts
	•	Use topics per game: “game:ID”. Presence tracks players. Only two players may join their game.  

Essential Code Snippets

# user_socket.ex
channel "game:*", IslandsWeb.GameChannel

# game_channel.ex
def join("game:" <> id, %{"player" => who}, socket) do
  with :ok <- authorize(id, who) do
    {:ok, assign(socket, :game_id, id) |> assign(:player, who)}
  else _ -> {:error, %{reason: "unauthorized"}} end
end

def handle_in("place", %{"type" => t, "row" => r, "col" => c}, socket) do
  case GameServer.place_island(socket.assigns.game_id, socket.assigns.player, t, {r,c}) do
    :ok -> {:reply, :ok, socket}
    {:error, reason} -> {:reply, {:error, reason}, socket}
  end
end

# Presence
alias Phoenix.Presence
Presence.track(socket, socket.assigns.player, %{online_at: System.system_time(:second)})
push socket, "presence_state", Presence.list(socket)

  

Tips & Pitfalls
	•	Fail fast in join/3. Keep handlers small. Handle disconnects; Presence updates.  

Exercises Application
	•	Build channel, add join auth, track with Presence, connect to GameServer API.  

Diagrams

Client ↔ Socket ↔ Channel("game:ID") ↔ GameServer(id)
             Presence(list/track)



⸻

7) Project structure and applications

Key Concepts
	•	Compose separate OTP apps: islands (engine) and islands_web (Phoenix). Keep boundaries clean.  

Essential Code Snippets

# islands/application.ex
def start(_type, _args) do
  children = [
    {Registry, keys: :unique, name: Islands.Registry},
    {DynamicSupervisor, name: Islands.GameSupervisor, strategy: :one_for_one}
  ]
  Supervisor.start_link(children, strategy: :one_for_one, name: Islands.Supervisor)
end

# islands_web/application.ex
children = [IslandsWeb.Endpoint]  # engine brought in via dependency



Tips & Pitfalls
	•	Keep compile-time deps minimal across apps. Public API of engine should be stable.  

Exercises Application
	•	Declare engine as dependency. Ensure both apps start. Connect router/controllers or channels to engine calls.  

Diagrams

Umbrella or multi-app:
islands (engine)  <-- dependency --  islands_web (Phoenix)



Cross-Chapter Checklist
	•	Small pure core. FSM governs legal transitions. GenServer is a thin state holder. DynamicSupervisor for many games. Phoenix only at the edge. Presence for online users. No Ecto unless persistence is added later.  

Quick Reference Crib

Pure Core: structs+funcs -> FSM(next/2)
OTP: Core in GenServer -> DynamicSupervisor -> Registry
Web: Router/Channel -> call GameServer -> broadcast
Presence: track/list per topic



Progression Diagram (core → OTP → Phoenix)

[Pure functions & structs]
        ↓
   [FSM next/2]
        ↓
[GenServer wrapper]  → [Registry names]
        ↓
[DynamicSupervisor tree]
        ↓
[Phoenix Router/Channel] ↔ [GameServer API] ↔ [Core]
                 + Presence(list/track)

        

Done.


---

## Drills


Phase 6 Drills

Core Skills to Practice
	•	Build a LiveView CRUD with optimistic UI.  
	•	Add a Phoenix Channel and Presence.  
	•	Add rate limits at the edge.  
	•	Keep controllers thin.  

Exercises
	1.	Orders LiveView CRUD
Implement create/read/update/delete in a LiveView with optimistic updates; show list updates without full reload.  
	2.	Realtime Channel + Presence
Create topic orders:*, broadcast order events, and show online users via Presence.  
	3.	Edge Rate Limiting
Add request-rate limits at the edge for write endpoints; document thresholds and failure response.  
	4.	Thin Controllers
Refactor controllers to delegate to contexts only; no business logic in controllers or templates.  

Common Pitfalls
	•	Fat controllers.  
	•	External calls in tests.  

Success Criteria
	•	E2E tests pass for HTML, JSON, and Channel flows.  
	•	Two clients visible via Presence on the same topic.  
	•	Edge rate limits enforced and logged.  
	•	Controllers contain no business logic; contexts own behavior.  

