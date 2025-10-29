# Phase 8 — Caching & ETS

High-performance in-memory caching with ETS.

## Books
- **Designing for Scalability with Erlang/OTP** — ETS usage

## Docs
- **:ets module reference**
  https://www.erlang.org/doc/man/ets.html

## Supplements
- **ETS primer (Elixir School)**
  https://elixirschool.com/en/lessons/storage/ets

- **Learn You Some Erlang — ETS**
  https://learnyousomeerlang.com/ets---

================================================================================

Designing for Scalability with Erlang/OTP — ETS Usage Summary

Outline
	•	Foundations, OTP behaviours, supervision, packaging, distribution, scaling, operations.
	•	Phase 8 targets for ETS: shared read store, writer process, read/write concurrency, TTL eviction.
	•	Phase 8 milestone scope: read-through cache, TTL sweeper, Benchee benches; single writer GenServer; read_concurrency. Acceptance: ≥2× faster p95.

Chapter/Section Summaries

ETS in OTP systems

Key Concepts
	•	Use ETS for fast in-node shared reads. Pair with a writer process.
	•	Place ETS in the broader OTP context: supervision, scaling, and operations.

Essential Code Snippets

# Create named, public ETS table for shared reads
:ets.new(:cache, [:set, :named_table, :public, read_concurrency: true])

Tips & Pitfalls
	•	Keep ETS ownership clear. One writer process. Readers do not mutate.

Exercises Application
	•	Build apps/cache with read-through semantics and single writer.

Diagrams

Readers →→→ :cache (ETS named table)
              ↑
           Writer (GenServer owner)


⸻

Table types and selection

Key Concepts
	•	Default :set. Others: :ordered_set, :bag, :duplicate_bag (choose per key semantics). (see “table types” refs)

Essential Code Snippets

# Bag example: one key, many values (from notes)
:ets.new(:todo_list, [:bag])
:ets.insert(:todo_list, {"friday", "trash"})
:ets.insert(:todo_list, {"friday", "dishes"})
:ets.lookup(:todo_list, "friday")
# => [{"friday","trash"},{"friday","dishes"}]

Tips & Pitfalls
	•	Pick the table type that matches cardinality and ordering needs. Avoid emulating bags on sets.

Exercises Application
	•	If a key maps to multiple cached items, prefer :bag or :duplicate_bag.

Diagrams

:set          K → V
:ordered_set  K (ordered) → V
:bag          K → [V1,V2,...]
:dup_bag      K → [V1,V1,V2,...]


⸻

Read/Write concurrency flags

Key Concepts
	•	read_concurrency improves concurrent reads; write_concurrency helps multi-writer patterns but prefer a single writer for caches.

Essential Code Snippets

:ets.new(:cache, [
  :set, :named_table, :public,
  read_concurrency: true, write_concurrency: false
])

Tips & Pitfalls
	•	Turn on write_concurrency only if you truly have safe multi-writer patterns; otherwise keep one writer GenServer.

Exercises Application
	•	For Phase 8 labs, keep one writer and enable read_concurrency.

Diagrams

Readers (many) ──fast──> ETS
Writer (one)   ──safe──> ETS


⸻

Writer process pattern

Key Concepts
	•	ETS table owned by a GenServer. All mutations go through that GenServer. Readers access ETS directly.

Essential Code Snippets

defmodule Cache.Writer do
  use GenServer
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def put(k, v, ttl_ms), do: GenServer.cast(__MODULE__, {:put, k, v, ttl_ms})

  @impl true
  def init(_), do: (:ets.new(:cache, [:set, :named_table, :public, read_concurrency: true]); {:ok, %{}})

  @impl true
  def handle_cast({:put, k, v, ttl}, s) do
    exp = System.monotonic_time(:millisecond) + ttl
    :ets.insert(:cache, {k, v, exp})
    {:noreply, s}
  end
end

(aligns with “single writer GenServer” lab spec)

Tips & Pitfalls
	•	Do not let random processes write. Avoid orphaned named tables after restarts.

Exercises Application
	•	Place writer under supervision. Verify table owner restarts cleanly.

Diagrams

Client → Cache.Writer (GenServer) → :ets.insert
Client → :ets.lookup(:cache, k)


⸻

Read-through cache and TTL eviction

