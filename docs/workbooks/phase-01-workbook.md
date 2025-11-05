# Phase 1 Workbook — Elixir Core

**Interactive exercises and self-assessment for mastering functional programming in Elixir.**

---

## 📋 Workbook Overview

**Purpose:** Hands-on practice with pattern matching, recursion, Enum/Stream, and property-based testing.

**Prerequisites:** Phase 0 complete (tooling setup working)

**Time Estimate:** 2-3 days of focused practice

**How to Use:**
1. Work through exercises sequentially
2. Check your answers against the solutions (at bottom)
3. Run code in IEx to verify understanding
4. Complete all checkpoints before advancing

---

## 🎯 Learning Checkpoint 1: Pattern Matching & Guards

### Exercise 1.1: Complete the Pattern Match

Fill in the blanks to make these pattern matches work:

```elixir
# Match on a tuple
{:ok, ______} = {:ok, 42}

# Match on a list head and tail
[first | ______] = [1, 2, 3, 4]

# Match on a map with specific keys
%{name: ______, age: user_age} = %{name: "Alice", age: 30}

# Match with a guard
def adult?(age) when ______ do
  true
end
def adult?(_), do: false
```

### Exercise 1.2: Fix the Guards

This code has bugs. Fix the guard clauses:

```elixir
defmodule SafeMath do
  # Bug: Guard allows zero division
  def safe_div(a, b) when is_number(a) and is_number(b) do
    {:ok, a / b}
  end

  # Bug: Missing guard for negative numbers
  def sqrt(n) do
    {:ok, :math.sqrt(n)}
  end
end
```

### Exercise 1.3: Pattern Match Challenge

Write a function that matches on different result tuples:

```elixir
defmodule ResultHandler do
  @doc """
  Unwraps results or provides default values.

  ## Examples
      iex> ResultHandler.unwrap({:ok, 42}, 0)
      42

      iex> ResultHandler.unwrap({:error, :not_found}, 0)
      0

      iex> ResultHandler.unwrap(nil, 0)
      0
  """
  def unwrap(_______, default) do
    # Your implementation here
  end
end
```

### ✅ Checkpoint 1 Self-Assessment

- [ ] I can match on tuples, lists, and maps
- [ ] I understand when to use guards vs pattern matching
- [ ] I can write multiple function heads with different patterns
- [ ] I know the difference between `=` (match) and `==` (equality)

---

## 🎯 Learning Checkpoint 2: Recursion & Tail-Call Optimization

### Exercise 2.1: Identify the Problem

This recursive function will crash on large lists. Why?

```elixir
defmodule BadList do
  def sum([]), do: 0
  def sum([h | t]), do: h + sum(t)
end

# Try: BadList.sum(1..100_000 |> Enum.to_list())
# What happens?
```

**Answer:** ___________________________________________

### Exercise 2.2: Convert to Tail Recursion

Rewrite this function to be tail-recursive:

```elixir
defmodule MyList do
  # Non-tail-recursive version
  def length([]), do: 0
  def length([_ | t]), do: 1 + length(t)

  # Tail-recursive version (fill in the blanks)
  def length(list), do: do_length(list, ______)

  defp do_length([], acc), do: ______
  defp do_length([_ | t], acc), do: do_length(______, ______)
end
```

### Exercise 2.3: Implement map/2

Implement a tail-recursive `map/2` function:

```elixir
defmodule MyList do
  @doc """
  Maps a function over a list.

  ## Examples
      iex> MyList.map([1, 2, 3], fn x -> x * 2 end)
      [2, 4, 6]

      iex> MyList.map([], fn x -> x * 2 end)
      []
  """
  def map(list, func) do
    # Your implementation here
    # Hint: Use an accumulator and reverse at the end
  end
end
```

### Exercise 2.4: Implement filter/2

Implement a tail-recursive `filter/2` function:

```elixir
defmodule MyList do
  @doc """
  Filters a list based on a predicate.

  ## Examples
      iex> MyList.filter([1, 2, 3, 4], fn x -> rem(x, 2) == 0 end)
      [2, 4]

      iex> MyList.filter([1, 3, 5], fn x -> rem(x, 2) == 0 end)
      []
  """
  def filter(list, predicate) do
    # Your implementation here
  end
end
```

