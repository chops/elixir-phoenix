defmodule FareharborClient do
  @moduledoc """
  Client for the FareHarbor External API v1.

  Handles OAuth 2.0 authentication and provides functions to interact with the FareHarbor API.

  ## Configuration

  Add the following to your config:

      config :elixir_systems_mastery, FareharborClient,
        client_id: System.get_env("FAREHARBOR_CLIENT_ID"),
        client_secret: System.get_env("FAREHARBOR_CLIENT_SECRET"),
        base_url: "https://fareharbor.com/api/external/v1"

  ## Usage

      # Step 1: Get access token using authorization code
      {:ok, token_data} = FareharborClient.get_access_token(auth_code)

      # Step 2: Make API requests with the access token
      {:ok, response} = FareharborClient.get("/companies/my-company/items/", token_data.access_token)
  """

  @base_url "https://fareharbor.com/api/external/v1"
  @oauth_base_url "https://fareharbor.com"

  @doc """
  Exchanges an authorization code for an access token.

  ## Parameters

    - `code` - The authorization code obtained from the OAuth flow
    - `opts` - Optional keyword list with:
      - `:client_id` - Override the configured client ID
      - `:client_secret` - Override the configured client secret
      - `:redirect_uri` - The redirect URI used in the authorization request

  ## Returns

    - `{:ok, token_data}` - Success with token data containing:
      - `access_token` - The bearer token to use for API requests
      - `token_type` - Usually "Bearer"
      - `expires_in` - Token expiration time in seconds (if provided)
      - `refresh_token` - Refresh token (if provided)
    - `{:error, reason}` - Error response

  ## Examples

      iex> FareharborClient.get_access_token("AUTH_CODE_HERE", redirect_uri: "https://myapp.com/callback")
      {:ok, %{
        "access_token" => "eyJ0eXAiOiJKV1QiLCJhbGc...",
        "token_type" => "Bearer",
        "expires_in" => 3600
      }}
  """
  def get_access_token(code, opts \\ []) do
    client_id = opts[:client_id] || get_config(:client_id)
    client_secret = opts[:client_secret] || get_config(:client_secret)
    redirect_uri = opts[:redirect_uri] || get_config(:redirect_uri)

    body =
      %{
        client_id: client_id,
        client_secret: client_secret,
        code: code,
        grant_type: "authorization_code"
      }
      |> maybe_add_redirect_uri(redirect_uri)

    Req.post("#{@oauth_base_url}/oauth/token/",
      json: body,
      headers: [
        {"content-type", "application/json"}
      ]
    )
    |> handle_response()
  end

  @doc """
  Refreshes an access token using a refresh token.

  ## Parameters

    - `refresh_token` - The refresh token
    - `opts` - Optional keyword list with client credentials

  ## Returns

    - `{:ok, token_data}` - New access token data
    - `{:error, reason}` - Error response
  """
  def refresh_access_token(refresh_token, opts \\ []) do
    client_id = opts[:client_id] || get_config(:client_id)
    client_secret = opts[:client_secret] || get_config(:client_secret)

    body = %{
      client_id: client_id,
      client_secret: client_secret,
      refresh_token: refresh_token,
      grant_type: "refresh_token"
    }

    Req.post("#{@oauth_base_url}/oauth/token/",
      json: body,
      headers: [
        {"content-type", "application/json"}
      ]
    )
    |> handle_response()
  end

  @doc """
  Makes a GET request to the FareHarbor API.

  ## Parameters

    - `path` - API endpoint path (e.g., "/companies/my-company/items/")
    - `access_token` - Bearer token for authentication
    - `opts` - Optional keyword list for query parameters

  ## Examples

      iex> FareharborClient.get("/companies/my-company/items/", token)
      {:ok, %{"items" => [...]}}
  """
  def get(path, access_token, opts \\ []) do
    url = build_url(path)

    Req.get(url,
      headers: [
        {"authorization", "Bearer #{access_token}"},
        {"content-type", "application/json"}
      ],
      params: opts
    )
    |> handle_response()
  end

  @doc """
  Makes a POST request to the FareHarbor API.

  ## Parameters

    - `path` - API endpoint path
    - `access_token` - Bearer token for authentication
    - `body` - Request body (will be JSON encoded)
    - `opts` - Optional keyword list for additional options
  """
  def post(path, access_token, body, opts \\ []) do
    url = build_url(path)

    Req.post(url,
      json: body,
      headers: [
        {"authorization", "Bearer #{access_token}"},
        {"content-type", "application/json"}
      ],
      params: opts[:params] || []
    )
    |> handle_response()
  end

  @doc """
  Makes a PUT request to the FareHarbor API.
  """
  def put(path, access_token, body, opts \\ []) do
    url = build_url(path)

    Req.put(url,
      json: body,
      headers: [
        {"authorization", "Bearer #{access_token}"},
        {"content-type", "application/json"}
      ],
      params: opts[:params] || []
    )
    |> handle_response()
  end

  @doc """
  Makes a DELETE request to the FareHarbor API.
  """
  def delete(path, access_token, opts \\ []) do
    url = build_url(path)

    Req.delete(url,
      headers: [
        {"authorization", "Bearer #{access_token}"},
        {"content-type", "application/json"}
      ],
      params: opts
    )
    |> handle_response()
  end

  # Private functions

  defp build_url(path) do
    base = get_config(:base_url, @base_url)
    path = String.trim_leading(path, "/")
    "#{base}/#{path}"
  end

  defp maybe_add_redirect_uri(body, nil), do: body

  defp maybe_add_redirect_uri(body, redirect_uri) do
    Map.put(body, :redirect_uri, redirect_uri)
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}})
       when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}}) do
    {:error, %{status: status, body: body}}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end

  defp get_config(key, default \\ nil) do
    Application.get_env(:elixir_systems_mastery, __MODULE__, [])
    |> Keyword.get(key, default)
  end
end
