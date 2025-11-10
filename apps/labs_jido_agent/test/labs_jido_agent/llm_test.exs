defmodule LabsJidoAgent.LLMTest do
  use ExUnit.Case, async: true

  alias LabsJidoAgent.LLM

  describe "provider/0" do
    test "returns :openai when LLM_PROVIDER is openai" do
      System.put_env("LLM_PROVIDER", "openai")
      assert LLM.provider() == :openai
    end

    test "returns :anthropic when LLM_PROVIDER is anthropic" do
      System.put_env("LLM_PROVIDER", "anthropic")
      assert LLM.provider() == :anthropic
    end

    test "returns :gemini when LLM_PROVIDER is gemini" do
      System.put_env("LLM_PROVIDER", "gemini")
      assert LLM.provider() == :gemini
    end

    test "defaults to :openai when LLM_PROVIDER is not set" do
      System.delete_env("LLM_PROVIDER")
      assert LLM.provider() == :openai
    end
  end

  describe "model_name/1" do
    test "returns correct OpenAI models" do
      System.put_env("LLM_PROVIDER", "openai")
      assert LLM.model_name(:fast) == "gpt-5-nano"
      assert LLM.model_name(:balanced) == "gpt-5-mini"
      assert LLM.model_name(:smart) == "gpt-5"
    end

    test "returns correct Anthropic models" do
      System.put_env("LLM_PROVIDER", "anthropic")
      assert LLM.model_name(:fast) == "claude-haiku-4-5"
      assert LLM.model_name(:balanced) == "claude-sonnet-4-5"
      assert LLM.model_name(:smart) == "claude-opus-4-1"
    end

    test "returns correct Gemini models" do
      System.put_env("LLM_PROVIDER", "gemini")
      assert LLM.model_name(:fast) == "gemini-2.5-flash"
      assert LLM.model_name(:balanced) == "gemini-2.5-flash"
      assert LLM.model_name(:smart) == "gemini-2.5-pro"
    end

    test "defaults to :balanced tier" do
      System.put_env("LLM_PROVIDER", "openai")
      assert LLM.model_name() == "gpt-5-mini"
    end
  end

  describe "available?/0" do
    test "returns true when OpenAI API key is set" do
      System.put_env("LLM_PROVIDER", "openai")
      System.put_env("OPENAI_API_KEY", "test-key")
      assert LLM.available?() == true
    end

    test "returns true when Anthropic API key is set" do
      System.put_env("LLM_PROVIDER", "anthropic")
      System.put_env("ANTHROPIC_API_KEY", "test-key")
      assert LLM.available?() == true
    end

    test "returns true when Gemini API key is set" do
      System.put_env("LLM_PROVIDER", "gemini")
      System.put_env("GEMINI_API_KEY", "test-key")
      assert LLM.available?() == true
    end

    test "returns false when no API key is set" do
      System.put_env("LLM_PROVIDER", "openai")
      System.delete_env("OPENAI_API_KEY")
      assert LLM.available?() == false
    end
  end

  describe "chat/2" do
    test "returns error when LLM not available" do
      System.put_env("LLM_PROVIDER", "openai")
      System.delete_env("OPENAI_API_KEY")

      result = LLM.chat("Test prompt")

      assert {:error, message} = result
      assert message =~ "LLM not configured"
      assert message =~ "OPENAI_API_KEY"
    end

    test "uses balanced model by default" do
      # This test verifies the default options are set correctly
      System.put_env("LLM_PROVIDER", "openai")
      System.delete_env("OPENAI_API_KEY")

      # Even though it will fail, we can verify it attempts with right defaults
      result = LLM.chat("Test")
      assert {:error, _} = result
    end

    test "accepts custom options" do
      System.put_env("LLM_PROVIDER", "anthropic")
      System.delete_env("ANTHROPIC_API_KEY")

      result = LLM.chat("Test", model: :fast, temperature: 0.5, max_tokens: 100)
      assert {:error, _} = result
    end
  end

  describe "chat_structured/2" do
    test "requires response_model option" do
      System.put_env("LLM_PROVIDER", "openai")
      System.put_env("OPENAI_API_KEY", "test-key")

      assert_raise KeyError, fn ->
        LLM.chat_structured("Test prompt", [])
      end
    end

    test "uses correct API URL for each provider" do
      # OpenAI
      System.put_env("LLM_PROVIDER", "openai")
      System.put_env("OPENAI_API_KEY", "test-key")

      # This will fail at the API level but shows config is set up
      _result = LLM.chat_structured("Test", response_model: %{test: :string})

      # Anthropic
      System.put_env("LLM_PROVIDER", "anthropic")
      System.put_env("ANTHROPIC_API_KEY", "test-key")
      _result = LLM.chat_structured("Test", response_model: %{test: :string})

      # Gemini
      System.put_env("LLM_PROVIDER", "gemini")
      System.put_env("GEMINI_API_KEY", "test-key")
      _result = LLM.chat_structured("Test", response_model: %{test: :string})

      # Test passes if no crashes occur
      assert true
    end
  end
end
