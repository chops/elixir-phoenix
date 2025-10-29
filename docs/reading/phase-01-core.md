# Phase 1 — Elixir Core

Master functional programming primitives, pattern matching, and core data structures.

## Books
- **Programming Elixir ≥ 1.6** (Dave Thomas)
- **Learn Functional Programming with Elixir** (Ulisses Almeida)

## Docs
- **Elixir "Introduction" and core docs index**
  https://elixir-lang.org/getting-started/introduction.html and https://hexdocs.pm/elixir

## Supplements
- **Elixir School: documentation basics**
  https://elixirschool.com/en/lessons/basics/documentation/

- **RunElixir quickstart**
  https://runelixir.com/---

================================================================================

Learn Functional Programming with Elixir Summary

Outline

1.	FP mindset in Elixir: immutability, data-first, pattern matching, recursion
2.	Functions and modules: named/anonymous funcs, guards, docs, Mix + ExUnit
3.	Core data structures: tuples, lists, maps, keyword lists, ranges, binaries, structs
4.	Transformations: Enum, Stream, list comprehensions, pipelines
5.	Control flow the FP way: case, cond, with, tagged tuples {:ok, _} | {:error, _}
6.	Building larger abstractions: structs, protocols, behaviours (intro)
7.	Concurrency essentials: processes, send/receive, links/monitors, Task/Agent
8.	OTP taste: GenServer patterns, supervision basics (lightweight in this book)
9.	I/O and apps: File/IO, configuration, dependencies, CLI entry points

Chapter/Section Summaries

1) FP mindset in Elixir

Key Concepts
•	Immutability; pure functions; data in, data out.
•	Pattern matching binds on structure and values; recursion replaces loops.
•	Prefer transformations over mutation.
•	Use algebraic-feeling return shapes (tagged tuples) for explicit outcomes.

Essential Code Snippets

# pattern matching
{:ok, total} = {:ok, 42}

# recursion with accumulator
def sum(list), do: do_sum(list, 0)
defp do_sum([], acc), do: acc
defp do_sum([h|t], acc), do: do_sum(t, acc + h)

Tips & Pitfalls
•	Avoid hidden state; avoid “update in place.”
•	Prefer guards over if for type/shape constraints.

Exercises Application
•	Reimplement small tasks with recursion + pattern matching to internalize the model.

Diagrams

input → transform → output
(no mutation; each step returns new data)

2) Functions and modules

Key Concepts
•	Multiple function heads with pattern matching; guards shape valid inputs.
•	Anonymous functions capture context; higher-order usage with Enum, Stream.
•	Mix sets up projects; ExUnit provides tests; doctests document examples.

Essential Code Snippets

defmodule Price do
  @moduledoc "Totals with tax"
  @doc "Compute total with rate"
  @spec total(number, number) :: number
  def total(net, rate) when is_number(net) and is_number(rate),
    do: net * (1 + rate)
end

# anonymous function
inc = fn x -> x + 1 end
Enum.map([1,2,3], inc)

Tips & Pitfalls
•	Prefer docstrings + @spec for public APIs.
•	Keep modules small and focused; test with ExUnit + doctest.

Exercises Application
•	Build small modules with multiple heads + guards; write doctests to lock behavior.

Diagrams

Caller → (pattern match + guards) → body

3) Core data structures

Key Concepts
•	Tuples (fixed), lists (linked), maps (keyed), keyword lists (ordered 2-tuples), ranges, binaries, structs.
•	Structs are maps with enforced keys; use for domain records.

Essential Code Snippets

{:ok, value} = Map.fetch(%{a: 1}, :a)
opts = [limit: 10, offset: 0]  # keyword
struct Example, a: 1            # defstruct in module

Tips & Pitfalls
•	Prefer maps/structs for records; keyword lists for options.
•	Don’t confuse charlists ‘abc’ with binaries “abc”.

Exercises Application
•	Choose maps/structs for domain data; use keywords only for options to functions.

Diagrams

tuple = {fixed, fields}
list  = [head | tail]
map   = %{key -> value}
struct %Example{a: 1}

