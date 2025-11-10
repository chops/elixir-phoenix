defmodule LabsJidoAgent.ActionsIntegrationTest do
  use ExUnit.Case, async: true

  alias LabsJidoAgent.{CodeReviewAction, ProgressCoachAction, StudyBuddyAction}

  describe "CodeReviewAction" do
    test "run/2 with valid code" do
      code = """
      defmodule Example do
        def add(a, b), do: a + b
      end
      """

      {:ok, result} = CodeReviewAction.run(
        %{code: code, phase: 1, focus: :all, use_llm: false},
        %{}
      )

      assert is_map(result)
      assert Map.has_key?(result, :score)
      assert Map.has_key?(result, :issues)
      assert Map.has_key?(result, :suggestions)
      assert is_integer(result.score)
      assert is_list(result.issues)
      assert is_list(result.suggestions)
    end

    test "run/2 with different focus areas" do
      code = "defmodule Test do\nend"

      {:ok, quality_result} = CodeReviewAction.run(
        %{code: code, phase: 1, focus: :quality, use_llm: false},
        %{}
      )
      {:ok, performance_result} = CodeReviewAction.run(
        %{code: code, phase: 1, focus: :performance, use_llm: false},
        %{}
      )
      {:ok, idioms_result} = CodeReviewAction.run(
        %{code: code, phase: 1, focus: :idioms, use_llm: false},
        %{}
      )

      assert is_map(quality_result)
      assert is_map(performance_result)
      assert is_map(idioms_result)
    end

    test "run/2 handles empty code" do
      result = CodeReviewAction.run(
        %{code: "", phase: 1, focus: :all, use_llm: false},
        %{}
      )

      assert {:ok, response} = result
      assert is_map(response)
    end

    test "run/2 with different phases" do
      code = "defmodule Test do\nend"

      {:ok, phase1} = CodeReviewAction.run(
        %{code: code, phase: 1, focus: :all, use_llm: false},
        %{}
      )
      {:ok, phase5} = CodeReviewAction.run(
        %{code: code, phase: 5, focus: :all, use_llm: false},
        %{}
      )
      {:ok, phase10} = CodeReviewAction.run(
        %{code: code, phase: 10, focus: :all, use_llm: false},
        %{}
      )

      assert is_map(phase1)
      assert is_map(phase5)
      assert is_map(phase10)
    end
  end

  describe "StudyBuddyAction" do
    test "run/2 answers simple questions" do
      {:ok, result} = StudyBuddyAction.run(
        %{question: "What is a process?", phase: 2, mode: :explain, use_llm: false},
        %{}
      )

      assert is_map(result)
      assert Map.has_key?(result, :answer)
      assert Map.has_key?(result, :concepts)
      assert is_binary(result.answer)
      assert is_list(result.concepts)
    end

    test "run/2 with different explanation modes" do
      question = "What is pattern matching?"

      {:ok, explain_result} = StudyBuddyAction.run(
        %{question: question, phase: 1, mode: :explain, use_llm: false},
        %{}
      )
      {:ok, socratic_result} = StudyBuddyAction.run(
        %{question: question, phase: 1, mode: :socratic, use_llm: false},
        %{}
      )
      {:ok, example_result} = StudyBuddyAction.run(
        %{question: question, phase: 1, mode: :example, use_llm: false},
        %{}
      )

      assert is_binary(explain_result.answer)
      assert is_binary(socratic_result.answer)
      assert is_binary(example_result.answer)
    end

    test "run/2 extracts concepts from questions" do
      {:ok, result} = StudyBuddyAction.run(
        %{question: "How do GenServers handle state?", phase: 3, mode: :explain, use_llm: false},
        %{}
      )

      assert is_list(result.concepts)
      assert length(result.concepts) > 0
    end

    test "run/2 provides follow-up questions" do
      {:ok, result} = StudyBuddyAction.run(
        %{question: "What is OTP?", phase: 3, mode: :explain, use_llm: false},
        %{}
      )

      assert Map.has_key?(result, :follow_ups)
      assert is_list(result.follow_ups)
    end

    test "run/2 includes resources" do
      {:ok, result} = StudyBuddyAction.run(
        %{question: "What are supervisors?", phase: 3, mode: :explain, use_llm: false},
        %{}
      )

      assert Map.has_key?(result, :resources)
      assert is_list(result.resources)
    end
  end

  describe "ProgressCoachAction" do
    test "run/2 analyzes empty progress" do
      {:ok, result} = ProgressCoachAction.run(
        %{student_id: "test123", progress_data: %{}, use_llm: false},
        %{}
      )

      assert is_map(result)
      assert Map.has_key?(result, :recommendations)
      assert is_list(result.recommendations)
    end

    test "run/2 analyzes progress with completed phases" do
      progress = %{
        "phase-01" => %{completed: true, score: 95},
        "phase-02" => %{completed: true, score: 88}
      }

      {:ok, result} = ProgressCoachAction.run(
        %{student_id: "test123", progress_data: progress, use_llm: false},
        %{}
      )

      assert is_map(result)
      assert Map.has_key?(result, :strengths)
      assert is_list(result.strengths)
    end

    test "run/2 identifies incomplete phases as challenges" do
      progress = %{
        "phase-01" => %{completed: true, score: 95},
        "phase-02" => %{completed: false, score: 45}
      }

      {:ok, result} = ProgressCoachAction.run(
        %{student_id: "test123", progress_data: progress, use_llm: false},
        %{}
      )

      assert Map.has_key?(result, :challenges)
      assert is_list(result.challenges)
    end

    test "run/2 suggests next phase" do
      progress = %{
        "phase-01" => %{completed: true, score: 90},
        "phase-02" => %{completed: true, score: 85}
      }

      {:ok, result} = ProgressCoachAction.run(
        %{student_id: "test123", progress_data: progress, use_llm: false},
        %{}
      )

      assert Map.has_key?(result, :next_phase)
      assert is_map(result.next_phase)
      assert Map.has_key?(result.next_phase, :phase)
    end

    test "run/2 provides recommendations with priorities" do
      progress = %{
        "phase-01" => %{completed: true, score: 70},
        "phase-02" => %{completed: false, score: 40}
      }

      {:ok, result} = ProgressCoachAction.run(
        %{student_id: "test123", progress_data: progress, use_llm: false},
        %{}
      )

      assert is_list(result.recommendations)
      assert length(result.recommendations) > 0

      # Check recommendation structure
      recommendation = List.first(result.recommendations)
      assert is_map(recommendation)
      assert Map.has_key?(recommendation, :priority)
      assert Map.has_key?(recommendation, :message)
    end
  end
end
