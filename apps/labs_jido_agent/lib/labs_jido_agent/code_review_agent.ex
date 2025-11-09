defmodule LabsJidoAgent.CodeReviewAgent do
  @moduledoc """
  An AI agent that reviews Elixir code and provides constructive feedback.

  This agent demonstrates:
  - Agent lifecycle (plan → act → observe)
  - Integration with LLMs via Instructor
  - Structured output generation
  - Error handling in AI pipelines

  ## Examples

      # Review a module
      code = '''
      defmodule MyList do
        def sum([]), do: 0
        def sum([h | t]), do: h + sum(t)
      end
      '''

      {:ok, feedback} = CodeReviewAgent.review(code, phase: 1)
      IO.inspect(feedback)
  """

  use Jido.Agent,
    name: "code_reviewer",
    description: "Reviews Elixir code for quality, idioms, and best practices",
    schema: [
      code: [type: :string, required: true, doc: "The Elixir code to review"],
      phase: [type: :integer, default: 1, doc: "Learning phase (1-15)"],
      focus: [
        type: {:in, [:quality, :performance, :idioms, :all]},
        default: :all,
        doc: "Review focus area"
      ]
    ]

  alias Jido.Agent.{Directive, Signal}

  @impl Jido.Agent
  def plan(agent, directive) do
    code = Directive.get_param(directive, :code)
    phase = Directive.get_param(directive, :phase, 1)
    focus = Directive.get_param(directive, :focus, :all)

    # Analyze what aspects to review based on phase
    review_aspects = get_review_aspects(phase, focus)

    # Create plan for review
    plan = %{
      code: code,
      phase: phase,
      aspects: review_aspects,
      timestamp: DateTime.utc_now()
    }

    {:ok, Agent.put_plan(agent, plan)}
  end

  @impl Jido.Agent
  def act(agent) do
    plan = Agent.get_plan(agent)

    # Simulate AI review (in real implementation, would call LLM via Instructor)
    feedback = perform_review(plan.code, plan.aspects, plan.phase)

    # Store result
    result = %{
      feedback: feedback,
      reviewed_at: DateTime.utc_now(),
      phase: plan.phase
    }

    {:ok, Agent.put_result(agent, result)}
  end

  @impl Jido.Agent
  def observe(agent) do
    result = Agent.get_result(agent)

    # Generate observations about the review
    observations = %{
      issues_found: count_issues(result.feedback),
      severity: assess_severity(result.feedback),
      phase_appropriate: true
    }

    signal = Signal.new(:review_complete, observations)
    {:ok, agent, [signal]}
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

  defp perform_review(code, aspects, phase) do
    # Simulate code analysis
    # In real implementation, this would use Instructor to call an LLM

    issues = analyze_code_structure(code, aspects)
    suggestions = generate_suggestions(issues, phase)

    %{
      score: calculate_score(issues),
      issues: issues,
      suggestions: suggestions,
      aspects_reviewed: aspects
    }
  end

  defp analyze_code_structure(code, aspects) do
    issues = []

    # Check for non-tail recursion
    if :recursion in aspects and String.contains?(code, "+ sum(") do
      issues = [
        %{
          type: :performance,
          severity: :medium,
          line: find_line(code, "+ sum("),
          message: "Non-tail-recursive function detected",
          suggestion: "Consider using an accumulator for tail-call optimization"
        }
        | issues
      ]
    end

    # Check for missing documentation
    if :documentation in aspects and not String.contains?(code, "@doc") do
      issues = [
        %{
          type: :quality,
          severity: :low,
          line: 1,
          message: "Missing module or function documentation",
          suggestion: "Add @moduledoc and @doc attributes"
        }
        | issues
      ]
    end

    # Check pattern matching usage
    if :pattern_matching in aspects and String.contains?(code, "if ") do
      issues = [
        %{
          type: :idioms,
          severity: :low,
          line: find_line(code, "if "),
          message: "Consider using pattern matching instead of if/else",
          suggestion: "Elixir idioms favor pattern matching in function heads"
        }
        | issues
      ]
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

  defp count_issues(feedback), do: length(feedback.issues)

  defp assess_severity(feedback) do
    feedback.issues
    |> Enum.map(& &1.severity)
    |> Enum.max(fn -> :none end, &severity_compare/2)
  end

  defp severity_compare(a, b) do
    severity_rank(a) >= severity_rank(b)
  end

  defp severity_rank(:critical), do: 4
  defp severity_rank(:high), do: 3
  defp severity_rank(:medium), do: 2
  defp severity_rank(:low), do: 1
  defp severity_rank(_), do: 0

  ## Public API

  @doc """
  Reviews code and provides feedback.

  ## Options
    * `:phase` - Learning phase (1-15), default: 1
    * `:focus` - Review focus (`:quality`, `:performance`, `:idioms`, `:all`), default: `:all`

  ## Examples

      code = "defmodule Example do\\n  def hello, do: :world\\nend"
      {:ok, feedback} = CodeReviewAgent.review(code, phase: 1)
  """
  def review(code, opts \\ []) do
    directive =
      Directive.new(:review_code,
        params: %{
          code: code,
          phase: Keyword.get(opts, :phase, 1),
          focus: Keyword.get(opts, :focus, :all)
        }
      )

    case Jido.Agent.run(__MODULE__, directive) do
      {:ok, agent} ->
        {:ok, Agent.get_result(agent).feedback}

      error ->
        error
    end
  end
end
