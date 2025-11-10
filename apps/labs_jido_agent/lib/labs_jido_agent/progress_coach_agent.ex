defmodule LabsJidoAgent.ProgressCoachAgent do
  @moduledoc """
  An Agent that monitors student progress and provides personalized recommendations.

  Features:
  - Reads `.progress.json` automatically
  - Identifies strengths and challenges
  - Suggests next phases
  - Recommends review areas
  - Estimates time to completion

  ## Examples

      {:ok, advice} = LabsJidoAgent.ProgressCoachAgent.analyze_progress("student_123")
      IO.inspect(advice.recommendations)
      IO.inspect(advice.next_phase)
  """

  use Jido.Agent,
    name: "progress_coach_agent",
    description: "Analyzes learning progress and provides personalized guidance",
    category: "education",
    tags: ["progress", "analytics"],
    schema: [
      student_id: [type: :string, doc: "Student identifier"],
      progress_data: [type: :map, default: %{}, doc: "Progress JSON data"]
    ],
    actions: [LabsJidoAgent.ProgressCoachAction]

  @doc """
  Analyzes student progress and provides coaching recommendations (convenience wrapper).

  ## Examples

      {:ok, advice} = LabsJidoAgent.ProgressCoachAgent.analyze_progress("student_123")
      IO.inspect(advice.recommendations)
      IO.inspect(advice.next_phase)
  """
  def analyze_progress(student_id, progress_data \\ %{}) do
    # Build params and call action directly for convenience
    params = %{student_id: student_id, progress_data: progress_data}
    LabsJidoAgent.ProgressCoachAction.run(params, %{})
  end
end
