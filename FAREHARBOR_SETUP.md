# FareHarbor API Authentication Setup

This guide explains how to authenticate with the FareHarbor External API v1.

## Overview

FareHarbor uses **OAuth 2.0** authentication with bearer tokens. The authentication flow requires:

1. Obtaining API credentials (client ID and secret)
2. Exchanging an authorization code for an access token
3. Using the access token in API requests

## Prerequisites

Before you begin, you need to obtain from FareHarbor:
- **Client ID** - Your API application identifier
- **Client Secret** - Your API application secret key
- **Authorization Code** - Obtained through OAuth authorization flow

Contact FareHarbor support or check your developer dashboard to get these credentials.

## Configuration

### 1. Environment Variables

Create a `.env` file or add to your existing one:

```bash
export FAREHARBOR_CLIENT_ID="your_client_id_here"
export FAREHARBOR_CLIENT_SECRET="your_client_secret_here"
```

### 2. Application Configuration

Add to your `config/config.exs`:

```elixir
config :elixir_systems_mastery, FareharborClient,
  client_id: System.get_env("FAREHARBOR_CLIENT_ID"),
  client_secret: System.get_env("FAREHARBOR_CLIENT_SECRET"),
  base_url: "https://fareharbor.com/api/external/v1"
```

For runtime configuration, use `config/runtime.exs`:

```elixir
import Config

if config_env() == :prod do
  config :elixir_systems_mastery, FareharborClient,
    client_id: System.fetch_env!("FAREHARBOR_CLIENT_ID"),
    client_secret: System.fetch_env!("FAREHARBOR_CLIENT_SECRET"),
    base_url: "https://fareharbor.com/api/external/v1"
end
```

## Usage Examples

### Step 1: Get Access Token

Exchange your authorization code for an access token:

```elixir
# You'll receive the authorization code from the OAuth flow
auth_code = "your_authorization_code"
redirect_uri = "https://yourapp.com/callback"  # Must match what you registered

case FareharborClient.get_access_token(auth_code, redirect_uri: redirect_uri) do
  {:ok, token_data} ->
    # Token data contains:
    # %{
    #   "access_token" => "eyJ0eXAiOiJKV1Qi...",
    #   "token_type" => "Bearer",
    #   "expires_in" => 3600,
    #   "refresh_token" => "..." # if provided
    # }
    access_token = token_data["access_token"]
    IO.puts("Successfully authenticated!")

  {:error, reason} ->
    IO.puts("Authentication failed: #{inspect(reason)}")
end
```

### Step 2: Make API Requests

Use the access token to make authenticated API calls:

```elixir
# Get list of items (activities/tours)
{:ok, items} = FareharborClient.get(
  "/companies/your-company-shortname/items/",
  access_token
)

# Get availability for an item
{:ok, availability} = FareharborClient.get(
  "/companies/your-company-shortname/items/12345/availability/",
  access_token,
  start_date: "2025-01-01",
  end_date: "2025-01-31"
)

# Create a booking
booking_data = %{
  contact: %{
    name: "John Doe",
    email: "john@example.com",
    phone: "+1234567890"
  },
  customers: [
    %{customer_type_rate: 123, count: 2}
  ]
}

{:ok, booking} = FareharborClient.post(
  "/companies/your-company-shortname/availabilities/98765/bookings/",
  access_token,
  booking_data
)
```

### Step 3: Refresh Token (if needed)

If FareHarbor provides refresh tokens:

```elixir
refresh_token = token_data["refresh_token"]

case FareharborClient.refresh_access_token(refresh_token) do
  {:ok, new_token_data} ->
    new_access_token = new_token_data["access_token"]
    IO.puts("Token refreshed successfully!")

  {:error, reason} ->
    IO.puts("Token refresh failed: #{inspect(reason)}")
end
```

## OAuth Authorization Flow

To get the initial authorization code, users need to:

1. **Redirect to FareHarbor authorization URL**:
   ```
   https://fareharbor.com/oauth/authorize/?client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&response_type=code
   ```

2. **User authorizes your application**

3. **FareHarbor redirects back** to your `redirect_uri` with the code:
   ```
   https://yourapp.com/callback?code=AUTHORIZATION_CODE
   ```

4. **Exchange the code for an access token** using `FareharborClient.get_access_token/1`

## API Endpoints Reference

Common FareHarbor API endpoints (replace `{shortname}` with your company shortname):

- **Companies**: `/companies/{shortname}/`
- **Items (Activities)**: `/companies/{shortname}/items/`
- **Availability**: `/companies/{shortname}/items/{item-pk}/availability/`
- **Bookings**: `/companies/{shortname}/availabilities/{availability-pk}/bookings/`
- **Customer Types**: `/companies/{shortname}/customer-types/`

## Error Handling

Always handle errors appropriately:

```elixir
case FareharborClient.get(path, token) do
  {:ok, data} ->
    # Process successful response
    process_data(data)

  {:error, %{status: 401}} ->
    # Unauthorized - token may be expired
    # Refresh token or re-authenticate

  {:error, %{status: 404}} ->
    # Resource not found

  {:error, %{status: status, body: body}} ->
    # Other HTTP error
    Logger.error("API error: #{status} - #{inspect(body)}")

  {:error, reason} ->
    # Network or other error
    Logger.error("Request failed: #{inspect(reason)}")
end
```

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use environment variables** for client ID and secret
3. **Store access tokens securely** (consider using ETS, encrypted database, or secure cache)
4. **Implement token refresh** logic to handle expired tokens
5. **Use HTTPS** for all API communications (enforced by default)
6. **Rotate secrets** periodically

## Testing

For testing, you can override credentials:

```elixir
# In your tests
FareharborClient.get_access_token(
  "test_code",
  client_id: "test_client_id",
  client_secret: "test_secret"
)
```

## Resources

- **FareHarbor Developer Portal**: https://developer.fareharbor.com/
- **API Documentation**: https://developer.fareharbor.com/api/external/v1/
- **Support**: Contact FareHarbor support for API access and credentials

## Troubleshooting

### "Invalid client credentials"
- Verify your `FAREHARBOR_CLIENT_ID` and `FAREHARBOR_CLIENT_SECRET` are correct
- Check that environment variables are loaded

### "Invalid authorization code"
- Authorization codes are single-use and may expire quickly
- Ensure you're using a fresh code from the OAuth flow

### "Token expired"
- Implement token refresh logic
- Re-authenticate if refresh token is not available

### 401 Unauthorized on API calls
- Verify the access token is valid
- Check that the Bearer token is properly formatted in the Authorization header
