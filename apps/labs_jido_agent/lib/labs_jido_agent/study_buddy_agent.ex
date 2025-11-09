defmodule LabsJidoAgent.StudyBuddyAgent do
  @moduledoc """
  An AI agent that answers questions about Elixir concepts using RAG (Retrieval Augmented Generation).

  This agent demonstrates:
  - Knowledge base integration
  - Context retrieval
  - Socratic questioning method
  - Progressive disclosure of information

  ## Examples

      {:ok, answer} = StudyBuddyAgent.ask("What is tail recursion?")
      IO.puts(answer)

      {:ok, answer} = StudyBuddyAgent.ask("How do I use GenServer?", phase: 3)
      IO.puts(answer)
  """

  use Jido.Agent,
    name: "study_buddy",
    description: "Answers questions about Elixir concepts and guides learning",
    schema: [
      question: [type: :string, required: true, doc: "The student's question"],
      phase: [type: :integer, default: 1, doc: "Current learning phase"],
      mode: [
        type: {:in, [:explain, :socratic, :example]},
        default: :explain,
        doc: "Response mode"
      ]
    ]

  alias Jido.Agent.{Directive, Signal}

  @impl Jido.Agent
  def plan(agent, directive) do
    question = Directive.get_param(directive, :question)
    phase = Directive.get_param(directive, :phase, 1)
    mode = Directive.get_param(directive, :mode, :explain)

    # Determine what concepts are involved
    concepts = extract_concepts(question)

    # Find relevant resources
    resources = find_resources(concepts, phase)

    plan = %{
      question: question,
      phase: phase,
      mode: mode,
      concepts: concepts,
      resources: resources
    }

    {:ok, Agent.put_plan(agent, plan)}
  end

  @impl Jido.Agent
  def act(agent) do
    plan = Agent.get_plan(agent)

    # Generate response based on mode
    response =
      case plan.mode do
        :explain -> generate_explanation(plan)
        :socratic -> generate_socratic_questions(plan)
        :example -> generate_examples(plan)
      end

    result = %{
      answer: response,
      concepts: plan.concepts,
      resources: plan.resources,
      follow_up_suggestions: generate_follow_ups(plan.concepts, plan.phase)
    }

    {:ok, Agent.put_result(agent, result)}
  end

  @impl Jido.Agent
  def observe(agent) do
    result = Agent.get_result(agent)

    observations = %{
      concepts_covered: length(result.concepts),
      resources_provided: length(result.resources),
      follow_ups_available: length(result.follow_up_suggestions)
    }

    signal = Signal.new(:question_answered, observations)
    {:ok, agent, [signal]}
  end

  # Private functions

  defp extract_concepts(question) do
    question_lower = String.downcase(question)

    concepts = []

    concepts =
      if String.contains?(question_lower, ["recursion", "recursive"]) do
        [:recursion | concepts]
      else
        concepts
      end

    concepts =
      if String.contains?(question_lower, ["tail", "tail-call", "tco"]) do
        [:tail_call_optimization | concepts]
      else
        concepts
      end

    concepts =
      if String.contains?(question_lower, ["pattern", "match"]) do
        [:pattern_matching | concepts]
      else
        concepts
      end

    concepts =
      if String.contains?(question_lower, ["genserver", "gen_server"]) do
        [:genserver | concepts]
      else
        concepts
      end

    concepts =
      if String.contains?(question_lower, ["process", "spawn"]) do
        [:processes | concepts]
      else
        concepts
      end

    concepts =
      if String.contains?(question_lower, ["supervision", "supervisor"]) do
        [:supervision | concepts]
      else
        concepts
      end

    if concepts == [], do: [:general], else: concepts
  end

  defp find_resources(concepts, phase) do
    Enum.flat_map(concepts, fn concept ->
      get_resources_for_concept(concept, phase)
    end)
    |> Enum.uniq()
  end

  defp get_resources_for_concept(:recursion, _phase) do
    [
      "Livebook: phase-01-core/02-recursion.livemd",
      "Official Elixir Guide: Recursion",
      "Exercise: Implement tail-recursive list operations"
    ]
  end

  defp get_resources_for_concept(:pattern_matching, _phase) do
    [
      "Livebook: phase-01-core/01-pattern-matching.livemd",
      "Official Elixir Guide: Pattern Matching",
      "Exercise: Match on different data structures"
    ]
  end

  defp get_resources_for_concept(:genserver, phase) when phase >= 3 do
    [
      "Livebook: phase-03-genserver/01-genserver-basics.livemd",
      "Official Elixir docs: GenServer",
      "Lab: labs_counter_ttl"
    ]
  end

  defp get_resources_for_concept(:genserver, _phase) do
    [
      "Complete Phase 1 and 2 first",
      "GenServer is covered in Phase 3"
    ]
  end

  defp get_resources_for_concept(_, _), do: []

  defp generate_explanation(plan) do
    # Simulated RAG response
    case List.first(plan.concepts) do
      :recursion ->
        """
        **Recursion in Elixir**

        Recursion is when a function calls itself. In Elixir, it's a fundamental pattern for processing lists and other data structures.

        **Key Concepts:**
        1. **Base case**: The condition that stops recursion
        2. **Recursive case**: The function calls itself with modified arguments

        **Example:**
        ```elixir
        def sum([]), do: 0
        def sum([h | t]), do: h + sum(t)
        ```

        **Important**: For large lists, you need tail-call optimization. See resources below for more details.
        """

      :tail_call_optimization ->
        """
        **Tail-Call Optimization (TCO)**

        A tail-recursive function is one where the recursive call is the LAST operation. The BEAM can optimize this into a loop.

        **Non-tail-recursive** (builds up stack):
        ```elixir
        def sum([]), do: 0
        def sum([h | t]), do: h + sum(t)  # Addition happens AFTER
        ```

        **Tail-recursive** (constant stack):
        ```elixir
        def sum(list), do: sum(list, 0)
        defp sum([], acc), do: acc
        defp sum([h | t], acc), do: sum(t, acc + h)  # Recursive call is LAST
        ```

        The key is using an **accumulator** to carry state through the recursion.
        """

      :pattern_matching ->
        """
        **Pattern Matching**

        Pattern matching is one of Elixir's most powerful features. The `=` operator matches the left side to the right side.

        **Key Patterns:**
        - Tuples: `{:ok, value} = {:ok, 42}`
        - Lists: `[head | tail] = [1, 2, 3]`
        - Maps: `%{name: n} = %{name: "Alice", age: 30}`

        **In Functions:**
        ```elixir
        def greet({:ok, name}), do: "Hello, \#{name}!"
        def greet({:error, _}), do: "Error!"
        ```

        Pattern matching happens at compile-time when possible, making it very efficient!
        """

      :genserver ->
        """
        **GenServer**

        GenServer (Generic Server) is a behaviour for building stateful processes in Elixir.

        **Core Callbacks:**
        - `init/1`: Initialize state
        - `handle_call/3`: Synchronous requests
        - `handle_cast/2`: Asynchronous messages
        - `handle_info/2`: Other messages

        **Example:**
        ```elixir
        defmodule Counter do
          use GenServer

          def start_link(initial) do
            GenServer.start_link(__MODULE__, initial, name: __MODULE__)
          end

          def increment do
            GenServer.call(__MODULE__, :increment)
          end

          def init(initial), do: {:ok, initial}

          def handle_call(:increment, _from, state) do
            {:reply, state + 1, state + 1}
          end
        end
        ```
        """

      _ ->
        """
        I can help you learn about Elixir concepts! Your question: "#{plan.question}"

        Try asking about specific topics like:
        - Pattern matching
        - Recursion and tail-call optimization
        - Processes and message passing
        - GenServer and OTP
        - Supervision trees
        - Enum vs Stream
        """
    end
  end

  defp generate_socratic_questions(plan) do
    # Guide learning through questions
    case List.first(plan.concepts) do
      :recursion ->
        """
        Let's explore recursion together. Consider these questions:

        1. What happens to the call stack when you call a function recursively?
        2. In `def sum([h | t]), do: h + sum(t)`, what operation happens AFTER the recursive call returns?
        3. How could you modify this function so the recursive call is the last operation?
        4. What role does an accumulator play in tail recursion?

        Think about these, then check your understanding against the examples in the resources below.
        """

      :pattern_matching ->
        """
        Let's think about pattern matching:

        1. What's the difference between `=` (match operator) and `==` (equality)?
        2. What happens if a pattern match fails?
        3. How does pattern matching in function heads differ from `case` statements?
        4. When would you use the pin operator `^`?

        Try experimenting with these concepts in IEx or Livebook!
        """

      _ ->
        generate_explanation(plan)
    end
  end

  defp generate_examples(plan) do
    case List.first(plan.concepts) do
      :recursion ->
        """
        **Recursion Examples**

        **Example 1: List Length**
        ```elixir
        # Non-tail-recursive
        def length([]), do: 0
        def length([_ | t]), do: 1 + length(t)

        # Tail-recursive
        def length(list), do: length(list, 0)
        defp length([], acc), do: acc
        defp length([_ | t], acc), do: length(t, acc + 1)
        ```

        **Example 2: Map Implementation**
        ```elixir
        def map(list, func), do: map(list, func, [])

        defp map([], _func, acc), do: Enum.reverse(acc)
        defp map([h | t], func, acc) do
          map(t, func, [func.(h) | acc])
        end
        ```

        **Example 3: Filter Implementation**
        ```elixir
        def filter(list, pred), do: filter(list, pred, [])

        defp filter([], _pred, acc), do: Enum.reverse(acc)
        defp filter([h | t], pred, acc) do
          if pred.(h) do
            filter(t, pred, [h | acc])
          else
            filter(t, pred, acc)
          end
        end
        ```

        Try implementing these yourself! Check your work against the Livebook exercises.
        """

      _ ->
        generate_explanation(plan)
    end
  end

  defp generate_follow_ups(concepts, phase) do
    base_suggestions = [
      "Try the interactive exercises in Livebook",
      "Implement the concept yourself",
      "Review related checkpoints"
    ]

    concept_suggestions =
      Enum.flat_map(concepts, fn concept ->
        case concept do
          :recursion ->
            [
              "Next: Learn about Enum vs Stream",
              "Practice: Implement reduce/3 using recursion"
            ]

          :pattern_matching ->
            [
              "Next: Learn about guards",
              "Practice: Write a function with multiple pattern-matched heads"
            ]

          :genserver when phase >= 3 ->
            [
              "Next: Learn about Supervision",
              "Practice: Build labs_counter_ttl"
            ]

          _ ->
            []
        end
      end)

    base_suggestions ++ concept_suggestions
  end

  ## Public API

  @doc """
  Ask a question and get an explanation.

  ## Options
    * `:phase` - Current learning phase (1-15)
    * `:mode` - Response mode (`:explain`, `:socratic`, `:example`)

  ## Examples

      {:ok, answer} = StudyBuddyAgent.ask("What is recursion?")
      {:ok, answer} = StudyBuddyAgent.ask("How do I use GenServer?", phase: 3, mode: :example)
  """
  def ask(question, opts \\ []) do
    directive =
      Directive.new(:ask_question,
        params: %{
          question: question,
          phase: Keyword.get(opts, :phase, 1),
          mode: Keyword.get(opts, :mode, :explain)
        }
      )

    case Jido.Agent.run(__MODULE__, directive) do
      {:ok, agent} ->
        result = Agent.get_result(agent)

        {:ok,
         %{
           answer: result.answer,
           resources: result.resources,
           follow_ups: result.follow_up_suggestions
         }}

      error ->
        error
    end
  end
end
