defmodule LabsJidoAgent do
  @moduledoc """
  Educational lab demonstrating AI agent patterns using the Jido framework.

  This application provides three AI agents for learning assistance:

  - `LabsJidoAgent.CodeReviewAgent` - Reviews Elixir code for quality and idioms
  - `LabsJidoAgent.StudyBuddyAgent` - Answers questions about Elixir concepts
  - `LabsJidoAgent.ProgressCoachAgent` - Analyzes learning progress and provides guidance

  ## Quick Start

      # Review some code
      {:ok, feedback} = LabsJidoAgent.CodeReviewAgent.review(code, phase: 1)

      # Ask a question
      {:ok, answer} = LabsJidoAgent.StudyBuddyAgent.ask("What is tail recursion?")

      # Analyze progress
      {:ok, advice} = LabsJidoAgent.ProgressCoachAgent.analyze_progress("student_123")

  See the README for full documentation and examples.
  """

  @doc """
  Returns the version of the labs_jido_agent application.
  """
  def version do
    Application.spec(:labs_jido_agent, :vsn) |> to_string()
  end
end