4) Transformations: Enum, Stream, pipelines

Key Concepts
•	Enum.* is eager; Stream.* is lazy; |> composes transformations.
•	Map/filter/reduce as core primitives.

Essential Code Snippets

1..10
|> Enum.map(&(&1 * &1))
|> Enum.filter(&(rem(&1, 2) == 0))

# lazy
File.stream!("large.csv")
|> Stream.map(&String.trim/1)
|> Enum.take(5)

Tips & Pitfalls
•	Start with Enum; switch to Stream for big or infinite data.
•	Try to keep each pipeline stage pure and small.

Exercises Application
•	Convert loops from other languages to pipelines; measure with Benchee if needed.

Diagrams

source → |> map → |> filter → |> reduce
Enum (eager) vs Stream (lazy)

5) Control flow the FP way

Key Concepts
•	case to pattern-match; cond for multiple predicates.
•	with for success-chains; return consistent tagged tuples.

Essential Code Snippets

case user do
  %User{age: age} when age >= 18 -> {:ok, :adult}
  _ -> {:error, :minor}
end

with {:ok, a} <- parse(s),
     {:ok, b} <- validate(a),
     {:ok, c} <- persist(b) do
  {:ok, c}
else
  err -> err
end

Tips & Pitfalls
•	Do not mix exceptions with with-chains for expected errors.
•	Keep return shapes uniform across branches.

Exercises Application
•	Refactor nested if/else into case + guards or with.

Diagrams

{:ok,_} chain → with → {:ok,_} | else {:error,_}

6) Structs, protocols, and light polymorphism

Key Concepts
•	Structs for domain records; protocols enable ad-hoc polymorphism.

Essential Code Snippets

defprotocol Priceable do
  @spec price(t) :: number
  def price(item)
end

defimpl Priceable, for: Cart do
  def price(%Cart{items: items}), do: Enum.sum(Enum.map(items, & &1.price))
end

Tips & Pitfalls
•	Reach for protocols sparingly; start with pattern matching.

Exercises Application
•	Add protocol impls only when multiple types share behavior.

Diagrams

Protocol → implementations per struct

7) Concurrency essentials

Key Concepts
•	Processes isolate state. send/receive as message passing.
•	Links crash both; monitors notify one-way.
•	Tasks for async, Agent for simple state.

Essential Code Snippets

pid = spawn(fn -> receive do {:ping, from} -> send(from, :pong) end end)
send(pid, {:ping, self()})
receive do :pong -> :ok after 1000 -> :timeout end

Task.async_stream(urls, &fetch/1, max_concurrency: 10)
|> Enum.to_list()

Tips & Pitfalls
•	Use timeouts; avoid unbounded mailboxes.
•	Prefer Task over manual spawn for supervised async work.

Exercises Application
•	Build small ping-pong or worker-pool examples.

Diagrams

Parent ⇆(link) Child
Parent ←(monitor) Child

8) OTP taste: GenServer and supervision (light)

Key Concepts
•	GenServer wraps stateful loops; supervisors restart children.
•	Keep callbacks thin; delegate to pure core.

Essential Code Snippets

def handle_call({:get, key}, _from, state), do: {:reply, Map.get(state, key), state}
def handle_cast({:put, k, v}, state), do: {:noreply, Map.put(state, k, v)}

Tips & Pitfalls
•	No blocking I/O in callbacks; consider Task for heavy work.
•	Use :timeout or handle_info for periodic actions.

Exercises Application
•	Wrap a stateful calculation or cache in GenServer; add a supervisor to restart it.

Diagrams

Client → GenServer.call/cast → State → reply
Supervisor
 └─ Cache (worker)

9) I/O, apps, and CLI glue

Key Concepts
•	File and stream APIs; escript for command-line apps.

Essential Code Snippets

File.stream!("data.log")
|> Stream.map(&String.trim/1)
|> Enum.frequencies()

# escript
# mix.exs: escript: [main_module: App.CLI]
defmodule App.CLI do
  def main(args), do: IO.puts(Enum.join(args, " "))
end

