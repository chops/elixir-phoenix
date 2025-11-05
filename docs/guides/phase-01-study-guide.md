# Phase 1 Study Guide — Elixir Core

**Structured learning path with checkpoints, reading schedule, and daily objectives.**

---

## 📚 Study Guide Overview

**Phase Duration:** 6-9 days (40-50 hours total)

**Prerequisites:**
- [ ] Phase 0 complete (`make ci` passes)
- [ ] Elixir 1.17+ installed
- [ ] Code editor configured

**Deliverables:**
- [ ] `apps/labs_csv_stats` - CSV parser with streaming
- [ ] `apps/pulse_core` - Pure domain logic
- [ ] >90% test coverage
- [ ] All property tests passing
- [ ] Zero Dialyzer warnings

---

## 📖 Required Reading

### Primary Books

1. **Programming Elixir ≥ 1.6** by Dave Thomas
   - Chapters 1-10 (~200 pages)
   - Estimated time: 10-12 hours

2. **Learn Functional Programming with Elixir** by Ulisses Almeida
   - Chapters 1-9 (~180 pages)
   - Estimated time: 8-10 hours

### Official Documentation

- [ ] Elixir Introduction: https://elixir-lang.org/getting-started/introduction.html
- [ ] Basic Types: https://elixir-lang.org/getting-started/basic-types.html
- [ ] Pattern Matching: https://elixir-lang.org/getting-started/pattern-matching.html
- [ ] case, cond, if: https://elixir-lang.org/getting-started/case-cond-and-if.html
- [ ] Keyword lists and maps: https://elixir-lang.org/getting-started/keywords-and-maps.html
- [ ] Modules and functions: https://elixir-lang.org/getting-started/modules-and-functions.html
- [ ] Recursion: https://elixir-lang.org/getting-started/recursion.html
- [ ] Enumerables and Streams: https://elixir-lang.org/getting-started/enumerables-and-streams.html
- [ ] Processes: https://elixir-lang.org/getting-started/processes.html
- [ ] IO and File: https://elixir-lang.org/getting-started/io-and-the-file-system.html

### Supplementary Resources

- [ ] Elixir School - Documentation: https://elixirschool.com/en/lessons/basics/documentation/
- [ ] RunElixir Quickstart: https://runelixir.com/
- [ ] StreamData docs: https://hexdocs.pm/stream_data
- [ ] ExUnit docs: https://hexdocs.pm/ex_unit

---

## 🗓️ Day-by-Day Schedule

### **Day 1: Functional Programming Foundations** (6-8 hours)

#### Morning Session (3-4 hours): Core Concepts

**Reading:**
- [ ] *Programming Elixir* Chapter 1: Core Elixir (pages 1-20)
- [ ] *Programming Elixir* Chapter 2: Pattern Matching (pages 21-30)
- [ ] *Learn FP with Elixir* Chapter 1: FP Mindset (pages 1-25)

**Key Concepts:**
- Immutability
- Pattern matching
- Data in, data out
- Pure functions

**Practice in IEx:**
```elixir
# Pattern matching exercises
{:ok, value} = {:ok, 42}
[h | t] = [1, 2, 3]
%{name: n} = %{name: "Alice", age: 30}
```

**Checkpoint:**
- [ ] Can explain what immutability means
- [ ] Can write 5 different pattern match examples
- [ ] Understand when pattern match fails (MatchError)

#### Afternoon Session (3-4 hours): Functions & Modules

**Reading:**
- [ ] *Programming Elixir* Chapter 3: Functions (pages 31-45)
- [ ] *Learn FP with Elixir* Chapter 2: Functions & Modules (pages 26-50)

**Key Concepts:**
- Multiple function heads
- Guards
- Anonymous functions
- Module structure

**Practice:**
- [ ] Create a module with multiple function heads
- [ ] Write guards to validate inputs
- [ ] Use anonymous functions with `Enum.map/2`

