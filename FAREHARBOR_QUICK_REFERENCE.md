# FareHarbor API Quick Reference

> Fast lookup guide for developers integrating with FareHarbor External API v1

---

## Essential URLs

```
OAuth Base:      https://fareharbor.com/oauth/
API Base:        https://fareharbor.com/api/external/v1/
Documentation:   https://developer.fareharbor.com/
```

---

## Authentication Cheat Sheet

### 1. Get Authorization URL

```
https://fareharbor.com/oauth/authorize/?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&response_type=code&state={CSRF_TOKEN}
```

### 2. Exchange Code for Token

```bash
curl -X POST https://fareharbor.com/oauth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "code": "AUTH_CODE",
    "grant_type": "authorization_code",
    "redirect_uri": "YOUR_REDIRECT_URI"
  }'
```

### 3. Refresh Token

```bash
curl -X POST https://fareharbor.com/oauth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "refresh_token": "REFRESH_TOKEN",
    "grant_type": "refresh_token"
  }'
```

### 4. Use Access Token

```bash
curl https://fareharbor.com/api/external/v1/companies/acme-tours/items/ \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

---

## Common Endpoints

### Companies

```elixir
# List all companies
GET /companies/

# Get company details
GET /companies/{shortname}/
```

### Items (Tours/Activities)

```elixir
# List all items for a company
GET /companies/{shortname}/items/

# Get specific item
GET /companies/{shortname}/items/{item_pk}/
```

### Availability

```elixir
# Check availability for a single date
GET /companies/{shortname}/items/{item_pk}/minimal/availabilities/date/{YYYY-MM-DD}/

# Check availability for date range
GET /companies/{shortname}/items/{item_pk}/minimal/availabilities/date-range/{start_date}/{end_date}/
```

### Bookings

```elixir
# Create booking
POST /companies/{shortname}/availabilities/{availability_pk}/bookings/

# Get booking details
GET /companies/{shortname}/bookings/{booking_uuid}/

# Cancel booking
DELETE /companies/{shortname}/bookings/{booking_uuid}/

# Reschedule booking
POST /companies/{shortname}/bookings/{booking_uuid}/rebook/
```

### Lodgings

```elixir
# List lodgings
GET /companies/{shortname}/lodgings/

# Get specific lodging
GET /companies/{shortname}/lodgings/{lodging_pk}/
```

### Customer Types

```elixir
# List customer types
GET /companies/{shortname}/customer-types/
```

---

## Request Examples

### List Items

```bash
curl -X GET \
  "https://fareharbor.com/api/external/v1/companies/acme-tours/items/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "items": [
    {
      "pk": 12345,
      "name": "Sunset Kayak Tour",
      "headline": "Paddle into paradise",
      "location": "Waikiki Beach",
      "customer_prototypes": [...]
    }
  ]
}
```

### Check Availability

```bash
curl -X GET \
  "https://fareharbor.com/api/external/v1/companies/acme-tours/items/12345/minimal/availabilities/date/2025-11-15/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

**Response:**
```json
{
  "availabilities": [
    {
      "pk": 98765,
      "start_at": "2025-11-15T09:00:00-10:00",
      "end_at": "2025-11-15T11:00:00-10:00",
      "capacity": 20,
      "customer_count": 5,
      "online_booking_status": "open",
      "customer_type_rates": [...]
    }
  ]
}
```

### Create Booking

```bash
curl -X POST \
  "https://fareharbor.com/api/external/v1/companies/acme-tours/availabilities/98765/bookings/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: unique-key-12345" \
  -d '{
    "contact": {
      "name": "Jane Smith",
      "email": "jane@example.com",
      "phone": "+1-808-555-1234"
    },
    "customers": [
      {"customer_type_rate": 201},
      {"customer_type_rate": 201},
      {"customer_type_rate": 202}
    ],
    "note": "Celebrating anniversary!"
  }'
```