Tips & Pitfalls
•	Prefer streaming for large files; separate parsing from I/O.

Exercises Application
•	Build small CLI around a pipeline; test parsing logic separately.

Diagrams

File → Stream → pipeline → output

Cross-chapter checklist

Key Concepts
•	Prefer pure functions + pattern matching; return tagged tuples.
•	Use Enum pipelines; switch to Stream when data is big.
•	Replace loops with recursion or comprehensions.
•	Structure data with maps/structs; protocols only when needed.
•	Concurrency for isolation or parallelism; use Tasks for easy parallel maps.
•	Keep state in GenServer only when required; supervise anything that must restart.
•	Tests first with ExUnit; add doctests for small examples.

Minimal ASCII crib

Key Concepts
•	Pipeline, recursion, concurrency, OTP cheat lines.

Essential Code Snippets

# —

Tips & Pitfalls
•	—

Exercises Application
•	—

Diagrams

Minimal ASCII crib

Pipeline: input → map → filter → [Enum.*] → output
Recursion: loop(state) → receive → new_state → loop(new_state)
Concur.: Parent ⇆(link) Child   |   Parent ←(monitor) Child
OTP: Client → GenServer ↔ State   under Supervisor(one_for_one)

This is scoped to what you need to finish the exercises: write s...rap state in a supervised GenServer with tests around each step.

Cross-Chapter Checklist

Prefer pure functions + pattern matching; return tagged tuples.
•	Use Enum pipelines; switch to Stream when data is big.
•	Replace loops with recursion or comprehensions.
•	Structure data with maps/structs; protocols only when needed.
•	Concurrency for isolation or parallelism; use Tasks for easy parallel maps.
•	Keep state in GenServer only when required; supervise anything that must restart.
•	Tests first with ExUnit; add doctests for small examples.

Quick Reference Crib

Minimal ASCII crib

Pipeline: input → map → filter → [Enum.*] → output
Recursion: loop(state) → receive → new_state → loop(new_state)
Concur.: Parent ⇆(link) Child   |   Parent ←(monitor) Child
OTP: Client → GenServer ↔ State   under Supervisor(one_for_one)

This is scoped to what you need to finish the exercises: write s...rap state in a supervised GenServer with tests around each step.


⸻

Programming Elixir ≥ 1.6 Summary

Outline

1.	Core Elixir: IEx, immutability, pattern matching, guards, recursion
2.	Collections and transforms: lists, tuples, maps, keyword lists; Enum, Stream, comprehensions
3.	Functions and modules: multiple heads, default args, docs, typespecs, Mix + ExUnit
4.	Strings, binaries, UTF-8, regex, sigils
5.	Control flow the FP way: case, cond, with, exceptions as data
6.	Structs, protocols, behaviours (intro)
7.	Concurrency: processes, links/monitors, mailboxes; Task/Agent
8.	OTP: GenServer, Supervisor, Registry, DynamicSupervisor; Applications
9.	Macros and metaprogramming (only what you need for exercises)
10.	Files, IO, and CLI (streams, escript, simple tooling)

Chapter/Section Summaries

1) Core Elixir

Key Concepts
•	Everything is an expression; data is immutable.
•	Pattern matching binds on structure and value; recursion replaces loops.
•	Guards refine function heads.

Essential Code Snippets

# pattern + guards
def safe_div(a, b) when is_number(a) and is_number(b) and b != 0, do: {:ok, a/b}
def safe_div(_, 0), do: {:error, :zero_div}

# tail recursion
def sum(xs), do: do_sum(xs, 0)
defp do_sum([], acc), do: acc
defp do_sum([h|t], acc), do: do_sum(t, acc + h)

Tips & Pitfalls
•	Prefer multiple heads + guards over nested if.
•	Return {:ok, _} | {:error, _} and match in callers.

Exercises Application
•	Lists-and-recursion (e.g., mapsum/2, max/1, Caesar cipher).
•	Build tiny modules (MyList) reimplementing map/reduce.

Diagrams

input → match/validate → pure transform → output

2) Collections and transforms

