#!/usr/bin/env elixir

# Quick LLM integration test script
# Usage:
#   export OPENAI_API_KEY=sk-...
#   mix run test_llm.exs

IO.puts("\n=== LLM Integration Test ===\n")

# Check if LLM is available
IO.puts("1. Checking LLM availability...")
available = LabsJidoAgent.LLM.available?()
provider = LabsJidoAgent.LLM.provider()
IO.puts("   LLM Available: #{available}")
IO.puts("   Provider: #{provider}")

if not available do
  IO.puts("\n❌ No API key found. Set one of:")
  IO.puts("   export OPENAI_API_KEY=sk-...")
  IO.puts("   export ANTHROPIC_API_KEY=sk-ant-...")
  IO.puts("   export GEMINI_API_KEY=...")
  System.halt(1)
end

IO.puts("\n2. Testing Code Review with LLM...")
code = """
defmodule Example do
  def sum([]), do: 0
  def sum([h | t]), do: h + sum(t)
end
"""

case LabsJidoAgent.CodeReviewAgent.review(code, phase: 1, use_llm: true) do
  {:ok, feedback} ->
    IO.puts("   ✓ Code review successful!")
    IO.puts("   LLM Powered: #{feedback.llm_powered}")
    IO.puts("   Score: #{feedback.score}/100")
    IO.puts("   Issues found: #{length(feedback.issues)}")
    if length(feedback.issues) > 0 do
      IO.puts("\n   First issue:")
      issue = List.first(feedback.issues)
      message = Map.get(issue, "message") || Map.get(issue, :message)
      suggestion = Map.get(issue, "suggestion") || Map.get(issue, :suggestion)
      IO.puts("   - #{message}")
      IO.puts("   - Suggestion: #{suggestion}")
    end

  {:error, reason} ->
    IO.puts("   ❌ Code review failed: #{inspect(reason)}")
end

IO.puts("\n3. Testing Study Buddy with LLM...")
case LabsJidoAgent.StudyBuddyAgent.ask("What is tail recursion?", phase: 1, use_llm: true) do
  {:ok, response} ->
    IO.puts("   ✓ Study buddy successful!")
    IO.puts("   LLM Powered: #{response.llm_powered}")
    IO.puts("   Answer length: #{String.length(response.answer)} chars")
    IO.puts("   Concepts: #{inspect(response.concepts)}")
    IO.puts("\n   Answer preview:")
    IO.puts("   #{String.slice(response.answer, 0..200)}...")

  {:error, reason} ->
    IO.puts("   ❌ Study buddy failed: #{inspect(reason)}")
end

IO.puts("\n4. Testing Progress Coach with LLM...")
progress_data = %{
  "phase-01-core" => %{"basics" => true, "recursion" => true},
  "phase-02-processes" => %{"spawn" => true}
}

case LabsJidoAgent.ProgressCoachAgent.analyze_progress("test_student", progress_data, use_llm: true) do
  {:ok, advice} ->
    IO.puts("   ✓ Progress coach successful!")
    IO.puts("   LLM Powered: #{advice.llm_powered}")
    IO.puts("   Recommendations: #{length(advice.recommendations)}")
    IO.puts("   Strengths: #{inspect(advice.strengths)}")
    if length(advice.recommendations) > 0 do
      IO.puts("\n   First recommendation:")
      rec = List.first(advice.recommendations)
      IO.puts("   - Priority: #{rec.priority}")
      IO.puts("   - #{rec.message}")
    end

  {:error, reason} ->
    IO.puts("   ❌ Progress coach failed: #{inspect(reason)}")
end

IO.puts("\n=== Test Complete ===\n")
