defmodule LabsJidoAgent.CodeReviewAction do
  @moduledoc """
  A Jido Action that reviews Elixir code using LLM-powered analysis.

  This action demonstrates:
  - Using Jido.Action behavior
  - LLM integration via Instructor
  - Structured parameter validation
  - Educational feedback generation

  ## LLM vs Simulated Mode

  By default, uses real LLM if configured (via OPENAI_API_KEY, etc).
  Falls back to simulated pattern-based analysis if LLM unavailable.

  ## Examples

      # With LLM configured
      {:ok, feedback} = LabsJidoAgent.CodeReviewAction.review(code, phase: 1)

      # Force simulated mode
      {:ok, feedback} = LabsJidoAgent.CodeReviewAction.review(code,
        phase: 1, use_llm: false)
  """

  use Jido.Action,
    name: "code_review",
    description: "Reviews Elixir code for quality, idioms, and best practices",
    category: "education",
    tags: ["code-review", "elixir", "education", "llm"],
    schema: [
      code: [type: :string, required: true, doc: "The Elixir code to review"],
      phase: [type: :integer, default: 1, doc: "Learning phase (1-15)"],
      focus: [
        type: {:in, [:quality, :performance, :idioms, :all]},
        default: :all,
        doc: "Review focus area"
      ],
      use_llm: [type: :boolean, default: true, doc: "Use LLM if available"]
    ]

  alias LabsJidoAgent.{LLM, Schemas}

  @impl true
  def run(params, _context) do
    code = params.code
    phase = params.phase
    focus = params.focus
    use_llm = params.use_llm

    if use_llm and LLM.available?() do
      llm_review(code, phase, focus)
    else
      simulated_review(code, phase, focus)
    end
  end

  # LLM-powered review
  defp llm_review(code, phase, focus) do
    prompt = build_review_prompt(code, phase, focus)

    case LLM.chat_structured(prompt,
           response_model: Schemas.CodeReviewResponse,
           model: :smart,
           temperature: 0.3
         ) do
      {:ok, %Schemas.CodeReviewResponse{} = review} ->
        # Convert Ecto schema to plain map
        feedback = %{
          score: review.score,
          issues: Enum.map(review.issues, &issue_to_map/1),
          suggestions: format_suggestions(review.suggestions, review.issues),
          aspects_reviewed: get_review_aspects(phase, focus),
          phase: phase,
          llm_powered: true
        }

        {:ok, feedback}

      {:error, reason} ->
        # Fall back to simulated on LLM error
        IO.warn("LLM review failed: #{inspect(reason)}, falling back to simulated")
        simulated_review(code, phase, focus)
    end
  end

  defp build_review_prompt(code, phase, focus) do
    aspects = get_review_aspects(phase, focus)
    aspects_text = Enum.join(aspects, ", ")

    """
    You are an expert Elixir code reviewer for educational purposes.

    Review the following Elixir code for a student in Phase #{phase} of learning.

    Focus areas: #{aspects_text}

    Code to review:
    ```elixir
    #{code}
    ```

    Provide:
    1. A score (0-100) based on code quality
    2. A brief summary of overall quality
    3. Specific issues found (type, severity, line number if identifiable, message, suggestion)
    4. General suggestions for improvement
    5. Learning resources relevant to the issues

    Be constructive and educational. Prioritize teaching over criticism.
    For Phase #{phase}, focus on concepts appropriate for that level.
    """
  end

  defp issue_to_map(%Schemas.CodeIssue{} = issue) do
    %{
      type: issue.type,
      severity: issue.severity,
      line: issue.line,
      message: issue.message,
      suggestion: issue.suggestion
    }
  end

  defp format_suggestions(general_suggestions, issues) do
    issue_suggestions =
      Enum.map(issues, fn issue ->
        %{
          original_issue: issue.message,
          suggestion: issue.suggestion,
          resources: get_resources_for_type(issue.type)
        }
      end)

    # Add general suggestions
    general =
      Enum.map(general_suggestions || [], fn sug ->
        %{
          original_issue: "General improvement",
          suggestion: sug,
          resources: []
        }
      end)

    issue_suggestions ++ general
  end

  # Simulated review (fallback when no LLM)
  defp simulated_review(code, phase, focus) do
    review_aspects = get_review_aspects(phase, focus)
    issues = analyze_code_structure(code, review_aspects)
    suggestions = generate_suggestions(issues, phase)
    score = calculate_score(issues)

    feedback = %{
      score: score,
      issues: issues,
      suggestions: suggestions,
      aspects_reviewed: review_aspects,
      phase: phase,
      llm_powered: false
    }

    {:ok, feedback}
  end

  # Review aspects based on phase
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

  # Simulated code analysis
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
        resources: get_resources_for_type(issue.type)
      }
    end)
  end

  defp get_resources_for_type(:performance) do
    [
      "Elixir docs: Recursion and tail-call optimization",
      "Livebook: phase-01-core/02-recursion.livemd"
    ]
  end

  defp get_resources_for_type(:quality) do
    [
      "Elixir docs: Writing documentation",
      "ExDoc documentation"
    ]
  end

  defp get_resources_for_type(:idioms) do
    [
      "Elixir Style Guide",
      "Livebook: phase-01-core/01-pattern-matching.livemd"
    ]
  end

  defp get_resources_for_type(_), do: []

  defp calculate_score(issues) do
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
    * `:use_llm` - Use LLM if available, default: true

  ## Examples

      code = "defmodule Example do\\n  def hello, do: :world\\nend"
      {:ok, feedback} = LabsJidoAgent.CodeReviewAction.review(code, phase: 1)
      {:ok, feedback} = LabsJidoAgent.CodeReviewAction.review(code, phase: 1, use_llm: false)
  """
  def review(code, opts \\ []) do
    params = %{
      code: code,
      phase: Keyword.get(opts, :phase, 1),
      focus: Keyword.get(opts, :focus, :all),
      use_llm: Keyword.get(opts, :use_llm, true)
    }

    run(params, %{})
  end
end