### ✅ Checkpoint 2 Self-Assessment

- [ ] I understand the difference between tail and non-tail recursion
- [ ] I can use accumulators to make recursion tail-optimized
- [ ] I know when to reverse the accumulator
- [ ] I can implement basic list operations recursively

---

## 🎯 Learning Checkpoint 3: Enum vs Stream

### Exercise 3.1: Identify Eager vs Lazy

Mark each operation as EAGER or LAZY:

```elixir
# A
1..10 |> Enum.map(&(&1 * 2))  # _______

# B
1..10 |> Stream.map(&(&1 * 2))  # _______

# C
File.stream!("large.csv") |> Stream.take(5)  # _______

# D
File.stream!("large.csv") |> Enum.take(5)  # _______
```

### Exercise 3.2: Choose the Right Tool

For each scenario, choose Enum or Stream and explain why:

1. Processing a 5GB log file to find errors
   - **Choice:** _______
   - **Why:** _______

2. Transforming a list of 100 items for display
   - **Choice:** _______
   - **Why:** _______

3. Generating an infinite sequence of Fibonacci numbers
   - **Choice:** _______
   - **Why:** _______

4. Sorting a list of 1,000 records
   - **Choice:** _______
   - **Why:** _______

### Exercise 3.3: Pipeline Transformation

Rewrite this imperative code as an Enum pipeline:

```elixir
# Imperative version
def process_numbers(nums) do
  result = []
  for n <- nums do
    if rem(n, 2) == 0 do
      squared = n * n
      result = [squared | result]
    end
  end
  Enum.reverse(result)
end

# Functional pipeline version
def process_numbers(nums) do
  # Your implementation here
end
```

### Exercise 3.4: Stream Efficiency Challenge

This code loads the entire file into memory. Fix it to stream:

```elixir
defmodule LogAnalyzer do
  # BAD: Loads entire file
  def count_errors(path) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.filter(&String.contains?(&1, "ERROR"))
    |> Enum.count()
  end

  # GOOD: Streams the file (fill in the blanks)
  def count_errors(path) do
    path
    |> ____________
    |> ____________
    |> ____________
  end
end
```

### ✅ Checkpoint 3 Self-Assessment

- [ ] I know when to use Enum vs Stream
- [ ] I can write clear pipeline transformations
- [ ] I understand lazy evaluation and when it's triggered
- [ ] I can refactor imperative loops to functional pipelines

---

## 🎯 Learning Checkpoint 4: Tagged Tuples & Error Handling

### Exercise 4.1: Convert Exceptions to Tagged Tuples

Rewrite this exception-based code to use tagged tuples:

```elixir
# Exception-based
defmodule UserFinder do
  def find!(id) do
    case Database.get(id) do
      nil -> raise "User not found"
      user -> user
    end
  end
end

# Tagged tuple version
defmodule UserFinder do
  def find(id) do
    # Your implementation here
  end
end
```

### Exercise 4.2: Build a with Pipeline

Complete this `with` chain for user registration:

```elixir
defmodule UserRegistration do
  def register(params) do
    with {:ok, validated} <- validate_params(params),
         ______ <- check_email_available(validated.email),
         ______ <- create_user(validated),
         ______ <- send_welcome_email(user) do
      {:ok, user}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Helper functions (already implemented)
  defp validate_params(params), do: # ...
  defp check_email_available(email), do: # ...
  defp create_user(params), do: # ...
  defp send_welcome_email(user), do: # ...
end
```

### Exercise 4.3: Find the Bug

This `with` chain has a bug. What's wrong?

```elixir
def process_order(order_id) do
  with {:ok, order} <- fetch_order(order_id),
       {:ok, payment} <- process_payment(order),
       {:ok, inventory} <- reserve_inventory(order),
       :ok <- notify_customer(order) do
    {:ok, order}
  else
    err -> err  # Bug is here!
  end
end
```

**Problem:** ___________________________________________
**Fix:** ___________________________________________

### ✅ Checkpoint 4 Self-Assessment