**Checkpoint:**
- [ ] Can write a module with 3+ function heads
- [ ] Understand when to use guards vs pattern matching
- [ ] Can pass functions as arguments

**Homework:**
- [ ] Complete Workbook Checkpoint 1 (Pattern Matching & Guards)
- [ ] Take notes in `docs/reading/phase-01-core.md`

---

### **Day 2: Recursion & Core Data Structures** (6-8 hours)

#### Morning Session (3-4 hours): Recursion

**Reading:**
- [ ] *Programming Elixir* Chapter 4: Lists and Recursion (pages 46-65)
- [ ] *Learn FP with Elixir* Chapter 3: Core Data Structures (pages 51-75)
- [ ] Official docs: Recursion guide

**Key Concepts:**
- Tail recursion
- Accumulators
- Base cases
- List structure [head | tail]

**Practice:**
- [ ] Implement `sum/1` with tail recursion
- [ ] Implement `length/1` with accumulator
- [ ] Implement `reverse/1` recursively

**Checkpoint:**
- [ ] Can explain tail call optimization
- [ ] Can write tail-recursive functions with accumulators
- [ ] Understand when to reverse accumulator

#### Afternoon Session (3-4 hours): Data Structures

**Reading:**
- [ ] *Programming Elixir* Chapter 5: Collections (pages 66-85)
- [ ] Official docs: Basic Types, Keywords and Maps

**Key Concepts:**
- Tuples (fixed size)
- Lists (linked)
- Maps (key-value)
- Keyword lists (options)
- Structs (domain records)

**Practice:**
- [ ] Create a struct for `User` with validation
- [ ] Practice map operations (fetch, put, update)
- [ ] Use keyword lists for function options

**Checkpoint:**
- [ ] Can choose appropriate data structure for each use case
- [ ] Understand difference between maps and keyword lists
- [ ] Can define structs with `@enforce_keys`

**Homework:**
- [ ] Complete Workbook Checkpoint 2 (Recursion)
- [ ] Complete Workbook Checkpoint 7 (Data Structures)
- [ ] Implement `MyList.map/2` and `MyList.filter/2`

---

### **Day 3: Enum, Stream & Pipelines** (6-8 hours)

#### Morning Session (3-4 hours): Enum Module

**Reading:**
- [ ] *Programming Elixir* Chapter 6: Enum (pages 86-105)
- [ ] *Learn FP with Elixir* Chapter 4: Transformations (pages 76-105)
- [ ] Official docs: Enumerables and Streams

**Key Concepts:**
- Eager evaluation
- map, filter, reduce
- Pipeline operator `|>`
- Comprehensions

**Practice:**
```elixir
# Rewrite these as pipelines
1..10
|> Enum.map(&(&1 * &1))
|> Enum.filter(&(rem(&1, 2) == 0))
|> Enum.sum()
```

**Checkpoint:**
- [ ] Can write clear pipeline transformations
- [ ] Understand all common Enum functions
- [ ] Can use list comprehensions

#### Afternoon Session (3-4 hours): Stream Module

**Reading:**
- [ ] *Programming Elixir* Chapter 7: Streams (pages 106-120)
- [ ] Official docs: Stream module

**Key Concepts:**
- Lazy evaluation
- Infinite streams
- When to use Stream vs Enum
- Memory efficiency

**Practice:**
- [ ] Create infinite stream of Fibonacci numbers
- [ ] Stream a large file line by line
- [ ] Compare Enum vs Stream performance

**Checkpoint:**
- [ ] Can explain when to use Enum vs Stream
- [ ] Understand lazy evaluation and realization points
- [ ] Can stream large files without loading into memory

**Homework:**
- [ ] Complete Workbook Checkpoint 3 (Enum vs Stream)
- [ ] Rewrite 3 imperative loops as pipelines
- [ ] Start Phase 1 Drill #5 (Pipelines rewrite)

---

### **Day 4: Control Flow & Error Handling** (6-8 hours)

