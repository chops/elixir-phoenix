# Labs: Jido Agent

**Phase 15: AI/ML Integration**

An educational lab demonstrating AI agent patterns in Elixir using the Jido v1.0 framework.

> ℹ️ **Implementation Note**
>
> This implementation uses **simulated AI responses** (pattern matching, not actual LLMs).
> It demonstrates the Jido Agent + Action architecture and educational tooling patterns.
>
> **What works:**
> - ✅ Full Jido v1.0 Agent and Action implementation
> - ✅ All tests passing (14/14)
> - ✅ Mix tasks functional
> - ✅ Proper error handling
>
> **What's simulated:**
> - AI responses are hardcoded (not using Instructor/LLM)
> - Pattern-based code analysis (not AST parsing)
>
> **For production use:** Replace simulated logic with actual LLM calls via Instructor.

## 🎯 Learning Objectives

By completing this lab, you will:

- Understand agent-based architecture (plan → act → observe)
- Build AI agents with structured lifecycles
- Integrate LLMs into Elixir systems
- Handle async workflows with supervision
- Implement multi-agent coordination patterns
- Learn RAG (Retrieval Augmented Generation) patterns

## 🤖 Agents Included

### 1. Code Review Agent
**File:** `lib/labs_jido_agent/code_review_agent.ex`

Reviews Elixir code and provides constructive feedback on:
- Code quality and idioms
- Performance issues (tail recursion, etc.)
- Documentation completeness
- Pattern matching usage

**Example:**
```elixir
code = """
defmodule MyList do
  def sum([]), do: 0
  def sum([h | t]), do: h + sum(t)
end
"""

{:ok, feedback} = LabsJidoAgent.CodeReviewAgent.review(code, phase: 1)
IO.inspect(feedback.issues)
# => [%{type: :performance, message: "Non-tail-recursive function detected", ...}]
```

### 2. Study Buddy Agent
**File:** `lib/labs_jido_agent/study_buddy_agent.ex`

Answers questions about Elixir concepts using knowledge base retrieval.

**Modes:**
- `:explain` - Direct explanations with examples
- `:socratic` - Guides learning through questions
- `:example` - Provides code examples

**Example:**
```elixir
{:ok, response} = LabsJidoAgent.StudyBuddyAgent.ask("What is tail recursion?")
IO.puts(response.answer)
# => "Tail-call optimization occurs when..."

IO.inspect(response.resources)
# => ["Livebook: phase-01-core/02-recursion.livemd", ...]
```

### 3. Progress Coach Agent
**File:** `lib/labs_jido_agent/progress_coach_agent.ex`

Analyzes learning progress and provides personalized recommendations.

**Features:**
- Reads `.progress.json` automatically
- Identifies strengths and challenges
- Suggests next phases
- Recommends review areas
- Estimates time to completion

**Example:**
```elixir
{:ok, advice} = LabsJidoAgent.ProgressCoachAgent.analyze_progress("student_123")

IO.inspect(advice.recommendations)
# => [%{priority: :high, message: "You're doing great on phase-01-core!"}]

IO.inspect(advice.next_phase)
# => %{phase: "phase-02-processes", prerequisite_met: true}
```

## 📚 Key Concepts Demonstrated

### Agent Lifecycle

All agents follow the Jido lifecycle:

1. **Plan** - Analyze input and create execution plan
2. **Act** - Execute the plan (call LLM, analyze data, etc.)
3. **Observe** - Generate observations and signals

```elixir
defmodule MyAgent do
  use Jido.Agent

  @impl Jido.Agent
  def plan(agent, directive) do
    # Extract parameters, create plan
    {:ok, Agent.put_plan(agent, plan)}
  end

  @impl Jido.Agent
  def act(agent) do
    # Execute plan, generate result
    {:ok, Agent.put_result(agent, result)}
  end

  @impl Jido.Agent
  def observe(agent) do
    # Create observations, emit signals
    {:ok, agent, [signal]}
  end
end
```

### Directive Pattern

Agents receive work via `Directive` structs:

```elixir
directive = Directive.new(:review_code,
  params: %{
    code: "...",
    phase: 1
  }
)

{:ok, agent} = Jido.Agent.run(CodeReviewAgent, directive)
```