- [ ] I use tagged tuples instead of exceptions for expected errors
- [ ] I can build `with` chains for success-path operations
- [ ] I handle all error cases in the `else` clause
- [ ] I keep return shapes consistent ({:ok, _} | {:error, _})

---

## 🎯 Learning Checkpoint 5: Property-Based Testing

### Exercise 5.1: Understand Properties

For each function, identify a property that should always be true:

```elixir
# Function: Enum.reverse/1
# Property: ___________________________________________

# Function: MyList.map/2
# Property: ___________________________________________

# Function: String.upcase/1 |> String.downcase/1
# Property: ___________________________________________

# Function: Enum.sort/1
# Property: ___________________________________________
```

### Exercise 5.2: Write Your First Property Test

Complete this property test for `MyList.length/1`:

```elixir
defmodule MyListTest do
  use ExUnit.Case
  use ExUnitProperties

  property "length is always non-negative" do
    check all list <- list_of(______) do
      length = MyList.length(list)
      assert ______ >= 0
    end
  end

  property "length of concatenated lists equals sum of lengths" do
    check all list1 <- list_of(integer()),
              list2 <- list_of(integer()) do
      combined = list1 ++ list2
      assert MyList.length(combined) == ______ + ______
    end
  end
end
```

### Exercise 5.3: Property Test for Caesar Cipher

Write a property test for a Caesar cipher that verifies encoding and decoding:

```elixir
defmodule CaesarTest do
  use ExUnit.Case
  use ExUnitProperties

  property "encoding then decoding returns original" do
    check all text <- ______,
              shift <- ______ do
      encoded = Caesar.encode(text, shift)
      decoded = Caesar.decode(encoded, shift)
      assert ______ == text
    end
  end
end
```

### ✅ Checkpoint 5 Self-Assessment

- [ ] I can identify invariant properties of functions
- [ ] I can write property tests using StreamData
- [ ] I understand how property tests find edge cases
- [ ] I prefer property tests over example-based tests when appropriate

---

## 🎯 Learning Checkpoint 6: Strings, Binaries & CSV Parsing

### Exercise 6.1: String vs Charlist

Fix the bugs caused by string/charlist confusion:

```elixir
defmodule StringBugs do
  # Bug: Wrong quote type
  def greet(name) do
    'Hello, ' <> name <> '!'
  end

  # Bug: Mixing charlists and binaries
  def join(words) do
    Enum.join(words, ', ')
  end

  # This will break: join(['hello', "world"])
end
```

### Exercise 6.2: Binary Pattern Matching

Complete this CSV row parser using binary pattern matching:

```elixir
defmodule CSVParser do
  @doc """
  Parses a single CSV row.

  ## Examples
      iex> CSVParser.parse_row("Alice,30,Engineer")
      ["Alice", "30", "Engineer"]

      iex> CSVParser.parse_row("Bob,25,Designer")
      ["Bob", "25", "Designer"]
  """
  def parse_row(line) do
    # Hint: Use String.split/2
  end

  @doc """
  Parses CSV with headers.

  ## Examples
      iex> csv = "name,age,job\\nAlice,30,Engineer"
      iex> CSVParser.parse_with_headers(csv)
      {:ok, [%{"name" => "Alice", "age" => "30", "job" => "Engineer"}]}
  """
  def parse_with_headers(csv) do
    # Your implementation here
  end
end
```

### Exercise 6.3: Streaming CSV Parser

Implement a streaming CSV parser for large files:

```elixir
defmodule CSVStream do
  @doc """
  Returns a stream of parsed CSV rows.

  ## Examples
      iex> CSVStream.parse("data.csv") |> Enum.take(2)
      [["Alice", "30"], ["Bob", "25"]]
  """
  def parse(path) do
    path
    |> File.stream!()
    |> Stream.map(______)  # Strip newlines
    |> Stream.map(______)  # Parse each row
  end
end
```

### ✅ Checkpoint 6 Self-Assessment

- [ ] I understand the difference between strings and charlists
- [ ] I can use binary pattern matching for parsing
- [ ] I can build streaming parsers for large files
- [ ] I handle UTF-8 correctly using String module

---

## 🎯 Learning Checkpoint 7: Core Data Structures

