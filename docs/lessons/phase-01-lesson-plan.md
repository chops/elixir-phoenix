# Phase 1 Lesson Plan — Elixir Core

**Auto-generated from roadmap.md and reading materials**

---

## 📋 Lesson Plan Metadata

**Phase:** 1 — Elixir Core
**Duration:** 6-9 days (40-50 hours)
**Prerequisites:** Phase 0 complete
**Mastery Definition:** You can write pure functional code using pattern matching, recursion, and the pipe operator. You understand immutability, tagged tuples for errors, and can process data with Enum and Stream.

**Generated from:**
- `docs/roadmap.md` (Phase 1 section)
- `docs/reading/phase-01-core.md`

---

## 🎯 Learning Objectives

By the end of this phase, you will be able to:

1. **Master pattern matching and guards**
   - Write functions with multiple heads
   - Use guards to refine valid inputs
   - Match on complex data structures

2. **Write tail-recursive functions**
   - Build accumulator-based recursion patterns
   - Avoid stack overflow on large inputs
   - Understand tail-call optimization

3. **Use Enum and Stream**
   - Understand eager vs lazy evaluation
   - Use pipelines for data transformation
   - Choose appropriate tool for each use case

4. **Handle errors with tagged tuples**
   - Return `{:ok, _}` | `{:error, _}` patterns consistently
   - Build `with` chains for success-path operations
   - Avoid exceptions for expected errors

5. **Apply property-based testing**
   - Write tests using StreamData
   - Find edge cases automatically
   - Define invariant properties

---

## 📚 Required Materials

### Books
- **Programming Elixir ≥ 1.6** by Dave Thomas (Chapters 1-10)
- **Learn Functional Programming with Elixir** by Ulisses Almeida (Chapters 1-9)

### Documentation
- Elixir Getting Started: https://elixir-lang.org/getting-started/introduction.html
- Hexdocs API reference: https://hexdocs.pm/elixir

### Supplements
- Elixir School documentation: https://elixirschool.com/en/lessons/basics/documentation/
- RunElixir quickstart: https://runelixir.com/

### Companion Materials
- `docs/workbooks/phase-01-workbook.md` - Interactive exercises
- `docs/guides/phase-01-study-guide.md` - Reading schedule
- `docs/reading/phase-01-core.md` - Detailed notes

---

## 🗓️ Weekly Schedule

### Week 1: Foundations & Theory (Days 1-5)

#### Day 1: FP Mindset & Pattern Matching
- **Time:** 6-8 hours
- **Focus:** Immutability, pattern matching, pure functions
- **Activities:**
  - Read Programming Elixir Ch 1-2
  - Read Learn FP with Elixir Ch 1
  - Practice pattern matching in IEx
  - Complete Workbook Checkpoint 1
- **Deliverable:** Can write 10 different pattern match examples

#### Day 2: Recursion & Data Structures
- **Time:** 6-8 hours
- **Focus:** Tail recursion, accumulators, lists/maps/tuples
- **Activities:**
  - Read Programming Elixir Ch 4-5
  - Read Learn FP with Elixir Ch 3
  - Implement tail-recursive `sum/1`, `length/1`, `reverse/1`
  - Complete Workbook Checkpoints 2 & 7
- **Deliverable:** MyList module with tail-recursive functions

#### Day 3: Enum, Stream & Pipelines
- **Time:** 6-8 hours
- **Focus:** Eager vs lazy evaluation, pipelines
- **Activities:**
  - Read Programming Elixir Ch 6-7
  - Read Learn FP with Elixir Ch 4
  - Practice Enum operations
  - Stream large files
  - Complete Workbook Checkpoint 3
- **Deliverable:** 3 pipelines rewriting imperative loops

#### Day 4: Control Flow & Error Handling
- **Time:** 6-8 hours
- **Focus:** case/cond/with, tagged tuples
- **Activities:**
  - Read Programming Elixir Ch 8
  - Read Learn FP with Elixir Ch 5
  - Build `with` chains
  - Convert exception code to tagged tuples
  - Complete Workbook Checkpoint 4