#### Morning Session (3-4 hours): Control Flow

**Reading:**
- [ ] *Programming Elixir* Chapter 8: Control Flow (pages 121-140)
- [ ] *Learn FP with Elixir* Chapter 5: Control Flow (pages 106-130)
- [ ] Official docs: case, cond, and if

**Key Concepts:**
- `case` for pattern matching
- `cond` for multiple predicates
- `with` for success chains
- Tagged tuples

**Practice:**
```elixir
# Write a with chain
with {:ok, user} <- get_user(id),
     {:ok, validated} <- validate(user),
     {:ok, saved} <- save(validated) do
  {:ok, saved}
else
  {:error, reason} -> {:error, reason}
end
```

**Checkpoint:**
- [ ] Can write `case` statements with guards
- [ ] Understand when to use `cond` vs `case`
- [ ] Can build `with` chains

#### Afternoon Session (3-4 hours): Tagged Tuples

**Reading:**
- [ ] Review examples in `docs/reading/phase-01-core.md`

**Key Concepts:**
- `{:ok, value}` | `{:error, reason}` pattern
- Consistent return shapes
- Avoid exceptions for expected errors

**Practice:**
- [ ] Convert exception-based code to tagged tuples
- [ ] Write functions that return `{:ok, _}` or `{:error, _}`
- [ ] Chain multiple operations with `with`

**Checkpoint:**
- [ ] Prefer tagged tuples over exceptions
- [ ] Keep return shapes consistent
- [ ] Handle all cases in `with` else clause

**Homework:**
- [ ] Complete Workbook Checkpoint 4 (Error Handling)
- [ ] Refactor old code to use tagged tuples

---

### **Day 5: Testing & Property-Based Testing** (6-8 hours)

#### Morning Session (3-4 hours): ExUnit

**Reading:**
- [ ] *Programming Elixir* Chapter 9: Testing (pages 141-160)
- [ ] Official docs: ExUnit
- [ ] Elixir School: Documentation

**Key Concepts:**
- `use ExUnit.Case`
- `test` macro
- `assert` and `refute`
- Doctests
- `@spec` and `@doc`

**Practice:**
- [ ] Write unit tests for MyList module
- [ ] Add doctests to functions
- [ ] Run `mix test` and achieve 100% coverage

**Checkpoint:**
- [ ] Can write unit tests with ExUnit
- [ ] Understand test organization (async: true)
- [ ] Can use doctests for documentation

#### Afternoon Session (3-4 hours): Property-Based Testing

**Reading:**
- [ ] StreamData documentation: https://hexdocs.pm/stream_data
- [ ] Property-based testing examples in docs

**Key Concepts:**
- Properties vs examples
- Generators (`list_of`, `integer`, `string`)
- `check all` macro
- Finding edge cases

**Practice:**
```elixir
use ExUnitProperties

property "length is always non-negative" do
  check all list <- list_of(integer()) do
    assert MyList.length(list) >= 0
  end
end
```

**Checkpoint:**
- [ ] Can identify invariant properties
- [ ] Can write property tests with StreamData
- [ ] Understand generator composition

**Homework:**
- [ ] Complete Workbook Checkpoint 5 (Property Testing)
- [ ] Add property tests to MyList module
- [ ] Run 100+ property test iterations

---

### **Day 6: Strings, Binaries & CSV Parsing** (6-8 hours)

#### Morning Session (3-4 hours): Strings & Binaries

**Reading:**
- [ ] *Programming Elixir* Chapter 10: Strings & Binaries (pages 161-185)
- [ ] *Learn FP with Elixir* Chapter 9: I/O and Apps (pages 180-210)

**Key Concepts:**
- Strings are UTF-8 binaries
- Charlists `'abc'` vs binaries `"abc"`
- Binary pattern matching
- String module

**Practice:**
```elixir
# Binary pattern matching
<<head::binary-size(1), rest::binary>> = "hello"

# String operations
"hello" |> String.upcase() |> String.reverse()
```

