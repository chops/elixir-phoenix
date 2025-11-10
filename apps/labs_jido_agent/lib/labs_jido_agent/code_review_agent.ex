defmodule LabsJidoAgent.CodeReviewAgent do
  @moduledoc """
  An Agent that reviews Elixir code using the CodeReviewAction.

  This demonstrates the Jido Agent + Action pattern for educational AI assistance.

  ## Examples

      # Create agent and review code
      {:ok, agent} = LabsJidoAgent.CodeReviewAgent.new()
      {:ok, agent} = LabsJidoAgent.CodeReviewAgent.set(agent,
        code: code_string,
        phase: 1,
        focus: :all
      )
      {:ok, agent} = LabsJidoAgent.CodeReviewAgent.plan(agent, LabsJidoAgent.CodeReviewAction)
      {:ok, agent} = LabsJidoAgent.CodeReviewAgent.run(agent)

      feedback = agent.result
      IO.inspect(feedback.issues)

      # Or use the convenient helper
      {:ok, feedback} = LabsJidoAgent.CodeReviewAgent.review(code, phase: 1)
  """

  use Jido.Agent,
    name: "code_review_agent",
    description: "Reviews Elixir code for quality, idioms, and best practices",
    category: "education",
    tags: ["code-review", "elixir"],
    schema: [
      code: [type: :string, doc: "The Elixir code to review"],
      phase: [type: :integer, default: 1, doc: "Learning phase (1-15)"],
      focus: [
        type: {:in, [:quality, :performance, :idioms, :all]},
        default: :all,
        doc: "Review focus area"
      ]
    ],
    actions: [LabsJidoAgent.CodeReviewAction]

  @doc """
  Convenience function to review code without manually managing agent lifecycle.

  ## Options
    * `:phase` - Learning phase (1-15), default: 1
    * `:focus` - Review focus (`:quality`, `:performance`, `:idioms`, `:all`), default: `:all`

  ## Examples

      code = '''
      defmodule MyList do
        def sum([]), do: 0
        def sum([h | t]), do: h + sum(t)
      end
      '''

      {:ok, feedback} = LabsJidoAgent.CodeReviewAgent.review(code, phase: 1)
      IO.inspect(feedback.issues)
  """
  def review(code, opts \\ []) do
    phase = Keyword.get(opts, :phase, 1)
    focus = Keyword.get(opts, :focus, :all)
    use_llm = Keyword.get(opts, :use_llm, true)

    # Build params and call action directly for convenience
    params = %{code: code, phase: phase, focus: focus, use_llm: use_llm}
    LabsJidoAgent.CodeReviewAction.run(params, %{})
  end
end
