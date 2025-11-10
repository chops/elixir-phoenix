defmodule LabsJidoAgentTest do
  use ExUnit.Case
  doctest LabsJidoAgent

  alias LabsJidoAgent.{CodeReviewAgent, ProgressCoachAgent, StudyBuddyAgent}

  describe "CodeReviewAgent" do
    test "reviews code and finds non-tail-recursive functions" do
      code = """
      defmodule BadList do
        def sum([]), do: 0
        def sum([h | t]), do: h + sum(t)
      end
      """

      {:ok, feedback} = CodeReviewAgent.review(code, phase: 1)

      assert feedback.score < 100
      assert length(feedback.issues) > 0

      # Should detect non-tail recursion
      assert Enum.any?(feedback.issues, fn issue ->
               issue.type == :performance &&
                 String.contains?(issue.message, "tail-recursive")
             end)
    end

    test "reviews code and finds missing documentation" do
      code = """
      defmodule Example do
        def hello, do: :world
      end
      """

      {:ok, feedback} = CodeReviewAgent.review(code, phase: 1)

      # Should detect missing docs
      assert Enum.any?(feedback.issues, fn issue ->
               issue.type == :quality && String.contains?(issue.message, "documentation")
             end)
    end

    test "provides suggestions for improvements" do
      code = """
      defmodule MyList do
        def length([]), do: 0
        def length([_ | t]), do: 1 + length(t)
      end
      """

      {:ok, feedback} = CodeReviewAgent.review(code, phase: 1)

      assert length(feedback.suggestions) > 0
      assert Enum.all?(feedback.suggestions, &Map.has_key?(&1, :suggestion))
      assert Enum.all?(feedback.suggestions, &Map.has_key?(&1, :resources))
    end

    test "returns perfect score for well-written code" do
      code = """
      @moduledoc "Example module"
      defmodule GoodCode do
        @doc "Does something good"
        def process(data) when is_list(data) do
          data
          |> Enum.map(&transform/1)
          |> Enum.filter(&valid?/1)
        end
      end
      """

      {:ok, feedback} = CodeReviewAgent.review(code, phase: 1)

      assert feedback.score >= 90
    end
  end

  describe "StudyBuddyAgent" do
    test "answers questions about recursion" do
      {:ok, response} = StudyBuddyAgent.ask("What is recursion?")

      assert Map.has_key?(response, :answer)
      assert Map.has_key?(response, :resources)
      assert Map.has_key?(response, :follow_ups)

      assert String.contains?(response.answer, "recursion") ||
               String.contains?(response.answer, "Recursion")
    end

    test "provides different modes of explanation" do
      question = "What is tail recursion?"

      {:ok, explain} = StudyBuddyAgent.ask(question, mode: :explain)
      {:ok, socratic} = StudyBuddyAgent.ask(question, mode: :socratic)
      {:ok, example} = StudyBuddyAgent.ask(question, mode: :example)

      # Each mode should have an answer
      assert explain.answer
      assert socratic.answer
      assert example.answer
    end

    test "suggests relevant resources" do
      {:ok, response} = StudyBuddyAgent.ask("How do I use pattern matching?")

      assert length(response.resources) > 0

      # Should mention Livebook
      assert Enum.any?(response.resources, &String.contains?(&1, "Livebook"))
    end

    test "provides follow-up suggestions" do
      {:ok, response} = StudyBuddyAgent.ask("What is recursion?")

      assert length(response.follow_ups) > 0
    end

    test "extracts concepts from questions" do
      {:ok, response} = StudyBuddyAgent.ask("How does GenServer work?")

      assert :genserver in response.concepts
    end
  end

  describe "ProgressCoachAgent" do
    test "analyzes progress and provides recommendations" do
      # Empty progress
      {:ok, advice} = ProgressCoachAgent.analyze_progress("test_student", %{})

      assert Map.has_key?(advice, :recommendations)
      assert Map.has_key?(advice, :next_phase)
      assert Map.has_key?(advice, :review_areas)

      assert length(advice.recommendations) > 0
    end

    test "suggests next phase when current is nearly complete" do
      # Simulate 80%+ completion of phase 1
      progress = %{
        "phase-01-core" => %{
          "checkpoint-01" => true,
          "checkpoint-02" => true,
          "checkpoint-03" => true,
          "checkpoint-04" => true,
          "checkpoint-05" => true,
          "checkpoint-06" => true
        }
      }

      {:ok, advice} = ProgressCoachAgent.analyze_progress("test_student", progress)

      # Should suggest progressing
      assert Enum.any?(advice.recommendations, fn rec ->
               rec.type == :progress
             end)
    end

    test "identifies review areas for incomplete phases" do
      # Simulate partial completion
      progress = %{
        "phase-01-core" => %{
          "checkpoint-01" => true,
          "checkpoint-02" => true
        }
      }

      {:ok, advice} = ProgressCoachAgent.analyze_progress("test_student", progress)

      # Should have valid structure
      assert is_list(advice.review_areas)
    end

    test "celebrates completed phases as strengths" do
      progress = %{
        "phase-01-core" => %{
          "checkpoint-01" => true,
          "checkpoint-02" => true,
          "checkpoint-03" => true,
          "checkpoint-04" => true,
          "checkpoint-05" => true,
          "checkpoint-06" => true,
          "checkpoint-07" => true
        }
      }

      {:ok, advice} = ProgressCoachAgent.analyze_progress("test_student", progress)

      assert length(advice.strengths) > 0
      assert "Elixir fundamentals" in advice.strengths
    end

    test "provides time estimates for next phase" do
      {:ok, advice} = ProgressCoachAgent.analyze_progress("test_student", %{})

      assert Map.has_key?(advice.estimated_time_to_next, :estimate_days)
      assert Map.has_key?(advice.estimated_time_to_next, :estimate_hours)
      assert Map.has_key?(advice.estimated_time_to_next, :confidence)
    end
  end
end
