defmodule LabsJidoAgent.SchemasTest do
  use ExUnit.Case, async: true

  alias LabsJidoAgent.Schemas

  describe "CodeIssue" do
    test "creates valid changeset with all fields" do
      attrs = %{
        type: :quality,
        severity: :medium,
        line: 10,
        message: "Test message",
        suggestion: "Test suggestion"
      }

      changeset = Schemas.CodeIssue.changeset(%Schemas.CodeIssue{}, attrs)
      assert changeset.valid?
    end

    test "requires type, severity, message, and suggestion" do
      changeset = Schemas.CodeIssue.changeset(%Schemas.CodeIssue{}, %{})
      refute changeset.valid?
      assert %{type: ["can't be blank"], severity: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "CodeReviewResponse" do
    test "creates valid changeset" do
      attrs = %{
        score: 85,
        summary: "Good code",
        issues: [],
        suggestions: ["Improve X"],
        resources: ["Link"]
      }

      changeset = Schemas.CodeReviewResponse.changeset(%Schemas.CodeReviewResponse{}, attrs)
      assert changeset.valid?
    end

    test "validates score range" do
      attrs = %{score: 150, summary: "Test"}
      changeset = Schemas.CodeReviewResponse.changeset(%Schemas.CodeReviewResponse{}, attrs)
      refute changeset.valid?

      attrs = %{score: -10, summary: "Test"}
      changeset = Schemas.CodeReviewResponse.changeset(%Schemas.CodeReviewResponse{}, attrs)
      refute changeset.valid?
    end
  end

  describe "StudyResponse" do
    test "creates valid changeset" do
      attrs = %{
        answer: "This is the answer",
        concepts: ["concept1", "concept2"],
        resources: ["resource1"],
        follow_ups: ["What about X?"]
      }

      changeset = Schemas.StudyResponse.changeset(%Schemas.StudyResponse{}, attrs)
      assert changeset.valid?
    end

    test "requires answer field" do
      changeset = Schemas.StudyResponse.changeset(%Schemas.StudyResponse{}, %{})
      refute changeset.valid?
      assert %{answer: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "ProgressRecommendation" do
    test "creates valid changeset" do
      attrs = %{
        priority: :high,
        type: :progress,
        message: "Keep going!",
        action: "Complete phase 2"
      }

      changeset =
        Schemas.ProgressRecommendation.changeset(%Schemas.ProgressRecommendation{}, attrs)

      assert changeset.valid?
    end

    test "requires all fields" do
      changeset = Schemas.ProgressRecommendation.changeset(%Schemas.ProgressRecommendation{}, %{})
      refute changeset.valid?

      assert %{
               priority: ["can't be blank"],
               type: ["can't be blank"],
               message: ["can't be blank"],
               action: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "ProgressAnalysis" do
    test "creates valid changeset" do
      attrs = %{
        recommendations: [],
        strengths: ["Good understanding"],
        challenges: ["Needs more practice"],
        next_phase_suggestion: "Phase 2"
      }

      changeset = Schemas.ProgressAnalysis.changeset(%Schemas.ProgressAnalysis{}, attrs)
      assert changeset.valid?
    end

    test "requires recommendations" do
      attrs = %{
        strengths: ["Test"],
        challenges: [],
        next_phase_suggestion: "Phase 2"
      }

      changeset = Schemas.ProgressAnalysis.changeset(%Schemas.ProgressAnalysis{}, attrs)
      refute changeset.valid?
    end
  end

  # Helper to extract errors from changeset
  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