- **Deliverable:** Error handling examples

#### Day 5: Testing & Property-Based Testing
- **Time:** 6-8 hours
- **Focus:** ExUnit, StreamData, doctests
- **Activities:**
  - Read Programming Elixir Ch 9
  - Study StreamData docs
  - Write unit tests
  - Write property tests
  - Complete Workbook Checkpoint 5
- **Deliverable:** 100+ property tests for MyList

### Week 2: Implementation (Days 6-9)

#### Day 6: Strings, Binaries & CSV Parsing
- **Time:** 6-8 hours
- **Focus:** Binary pattern matching, CSV parsing
- **Activities:**
  - Read Programming Elixir Ch 10
  - Read Learn FP with Elixir Ch 9
  - Binary pattern matching practice
  - CSV parsing implementation
  - Complete Workbook Checkpoint 6
- **Deliverable:** CSV parser with streaming

#### Day 7: Build labs_csv_stats (Part 1)
- **Time:** 8-10 hours
- **Focus:** Project setup, parser, stats calculator
- **Activities:**
  - Create `apps/labs_csv_stats` project
  - Implement CSV parser module
  - Implement statistics calculator
  - Write unit tests
- **Deliverable:** Basic CSV stats app working

#### Day 8: Build labs_csv_stats (Part 2)
- **Time:** 6-8 hours
- **Focus:** Streaming, property tests, performance
- **Activities:**
  - Implement streaming for large files
  - Add comprehensive property tests
  - Performance testing and optimization
  - Verify memory usage < 50MB
- **Deliverable:** labs_csv_stats complete and tested

#### Day 9: Build pulse_core
- **Time:** 6-8 hours
- **Focus:** Domain modeling, business rules
- **Activities:**
  - Create `apps/pulse_core` project
  - Define domain structs (Product, Pricing)
  - Implement business rules (pure functions)
  - Add property tests
  - Run quality gates
- **Deliverable:** pulse_core complete with >90% coverage

#### Day 10 (Optional): Refinement
- **Time:** 4-6 hours
- **Focus:** Code review, performance validation
- **Activities:**
  - Self-review code quality
  - Refactor and optimize
  - Benchmarking
  - Final `make ci` verification
- **Deliverable:** Ready to advance to Phase 2

---

## 📝 Daily Lesson Structure

Each lesson day follows this structure:

### Morning Session (3-4 hours)
1. **Review** (15 min) - Previous day's key concepts
2. **Reading** (2-3 hours) - Book chapters and docs
3. **Discussion** (30 min) - Key concepts and questions
4. **Practice** (30 min) - IEx exercises

### Afternoon Session (3-4 hours)
1. **Deep Dive** (1-2 hours) - Additional reading or examples
2. **Hands-On Practice** (2-3 hours) - Coding exercises
3. **Checkpoint** (30 min) - Workbook exercises
4. **Review** (15 min) - What did you learn?

### Evening
1. **Homework** - Complete workbook checkpoints
2. **Notes** - Update reading notes
3. **Reflect** - Journal about challenges and insights

---

## 🎓 Teaching Methodology

### Active Learning Strategies

1. **Read-Practice-Apply Cycle**
   - Read concept in book
   - Practice in IEx immediately
   - Apply in workbook exercise
   - Use in project code

2. **Spaced Repetition**
   - Introduce concept (Day 1)
   - Practice with guidance (Day 2)
   - Apply independently (Day 3+)
   - Review in different context (later phases)

3. **Progressive Complexity**
   - Start with simple examples (sum a list)
   - Add complexity (handle edge cases)
   - Combine concepts (streaming + parsing + stats)
   - Build production-ready code (labs apps)

4. **Immediate Feedback**
   - Run code in IEx (instant feedback)
   - Run tests frequently (`mix test`)
   - Check coverage (`mix test --cover`)
   - Quality gates (`make ci`)

### Assessment Methods

1. **Formative Assessment** (Throughout)
   - Workbook checkpoints
   - Self-assessment questions
   - Daily coding exercises
   - IEx practice