Key Concepts
•	Lists, tuples, maps; keyword lists for options.
•	Enum vs Stream; comprehensions for derived collections.

Essential Code Snippets

for x <- 1..5, y <- 1..5, rem(x*y, 3) == 0, do: {x, y}

1..10
|> Enum.map(&(&1 * &1))
|> Enum.sum()

Tips & Pitfalls
•	Stream for large or infinite; use pipelines for clarity.

Exercises Application
•	Stats over sequences; implement transforms with pipelines.

Diagrams

source → |> map → |> filter → |> reduce

3) Functions, modules, docs, tests

Key Concepts
•	Multiple heads, default args; @doc, @moduledoc; @spec typespecs.
•	Mix projects; ExUnit and doctests.

Essential Code Snippets

defmodule MyList do
  @doc "Maps"
  def map([], _f), do: []
  def map([h|t], f), do: [f.(h) | map(t, f)]
end

defmodule MyListTest do
  use ExUnit.Case, async: true
  doctest MyList
end

Tips & Pitfalls
•	Keep modules cohesive; prefer doctests for examples.

Exercises Application
•	Write doctests for MyList; run mix test.

Diagrams

Module → public API (specs) → tests (ExUnit/doctest)

4) Strings, binaries, UTF-8, regex, sigils

Key Concepts
•	Binaries are bytes; strings are UTF-8 binaries.
•	Sigils for literals; regex for patterns.

Essential Code Snippets

"über" |> String.length() # graphemes
<<0,1,2>> # binary
~r/\w+/ |> Regex.match?("abc")
~w[one two three]a  # atoms

Tips & Pitfalls
•	Handle graphemes with String APIs (String.length/1, graphemes/1).
•	Don’t iterate raw bytes for UTF-8 tasks.

Exercises Application
•	“Center strings,” anagrams, word stats using String.* and regex.

Diagrams

binary (bytes) ⇄ string (UTF-8 graphemes)

5) Control flow the FP way

Key Concepts
•	case + guards; cond for multi-predicates; with for success chains.
•	Prefer tagged tuples over exceptions for expected failures.

Essential Code Snippets

with {:ok, a} <- parse(s),
     {:ok, b} <- validate(a),
     {:ok, c} <- persist(b) do
  {:ok, c}
else
  err -> err
end

Tips & Pitfalls
•	Keep with branches flat; return consistent shapes.

Exercises Application
•	Refactor exception-based flows to tagged tuples + with.

Diagrams

{:ok,_} chain → with → {:ok,_} | else {:error,_}

6) Structs, protocols, behaviours (intro)

Key Concepts
•	Structs impose shape; protocols enable polymorphism; behaviours define callbacks.

Essential Code Snippets

defprotocol Stringify do
  def s(value)
end

defimpl Stringify, for: [Atom, Integer] do
  def s(v), do: to_string(v)
end

Tips & Pitfalls
•	Reach for protocols when many types share a concern.

Exercises Application
•	Implement simple protocol across custom structs.

Diagrams

Behaviour → module callbacks
Protocol → per-type implementations

7) Concurrency essentials

Key Concepts
•	Processes, mailboxes; links vs monitors; Task/Agent for convenience.

Essential Code Snippets

pid = spawn(fn ->
  receive do {:ping, from} -> send(from, :pong) end
end)

Task.async_stream(urls, &fetch/1, max_concurrency: 8)
|> Enum.to_list()

Tips & Pitfalls
•	Always set timeouts; avoid synchronous bottlenecks.

Exercises Application
•	Ping-pong, parallel map with Task.async_stream.

Diagrams

Parent ⇆(link) Child | Parent ←(monitor) Child

8) OTP: GenServer, Supervisor, Registry, DynamicSupervisor; Applications

Key Concepts
•	GenServer callbacks; supervision strategies; Registry naming; DynamicSupervisor.

Essential Code Snippets

def init(state), do: {:ok, state, :timeout}
def handle_call(:get, _from, s), do: {:reply, s, s}
def handle_cast({:put, v}, _), do: {:noreply, v}

children = [
  {Registry, keys: :unique, name: My.Reg},
  {DynamicSupervisor, name: My.Dyn, strategy: :one_for_one}
]