### Exercise 7.1: Choose the Right Structure

For each use case, pick the best data structure (tuple, list, map, keyword list, struct):

1. Function return with status and value: _______
2. Configuration options with defaults: _______
3. User record with name, email, age: _______
4. Collection of items to process in order: _______
5. Cache with key-value lookups: _______

### Exercise 7.2: Define a Struct

Create a `Product` struct with validation:

```elixir
defmodule Product do
  # Define struct with: id, name, price, in_stock
  defstruct ______

  @doc """
  Creates a new product with validation.

  ## Examples
      iex> Product.new(id: 1, name: "Widget", price: 9.99, in_stock: true)
      {:ok, %Product{id: 1, name: "Widget", price: 9.99, in_stock: true}}

      iex> Product.new(id: 1, name: "", price: -5, in_stock: true)
      {:error, :invalid_product}
  """
  def new(fields) do
    # Validate and return {:ok, struct} or {:error, reason}
  end
end
```

### Exercise 7.3: Map vs Keyword List

When should you use keyword lists instead of maps?

**Answer:** ___________________________________________

### ✅ Checkpoint 7 Self-Assessment

- [ ] I can choose the appropriate data structure for each use case
- [ ] I know when to use structs vs maps
- [ ] I understand keyword list limitations (duplicate keys allowed)
- [ ] I can define structs with @enforce_keys

---

## 🎯 Final Challenge: Build a Statistics Calculator

Put everything together to build a streaming statistics calculator.

### Requirements

```elixir
defmodule Stats do
  @moduledoc """
  Statistical calculations using pure functions and streaming.
  """

  defstruct [:mean, :median, :mode, :std_dev, :count]

  @doc """
  Calculates statistics for a list of numbers.

  ## Examples
      iex> Stats.calculate([1, 2, 3, 4, 5])
      {:ok, %Stats{mean: 3.0, median: 3, mode: [1, 2, 3, 4, 5], std_dev: 1.41, count: 5}}
  """
  def calculate(numbers) when is_list(numbers) do
    # Your implementation here
  end

  @doc """
  Streams a CSV file and calculates statistics for a column.

  ## Examples
      iex> Stats.from_csv("data.csv", column: "age")
      {:ok, %Stats{...}}
  """
  def from_csv(path, opts) do
    # Your implementation here
    # Must use Stream for large files
  end
end
```

### Test Requirements

Write tests that verify:
- [ ] Handles empty lists gracefully
- [ ] Calculates correct mean, median, mode, std_dev
- [ ] Property test: mean is always between min and max
- [ ] Property test: count equals list length
- [ ] Streams files without loading into memory
- [ ] Handles non-numeric values in CSV

---

## ✅ Final Self-Assessment

Before moving to Phase 2, verify you can:

- [ ] Write pure functions with pattern matching and guards
- [ ] Implement tail-recursive functions with accumulators
- [ ] Choose between Enum and Stream appropriately
- [ ] Build pipeline transformations with `|>`
- [ ] Handle errors with tagged tuples and `with`
- [ ] Write property-based tests with StreamData
- [ ] Parse CSV using binary pattern matching
- [ ] Stream large files efficiently
- [ ] Define and use structs for domain models
- [ ] Achieve >90% test coverage
- [ ] Pass all Dialyzer checks

---

## 📚 Solutions

<details>
<summary>Click to reveal solutions (try exercises first!)</summary>

### Solution 1.1: Pattern Matching

```elixir
{:ok, value} = {:ok, 42}
[first | rest] = [1, 2, 3, 4]
%{name: user_name, age: user_age} = %{name: "Alice", age: 30}

def adult?(age) when age >= 18 do
  true
end
```

### Solution 1.2: Fixed Guards

```elixir
defmodule SafeMath do
  def safe_div(a, b) when is_number(a) and is_number(b) and b != 0 do
    {:ok, a / b}
  end
  def safe_div(_, 0), do: {:error, :zero_division}

  def sqrt(n) when is_number(n) and n >= 0 do
    {:ok, :math.sqrt(n)}
  end
  def sqrt(n) when is_number(n) and n < 0 do
    {:error, :negative_number}
  end
end
```