2. **Summative Assessment** (End of Phase)
   - Labs app complete and working
   - Pulse feature integrated
   - All tests passing
   - Performance targets met
   - Quality gates passing

---

## 🏗️ Projects & Deliverables

### Labs App: labs_csv_stats

**Scope:** CSV parser and statistics calculator using pure functions

**Module Structure:**
```
apps/labs_csv_stats/
├── lib/
│   ├── labs_csv_stats.ex           # Public API
│   ├── labs_csv_stats/
│   │   ├── parser.ex               # CSV parsing
│   │   ├── stats.ex                # Statistics calculations
│   │   └── stream.ex               # Streaming for large files
├── test/
│   ├── labs_csv_stats_test.exs
│   ├── parser_test.exs
│   ├── stats_test.exs
│   └── property_test.exs           # Property-based tests
└── mix.exs
```

**Key Features:**
- Parse CSV files using binary pattern matching
- Calculate statistics (mean, median, mode, stddev) with Enum
- Stream large files without loading into memory
- Property-based tests for edge cases

**Success Criteria:**
- [ ] Handles 1M+ row CSV files via Stream
- [ ] All functions are pure (no side effects)
- [ ] 100+ property-based tests passing
- [ ] Coverage > 90%
- [ ] Performance: p95 < 50ms for 10K rows
- [ ] Memory: < 50MB for 1M rows
- [ ] Zero Dialyzer warnings

### Pulse Feature: pulse_core

**Scope:** Pure domain logic for product catalog and pricing

**Module Structure:**
```
apps/pulse_core/
├── lib/
│   ├── pulse_core.ex
│   ├── pulse_core/
│   │   ├── product.ex              # Product domain model
│   │   ├── pricing.ex              # Pricing calculations
│   │   ├── cart.ex                 # Cart logic (pure)
│   │   └── discount.ex             # Discount rules
├── test/
│   ├── pulse_core_test.exs
│   ├── product_test.exs
│   ├── pricing_test.exs
│   └── property_test.exs
└── mix.exs
```

**Key Features:**
- Product structs with validation
- Pricing calculations (subtotal, tax, discounts)
- Cart operations (add, remove, update)
- Business rule validation

**Success Criteria:**
- [ ] All business rules in pure functions
- [ ] Comprehensive property tests
- [ ] Zero Dialyzer warnings
- [ ] Coverage > 90%
- [ ] All functions return tagged tuples
- [ ] Complete @spec and @doc coverage

---

## 🎯 Phase 1 Drills

These drills reinforce core concepts. Complete before advancing.

### Drill #1: MyList Module
Implement `map/2`, `filter/2`, `reduce/3`, `mapsum/2`

**Expected Outcome:**
- Functions are tail-recursive
- Pass property tests
- Add StreamData tests and doctests

### Drill #2: List Maximum
Implement `max/1` using pattern matching and recursion

**Expected Outcome:**
- Handles empty list as `{:error, :empty}`
- Uses pattern matching for base case
- Tail-recursive implementation

### Drill #3: Caesar Cipher
Implement `caesar/2` that rotates alphabetic characters by N

**Expected Outcome:**
- Preserves case
- Leaves non-letters unchanged
- Works on binaries (UTF-8)
- Property test: encode then decode returns original

### Drill #4: CSV Parser via Binaries
Parse a header and rows using binary pattern matching

**Expected Outcome:**
- Streaming variant with `File.stream!/1`
- Use `Stream.transform/3` for large files
- Returns list of maps with header keys

### Drill #5: Pipelines Rewrite
Take three loop-based tasks and rewrite as Enum pipelines

**Expected Outcome:**
- Identical results
- Fewer intermediate lists with Stream
- Benchmark Enum vs Stream performance

---

## 📊 Assessment Rubric

### Code Quality (30%)
- [ ] All functions pure (no side effects)
- [ ] Consistent use of pattern matching
- [ ] Proper tail recursion with accumulators
- [ ] Clear function names and module organization
- [ ] No code duplication