Tips & Pitfalls
•	Thin callbacks; name processes via Registry; supervise everything that must live.

Exercises Application
•	Migrate mailbox loop to GenServer; wire under Supervisor; add Registry naming.

Diagrams

Client → GenServer ↔ State
Supervisor(one_for_one)
Registry(via tuples)     DynamicSupervisor(spawn on demand)

9) Macros and metaprogramming (minimal)

Key Concepts
•	Only the minimum to support exercises; prefer functions first.

Essential Code Snippets

defmacro unless(expr, do: block) do
  quote do
    if !unquote(expr), do: unquote(block)
  end
end

Tips & Pitfalls
•	Don’t overuse macros; keep logic in functions.

Exercises Application
•	Recreate small macros (unless, ok!/1) and prove via tests.

Diagrams

AST ↔ quote/unquote

10) Files, IO, CLI

Key Concepts
•	Stream files into pipelines; Path, File, IO; escript for CLIs.

Essential Code Snippets

File.stream!("data.log")
|> Stream.map(&String.trim/1)
|> Enum.frequencies()

# escript
# mix.exs: escript: [main_module: App.CLI]
defmodule App.CLI do
  def main(args), do: IO.puts(Enum.join(args, " "))
end

Tips & Pitfalls
•	Prefer streaming for large files; handle errors with with.

Exercises Application
•	Build small CLI utilities over stream pipelines.

Diagrams

File → Stream → pipeline → output

Cross-Chapter Checklist

Pure cores, explicit results, pattern matching.
•	Pipelines first; switch to Stream for scale.
•	Replace loops with recursion/comprehensions.
•	Structure data with maps/structs; protocols only when needed.
•	Concurrency for isolation/parallelism; supervise stateful parts.
•	Keep GenServer thin; name with Registry; scale with DynamicSupervisor.
•	Use tests and doctests to lock behavior; measure, then optimize.

Quick Reference Crib

Pipeline : input → map → filter → [Enum.*] → output
Recursion: loop(state) → receive → new_state → loop(new_state)
Concurrency: Parent ⇆(link) Child | Parent ←(monitor) Child
OTP      : Client → GenServer ↔ State   under Supervisor/Registry


---

## Drills


Phase 1 Drills

Core Skills to Practice
	•	Reimplement map, filter, reduce with tail recursion and guards.  
	•	Write binary pattern matchers for CSV and simple line protocols. Handle UTF-8 correctly.    
	•	Convert imperative loops to |> pipelines. Compare Enum vs Stream.  
	•	Replace exception control flow with tagged tuples and with-chains.  

Exercises
	1.	MyList module: implement map/2, filter/2, reduce/3, plus mapsum/2.
Expected: functions are tail-recursive and pass property tests. Add StreamData tests and doctests.    
	2.	List maximum: implement max/1 using pattern matching and recursion.
Expected: handles empty list as {:error, :empty} or similar tagged result.  
	3.	Caesar cipher: implement caesar/2 that rotates alphabetic characters by N.
Expected: preserves case, leaves non-letters unchanged, works on binaries (UTF-8).    
	4.	CSV parser via binaries: parse a header and rows using binary pattern matching.
Expected: streaming variant with File.stream!/1 and Stream.transform/3 for large files.    
	5.	Pipelines rewrite: take three loop-based tasks and rewrite as Enum pipelines; switch to Stream for large sources and measure realization points.
Expected: identical results; fewer intermediate lists with Stream.  

Common Pitfalls
	•	Confusing 'abc' (charlist) with "abc" (UTF-8 binary).  
	•	Realizing unbounded Streams by accident; know where realization occurs.  
	•	Loading bytes and iterating raw code units for UTF-8 tasks; prefer String.* APIs.  

Success Criteria
	•	apps/core contains MyList.map/reduce, max/1, caesar/2, and a CSV parser via binary matching.  
	•	Property tests and doctests added; >90% function coverage; all tests pass.  
	•	You can explain when to use Enum vs Stream and show a pipeline rewrite for a loop.  

