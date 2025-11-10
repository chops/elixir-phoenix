defmodule LabsJidoAgent.CodeReviewAction do
  @moduledoc """
  A Jido Action that reviews Elixir code and provides constructive feedback.

  This action demonstrates:
  - Using Jido.Action behavior
  - Structured parameter validation
  - Pattern-based code analysis
  - Educational feedback generation

  ## Examples

      # Create an agent and run the action
      {:ok, agent} = LabsJidoAgent.CodeReviewAgent.new()
      {:ok, agent} = LabsJidoAgent.CodeReviewAgent.set(agent, code: code_string, phase: 1)
      {:ok, agent} = LabsJidoAgent.CodeReviewAgent.plan(agent, LabsJidoAgent.CodeReviewAction)
      {:ok, agent} = LabsJidoAgent.CodeReviewAgent.run(agent)
      feedback = agent.result

      # Or use the helper function
      {:ok, feedback} = LabsJidoAgent.CodeReviewAction.review(code, phase: 1)
  """

  use Jido.Action,
    name: "code_review",
    description: "Reviews Elixir code for quality, idioms, and best practices",
    category: "education",
    tags: ["code-review", "elixir", "education"],
    schema: [
      code: [type: :string, required: true, doc: "The Elixir code to review"],
      phase: [type: :integer, default: 1, doc: "Learning phase (1-15)"],
      focus: [
        type: {:in, [:quality, :performance, :idioms, :all]},
        default: :all,
        doc: "Review focus area"
      ]
    ]

  @impl true
  def run(params, _context) do
    code = params.code
    phase = params.phase
    focus = params.focus

    # Analyze what aspects to review based on phase
    review_aspects = get_review_aspects(phase, focus)

    # Perform review (simulated - would use LLM in production)
    issues = analyze_code_structure(code, review_aspects)
    suggestions = generate_suggestions(issues, phase)
    score = calculate_score(issues)

    feedback = %{
      score: score,
      issues: issues,
      suggestions: suggestions,
      aspects_reviewed: review_aspects,
      phase: phase
    }

    {:ok, feedback}
  end

  # Private functions

  defp get_review_aspects(phase, focus) when focus == :all do
    base_aspects = [:pattern_matching, :function_heads, :documentation]

    phase_aspects =
      case phase do
        1 -> [:recursion, :tail_optimization, :enum_vs_stream]
        2 -> [:process_design, :message_passing]
        3 -> [:genserver_patterns, :supervision]
        4 -> [:naming, :registry_usage]
        5 -> [:ecto_schemas, :changesets, :transactions]
        _ -> []
      end

    base_aspects ++ phase_aspects
  end

  defp get_review_aspects(_phase, focus), do: [focus]

  defp analyze_code_structure(code, aspects) do
    issues = []

    # Check for non-tail recursion
    issues =
      if :recursion in aspects and String.contains?(code, "+ sum(") do
        [
          %{
            type: :performance,
            severity: :medium,
            line: find_line(code, "+ sum("),
            message: "Non-tail-recursive function detected",
            suggestion: "Consider using an accumulator for tail-call optimization"
          }
          | issues
        ]
      else
        issues
      end

    # Check for missing documentation
    issues =
      if :documentation in aspects and not String.contains?(code, "@doc") do
        [
          %{
            type: :quality,
            severity: :low,
            line: 1,
            message: "Missing module or function documentation",
            suggestion: "Add @moduledoc and @doc attributes"
          }
          | issues
        ]
      else
        issues
      end

    # Check pattern matching usage
    issues =
      if :pattern_matching in aspects and String.contains?(code, "if ") do
        [
          %{
            type: :idioms,
            severity: :low,
            line: find_line(code, "if "),
            message: "Consider using pattern matching instead of if/else",
            suggestion: "Elixir idioms favor pattern matching in function heads"
          }
          | issues
        ]
      else
        issues
      end

    issues
  end

  defp find_line(code, pattern) do
    code
    |> String.split("\n")
    |> Enum.find_index(&String.contains?(&1, pattern))
    |> case do
      nil -> nil
      idx -> idx + 1
    end
  end

  defp generate_suggestions(issues, _phase) do
    Enum.map(issues, fn issue ->
      %{
        original_issue: issue.message,
        suggestion: issue.suggestion,
        resources: get_resources_for_issue(issue.type)
      }
    end)
  end

  defp get_resources_for_issue(:performance) do
    [
      "Elixir docs: Recursion and tail-call optimization",
      "Livebook: phase-01-core/02-recursion.livemd"
    ]
  end

  defp get_resources_for_issue(:quality) do
    [
      "Elixir docs: Writing documentation",
      "ExDoc documentation"
    ]
  end

  defp get_resources_for_issue(:idioms) do
    [
      "Elixir Style Guide",
      "Livebook: phase-01-core/01-pattern-matching.livemd"
    ]
  end

  defp get_resources_for_issue(_), do: []

  defp calculate_score(issues) do
    # Simple scoring: start at 100, deduct points for issues
    base_score = 100

    deductions =
      Enum.reduce(issues, 0, fn issue, acc ->
        case issue.severity do
          :critical -> acc + 20
          :high -> acc + 10
          :medium -> acc + 5
          :low -> acc + 2
        end
      end)

    max(0, base_score - deductions)
  end

  ## Public Helper API

  @doc """
  Reviews code and provides feedback (convenience wrapper).

  ## Options
    * `:phase` - Learning phase (1-15), default: 1
    * `:focus` - Review focus (`:quality`, `:performance`, `:idioms`, `:all`), default: `:all`

  ## Examples

      code = "defmodule Example do\\n  def hello, do: :world\\nend"
      {:ok, feedback} = LabsJidoAgent.CodeReviewAction.review(code, phase: 1)
  """
  def review(code, opts \\ []) do
    params = %{
      code: code,
      phase: Keyword.get(opts, :phase, 1),
      focus: Keyword.get(opts, :focus, :all)
    }

    run(params, %{})
  end
end