### Testing (25%)
- [ ] Unit tests for all public functions
- [ ] Property tests for core logic
- [ ] Doctests for examples
- [ ] Coverage > 90%
- [ ] Tests run in < 10 seconds

### Documentation (15%)
- [ ] All public functions have @spec
- [ ] All public functions have @doc
- [ ] Examples in doctests
- [ ] Module documentation (@moduledoc)
- [ ] Clear variable names (self-documenting)

### Correctness (20%)
- [ ] All tests passing
- [ ] Handles edge cases (empty lists, nil, negatives)
- [ ] Error handling with tagged tuples
- [ ] No crashes or exceptions
- [ ] Dialyzer passes (no type errors)

### Performance (10%)
- [ ] CSV parsing: p95 < 50ms for 10K rows
- [ ] Stats calculation: p95 < 100ms for 100K numbers
- [ ] Memory: < 50MB for 1M row streaming
- [ ] No unnecessary allocations

---

## ✅ Mastery Gate

You can advance to Phase 2 when:

1. **All deliverables complete**
   - [ ] `apps/labs_csv_stats` working
   - [ ] `apps/pulse_core` working

2. **All tests passing**
   - [ ] `mix test` (unit tests)
   - [ ] Property tests (100+ cases)
   - [ ] Doctests

3. **Quality gates green**
   ```bash
   make ci  # Must pass
   ```

4. **Performance targets met**
   ```bash
   k6 run tools/k6/phase-01-gate.js
   ```

5. **Conceptual understanding**
   - [ ] Can explain tail recursion vs regular recursion
   - [ ] Can articulate when to use Enum vs Stream
   - [ ] Can justify using tagged tuples vs exceptions
   - [ ] Can identify properties for property-based testing

6. **Workbook complete**
   - [ ] All 7 checkpoints finished
   - [ ] Self-assessment questions answered
   - [ ] Final challenge completed

---

## 🚨 Common Pitfalls & Solutions

### Pitfall #1: Non-Tail-Recursive Functions
**Problem:** Stack overflow on large lists

**Solution:** Use accumulators and make last call recursive
```elixir
# Bad
def sum([]), do: 0
def sum([h|t]), do: h + sum(t)

# Good
def sum(list), do: do_sum(list, 0)
defp do_sum([], acc), do: acc
defp do_sum([h|t], acc), do: do_sum(t, acc + h)
```

### Pitfall #2: Confusing Charlists and Binaries
**Problem:** `'abc'` vs `"abc"` causes unexpected errors

**Solution:** Always use double quotes for strings
```elixir
# Bad
'Hello, ' <> name  # Error!

# Good
"Hello, " <> name  # Works
```

### Pitfall #3: Loading Large Files into Memory
**Problem:** `File.read!/1` loads entire file

**Solution:** Use `File.stream!/1` for streaming
```elixir
# Bad
File.read!("large.csv") |> String.split("\n")

# Good
File.stream!("large.csv")
```

### Pitfall #4: Mixing Exceptions with Tagged Tuples
**Problem:** Inconsistent error handling

**Solution:** Pick one pattern and stick with it
```elixir
# Consistent
def find(id), do: {:ok, user} or {:error, :not_found}
```

### Pitfall #5: Realizing Streams Too Early
**Problem:** Stream benefits lost

**Solution:** Keep operations lazy until final step
```elixir
# Stream stays lazy until Enum.take
File.stream!("data.csv")
|> Stream.map(&parse/1)
|> Stream.filter(&valid?/1)
|> Enum.take(10)  # Only process 10 rows
```

---

## 📖 Recommended Reading Order

### Week 1 Reading Path

**Day 1:**
1. Programming Elixir Ch 1 (Introduction) - 30 min
2. Programming Elixir Ch 2 (Pattern Matching) - 1 hour
3. Learn FP with Elixir Ch 1 (FP Mindset) - 1.5 hours
4. Practice in IEx - 1 hour

**Day 2:**
1. Programming Elixir Ch 4 (Lists & Recursion) - 2 hours
2. Learn FP with Elixir Ch 3 (Data Structures) - 2 hours
3. Implement MyList exercises - 2 hours