**Response:**
```json
{
  "booking": {
    "uuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "display_id": "XYZ789",
    "status": "confirmed",
    "voucher_number": "FH-2025-11-15-XYZ789",
    "invoice_price": "325.00 usd",
    "receipt_total": "354.25 usd",
    "dashboard_url": "https://fareharbor.com/acme-tours/dashboard/...",
    "contact": {...},
    "customers": [...],
    "availability": {...}
  }
}
```

### Cancel Booking

```bash
curl -X DELETE \
  "https://fareharbor.com/api/external/v1/companies/acme-tours/bookings/a1b2c3d4-e5f6-7890-abcd-ef1234567890/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

**Response:** `204 No Content` (empty body on success)

---

## Elixir Client Usage

### Setup

```elixir
# Add to mix.exs
{:req, "~> 0.5"}
{:jason, "~> 1.4"}

# Configure in config/config.exs
config :elixir_systems_mastery, FareharborClient,
  client_id: System.get_env("FAREHARBOR_CLIENT_ID"),
  client_secret: System.get_env("FAREHARBOR_CLIENT_SECRET"),
  redirect_uri: System.get_env("FAREHARBOR_REDIRECT_URI")
```

### Get Access Token

```elixir
{:ok, token_data} = FareharborClient.get_access_token(
  "auth_code_here",
  redirect_uri: "https://yourapp.com/callback"
)

access_token = token_data["access_token"]
refresh_token = token_data["refresh_token"]
```

### List Items

```elixir
{:ok, response} = FareharborClient.get(
  "/companies/acme-tours/items/",
  access_token
)

items = response["items"]
```

### Check Availability

```elixir
{:ok, response} = FareharborClient.get(
  "/companies/acme-tours/items/12345/minimal/availabilities/date/2025-11-15/",
  access_token
)

availabilities = response["availabilities"]
```

### Create Booking

```elixir
booking_data = %{
  contact: %{
    name: "Jane Smith",
    email: "jane@example.com",
    phone: "+1-808-555-1234"
  },
  customers: [
    %{customer_type_rate: 201},
    %{customer_type_rate: 201},
    %{customer_type_rate: 202}
  ],
  note: "Celebrating anniversary!"
}

{:ok, response} = FareharborClient.post(
  "/companies/acme-tours/availabilities/98765/bookings/",
  access_token,
  booking_data
)

booking = response["booking"]
voucher_number = booking["voucher_number"]
```

### Cancel Booking

```elixir
{:ok, _} = FareharborClient.delete(
  "/companies/acme-tours/bookings/a1b2c3d4-e5f6-7890-abcd-ef1234567890/",
  access_token
)
```

---

## Data Structures

### Contact Object

```elixir
%{
  "name" => "Jane Smith",
  "email" => "jane@example.com",
  "phone" => "+1-808-555-1234",
  "normalized_phone" => "+18085551234",
  "is_subscribed_to_email_list" => true
}
```

### Customer Object

```elixir
%{
  "customer_type_rate" => 201  # Required: Customer type rate PK
}
```

### Availability Object

```elixir
%{
  "pk" => 98765,
  "start_at" => "2025-11-15T09:00:00-10:00",
  "end_at" => "2025-11-15T11:00:00-10:00",
  "capacity" => 20,
  "customer_count" => 5,
  "online_booking_status" => "open",
  "customer_type_rates" => [...]
}
```

### Booking Object

```elixir
%{
  "uuid" => "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "display_id" => "XYZ789",
  "status" => "confirmed",
  "voucher_number" => "FH-2025-11-15-XYZ789",
  "invoice_price" => "325.00 usd",
  "receipt_total" => "354.25 usd",
  "contact" => %{...},
  "customers" => [...],
  "availability" => %{...}
}
```

---

## Error Handling

### Common HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response |
| 201 | Created | Booking successful |
| 204 | No Content | Deletion successful |
| 400 | Bad Request | Check request format |
| 401 | Unauthorized | Refresh token |
| 403 | Forbidden | Check permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Availability changed |
| 422 | Validation Error | Fix input data |
| 429 | Rate Limit | Retry with backoff |
| 500 | Server Error | Retry request |
| 503 | Unavailable | Service down, retry later |

### Error Response Format

```json
{
  "error": "validation_error",
  "message": "Invalid customer count",
  "details": {
    "customers": ["At least 1 adult is required"]
  }
}
```

### Retry Logic

```elixir
defmodule FareharborRetry do
  def with_retry(request_fn, max_retries \\ 3) do
    do_retry(request_fn, 0, max_retries)
  end

  defp do_retry(request_fn, attempt, max_retries) do
    case request_fn.() do
      {:ok, result} ->
        {:ok, result}

      {:error, %{status: status}} when status in [429, 500, 502, 503, 504] ->
        if attempt < max_retries do
          backoff = :math.pow(2, attempt) * 1000 |> round()
          Process.sleep(backoff)
          do_retry(request_fn, attempt + 1, max_retries)
        else
          {:error, :max_retries_exceeded}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end

