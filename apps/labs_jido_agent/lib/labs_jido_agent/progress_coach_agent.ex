defmodule LabsJidoAgent.ProgressCoachAgent do
  @moduledoc """
  An AI agent that monitors student progress and provides personalized recommendations.

  This agent demonstrates:
  - State analysis and pattern recognition
  - Personalized recommendation generation
  - Progress tracking integration
  - Adaptive learning path suggestions

  ## Examples

      {:ok, advice} = ProgressCoachAgent.analyze_progress("student_123")
      IO.inspect(advice)
  """

  use Jido.Agent,
    name: "progress_coach",
    description: "Analyzes learning progress and provides personalized guidance",
    schema: [
      student_id: [type: :string, required: true, doc: "Student identifier"],
      progress_data: [type: :map, default: %{}, doc: "Progress JSON data"]
    ]

  alias Jido.Agent.{Directive, Signal}

  @impl Jido.Agent
  def plan(agent, directive) do
    student_id = Directive.get_param(directive, :student_id)
    progress_data = Directive.get_param(directive, :progress_data, %{})

    # Load progress from file if not provided
    progress = if progress_data == %{}, do: load_progress(), else: progress_data

    # Analyze current state
    analysis = analyze_student_progress(progress)

    plan = %{
      student_id: student_id,
      progress: progress,
      analysis: analysis,
      timestamp: DateTime.utc_now()
    }

    {:ok, Agent.put_plan(agent, plan)}
  end

  @impl Jido.Agent
  def act(agent) do
    plan = Agent.get_plan(agent)

    # Generate personalized recommendations
    recommendations = generate_recommendations(plan.analysis)

    # Determine next best phase
    next_phase = suggest_next_phase(plan.analysis)

    # Identify areas needing review
    review_areas = identify_review_areas(plan.analysis)

    result = %{
      recommendations: recommendations,
      next_phase: next_phase,
      review_areas: review_areas,
      strengths: plan.analysis.strengths,
      challenges: plan.analysis.challenges,
      estimated_time_to_next: estimate_time_to_completion(plan.analysis, next_phase)
    }

    {:ok, Agent.put_result(agent, result)}
  end

  @impl Jido.Agent
  def observe(agent) do
    result = Agent.get_result(agent)

    observations = %{
      recommendations_count: length(result.recommendations),
      review_areas_count: length(result.review_areas),
      confidence: calculate_confidence(result)
    }

    signal = Signal.new(:coaching_complete, observations)
    {:ok, agent, [signal]}
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
      challenges: challenges,
      learning_velocity: estimate_velocity(phase_stats)
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
  defp get_checkpoint_count("phase-02-processes"), do: 5
  defp get_checkpoint_count("phase-03-genserver"), do: 6
  defp get_checkpoint_count("phase-04-naming"), do: 4
  defp get_checkpoint_count("phase-05-data"), do: 8
  defp get_checkpoint_count("phase-06-phoenix"), do: 10
  defp get_checkpoint_count("phase-07-jobs"), do: 6
  defp get_checkpoint_count("phase-08-caching"), do: 5
  defp get_checkpoint_count("phase-09-distribution"), do: 8
  defp get_checkpoint_count("phase-10-observability"), do: 7
  defp get_checkpoint_count("phase-11-testing"), do: 6
  defp get_checkpoint_count("phase-12-delivery"), do: 5
  defp get_checkpoint_count("phase-13-capstone"), do: 10
  defp get_checkpoint_count("phase-14-cto"), do: 8
  defp get_checkpoint_count("phase-15-ai"), do: 8

  defp determine_phase_status(completed, total) do
    percentage = completed / total * 100

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
    |> Enum.map(fn stat -> stat.phase end)
    |> Enum.map(&phase_to_concept/1)
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
  defp phase_to_concept("phase-04-naming"), do: "Process naming & fleets"
  defp phase_to_concept("phase-05-data"), do: "Database & Ecto"
  defp phase_to_concept("phase-06-phoenix"), do: "Web development"
  defp phase_to_concept(phase), do: phase

  defp estimate_velocity(_phase_stats) do
    # In real implementation, would analyze completion timestamps
    # For now, return placeholder
    :moderate
  end

  defp generate_recommendations(analysis) do
    recommendations = []

    # Recommend next phase if current is nearly complete
    recommendations =
      if analysis.current_phase && analysis.current_phase.percentage >= 80 do
        [
          %{
            priority: :high,
            type: :progress,
            message: "You're doing great on #{analysis.current_phase.phase}! Consider moving to the next phase soon.",
            action: "Review remaining checkpoints and advance"
          }
          | recommendations
        ]
      else
        recommendations
      end

    # Recommend review for struggling areas
    recommendations =
      if length(analysis.challenges) > 0 do
        challenge = List.first(analysis.challenges)

        [
          %{
            priority: :medium,
            type: :review,
            message: "Consider reviewing #{challenge.phase} - you're at #{round(challenge.completion)}% completion",
            action: "Revisit key concepts and complete remaining checkpoints"
          }
          | recommendations
        ]
      else
        recommendations
      end

    # Celebrate strengths
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

    # Add default recommendation if list is empty
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
        # Suggest next phase
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
        resources: ["Livebook: #{challenge.phase}", "Study guide", "Lab exercises"]
      }
    end)
  end

  defp estimate_time_to_completion(_analysis, next_phase) do
    # Estimate based on phase difficulty
    days = get_estimated_days(next_phase.phase)

    %{
      estimate_days: days,
      estimate_hours: days * 6,
      confidence: :medium
    }
  end

  defp get_estimated_days("phase-01-core"), do: 7
  defp get_estimated_days("phase-02-processes"), do: 6
  defp get_estimated_days("phase-03-genserver"), do: 7
  defp get_estimated_days("phase-04-naming"), do: 7
  defp get_estimated_days("phase-05-data"), do: 9
  defp get_estimated_days("phase-06-phoenix"), do: 11
  defp get_estimated_days("phase-07-jobs"), do: 9
  defp get_estimated_days("phase-08-caching"), do: 7
  defp get_estimated_days("phase-09-distribution"), do: 12
  defp get_estimated_days("phase-10-observability"), do: 10
  defp get_estimated_days("phase-11-testing"), do: 7
  defp get_estimated_days("phase-12-delivery"), do: 6
  defp get_estimated_days("phase-13-capstone"), do: 12
  defp get_estimated_days("phase-14-cto"), do: 9
  defp get_estimated_days("phase-15-ai"), do: 10
  defp get_estimated_days(_), do: 7

  defp calculate_confidence(result) do
    # Simple heuristic: more data = higher confidence
    data_points = length(result.recommendations) + length(result.review_areas)

    cond do
      data_points >= 5 -> :high
      data_points >= 3 -> :medium
      true -> :low
    end
  end

  ## Public API

  @doc """
  Analyzes student progress and provides coaching recommendations.

  ## Examples

      {:ok, advice} = ProgressCoachAgent.analyze_progress("student_123")
      IO.inspect(advice.recommendations)
      IO.inspect(advice.next_phase)
  """
  def analyze_progress(student_id, progress_data \\ %{}) do
    directive =
      Directive.new(:analyze,
        params: %{
          student_id: student_id,
          progress_data: progress_data
        }
      )

    case Jido.Agent.run(__MODULE__, directive) do
      {:ok, agent} ->
        {:ok, Agent.get_result(agent)}

      error ->
        error
    end
  end
end
