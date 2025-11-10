# LLM Integration Setup Guide

This guide explains how to configure the LabsJidoAgent educational AI system to use real LLM providers.

## Overview

LabsJidoAgent supports three LLM providers:
- **OpenAI** (GPT-4, GPT-3.5)
- **Anthropic** (Claude 3.5 Sonnet, Claude 3 Haiku)
- **Google Gemini** (Gemini 1.5 Pro, Gemini 1.5 Flash)

The system automatically falls back to simulated mode if no API key is configured, ensuring the application works without requiring LLM access.

## Quick Start

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Choose your provider and add your API key:**

   Edit `.env` and set:
   ```bash
   LLM_PROVIDER=openai  # or anthropic, or gemini
   OPENAI_API_KEY=sk-proj-your-key-here
   ```

3. **Load environment variables before running:**
   ```bash
   source .env
   mix test
   ```

   Or use `direnv` for automatic loading:
   ```bash
   echo "dotenv" >> .envrc
   direnv allow
   ```

## Getting API Keys

### OpenAI
1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign in or create an account
3. Create a new API key
4. Copy the key (starts with `sk-proj-`)

### Anthropic
1. Visit [Anthropic Console](https://console.anthropic.com/settings/keys)
2. Sign in or create an account
3. Create a new API key
4. Copy the key (starts with `sk-ant-`)

### Google Gemini
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy the key

## Model Selection

The system uses three model tiers that automatically map to the appropriate model for your provider:

| Tier | Use Case | OpenAI | Anthropic | Gemini |
|------|----------|--------|-----------|--------|
| `:fast` | Quick responses | gpt-3.5-turbo | claude-3-haiku-20240307 | gemini-1.5-flash |
| `:balanced` | Good quality/speed | gpt-4-turbo-preview | claude-3-5-sonnet-20241022 | gemini-1.5-pro-latest |
| `:smart` | Best quality | gpt-4-turbo-preview | claude-3-5-sonnet-20241022 | gemini-1.5-pro-latest |

You don't need to configure models manually - the system chooses the appropriate one based on the task:
- **Code Review**: Uses `:smart` (highest quality)
- **Study Buddy**: Uses `:balanced` (good balance)
- **Progress Coach**: Uses `:balanced` (good balance)

## Usage Examples

### Code Review

```elixir
# With LLM (default)
code = """
defmodule MyList do
  def sum([]), do: 0
  def sum([h | t]), do: h + sum(t)
end
"""

{:ok, feedback} = LabsJidoAgent.CodeReviewAgent.review(code, phase: 1)
IO.inspect(feedback.llm_powered)  # true
IO.inspect(feedback.score)
IO.inspect(feedback.issues)

# Force simulated mode
{:ok, feedback} = LabsJidoAgent.CodeReviewAgent.review(code,
  phase: 1, use_llm: false)
IO.inspect(feedback.llm_powered)  # false
```

### Study Buddy

```elixir
# Ask a question
{:ok, response} = LabsJidoAgent.StudyBuddyAgent.ask(
  "What is tail recursion?",
  phase: 1,
  mode: :explain
)

IO.puts(response.answer)
IO.inspect(response.concepts)
IO.inspect(response.resources)
```

### Progress Coach

```elixir
# Analyze progress
{:ok, advice} = LabsJidoAgent.ProgressCoachAgent.analyze_progress("student_123")

IO.inspect(advice.recommendations)
IO.inspect(advice.next_phase)
IO.inspect(advice.strengths)
```

## Simulated Mode

If no API key is configured, or if you explicitly set `use_llm: false`, the system uses simulated responses:

- **Code Review**: Pattern-based analysis for common issues
- **Study Buddy**: Pre-configured explanations for common topics
- **Progress Coach**: Statistical analysis of progress data

This ensures the system is useful even without LLM access, making it ideal for:
- Testing and development
- Cost-conscious deployments
- Offline environments
- Educational demonstrations

## Testing

Run tests in simulated mode (no API key needed):
```bash
mix test
```

Run tests with LLM (requires API key):
```bash
LLM_PROVIDER=openai OPENAI_API_KEY=sk-... mix test
```

All tests should pass regardless of LLM availability.

## Cost Considerations

### Typical Costs per Request

**OpenAI GPT-4:**
- Code review (~1000 tokens): $0.01 - $0.03
- Q&A (~500 tokens): $0.005 - $0.015

**Anthropic Claude:**
- Code review: $0.003 - $0.015
- Q&A: $0.001 - $0.008

**Google Gemini:**
- Code review: Free tier available, then $0.001 - $0.005
- Q&A: Free tier available, then $0.0005 - $0.003

### Cost Optimization Tips

1. Use simulated mode for development/testing
2. Use `:fast` models for less critical tasks
3. Set reasonable timeout limits
4. Monitor usage via provider dashboards

## Troubleshooting

### LLM not being used

Check:
1. API key is correctly set: `echo $OPENAI_API_KEY`
2. Provider matches key: `LLM_PROVIDER=openai` for OpenAI keys
3. `use_llm: true` is set (default)

Test availability:
```elixir
iex> LabsJidoAgent.LLM.available?()
true

iex> LabsJidoAgent.LLM.provider()
:openai
```

### API Errors

Common issues:
- **Invalid API key**: Check key is correct and active
- **Rate limits**: Wait and retry, or upgrade plan
- **Model not found**: Check provider has access to the model
- **Timeout**: Increase timeout or use `:fast` model

The system automatically falls back to simulated mode on LLM errors.

## Architecture

The LLM integration uses:
- **Instructor**: For structured LLM output with validation
- **Ecto Schemas**: Define expected response structure
- **Graceful Fallback**: Automatic simulated mode on errors

Key modules:
- `LabsJidoAgent.LLM` - Provider abstraction and configuration
- `LabsJidoAgent.Schemas` - Response validation schemas
- `LabsJidoAgent.*Action` - LLM integration with fallback

## Next Steps

1. Configure your API key
2. Try the interactive examples above
3. Explore the Livebook notebooks with LLM-powered assistance
4. Review the code in `apps/labs_jido_agent/lib/labs_jido_agent/`

For questions or issues, please open a GitHub issue.