### State Management

Agents maintain state through the execution:

```elixir
# Set plan
agent = Agent.put_plan(agent, %{step: 1})

# Get plan
plan = Agent.get_plan(agent)

# Set result
agent = Agent.put_result(agent, %{output: "done"})

# Get result
result = Agent.get_result(agent)
```

## 🧪 Running the Agents

### Interactive Testing (IEx)

```elixir
# Start IEx with the app
iex -S mix

# Test Code Review Agent
code = "defmodule Example do\n  def hello, do: :world\nend"
{:ok, feedback} = LabsJidoAgent.CodeReviewAgent.review(code)

# Test Study Buddy
{:ok, answer} = LabsJidoAgent.StudyBuddyAgent.ask("What is pattern matching?")

# Test Progress Coach
{:ok, advice} = LabsJidoAgent.ProgressCoachAgent.analyze_progress("me")
```

### From Other Apps

```elixir
# In mix.exs deps
defp deps do
  [
    {:labs_jido_agent, in_umbrella: true}
  ]
end

# Then use
alias LabsJidoAgent.CodeReviewAgent

{:ok, feedback} = CodeReviewAgent.review(my_code, phase: 3)
```

## 🔬 Exercises

### Exercise 1: Extend Code Review Agent

Add a new review aspect:

```elixir
# Add to get_review_aspects/2
defp get_review_aspects(phase, :security) do
  [:sql_injection, :xss, :secrets_in_code]
end

# Implement detection in analyze_code_structure/2
if :secrets_in_code in aspects and String.contains?(code, "password =") do
  # Add security warning
end
```

### Exercise 2: Build a Test Generator Agent

Create an agent that generates property tests:

```elixir
defmodule LabsJidoAgent.TestGeneratorAgent do
  use Jido.Agent,
    name: "test_generator",
    schema: [
      function_code: [type: :string, required: true],
      test_type: [type: {:in, [:property, :example]}, default: :property]
    ]

  # Implement plan/2, act/1, observe/1
  # Generate StreamData property tests based on function signature
end
```

### Exercise 3: Multi-Agent Workflow

Create a workflow that coordinates multiple agents:

```elixir
defmodule LabsJidoAgent.FullReviewWorkflow do
  # 1. Code Review Agent analyzes code
  # 2. Test Generator creates tests
  # 3. Study Buddy explains any issues found
  # 4. Progress Coach updates student progress
end
```

### Exercise 4: Add LLM Integration

Replace simulated responses with real LLM calls using Instructor:

```elixir
defmodule CodeReviewSchema do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :score, :integer
    embeds_many :issues, Issue do
      field :type, :string
      field :severity, :string
      field :message, :string
      field :suggestion, :string
    end
  end
end

# In act/1
{:ok, review} = Instructor.chat_completion(
  model: "gpt-4",
  response_model: CodeReviewSchema,
  messages: [
    %{role: "user", content: "Review this Elixir code: #{code}"}
  ]
)
```

## 🎓 Learning Path

1. **Read the Code** - Study each agent implementation
2. **Understand Lifecycle** - Trace plan → act → observe flow
3. **Run Examples** - Test agents in IEx
4. **Complete Exercises** - Build new features
5. **Integrate LLMs** - Add real AI capabilities
6. **Build Multi-Agent Systems** - Coordinate multiple agents

## 📖 Resources

- **Jido Documentation**: https://github.com/agentjido/jido
- **Instructor (Elixir)**: Structured LLM outputs
- **Agent Patterns**: Plan-Act-Observe architecture
- **RAG**: Retrieval Augmented Generation

## 🚀 Next Steps

After mastering this lab:

1. Add agents to Livebook (Smart Cell integration)
2. Build a code grading system
3. Create an adaptive learning path generator
4. Implement pair programming assistant
5. Build multi-agent project scaffolder

## 🧩 Integration with Learning System

These agents are designed to integrate with:

- **Livebook** - Smart Cells for interactive assistance
- **Mix Tasks** - CLI tools for grading and help
- **Progress Tracking** - Automated coaching
- **CI/CD** - Automated code review in PRs

See the main repository for full integration examples!

## 📝 License

Part of Elixir Systems Mastery learning repository.