**Day 3:**
1. Programming Elixir Ch 6 (Enum) - 1.5 hours
2. Programming Elixir Ch 7 (Streams) - 1 hour
3. Learn FP with Elixir Ch 4 (Transformations) - 1.5 hours
4. Pipeline exercises - 2 hours

**Day 4:**
1. Programming Elixir Ch 8 (Control Flow) - 2 hours
2. Learn FP with Elixir Ch 5 (Control Flow) - 2 hours
3. with-chain exercises - 2 hours

**Day 5:**
1. Programming Elixir Ch 9 (Testing) - 2 hours
2. StreamData documentation - 1 hour
3. Write property tests - 3 hours

---

## 🎓 Instructor Notes

### Facilitation Tips

1. **Emphasize Experimentation**
   - Encourage trying code in IEx immediately
   - "Let's break this and see what happens"
   - Make failures learning opportunities

2. **Connect to Prior Knowledge**
   - Compare recursion to loops in other languages
   - Relate pattern matching to destructuring in JS/Python
   - Show how pipelines are like Unix pipes

3. **Progressive Disclosure**
   - Don't introduce all Enum functions at once
   - Start with map/filter/reduce, add others as needed
   - Same with Stream - start simple

4. **Use Visual Aids**
   - Draw recursion call stacks
   - Diagram pipeline transformations
   - Show memory usage for Enum vs Stream

5. **Celebrate Wins**
   - First tail-recursive function: celebrate!
   - Tests pass: celebrate!
   - `make ci` green: celebrate!

### Common Questions & Answers

**Q: Why tail recursion instead of Enum?**
A: Understanding recursion is foundational. Enum is built on recursion. In practice, use Enum, but know how it works.

**Q: When should I really use Stream?**
A: Large files (>100MB), infinite sequences, or when you need only part of the result.

**Q: Why not exceptions?**
A: Exceptions for exceptional cases. Expected errors (not found, invalid input) use tagged tuples for explicit handling.

**Q: Do I need 100% test coverage?**
A: No. 90%+ is excellent. Focus on critical business logic and edge cases.

### Debugging Help

**Student stuck on recursion:**
- Draw out first 3-4 calls
- Show accumulator changing
- Trace with IO.inspect

**Student confused about Enum vs Stream:**
- Show memory usage with `:observer`
- Demonstrate with 1M element list
- Time both approaches with `:timer.tc`

**Property tests failing:**
- Check if property is actually true
- Look at generated values (use `check all` with `IO.inspect`)
- Simplify property to isolate issue

---

## 📚 Additional Resources

### Books (Optional)
- **Elixir in Action** by Saša Jurić (alternative perspective)
- **Functional Programming Patterns in Scala and Clojure** (concepts apply)

### Video Courses
- ElixirCasts.io (basic Elixir)
- Pragmatic Studio Elixir course

### Practice Platforms
- Exercism Elixir track
- Codewars Elixir problems
- Advent of Code (in Elixir)

### Community
- Elixir Forum
- Elixir Slack
- /r/elixir on Reddit

---

## 🔄 Continuous Improvement

### Lesson Plan Updates

This lesson plan should be updated based on:
- Student feedback on pacing
- Common struggle points
- New Elixir version features
- Better teaching methods discovered

**Review cycle:** After each cohort completes Phase 1

**Feedback channels:**
- Retrospective at end of phase
- Daily check-ins during week 2
- Post-phase survey

---

## 📅 Next Phase Preview

**Phase 2: Processes & Mailboxes**

You'll learn:
- Process creation and message passing
- Mailboxes and timeouts
- Links and monitors
- Building stateful systems with bare processes

**Preview exercise:** Build a simple counter using `spawn` and `receive` to get a taste of what's coming.

---

**End of Phase 1 Lesson Plan**

Generated: 2025-11-05
Version: 1.0
Maintainer: System
Based on: docs/roadmap.md, docs/reading/phase-01-core.md