# Usage
FareharborRetry.with_retry(fn ->
  FareharborClient.get("/companies/acme-tours/items/", token)
end)
```

---

## Webhooks

### Event Types

- `booking.created` - New booking made
- `booking.updated` - Booking modified
- `booking.cancelled` - Booking cancelled
- `booking.rebooked` - Booking rescheduled

### Webhook Payload

```json
{
  "event": "booking.created",
  "timestamp": "2025-11-10T14:23:45Z",
  "company": {
    "shortname": "acme-tours"
  },
  "booking": {
    "uuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "display_id": "XYZ789",
    "status": "confirmed"
  }
}
```

### Verify Webhook Signature

```elixir
defmodule WebhookHandler do
  def verify_signature(payload, signature, secret) do
    expected = :crypto.mac(:hmac, :sha256, secret, payload)
    |> Base.encode16(case: :lower)

    Plug.Crypto.secure_compare(signature, expected)
  end

  def handle_webhook(conn) do
    payload = conn.assigns.raw_body
    signature = get_req_header(conn, "x-fareharbor-signature") |> List.first()

    if verify_signature(payload, signature, webhook_secret()) do
      process_event(Jason.decode!(payload))
      send_resp(conn, 200, "OK")
    else
      send_resp(conn, 401, "Invalid signature")
    end
  end
end
```

---

## Best Practices Checklist

### Security
- ✅ Store tokens in encrypted storage (not code/config)
- ✅ Use HTTPS for all requests
- ✅ Verify webhook signatures
- ✅ Implement CSRF protection for OAuth
- ✅ Sanitize user input
- ✅ Use environment variables for secrets

### Reliability
- ✅ Use `Idempotency-Key` header for booking creation
- ✅ Implement retry logic with exponential backoff
- ✅ Handle rate limits gracefully
- ✅ Use circuit breakers for API calls
- ✅ Monitor API health and latency
- ✅ Set up alerts for failures

### Performance
- ✅ Cache frequently accessed data (items, companies)
- ✅ Invalidate cache on webhook events
- ✅ Use connection pooling
- ✅ Batch requests where possible
- ✅ Prefetch related data in parallel
- ✅ Set appropriate cache TTLs

### User Experience
- ✅ Display times in local timezone
- ✅ Show clear error messages
- ✅ Handle availability conflicts gracefully
- ✅ Provide booking confirmation immediately
- ✅ Send confirmation emails
- ✅ Show cancellation policy clearly

---

## Testing

### Environment Variables for Testing

```bash
# .env.test
export FAREHARBOR_CLIENT_ID="test_client_id"
export FAREHARBOR_CLIENT_SECRET="test_client_secret"
export FAREHARBOR_REDIRECT_URI="http://localhost:4000/oauth/callback"
export FAREHARBOR_COMPANY_SHORTNAME="test-company"
export FAREHARBOR_WEBHOOK_SECRET="test_webhook_secret"
```

### Mock API Responses

```elixir
defmodule FareharborClientMock do
  def get("/companies/test-company/items/", _token) do
    {:ok, %{
      "items" => [
        %{
          "pk" => 12345,
          "name" => "Test Tour",
          "headline" => "Test Headline"
        }
      ]
    }}
  end

  def post("/companies/test-company/availabilities/98765/bookings/", _token, _body) do
    {:ok, %{
      "booking" => %{
        "uuid" => "test-uuid-12345",
        "status" => "confirmed"
      }
    }}
  end
