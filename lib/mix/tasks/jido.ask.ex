defmodule Mix.Tasks.Jido.Ask do
  @moduledoc """
  Ask Jido Study Buddy Agent questions about Elixir concepts.

  Interactive Q&A for learning Elixir. Provides explanations, examples,
  and resources tailored to your current learning phase.

  ## Usage

      # Ask a question
      mix jido.ask "What is tail recursion?"

      # Ask with specific phase context
      mix jido.ask "How do I use GenServer?" --phase 3

      # Get Socratic-style guidance
      mix jido.ask "What is pattern matching?" --mode socratic

      # Get code examples
      mix jido.ask "How do I implement map?" --mode example

  ## Options

    * `--phase` or `-p` - Current learning phase (1-15), default: 1
    * `--mode` or `-m` - Response mode: explain, socratic, or example (default: explain)

  ## Response Modes

    * `explain` - Direct explanation with theory and examples
    * `socratic` - Guides learning through questions
    * `example` - Provides runnable code examples

  ## Examples

      # Basic question
      mix jido.ask "What is recursion?"

      # Phase-specific question
      mix jido.ask "How do supervision trees work?" --phase 3

      # Socratic method for deeper understanding
      mix jido.ask "What is tail recursion?" --mode socratic

      # Get practical examples
      mix jido.ask "How do I use Enum vs Stream?" --mode example
  """

  use Mix.Task

  @shortdoc "Ask questions about Elixir concepts"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, [question | _], _} =
      OptionParser.parse(args,
        switches: [
          phase: :integer,
          mode: :string
        ],
        aliases: [
          p: :phase,
          m: :mode
        ]
      )

    if !question || question == "" do
      Mix.shell().error("Please provide a question")
      Mix.shell().info("")
      Mix.shell().info("Usage: mix jido.ask \"What is tail recursion?\"")
      Mix.shell().info("")
      Mix.shell().info("Examples:")
      Mix.shell().info("  mix jido.ask \"What is pattern matching?\"")
      Mix.shell().info("  mix jido.ask \"How do I use GenServer?\" --phase 3")
      Mix.shell().info("  mix jido.ask \"What is recursion?\" --mode socratic")
      System.halt(1)
    end

    phase = Keyword.get(opts, :phase, detect_current_phase())
    mode = parse_mode(Keyword.get(opts, :mode, "explain"))

    Mix.shell().info("")
    Mix.shell().info("🤖 Jido Study Buddy")
    Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    Mix.shell().info("")
    Mix.shell().info(["📚 Question: ", :bright, question, :reset])
    Mix.shell().info("Phase: #{phase} | Mode: #{mode}")
    Mix.shell().info("")

    # Ask the Study Buddy Agent
    case LabsJidoAgent.StudyBuddyAgent.ask(question, phase: phase, mode: mode) do
      {:ok, response} ->
        display_response(response, mode)

      {:error, reason} ->
        Mix.shell().error("Error: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp detect_current_phase do
    # Read .progress.json to determine current phase
    progress_file = "livebooks/.progress.json"

    case File.read(progress_file) do
      {:ok, content} ->
        progress = Jason.decode!(content)
        find_current_phase_from_progress(progress)

      {:error, _} ->
        1
    end
  end

  defp find_current_phase_from_progress(progress) do
    phases = [
      "phase-01-core",
      "phase-02-processes",
      "phase-03-genserver",
      "phase-04-naming",
      "phase-05-data",
      "phase-06-phoenix",
      "phase-07-jobs",
      "phase-08-caching",
      "phase-09-distribution",
      "phase-10-observability",
      "phase-11-testing",
      "phase-12-delivery",
      "phase-13-capstone",
      "phase-14-cto",
      "phase-15-ai"
    ]

    Enum.find_index(phases, fn phase ->
      phase_data = Map.get(progress, phase, %{})
      total = 5
      # Simplified for now
      completed = Enum.count(Map.values(phase_data), & &1)
      completed < total
    end)
    |> case do
      nil -> 1
      idx -> idx + 1
    end
  end

  defp parse_mode("explain"), do: :explain
  defp parse_mode("socratic"), do: :socratic
  defp parse_mode("example"), do: :example
  defp parse_mode(_), do: :explain

  defp display_response(response, _mode) do
    # Display answer
    Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    Mix.shell().info(["💡 ", :bright, "Answer", :reset])
    Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    Mix.shell().info("")
    Mix.shell().info(response.answer)
    Mix.shell().info("")

    # Display resources
    if length(response.resources) > 0 do
      Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      Mix.shell().info(["📖 ", :bright, "Resources", :reset])
      Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      Mix.shell().info("")

      Enum.each(response.resources, fn resource ->
        Mix.shell().info("  • #{resource}")
      end)

      Mix.shell().info("")
    end

    # Display follow-ups
    if length(response.follow_ups) > 0 do
      Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      Mix.shell().info(["🔗 ", :bright, "Next Steps", :reset])
      Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      Mix.shell().info("")

      Enum.each(response.follow_ups, fn follow_up ->
        Mix.shell().info("  • #{follow_up}")
      end)

      Mix.shell().info("")
    end
  end
end
