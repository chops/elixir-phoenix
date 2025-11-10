defmodule Mix.Tasks.Jido.Grade do
  @moduledoc """
  Grades student code using Jido Code Review Agent.

  Analyzes code quality, idiomatic patterns, test coverage, and provides
  constructive feedback for improvement.

  ## Usage

      # Grade current directory (auto-detect phase from checkpoint completion)
      mix jido.grade

      # Grade specific phase
      mix jido.grade --phase 1

      # Grade specific app
      mix jido.grade --app labs_csv_stats

      # Interactive mode with detailed feedback
      mix jido.grade --interactive

      # Focus on specific aspects
      mix jido.grade --focus performance
      mix jido.grade --focus idioms

  ## Options

    * `--phase` - Learning phase number (1-15), default: auto-detect
    * `--app` - Specific app to grade (e.g., labs_csv_stats)
    * `--interactive` - Show detailed feedback interactively
    * `--focus` - Review focus: quality, performance, idioms, or all (default: all)
    * `--threshold` - Minimum score to pass (default: 70)

  ## Examples

      # Grade Phase 1 code
      mix jido.grade --phase 1

      # Grade with high threshold
      mix jido.grade --phase 1 --threshold 90

      # Interactive grading for specific app
      mix jido.grade --app labs_csv_stats --interactive
  """

  use Mix.Task

  @shortdoc "Grades student code using AI code review"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _, _} =
      OptionParser.parse(args,
        switches: [
          phase: :integer,
          app: :string,
          interactive: :boolean,
          focus: :string,
          threshold: :integer
        ],
        aliases: [
          p: :phase,
          a: :app,
          i: :interactive,
          f: :focus,
          t: :threshold
        ]
      )

    phase = Keyword.get(opts, :phase, detect_current_phase())
    app = Keyword.get(opts, :app)
    interactive = Keyword.get(opts, :interactive, false)
    focus = parse_focus(Keyword.get(opts, :focus, "all"))
    threshold = Keyword.get(opts, :threshold, 70)

    Mix.shell().info("🤖 Jido Code Grader")
    Mix.shell().info("Phase: #{phase}")
    Mix.shell().info("Threshold: #{threshold}")
    Mix.shell().info("")

    # Determine what to grade
    files_to_grade =
      if app do
        get_app_files(app)
      else
        get_phase_files(phase)
      end

    if files_to_grade == [] do
      Mix.shell().error("No files found to grade")
      Mix.shell().info("Hint: Make sure you're in the repository root or specify --app")
      System.halt(1)
    end

    Mix.shell().info("Found #{length(files_to_grade)} files to review")
    Mix.shell().info("")

    # Grade each file
    results =
      Enum.map(files_to_grade, fn file ->
        grade_file(file, phase, focus, interactive)
      end)

    # Calculate overall score
    overall_score = calculate_overall_score(results)

    # Display results
    display_results(results, overall_score, threshold, interactive)

    # Exit with appropriate code
    if overall_score >= threshold do
      Mix.shell().info("")
      Mix.shell().info("✅ PASSED - Score: #{overall_score}/100")
      System.halt(0)
    else
      Mix.shell().error("")
      Mix.shell().error("❌ FAILED - Score: #{overall_score}/100 (threshold: #{threshold})")
      Mix.shell().info("")
      Mix.shell().info("Review the feedback above and improve your code.")
      System.halt(1)
    end
  end

  defp detect_current_phase do
    # Read .progress.json to determine current phase
    progress_file = "livebooks/.progress.json"

    case File.read(progress_file) do
      {:ok, content} ->
        progress = Jason.decode!(content)

        # Find first incomplete phase
        phases = get_all_phases()

        Enum.find_index(phases, fn phase ->
          phase_data = Map.get(progress, phase, %{})
          total = get_checkpoint_count(phase)
          completed = Enum.count(Map.values(phase_data), & &1)
          completed < total
        end)
        |> case do
          nil -> 1
          idx -> idx + 1
        end

      {:error, _} ->
        1
    end
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

  defp parse_focus("quality"), do: :quality
  defp parse_focus("performance"), do: :performance
  defp parse_focus("idioms"), do: :idioms
  defp parse_focus(_), do: :all

  defp get_app_files(app_name) do
    app_path = Path.join("apps", app_name)

    if File.dir?(app_path) do
      Path.wildcard(Path.join([app_path, "lib", "**", "*.ex"]))
    else
      []
    end
  end

  defp get_phase_files(phase) do
    case phase_to_app_name(phase) do
      nil ->
        Mix.shell().info("No specific app for phase #{phase}, scanning all labs apps...")
        Path.wildcard("apps/labs_*/lib/**/*.ex")

      app_name ->
        get_app_files(app_name)
    end
  end

  defp phase_to_app_name(1), do: "labs_csv_stats"
  defp phase_to_app_name(2), do: "labs_mailbox_kv"
  defp phase_to_app_name(3), do: "labs_counter_ttl"
  defp phase_to_app_name(4), do: "labs_session_workers"
  defp phase_to_app_name(5), do: "labs_inventory"
  defp phase_to_app_name(6), do: "labs_cart_api"
  defp phase_to_app_name(7), do: "labs_job_queue"
  defp phase_to_app_name(8), do: "labs_cache"
  defp phase_to_app_name(9), do: "labs_cluster"
  defp phase_to_app_name(10), do: "labs_metrics"
  defp phase_to_app_name(11), do: "labs_integration_tests"
  defp phase_to_app_name(12), do: "labs_deployment"
  defp phase_to_app_name(13), do: "labs_capstone"
  defp phase_to_app_name(14), do: "labs_architecture"
  defp phase_to_app_name(15), do: "labs_jido_agent"
  defp phase_to_app_name(_), do: nil

  defp grade_file(file_path, phase, focus, interactive) do
    Mix.shell().info("📝 Reviewing: #{Path.relative_to_cwd(file_path)}")

    case File.read(file_path) do
      {:error, reason} ->
        Mix.shell().error("  Error reading file: #{inspect(reason)}")
        %{file: file_path, score: 0, feedback: nil, passed: false, error: :unreadable}

      {:ok, ""} ->
        Mix.shell().error("  Skipping empty file")
        %{file: file_path, score: 0, feedback: nil, passed: false, error: :empty}

      {:ok, code} ->
        grade_file_content(code, file_path, phase, focus, interactive)
    end
  end

  defp grade_file_content(code, file_path, phase, focus, interactive) do
    # Use Code Review Agent
    result =
      case LabsJidoAgent.CodeReviewAgent.review(code, phase: phase, focus: focus) do
        {:ok, feedback} ->
          %{
            file: file_path,
            score: feedback.score,
            feedback: feedback,
            passed: feedback.score >= 70
          }

        {:error, reason} ->
          Mix.shell().error("  Error: #{inspect(reason)}")

          %{
            file: file_path,
            score: 0,
            feedback: nil,
            passed: false,
            error: reason
          }
      end

    # Display feedback if interactive
    if interactive && result.feedback do
      display_file_feedback(result)
    else
      status_icon = if result.passed, do: "✅", else: "⚠️ "
      Mix.shell().info("  #{status_icon} Score: #{result.score}/100")

      if length(result.feedback.issues) > 0 do
        Mix.shell().info("  Issues found: #{length(result.feedback.issues)}")
      end
    end

    Mix.shell().info("")
    result
  end

  defp display_file_feedback(result) do
    feedback = result.feedback

    Mix.shell().info("  Score: #{feedback.score}/100")
    Mix.shell().info("")

    display_issues(feedback.issues)
    display_suggestions(feedback.suggestions)
  end

  defp display_issues([]), do: :ok

  defp display_issues(issues) do
    Mix.shell().info("  Issues:")
    Enum.each(issues, &display_single_issue/1)
  end

  defp display_single_issue(issue) do
    severity_color = severity_to_color(issue.severity)

    Mix.shell().info([
      "    ",
      severity_color,
      "#{String.upcase(to_string(issue.severity))}",
      :reset,
      " [#{issue.type}] Line #{issue.line || "?"}"
    ])

    Mix.shell().info("    #{issue.message}")

    if issue.suggestion do
      Mix.shell().info(["    ", :green, "💡 #{issue.suggestion}", :reset])
    end

    Mix.shell().info("")
  end

  defp severity_to_color(:critical), do: :red
  defp severity_to_color(:high), do: :red
  defp severity_to_color(:medium), do: :yellow
  defp severity_to_color(:low), do: :cyan
  defp severity_to_color(_), do: :normal

  defp display_suggestions([]), do: :ok

  defp display_suggestions(suggestions) do
    Mix.shell().info("  Suggestions:")
    Enum.each(suggestions, &display_single_suggestion/1)
    Mix.shell().info("")
  end

  defp display_single_suggestion(suggestion) do
    Mix.shell().info("    • #{suggestion.suggestion}")

    if length(suggestion.resources) > 0 do
      Mix.shell().info("      Resources: #{Enum.join(suggestion.resources, ", ")}")
    end
  end

  defp calculate_overall_score(results) do
    scores = Enum.map(results, & &1.score)
    total = Enum.sum(scores)
    count = length(scores)

    if count > 0, do: div(total, count), else: 0
  end

  defp display_results(results, overall_score, threshold, false = _interactive) do
    Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    Mix.shell().info("Results Summary")
    Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    passed = Enum.count(results, & &1.passed)
    total = length(results)

    Mix.shell().info("Files reviewed: #{total}")
    Mix.shell().info("Files passed: #{passed}/#{total}")
    Mix.shell().info("Overall score: #{overall_score}/100")

    total_issues =
      results
      |> Enum.map(fn r -> if r.feedback, do: length(r.feedback.issues), else: 0 end)
      |> Enum.sum()

    if total_issues > 0 do
      Mix.shell().info("Total issues: #{total_issues}")
      Mix.shell().info("")
      Mix.shell().info("Run with --interactive for detailed feedback")
    end
  end

  defp display_results(_results, _overall_score, _threshold, true = _interactive) do
    # Already displayed inline
    :ok
  end
end
