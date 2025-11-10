defmodule LabsJidoAgent.StudyBuddyAction do
  @moduledoc """
  A Jido Action that answers questions about Elixir concepts.

  This action provides three response modes:
  - `:explain` - Direct explanations with theory and examples
  - `:socratic` - Guides learning through questions
  - `:example` - Provides runnable code examples

  ## Examples

      params = %{question: "What is tail recursion?", phase: 1, mode: :explain}
      {:ok, response} = LabsJidoAgent.StudyBuddyAction.run(params, %{})
  """

  use Jido.Action,
    name: "study_buddy",
    description: "Answers questions about Elixir concepts and guides learning",
    category: "education",
    tags: ["qa", "elixir", "learning"],
    schema: [
      question: [type: :string, required: true, doc: "The student's question"],
      phase: [type: :integer, default: 1, doc: "Current learning phase"],
      mode: [
        type: {:in, [:explain, :socratic, :example]},
        default: :explain,
        doc: "Response mode"
      ]
    ]

  @impl true
  def run(params, _context) do
    question = params.question
    phase = params.phase
    mode = params.mode

    # Determine what concepts are involved
    concepts = extract_concepts(question)

    # Find relevant resources
    resources = find_resources(concepts, phase)

    # Generate response based on mode
    answer =
      case mode do
        :explain -> generate_explanation(concepts, question)
        :socratic -> generate_socratic_questions(concepts, question)
        :example -> generate_examples(concepts, question)
      end

    response = %{
      answer: answer,
      concepts: concepts,
      resources: resources,
      follow_ups: generate_follow_ups(concepts, phase)
    }

    {:ok, response}
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
      "Official Elixir Guide: Recursion"
    ]
  end

  defp get_resources_for_concept(:pattern_matching, _phase) do
    [
      "Livebook: phase-01-core/01-pattern-matching.livemd",
      "Official Elixir Guide: Pattern Matching"
    ]
  end

  defp get_resources_for_concept(:genserver, phase) when phase >= 3 do
    [
      "Livebook: phase-03-genserver/01-genserver-basics.livemd",
      "Official Elixir docs: GenServer"
    ]
  end

  defp get_resources_for_concept(:genserver, _phase) do
    ["GenServer is covered in Phase 3"]
  end

  defp get_resources_for_concept(_, _), do: []

  defp generate_explanation(concepts, _question) do
    case List.first(concepts) do
      :recursion ->
        """
        **Recursion in Elixir**

        Recursion is when a function calls itself. In Elixir, it's fundamental for processing lists.

        **Key Concepts:**
        1. **Base case** - Stops recursion
        2. **Recursive case** - Calls itself with modified arguments

        **Example:**
        ```elixir
        def sum([]), do: 0
        def sum([h | t]), do: h + sum(t)
        ```

        **Important**: For large lists, use tail-call optimization with an accumulator.
        """

      :tail_call_optimization ->
        """
        **Tail-Call Optimization (TCO)**

        A tail-recursive function has the recursive call as the LAST operation.

        **Non-tail-recursive** (builds up stack):
        ```elixir
        def sum([]), do: 0
        def sum([h | t]), do: h + sum(t)  # Addition happens AFTER
        ```

        **Tail-recursive** (constant stack):
        ```elixir
        def sum(list), do: sum(list, 0)
        defp sum([], acc), do: acc
        defp sum([h | t], acc), do: sum(t, acc + h)  # Call is LAST
        ```
        """

      :pattern_matching ->
        """
        **Pattern Matching**

        The `=` operator matches left to right in Elixir.

        **Examples:**
        - `{:ok, value} = {:ok, 42}`
        - `[head | tail] = [1, 2, 3]`
        - `%{name: n} = %{name: "Alice", age: 30}`

        Pattern matching in functions:
        ```elixir
        def greet({:ok, name}), do: "Hello, \#{name}!"
        def greet({:error, _}), do: "Error!"
        ```
        """

      _ ->
        """
        I can help you learn about Elixir! Try asking about:
        - Pattern matching
        - Recursion and tail-call optimization
        - Processes and message passing
        - GenServer and OTP
        """
    end
  end

  defp generate_socratic_questions(concepts, question) do
    case List.first(concepts) do
      :recursion ->
        """
        Let's explore recursion together:

        1. What happens to the call stack when you call a function recursively?
        2. In `def sum([h | t]), do: h + sum(t)`, what operation happens AFTER the recursive call?
        3. How could you modify this so the recursive call is the last operation?
        4. What role does an accumulator play in tail recursion?

        Think about these, then check the resources below.
        """

      _ ->
        generate_explanation(concepts, question)
    end
  end

  defp generate_examples(concepts, question) do
    case List.first(concepts) do
      :recursion ->
        """
        **Recursion Examples**

        **List Length:**
        ```elixir
        # Tail-recursive
        def length(list), do: length(list, 0)
        defp length([], acc), do: acc
        defp length([_ | t], acc), do: length(t, acc + 1)
        ```

        **Map Implementation:**
        ```elixir
        def map(list, func), do: map(list, func, [])

        defp map([], _func, acc), do: Enum.reverse(acc)
        defp map([h | t], func, acc), do: map(t, func, [func.(h) | acc])
        ```
        """

      _ ->
        generate_explanation(concepts, question)
    end
  end

  defp generate_follow_ups(concepts, _phase) do
    base_suggestions = [
      "Try the interactive exercises in Livebook"
    ]

    concept_suggestions =
      Enum.flat_map(concepts, fn concept ->
        case concept do
          :recursion -> ["Next: Learn about Enum vs Stream"]
          :pattern_matching -> ["Next: Learn about guards"]
          _ -> []
        end
      end)

    base_suggestions ++ concept_suggestions
  end

  ## Public Helper API

  @doc """
  Ask a question (convenience wrapper).

  ## Examples

      {:ok, response} = LabsJidoAgent.StudyBuddyAction.ask("What is recursion?")
      {:ok, response} = LabsJidoAgent.StudyBuddyAction.ask("How do I use GenServer?",
        phase: 3, mode: :example)
  """
  def ask(question, opts \\ []) do
    params = %{
      question: question,
      phase: Keyword.get(opts, :phase, 1),
      mode: Keyword.get(opts, :mode, :explain)
    }

    run(params, %{})
  end
end
