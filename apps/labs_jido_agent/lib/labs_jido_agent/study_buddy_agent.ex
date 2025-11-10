defmodule LabsJidoAgent.StudyBuddyAgent do
  @moduledoc """
  An Agent that answers questions about Elixir concepts using StudyBuddyAction.

  Provides three response modes:
  - `:explain` - Direct explanations
  - `:socratic` - Guided learning through questions
  - `:example` - Code examples

  ## Examples

      {:ok, response} = LabsJidoAgent.StudyBuddyAgent.ask("What is tail recursion?")
      IO.puts(response.answer)

      {:ok, response} = LabsJidoAgent.StudyBuddyAgent.ask("How do I use GenServer?",
        phase: 3, mode: :example)
  """

  use Jido.Agent,
    name: "study_buddy_agent",
    description: "Answers questions about Elixir concepts and guides learning",
    category: "education",
    tags: ["qa", "learning"],
    schema: [
      question: [type: :string, doc: "The student's question"],
      phase: [type: :integer, default: 1, doc: "Current learning phase"],
      mode: [
        type: {:in, [:explain, :socratic, :example]},
        default: :explain,
        doc: "Response mode"
      ]
    ],
    actions: [LabsJidoAgent.StudyBuddyAction]

  @doc """
  Ask a question and get an explanation (convenience wrapper).

  ## Options
    * `:phase` - Current learning phase (1-15)
    * `:mode` - Response mode (`:explain`, `:socratic`, `:example`)

  ## Examples

      {:ok, response} = LabsJidoAgent.StudyBuddyAgent.ask("What is recursion?")
      {:ok, response} = LabsJidoAgent.StudyBuddyAgent.ask("How do I use GenServer?",
        phase: 3, mode: :example)
  """
  def ask(question, opts \\ []) do
    phase = Keyword.get(opts, :phase, 1)
    mode = Keyword.get(opts, :mode, :explain)
    use_llm = Keyword.get(opts, :use_llm, true)

    # Build params and call action directly for convenience
    params = %{question: question, phase: phase, mode: mode, use_llm: use_llm}
    LabsJidoAgent.StudyBuddyAction.run(params, %{})
  end
end
