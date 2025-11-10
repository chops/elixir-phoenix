defmodule LabsJidoAgent.LLM do
  @moduledoc """
  Centralized LLM configuration and client for Jido agents.

  Supports multiple providers: OpenAI, Anthropic, Google Gemini.

  ## Configuration

  Set via environment variables:

      export LLM_PROVIDER=openai        # or anthropic, gemini
      export OPENAI_API_KEY=sk-...
      export ANTHROPIC_API_KEY=sk-ant-...
      export GEMINI_API_KEY=...

  ## Usage

      # Simple text completion
      {:ok, response} = LabsJidoAgent.LLM.chat("Explain recursion", model: :fast)

      # Structured output with validation
      {:ok, result} = LabsJidoAgent.LLM.chat_structured(
        "Review this code: ...",
        response_model: CodeReviewResponse,
        model: :smart
      )
  """

  @doc """
  Get the configured LLM provider.
  Defaults to :openai if not set.
  """
  def provider do
    case System.get_env("LLM_PROVIDER", "openai") do
      "anthropic" -> :anthropic
      "gemini" -> :gemini
      _ -> :openai
    end
  end

  @doc """
  Get the model name for the specified tier.

  ## Tiers
  - `:fast` - Quick, cheaper responses
  - `:smart` - Better quality, more expensive
  - `:balanced` - Middle ground
  """
  def model_name(tier \\ :balanced) do
    get_model_for_provider(provider(), tier)
  end

  defp get_model_for_provider(:openai, :fast), do: "gpt-3.5-turbo"
  defp get_model_for_provider(:openai, :balanced), do: "gpt-4-turbo-preview"
  defp get_model_for_provider(:openai, :smart), do: "gpt-4"
  defp get_model_for_provider(:anthropic, :fast), do: "claude-3-haiku-20240307"
  defp get_model_for_provider(:anthropic, :balanced), do: "claude-3-sonnet-20240229"
  defp get_model_for_provider(:anthropic, :smart), do: "claude-3-5-sonnet-20241022"
  defp get_model_for_provider(:gemini, :fast), do: "gemini-1.5-flash"
  defp get_model_for_provider(:gemini, :balanced), do: "gemini-1.5-pro"
  defp get_model_for_provider(:gemini, :smart), do: "gemini-1.5-pro"

  @doc """
  Simple chat completion returning text response.

  ## Options
  - `:model` - Model tier (`:fast`, `:balanced`, `:smart`)
  - `:temperature` - Creativity (0.0-2.0, default 0.7)
  - `:max_tokens` - Max response length
  """
  def chat(prompt, opts \\ []) do
    model = Keyword.get(opts, :model, :balanced)
    temperature = Keyword.get(opts, :temperature, 0.7)
    max_tokens = Keyword.get(opts, :max_tokens, 2000)

    params = %{
      model: model_name(model),
      temperature: temperature,
      max_tokens: max_tokens,
      messages: [
        %{role: "user", content: prompt}
      ]
    }

    case call_llm(params) do
      {:ok, response} -> {:ok, extract_text(response)}
      error -> error
    end
  end

  @doc """
  Structured chat completion with validation via Instructor.

  ## Options
  - `:response_model` - Ecto schema or map of types for validation
  - `:model` - Model tier (`:fast`, `:balanced`, `:smart`)
  - `:temperature` - Creativity (0.0-2.0)
  - `:max_retries` - Retry count for validation failures (default 2)
  """
  def chat_structured(prompt, opts) do
    response_model = Keyword.fetch!(opts, :response_model)
    model = Keyword.get(opts, :model, :balanced)
    temperature = Keyword.get(opts, :temperature, 0.7)
    max_retries = Keyword.get(opts, :max_retries, 2)

    params = %{
      model: model_name(model),
      temperature: temperature,
      response_model: response_model,
      max_retries: max_retries,
      messages: [
        %{role: "user", content: prompt}
      ]
    }

    Instructor.chat_completion(params)
  end

  @doc """
  Check if LLM is configured and available.
  """
  def available? do
    case provider() do
      :openai -> System.get_env("OPENAI_API_KEY") != nil
      :anthropic -> System.get_env("ANTHROPIC_API_KEY") != nil
      :gemini -> System.get_env("GEMINI_API_KEY") != nil
    end
  end

  # Private functions

  defp call_llm(params) do
    if available?() do
      # Use Instructor for all calls (it handles provider differences)
      Instructor.chat_completion(params)
    else
      {:error, "LLM not configured. Set #{provider_env_var()} environment variable."}
    end
  end

  defp extract_text(%{choices: [%{message: %{content: content}} | _]}), do: content
  defp extract_text(response) when is_binary(response), do: response
  defp extract_text(_), do: ""

  defp provider_env_var do
    case provider() do
      :openai -> "OPENAI_API_KEY"
      :anthropic -> "ANTHROPIC_API_KEY"
      :gemini -> "GEMINI_API_KEY"
    end
  end
end
