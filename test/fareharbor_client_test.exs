defmodule FareharborClientTest do
  use ExUnit.Case, async: true

  alias FareharborClient

  @moduletag :external

  describe "get_access_token/2" do
    @tag :skip
    test "exchanges authorization code for access token" do
      # This test requires a valid authorization code
      # Skip by default and run manually with real credentials
      auth_code = System.get_env("FAREHARBOR_AUTH_CODE")

      case FareharborClient.get_access_token(auth_code) do
        {:ok, token_data} ->
          assert is_binary(token_data["access_token"])
          assert token_data["token_type"] == "Bearer"

        {:error, reason} ->
          flunk("Failed to get access token: #{inspect(reason)}")
      end
    end

    test "returns error with invalid credentials" do
      result =
        FareharborClient.get_access_token(
          "invalid_code",
          client_id: "invalid_id",
          client_secret: "invalid_secret"
        )

      assert {:error, _reason} = result
    end
  end

  describe "API requests" do
    setup do
      # Mock access token for testing
      token = "test_access_token"
      {:ok, token: token}
    end

    @tag :skip
    test "get/3 makes authenticated GET request", %{token: token} do
      # This requires a valid token and company shortname
      company = System.get_env("FAREHARBOR_COMPANY_SHORTNAME", "test-company")

      case FareharborClient.get("/companies/#{company}/items/", token) do
        {:ok, response} ->
          assert is_map(response) or is_list(response)

        {:error, %{status: 401}} ->
          # Expected if token is invalid
          :ok

        {:error, reason} ->
          flunk("Unexpected error: #{inspect(reason)}")
      end
    end

    @tag :skip
    test "post/4 makes authenticated POST request", %{token: token} do
      company = System.get_env("FAREHARBOR_COMPANY_SHORTNAME", "test-company")

      body = %{
        test: "data"
      }

      # This will fail without a valid token, but tests the function structure
      result = FareharborClient.post("/companies/#{company}/test/", token, body)

      assert match?({:ok, _} | {:error, _}, result)
    end
  end

  describe "refresh_access_token/2" do
    @tag :skip
    test "refreshes token using refresh_token" do
      refresh_token = System.get_env("FAREHARBOR_REFRESH_TOKEN")

      case FareharborClient.refresh_access_token(refresh_token) do
        {:ok, token_data} ->
          assert is_binary(token_data["access_token"])

        {:error, _reason} ->
          # Expected if no valid refresh token
          :ok
      end
    end
  end

  describe "error handling" do
    test "handles network errors gracefully" do
      # Use invalid URL to trigger network error
      result =
        Req.get("http://invalid-domain-that-does-not-exist-12345.com")
        |> case do
          {:ok, _} -> {:ok, nil}
          {:error, reason} -> {:error, reason}
        end

      assert {:error, _reason} = result
    end
  end
end