### Solution 1.3: Result Handler

```elixir
defmodule ResultHandler do
  def unwrap({:ok, value}, _default), do: value
  def unwrap({:error, _}, default), do: default
  def unwrap(nil, default), do: default
end
```

### Solution 2.1: Recursion Problem

**Answer:** The function is not tail-recursive. Each call adds a stack frame, causing a stack overflow on large lists (100K+ items). The `+ sum(t)` operation happens *after* the recursive call returns.

### Solution 2.2: Tail-Recursive Length

```elixir
def length(list), do: do_length(list, 0)

defp do_length([], acc), do: acc
defp do_length([_ | t], acc), do: do_length(t, acc + 1)
```

### Solution 2.3: Tail-Recursive map/2

```elixir
def map(list, func), do: do_map(list, func, [])

defp do_map([], _func, acc), do: Enum.reverse(acc)
defp do_map([h | t], func, acc) do
  do_map(t, func, [func.(h) | acc])
end
```

### Solution 2.4: Tail-Recursive filter/2

```elixir
def filter(list, predicate), do: do_filter(list, predicate, [])

defp do_filter([], _pred, acc), do: Enum.reverse(acc)
defp do_filter([h | t], pred, acc) do
  if pred.(h) do
    do_filter(t, pred, [h | acc])
  else
    do_filter(t, pred, acc)
  end
end
```

### Solution 3.1: Eager vs Lazy

```elixir
# A: EAGER - Enum.map evaluates immediately
# B: LAZY - Stream.map returns a stream
# C: LAZY - File.stream! returns a stream, take/5 is lazy
# D: EAGER - Enum.take/2 forces evaluation
```

### Solution 3.2: Choosing Enum vs Stream

1. **Stream** - Large file; don't want to load into memory
2. **Enum** - Small list; eager evaluation is fine
3. **Stream** - Infinite sequence; must be lazy
4. **Enum** - Sorting requires full collection anyway

### Solution 3.3: Pipeline Transformation

```elixir
def process_numbers(nums) do
  nums
  |> Enum.filter(&(rem(&1, 2) == 0))
  |> Enum.map(&(&1 * &1))
end
```

### Solution 3.4: Streaming Log Analyzer

```elixir
def count_errors(path) do
  path
  |> File.stream!()
  |> Stream.filter(&String.contains?(&1, "ERROR"))
  |> Enum.count()
end
```

### Solution 4.1: Tagged Tuples

```elixir
defmodule UserFinder do
  def find(id) do
    case Database.get(id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
```

### Solution 4.2: with Pipeline

```elixir
with {:ok, validated} <- validate_params(params),
     {:ok, _} <- check_email_available(validated.email),
     {:ok, user} <- create_user(validated),
     {:ok, _} <- send_welcome_email(user) do
  {:ok, user}
else
  {:error, reason} -> {:error, reason}
end
```

### Solution 4.3: with Bug

**Problem:** The `:ok` return from `notify_customer/1` doesn't match the `{:error, _}` pattern in else, causing a `WithClauseError`.

**Fix:** Either change `notify_customer` to return `{:ok, :sent}` or handle `:ok` in the else clause.

### Solution 5.2: Property Tests

```elixir
property "length is always non-negative" do
  check all list <- list_of(integer()) do
    length = MyList.length(list)
    assert length >= 0
  end
end

property "length of concatenated lists equals sum of lengths" do
  check all list1 <- list_of(integer()),
            list2 <- list_of(integer()) do
    combined = list1 ++ list2
    assert MyList.length(combined) == MyList.length(list1) + MyList.length(list2)
  end
end
```

</details>

---

## 📖 Additional Resources

- **Elixir Pattern Matching Guide:** https://elixir-lang.org/getting-started/pattern-matching.html
- **Enum vs Stream:** https://hexdocs.pm/elixir/Enum.html and https://hexdocs.pm/elixir/Stream.html
- **StreamData Documentation:** https://hexdocs.pm/stream_data
- **Recursion Tutorial:** https://elixirschool.com/en/lessons/basics/functions#recursion

---

**Next:** Complete Phase 1 Study Guide for structured learning schedule.