end
```

### Integration Test Example

```elixir
defmodule FareharborIntegrationTest do
  use ExUnit.Case

  @moduletag :integration

  setup do
    token = get_test_token()
    {:ok, token: token}
  end

  test "complete booking flow", %{token: token} do
    # 1. List items
    {:ok, items} = FareharborClient.get("/companies/test-company/items/", token)
    assert length(items["items"]) > 0

    # 2. Check availability
    item_pk = List.first(items["items"])["pk"]
    {:ok, avail} = FareharborClient.get(
      "/companies/test-company/items/#{item_pk}/minimal/availabilities/date/2025-12-01/",
      token
    )
    assert length(avail["availabilities"]) > 0

    # 3. Create booking
    availability_pk = List.first(avail["availabilities"])["pk"]
    booking_data = %{
      contact: %{name: "Test User", email: "test@example.com", phone: "+15551234567"},
      customers: [%{customer_type_rate: 201}]
    }

    {:ok, result} = FareharborClient.post(
      "/companies/test-company/availabilities/#{availability_pk}/bookings/",
      token,
      booking_data
    )

    assert result["booking"]["status"] == "confirmed"
    booking_uuid = result["booking"]["uuid"]

    # 4. Cancel booking
    {:ok, _} = FareharborClient.delete(
      "/companies/test-company/bookings/#{booking_uuid}/",
      token
    )
  end
end
```

---

## Troubleshooting

### "Invalid client credentials"
- Verify `FAREHARBOR_CLIENT_ID` and `FAREHARBOR_CLIENT_SECRET`
- Check that environment variables are loaded
- Confirm credentials with FareHarbor support

### "Authorization code expired"
- Auth codes expire quickly (usually 10 minutes)
- Request a new authorization code
- Exchange immediately after receiving

### "Token expired" (401)
- Access tokens expire (typically 1 hour)
- Use refresh token to get new access token
- Implement automatic token refresh

### "Availability conflict" (409)
- Another user booked the slot
- Show alternative time slots
- Implement optimistic UI with rollback

### "Rate limit exceeded" (429)
- Implement exponential backoff
- Cache responses to reduce requests
- Contact FareHarbor to increase limits

### Webhook not received
- Check webhook URL is publicly accessible
- Verify HTTPS with valid certificate
- Check firewall/security group rules
- Implement retry logic (FareHarbor retries failed webhooks)

---

## Resources

### Official Documentation
- **API Docs:** https://developer.fareharbor.com/
- **GitHub:** https://github.com/FareHarbor/fareharbor-docs
- **Support:** support@fareharbor.com

### Community Resources
- **Postman Collection:** Search "FareHarbor External API" on Postman
- **Stack Overflow:** Tag `fareharbor`

### Internal Documentation
- **Architecture Guide:** `FAREHARBOR_ARCHITECTURE.md`
- **Setup Guide:** `FAREHARBOR_SETUP.md`
- **Client Code:** `lib/fareharbor_client.ex`

---

## Contact

**FareHarbor Support:**
- Email: support@fareharbor.com
- For API credentials: Contact your account manager

**Emergency Support:**
- Check status page (if available)
- Implement fallback behavior
- Monitor webhook delivery

---

*Quick Reference Version: 1.0 | Last Updated: 2025-11-12*