**Checkpoint:**
- [ ] Understand string vs charlist
- [ ] Can use binary pattern matching
- [ ] Know when to use String module

#### Afternoon Session (3-4 hours): CSV Parsing

**Reading:**
- [ ] Official docs: IO and File System

**Key Concepts:**
- `File.stream!/1` for large files
- `String.split/2` for parsing
- Stream transformations
- Handling headers

**Practice:**
- [ ] Parse CSV header row
- [ ] Parse CSV data rows into maps
- [ ] Stream large CSV files

**Checkpoint:**
- [ ] Can parse CSV using String.split
- [ ] Can stream files line by line
- [ ] Handle CSV with headers

**Homework:**
- [ ] Complete Workbook Checkpoint 6 (CSV Parsing)
- [ ] Start Phase 1 Drill #4 (CSV parser)

---

### **Day 7: Build labs_csv_stats App** (8-10 hours)

#### Morning Session (4-5 hours): Project Setup

**Tasks:**
- [ ] Create new app: `cd apps && mix new labs_csv_stats`
- [ ] Update `mix.exs` with dependencies
  - Add `stream_data` to `:test` env
  - Add `benchee` for benchmarking
- [ ] Create module structure:
  - `LabsCsvStats.Parser` - CSV parsing
  - `LabsCsvStats.Stats` - Statistics calculations
  - `LabsCsvStats` - Public API

**Implement CSV Parser:**
```elixir
defmodule LabsCsvStats.Parser do
  @doc "Parses CSV with headers into list of maps"
  def parse_file(path)

  @doc "Streams CSV file lazily"
  def stream_file(path)
end
```

**Checkpoint:**
- [ ] Project created and compiles
- [ ] Basic CSV parsing works
- [ ] Tests written for parser

#### Afternoon Session (4-5 hours): Statistics Calculator

**Implement Stats Module:**
```elixir
defmodule LabsCsvStats.Stats do
  defstruct [:mean, :median, :mode, :std_dev, :count, :min, :max]

  def calculate(numbers)
  def mean(numbers)
  def median(numbers)
  def mode(numbers)
  def std_dev(numbers)
end
```

**Requirements:**
- [ ] All functions pure (no side effects)
- [ ] Tail-recursive implementations
- [ ] Handle empty lists gracefully
- [ ] Return `{:ok, result}` or `{:error, reason}`

**Checkpoint:**
- [ ] All stats functions implemented
- [ ] Unit tests passing
- [ ] Property tests added
- [ ] `mix test` passes

**Homework:**
- [ ] Add doctests to all public functions
- [ ] Achieve >90% test coverage: `mix test --cover`
- [ ] Run Dialyzer: `mix dialyzer`

---

### **Day 8: Streaming & Property Tests** (6-8 hours)

#### Morning Session (3-4 hours): Streaming Implementation

**Tasks:**
- [ ] Implement streaming CSV parser for 1M+ row files
- [ ] Use `Stream.transform/3` for stateful parsing
- [ ] Memory profile with `:observer.start()`

**Streaming Requirements:**
```elixir
# Must handle 1M rows without loading into memory
LabsCsvStats.Parser.stream_file("large.csv")
|> Stream.map(&parse_row/1)
|> LabsCsvStats.Stats.calculate_stream()
```

**Performance Test:**
```elixir
# Generate large CSV
File.write!("test_1m.csv", generate_csv(1_000_000))

# Should use < 50MB memory
:observer.start()
LabsCsvStats.process("test_1m.csv")
```

**Checkpoint:**
- [ ] Handles 1M+ rows via Stream
- [ ] Memory usage < 50MB
- [ ] Performance: p95 < 50ms for 10K rows

#### Afternoon Session (3-4 hours): Property-Based Tests

