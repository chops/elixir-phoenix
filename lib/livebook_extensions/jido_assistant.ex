defmodule LivebookExtensions.JidoAssistant do
  @moduledoc """
  A Livebook Smart Cell for interactive AI assistance while learning.

  ⚠️ **UI NOT IMPLEMENTED**
  This Smart Cell currently lacks UI rendering (`handle_ui/2` callback).
  It generates working code but the form interface is not implemented.

  **Workaround:** Use the Mix task instead: `mix jido.ask "Your question here"`

  ## Features (code generation works)

  - Ask questions about Elixir concepts
  - Get explanations, examples, or Socratic guidance
  - Automatically detects current phase from progress
  - Displays resources and follow-up suggestions
  - Interactive Q&A right in your notebook

  ## Usage

  1. Add this smart cell to any Livebook
  2. Type your question
  3. Select response mode (explain, socratic, example)
  4. Click "Ask Jido"
  5. Get instant help!
  """

  use Kino.SmartCell, name: "Jido Assistant"

  @impl true
  def init(_attrs, ctx) do
    fields = %{
      question: "",
      mode: "explain",
      phase: detect_current_phase()
    }

    {:ok, fields, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, ctx.assigns, ctx}
  end

  @impl true
  def handle_event("update_question", %{"question" => question}, ctx) do
    ctx = update(ctx, :question, fn _ -> question end)
    broadcast_update(ctx, ctx.assigns)
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_mode", %{"mode" => mode}, ctx) do
    ctx = update(ctx, :mode, fn _ -> mode end)
    broadcast_update(ctx, ctx.assigns)
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_phase", %{"phase" => phase}, ctx) do
    phase_int = String.to_integer(phase)
    ctx = update(ctx, :phase, fn _ -> phase_int end)
    broadcast_update(ctx, ctx.assigns)
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    ctx.assigns
  end

  @impl true
  def to_source(attrs) do
    question = attrs.question || ""
    mode = String.to_atom(attrs.mode || "explain")
    phase = attrs.phase || 1

    if question == "" do
      """
      Kino.Markdown.new("ℹ️ **Please enter a question above and re-evaluate this cell.**")
      """
    else
      """
      # Ask Jido Study Buddy Agent
      question = \"\"\"
      #{question}
      \"\"\"
      case LabsJidoAgent.StudyBuddyAgent.ask(question, phase: #{phase}, mode: :#{mode}) do
        {:ok, response} ->
          # Display answer
          answer_md = Kino.Markdown.new(\"\"\"
          ## 💡 Answer

          \#{response.answer}
          \"\"\")

          Kino.render(answer_md)

          # Display resources if available
          if length(response.resources) > 0 do
            resources_text = Enum.map_join(response.resources, "\\n", fn r -> "- \#{r}" end)

            resources_md = Kino.Markdown.new(\"\"\"
            ---

            ## 📖 Resources

            \#{resources_text}
            \"\"\")

            Kino.render(resources_md)
          end

          # Display follow-ups if available
          if length(response.follow_ups) > 0 do
            follow_ups_text = Enum.map_join(response.follow_ups, "\\n", fn f -> "- \#{f}" end)

            follow_ups_md = Kino.Markdown.new(\"\"\"
            ---

            ## 🔗 Next Steps

            \#{follow_ups_text}
            \"\"\")

            Kino.render(follow_ups_md)
          end

          :ok

        {:error, reason} ->
          Kino.Markdown.new("❌ **Error:** \#{inspect(reason)}")
      end
      """
    end
  end

  defp detect_current_phase do
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
      completed = Enum.count(Map.values(phase_data), & &1)
      completed < total
    end)
    |> case do
      nil -> 1
      idx -> idx + 1
    end
  end

  defp update(ctx, key, fun) do
    Map.update!(ctx, :assigns, fn assigns ->
      Map.update!(assigns, key, fun)
    end)
  end

  defp broadcast_update(ctx, assigns) do
    send(ctx.origin, {:broadcast_update, assigns})
  end
end