Key Concepts
	•	Read-through: lookup → miss → fetch from Repo → insert → return.
	•	TTL eviction: store expires_at; sweep periodically.

Essential Code Snippets

def fetch(k, fetch_fun, ttl_ms) do
  now = System.monotonic_time(:millisecond)
  case :ets.lookup(:cache, k) do
    [{^k, v, exp}] when exp > now -> {:hit, v}
    _ ->
      v = fetch_fun.()
      Cache.Writer.put(k, v, ttl_ms)
      {:miss, v}
  end
end

# periodic sweeper
@interval 5_000
def handle_info(:sweep, s) do
  now = System.monotonic_time(:millisecond)
  :ets.select_delete(:cache, [{{:"$1", :"$2", :"$3"}, [{:<, :"$3", now}], [true]}])
  Process.send_after(self(), :sweep, @interval)
  {:noreply, s}
end

(“TTL eviction via handle_info” per Phase 8)

Tips & Pitfalls
	•	Sweeper in owner process. Keep the match spec tight. Avoid long sweeps in one GC cycle.

Exercises Application
	•	Implement read-through flow and verify hits vs misses under load.

Diagrams

get(k)
 ├─ hit → return v
 └─ miss → Repo.get → insert(k,v,exp) → return v


⸻

Benchmarking with Benchee

Key Concepts
	•	Add micro-benchmarks and p50/p95/p99 tracking. Record before/after charts.

Essential Code Snippets

Benchee.run(%{
  "repo_get" => fn -> Repo.get(Item, 42) end,
  "cache_get" => fn -> fetch({:item, 42}, fn -> Repo.get!(Item, 42) end, 60_000) end
})

(bench requirement and metrics capture)

Tips & Pitfalls
	•	Benchmark in isolation. Label scenarios clearly. Track percentiles.

Exercises Application
	•	Prove ≥2× p95 improvement on hot read path.

Diagrams

Benchee → scenarios(repo_get | cache_get) → p50/p95/p99 → docs/perf/cache.md


⸻

When to use ETS vs Mnesia vs external cache

Key Concepts
	•	Choose persistence explicitly: ETS (in-memory), Mnesia, or external DB/cache.

Essential Guidance
	•	ETS: per-node, ultra-fast reads, ephemeral, owned by a process; ideal read-through caches.
	•	Mnesia: in-VM distributed transactional store when you need transactions and replication. (selection call-out)
	•	External cache/DB: cross-language, cross-cluster, or durable needs; pays network hop.

Tips & Pitfalls
	•	Don’t use ETS as a primary store. Be explicit about failure and cache invalidation.

Exercises Application
	•	For Phase 8, stick with ETS. Reserve Mnesia or external systems for later phases.

Diagrams

request → ETS (fast, local)
         ↘ miss → DB/external → fill ETS → return


⸻

Canonical ETS operations

Key Concepts
	•	Minimal API surface: :ets.new/2, :ets.insert/2, :ets.lookup/2.

Essential Code Snippets

:ets.new(:cache, [:set, :named_table, :public, read_concurrency: true])
:ets.insert(:cache, {"friday", "trash"})
:ets.lookup(:cache, "friday")

(from notes’ bag example; API identical for sets)

Tips & Pitfalls
	•	Always create the table in the writer’s init/1. Ensure table exists before first read.

Exercises Application
	•	Add a startup check that table exists and owner is alive.

Diagrams

init → ets.new
cast/put → ets.insert
get      → ets.lookup


⸻

Cross-Chapter Checklist
	•	Single writer GenServer owns ETS table.
	•	read_concurrency: true set; verify reader-only code paths.
	•	TTL stored alongside value; periodic sweeper removes expired rows.
	•	Benchee micro-benchmarks committed; p50/p95/p99 recorded.
	•	No multi-writer mutations; no leaked named tables across restarts.
	•	Document persistence choice: ETS vs Mnesia vs external.

Quick Reference Crib

# Create table
:ets.new(:cache, [:set, :named_table, :public, read_concurrency: true])

# Insert with TTL
exp = System.monotonic_time(:millisecond) + ttl_ms
:ets.insert(:cache, {key, val, exp})

# Lookup with TTL check
case :ets.lookup(:cache, key) do
  [{^key, v, exp}] when exp > now -> {:hit, v}
  _ -> :miss
end