**Add Property Tests:**
```elixir
property "mean is between min and max" do
  check all numbers <- list_of(integer(), min_length: 1) do
    stats = Stats.calculate(numbers)
    assert stats.mean >= stats.min
    assert stats.mean <= stats.max
  end
end

property "count equals list length" do
  check all numbers <- list_of(integer()) do
    stats = Stats.calculate(numbers)
    assert stats.count == length(numbers)
  end
end
```

**Requirements:**
- [ ] 100+ property tests
- [ ] Edge cases covered (empty lists, negatives, duplicates)
- [ ] All tests pass in < 10 seconds

**Checkpoint:**
- [ ] Property tests comprehensive
- [ ] Found and fixed edge case bugs
- [ ] Coverage > 90%

**Homework:**
- [ ] Run full test suite: `make ci`
- [ ] Fix any Credo warnings
- [ ] Review code for improvements

---

### **Day 9: Build pulse_core App** (6-8 hours)

#### Morning Session (3-4 hours): Domain Modeling

**Tasks:**
- [ ] Create new app: `cd apps && mix new pulse_core`
- [ ] Design domain models:
  - `PulseCore.Product` - Product catalog
  - `PulseCore.Pricing` - Price calculations
  - `PulseCore.Cart` - Cart logic (pure)

**Product Module:**
```elixir
defmodule PulseCore.Product do
  defstruct [:id, :name, :price, :category, :in_stock]

  def new(attrs)
  def valid?(product)
  def in_stock?(product)
end
```

**Pricing Module:**
```elixir
defmodule PulseCore.Pricing do
  def calculate_total(items)
  def apply_discount(total, discount)
  def calculate_tax(total, tax_rate)
end
```

**Checkpoint:**
- [ ] Domain structs defined
- [ ] All functions pure
- [ ] Tagged tuple returns

#### Afternoon Session (3-4 hours): Business Rules

**Implement Business Logic:**
- [ ] Product validation rules
- [ ] Pricing calculations (subtotal, tax, discounts)
- [ ] Cart operations (add, remove, update quantity)

**Requirements:**
- [ ] All functions pure (no side effects)
- [ ] Comprehensive pattern matching
- [ ] Return `{:ok, _}` or `{:error, _}` consistently

**Property Tests:**
```elixir
property "discount never makes total negative" do
  check all total <- positive_integer(),
            discount <- integer(0..100) do
    result = Pricing.apply_discount(total, discount)
    assert result >= 0
  end
end
```

**Checkpoint:**
- [ ] All business rules implemented
- [ ] Property tests cover critical paths
- [ ] Zero Dialyzer warnings
- [ ] Coverage > 90%

**Homework:**
- [ ] Add @spec to all public functions
- [ ] Document with @doc and doctests
- [ ] Run `make ci` and verify passing

---

### **Day 10 (Optional): Refinement & Review** (4-6 hours)

#### Morning Session (2-3 hours): Code Review

**Self-Review Checklist:**
- [ ] All functions have @spec and @doc
- [ ] Doctests added to key functions
- [ ] No Credo warnings
- [ ] No Dialyzer warnings
- [ ] Test coverage > 90%
- [ ] Property tests comprehensive

**Refactoring:**
- [ ] Extract common patterns
- [ ] Improve function names
- [ ] Add missing edge case handling
- [ ] Optimize slow functions

#### Afternoon Session (2-3 hours): Performance Validation

**Benchmarking:**
```elixir
# Run benchmarks
cd apps/labs_csv_stats
mix run bench/stats_bench.exs
```

**Performance Targets:**
- [ ] CSV parsing: p95 < 50ms for 10K rows
- [ ] Stats calculation: p95 < 100ms for 100K numbers
- [ ] Memory: < 50MB for 1M row streaming
- [ ] Property tests: < 10 seconds total

**Final Gate:**
```bash
# All checks must pass
make ci

# Coverage report
mix test --cover

# Performance test
k6 run tools/k6/phase-01-gate.js
```

**Checkpoint:**
- [ ] All performance targets met
- [ ] `make ci` passes
- [ ] Ready to advance to Phase 2

---

