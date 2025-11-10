defmodule LabsJidoAgent.ProgressCoachAction do
  @moduledoc """
  A Jido Action that analyzes learning progress and provides personalized recommendations.

  This action:
  - Reads `.progress.json` to analyze completion
  - Identifies strengths and challenges
  - Suggests next phases
  - Estimates time to completion

  ## Examples

      params = %{student_id: "student_123", progress_data: %{}}
      {:ok, advice} = LabsJidoAgent.ProgressCoachAction.run(params, %{})
  """

  use Jido.Action,
    name: "progress_coach",
    description: "Analyzes learning progress and provides personalized guidance",
    category: "education",
    tags: ["progress", "coaching", "analytics"],
    schema: [
      student_id: [type: :string, required: true, doc: "Student identifier"],
      progress_data: [type: :map, default: %{}, doc: "Progress JSON data (optional)"]
    ]

  @impl true
  def run(params, _context) do
    student_id = params.student_id
    progress_data = params.progress_data

    # Load progress from file if not provided
    progress = if progress_data == %{}, do: load_progress(), else: progress_data

    # Analyze current state
    analysis = analyze_student_progress(progress)

    # Generate personalized recommendations
    recommendations = generate_recommendations(analysis)

    # Determine next best phase
    next_phase = suggest_next_phase(analysis)

    # Identify areas needing review
    review_areas = identify_review_areas(analysis)

    result = %{
      student_id: student_id,
      recommendations: recommendations,
      next_phase: next_phase,
      review_areas: review_areas,
      strengths: analysis.strengths,
      challenges: analysis.challenges,
      estimated_time_to_next: estimate_time_to_completion(analysis, next_phase)
    }

    {:ok, result}
  end

  # Private functions

  defp load_progress do
    progress_file = "livebooks/.progress.json"

    case File.read(progress_file) do
      {:ok, content} -> Jason.decode!(content)
      {:error, _} -> %{}
    end
  end

  defp analyze_student_progress(progress) do
    phases = get_all_phases()

    phase_stats =
      Enum.map(phases, fn phase ->
        phase_data = Map.get(progress, phase, %{})
        checkpoints = Map.keys(phase_data)
        completed = Enum.count(checkpoints, fn cp -> Map.get(phase_data, cp) == true end)
        total = get_checkpoint_count(phase)

        %{
          phase: phase,
          completed: completed,
          total: total,
          percentage: if(total > 0, do: completed / total * 100, else: 0),
          status: determine_phase_status(completed, total)
        }
      end)

    current_phase = find_current_phase(phase_stats)
    strengths = identify_strengths(phase_stats)
    challenges = identify_challenges(phase_stats)

    %{
      current_phase: current_phase,
      phase_stats: phase_stats,
      overall_completion: calculate_overall_completion(phase_stats),
      strengths: strengths,
      challenges: challenges
    }
  end

  defp get_all_phases do
    [
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
  end

  defp get_checkpoint_count("phase-01-core"), do: 7
  defp get_checkpoint_count(_), do: 5

  defp determine_phase_status(completed, total) do
    percentage = if total > 0, do: completed / total * 100, else: 0

    cond do
      percentage == 0 -> :not_started
      percentage == 100 -> :completed
      percentage >= 50 -> :in_progress_strong
      true -> :in_progress
    end
  end

  defp find_current_phase(phase_stats) do
    phase_stats
    |> Enum.find(fn stat ->
      stat.status in [:in_progress, :in_progress_strong]
    end)
    |> case do
      nil ->
        # Find first incomplete phase
        Enum.find(phase_stats, fn stat -> stat.status == :not_started end)

      phase ->
        phase
    end
  end

  defp calculate_overall_completion(phase_stats) do
    total_checkpoints = Enum.sum(Enum.map(phase_stats, & &1.total))
    completed_checkpoints = Enum.sum(Enum.map(phase_stats, & &1.completed))

    if total_checkpoints > 0 do
      completed_checkpoints / total_checkpoints * 100
    else
      0
    end
  end

  defp identify_strengths(phase_stats) do
    phase_stats
    |> Enum.filter(fn stat -> stat.percentage == 100 end)
    |> Enum.map(fn stat -> phase_to_concept(stat.phase) end)
  end

  defp identify_challenges(phase_stats) do
    phase_stats
    |> Enum.filter(fn stat ->
      stat.status == :in_progress and stat.percentage < 50 and stat.percentage > 0
    end)
    |> Enum.map(fn stat -> %{phase: stat.phase, completion: stat.percentage} end)
  end

  defp phase_to_concept("phase-01-core"), do: "Elixir fundamentals"
  defp phase_to_concept("phase-02-processes"), do: "Process management"
  defp phase_to_concept("phase-03-genserver"), do: "GenServer & supervision"
  defp phase_to_concept(phase), do: phase

  defp generate_recommendations(analysis) do
    recommendations = []

    # Recommend next phase if current is nearly complete
    recommendations =
      if analysis.current_phase && analysis.current_phase.percentage >= 80 do
        [
          %{
            priority: :high,
            type: :progress,
            message:
              "You're doing great on #{analysis.current_phase.phase}! Consider moving to the next phase soon.",
            action: "Review remaining checkpoints and advance"
          }
          | recommendations
        ]
      else
        recommendations
      end

    # Add encouragement for strengths
    recommendations =
      if length(analysis.strengths) > 0 do
        [
          %{
            priority: :low,
            type: :encouragement,
            message: "Great work mastering: #{Enum.join(analysis.strengths, ", ")}!",
            action: "Keep up the momentum"
          }
          | recommendations
        ]
      else
        recommendations
      end

    # Default recommendation if empty
    if recommendations == [] do
      [
        %{
          priority: :medium,
          type: :start,
          message: "Ready to start your Elixir journey?",
          action: "Begin with Phase 1: Elixir Core"
        }
      ]
    else
      recommendations
    end
  end

  defp suggest_next_phase(analysis) do
    if analysis.current_phase do
      if analysis.current_phase.percentage >= 80 do
        current_index =
          Enum.find_index(get_all_phases(), fn p -> p == analysis.current_phase.phase end)

        next_phase = Enum.at(get_all_phases(), current_index + 1)

        %{
          phase: next_phase,
          reason: "You've completed #{round(analysis.current_phase.percentage)}% of #{analysis.current_phase.phase}",
          prerequisite_met: true
        }
      else
        %{
          phase: analysis.current_phase.phase,
          reason: "Complete remaining checkpoints first",
          prerequisite_met: false
        }
      end
    else
      %{
        phase: "phase-01-core",
        reason: "Start here for Elixir fundamentals",
        prerequisite_met: true
      }
    end
  end

  defp identify_review_areas(analysis) do
    Enum.map(analysis.challenges, fn challenge ->
      %{
        phase: challenge.phase,
        completion: challenge.completion,
        suggested_action: "Review checkpoints and complete exercises",
        resources: ["Livebook: #{challenge.phase}", "Study guide"]
      }
    end)
  end

  defp estimate_time_to_completion(_analysis, next_phase) do
    days = get_estimated_days(next_phase.phase)

    %{
      estimate_days: days,
      estimate_hours: days * 6,
      confidence: :medium
    }
  end

  defp get_estimated_days("phase-01-core"), do: 7
  defp get_estimated_days(_), do: 7

  ## Public Helper API

  @doc """
  Analyzes student progress and provides coaching recommendations (convenience wrapper).

  ## Examples

      {:ok, advice} = LabsJidoAgent.ProgressCoachAction.analyze_progress("student_123")
      IO.inspect(advice.recommendations)
  """
  def analyze_progress(student_id, progress_data \\ %{}) do
    params = %{
      student_id: student_id,
      progress_data: progress_data
    }

    run(params, %{})
  end
end