# Sweep expired
:ets.select_delete(:cache, [{{:"$1", :"$2", :"$3"}, [{:<, :"$3", now}], [true]}])

# Table types (pick per need)
:set | :ordered_set | :bag | :duplicate_bag

(aligns with Phase 8 targets and labs)


---

## Drills


Phase 8 Drills

Core Skills to Practice
	•	Replace a hot Repo.get/2 path with an ETS read-through cache.
	•	Select ETS options: :set, :public, :named_table, read_concurrency: true, write_concurrency: true.
	•	Use a single writer process pattern; readers hit ETS directly.
	•	Implement TTL eviction using expires_at and periodic sweeps with :ets.select_delete/2.
	•	Benchmark and compare p50/p99 latency before vs after using Benchee.

Exercises
	1.	Read-through cache for hot lookup
	•	Create table on app start:

# in your Application.start/2
:ets.new(:users_cache, [:set, :public, :named_table,
                        read_concurrency: true, write_concurrency: true])


	•	Implement cache module:

defmodule Users.Cache do
  @table :users_cache
  @ttl_ms 60_000
  def now_ms, do: System.monotonic_time(:millisecond)

  def get(id, fetch_fn \\ fn id -> Repo.get(User, id) end) do
    case :ets.lookup(@table, id) do
      [{^id, value, exp}] when exp > now_ms() ->
        {:hit, value}

      _ ->
        value = fetch_fn.(id)
        :ets.insert(@table, {id, value, now_ms() + @ttl_ms})
        {:miss, value}
    end
  end
end


	•	Route writes through one place (context or a dedicated writer GenServer) to prevent concurrent mutations.

	2.	TTL eviction with periodic sweeps
	•	Sweeper process:

defmodule Users.CacheSweeper do
  use GenServer
  @table :users_cache
  @sweep_ms 5_000

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    :timer.send_interval(@sweep_ms, :sweep)
    {:ok, %{}}
  end

  def handle_info(:sweep, state) do
    now = System.monotonic_time(:millisecond)
    # MatchSpec: delete rows where expires_at < now
    ms = [{{:"$1", :"$2", :"$3"}, [{:<, :"$3", now}], [true]}]
    :ets.select_delete(@table, ms)
    {:noreply, state}
  end
end


	•	Supervise Users.CacheSweeper under your app supervisor.

	3.	Benchmark p50/p99 improvements with Benchee
	•	Bench script:

hot_id = 123

Benchee.run(
  %{
    "Repo.get" => fn -> Repo.get(User, hot_id) end,
    "ETS cache" => fn ->
      {:hit, _v} = Users.Cache.get(hot_id, &Repo.get(User, &1))
    end
  },
  warmup: 2,
  time: 10,
  formatters: [{Benchee.Formatters.Console, extended_statistics: true}]
)


	•	Optional programmatic comparison:

suite = Benchee.run(%{"repo" => fn -> Repo.get(User, hot_id) end,
                      "cache" => fn -> Users.Cache.get(hot_id, &Repo.get(User, &1)) end},
                    warmup: 2, time: 10, formatters: [])
stats = fn name ->
  s = Enum.find(suite.scenarios, &(&1.name == name))
  s.run_time_statistics.percentiles
end
repo = stats.("repo"); cache = stats.("cache")
p50_improvement = repo[50.0] / cache[50.0]
p99_improvement = repo[99.0] / cache[99.0]
IO.inspect(%{p50_improvement: p50_improvement, p99_improvement: p99_improvement})


	•	Expected: measurable reduction in p50 and p99 when the key is hot and cache hit rate is high.

Common Pitfalls
	•	Multiple writers mutating ETS concurrently causing races. Use a single writer path.
	•	Leaking named ETS tables across restarts. Ensure table creation happens once per node under supervision.
	•	Forgetting read_concurrency/write_concurrency on hot tables.
	•	Storing expires_at with system_time and comparing to monotonic_time. Use monotonic consistently.

Success Criteria
	•	Hot path switched to ETS read-through with a single writer pattern.
	•	TTL eviction implemented via periodic sweep using :ets.select_delete/2.
	•	Benchee report shows improvement with numbers recorded: p50 → ms, p99 → ms.
	•	p50 improvement ≥ 3× and p99 improvement ≥ 2× on hot keys under representative load.
	•	Cache table recreated cleanly after app restart with no orphaned named tables.