## ✅ Phase 1 Completion Checklist

### Code Deliverables
- [ ] `apps/labs_csv_stats` exists and compiles
- [ ] `apps/pulse_core` exists and compiles
- [ ] All tests pass (`mix test`)
- [ ] Coverage > 90% (`mix test --cover`)
- [ ] Zero Dialyzer warnings (`mix dialyzer`)
- [ ] No Credo warnings (`mix credo --strict`)
- [ ] `make ci` passes

### Learning Objectives
- [ ] Can write pure functions with pattern matching
- [ ] Master tail-recursive functions with accumulators
- [ ] Choose Enum vs Stream appropriately
- [ ] Build clear pipeline transformations
- [ ] Handle errors with tagged tuples and `with`
- [ ] Write property-based tests with StreamData
- [ ] Parse CSV using binary pattern matching
- [ ] Stream large files efficiently
- [ ] Define and use structs for domain models

### Performance Targets
- [ ] CSV parsing: p95 < 50ms for 10K rows
- [ ] Stats calculation: p95 < 100ms for 100K numbers
- [ ] Memory usage: < 50MB for 1M row streaming
- [ ] Property tests: < 10 seconds total

### Documentation
- [ ] All public functions have @spec
- [ ] All public functions have @doc
- [ ] Doctests added where appropriate
- [ ] Reading notes updated in `docs/reading/phase-01-core.md`

### Drills Completed
- [ ] Drill #1: MyList module (map, filter, reduce, mapsum)
- [ ] Drill #2: List maximum with pattern matching
- [ ] Drill #3: Caesar cipher
- [ ] Drill #4: CSV parser via binaries
- [ ] Drill #5: Pipelines rewrite (3 examples)

---

## 📊 Self-Assessment Quiz

Before advancing, answer these questions:

### Conceptual Understanding

1. **What is tail recursion and why is it important?**
   - Your answer: ___________________________________________

2. **When should you use Stream instead of Enum?**
   - Your answer: ___________________________________________

3. **Why use tagged tuples instead of exceptions?**
   - Your answer: ___________________________________________

4. **What's the difference between a map and a keyword list?**
   - Your answer: ___________________________________________

5. **What properties would you test for a `reverse/1` function?**
   - Your answer: ___________________________________________

### Practical Skills

Can you implement these without looking at docs?

- [ ] Tail-recursive `map/2` function
- [ ] Stream a CSV file and calculate statistics
- [ ] Build a `with` chain for a multi-step operation
- [ ] Write a property test for a custom function
- [ ] Define a struct with validation

---

## 🎓 Ready to Advance?

You can advance to Phase 2 when:

1. **All code deliverables complete** (labs_csv_stats + pulse_core)
2. **All tests passing** (unit + property + doctests)
3. **Quality gates green** (`make ci` passes)
4. **Performance targets met** (benchmarks within spec)
5. **Can explain key concepts** (tail recursion, Enum vs Stream, tagged tuples)
6. **Workbook completed** (all 7 checkpoints)

**Mastery Gate Command:**
```bash
cd apps/labs_csv_stats && mix test --cover && \
cd ../pulse_core && mix test --cover && \
cd ../.. && make ci
```

If all checks pass: **Congratulations! You're ready for Phase 2: Processes & Mailboxes**

---

## 📚 Additional Resources

- [ ] Elixir Forum: https://elixirforum.com/
- [ ] Elixir Slack: https://elixir-slackin.herokuapp.com/
- [ ] Exercism Elixir Track: https://exercism.org/tracks/elixir
- [ ] Elixir Koans: http://elixirkoans.io/

---

## 📝 Notes & Reflections

Use this space to capture insights, challenges, and breakthroughs:

**Key Learnings:**
-
-
-

**Challenges Faced:**
-
-
-

**Questions for Later:**
-
-
-

**Next Phase Preview:**
Phase 2 introduces processes, mailboxes, and concurrency. You'll build stateful systems using message passing.
