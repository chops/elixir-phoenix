# FareHarbor API: Complete Architectural Guide

> **Software Architect's Deep Dive into the FareHarbor External API v1**
>
> A comprehensive technical reference for building tour, activity, and experience booking platforms

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [API Overview](#api-overview)
3. [Authentication Architecture](#authentication-architecture)
4. [Data Model & Entity Relationships](#data-model--entity-relationships)
5. [API Endpoints Reference](#api-endpoints-reference)
6. [Integration Workflows](#integration-workflows)
7. [Use Cases & Business Scenarios](#use-cases--business-scenarios)
8. [Architecture Patterns](#architecture-patterns)
9. [Error Handling & Edge Cases](#error-handling--edge-cases)
10. [Performance & Optimization](#performance--optimization)
11. [Security Considerations](#security-considerations)
12. [Implementation Roadmap](#implementation-roadmap)

---

## Executive Summary

### What is FareHarbor?

FareHarbor is a **reservation and booking management system** specifically designed for tour operators, activity providers, and experience-based businesses. Think kayaking tours, wine tastings, zipline adventures, boat charters, museum tours, etc.

### The FareHarbor External API v1

The External API allows **affiliates, resellers, OTAs (Online Travel Agencies), and integration partners** to:

- **Discover** available tours and activities from FareHarbor operators
- **Check real-time availability** for specific dates and times
- **Create bookings** on behalf of customers
- **Manage bookings** (retrieve, update, cancel)
- **Receive webhook notifications** for booking changes

### Who Uses This API?

- **Travel aggregators** (Viator, GetYourGuide, Expedia Local Experiences)
- **Hotel concierge systems** (booking activities for guests)
- **Custom booking platforms** (white-label tour booking sites)
- **Channel managers** (distributing inventory across multiple platforms)
- **Integration middleware** (connecting FareHarbor with CRMs, ERPs, accounting systems)

---

## API Overview

### Base Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FareHarbor Platform                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │  Dashboard │  │ Scheduling │  │  Payments  │           │
│  │    (UI)    │  │   Engine   │  │  Gateway   │           │
│  └────────────┘  └────────────┘  └────────────┘           │
│         │               │               │                   │
│  ┌──────────────────────────────────────────┐              │
│  │      FareHarbor Core Business Logic      │              │
│  └──────────────────────────────────────────┘              │
│         │               │               │                   │
│  ┌──────────────────────────────────────────┐              │
│  │         External API v1 Layer            │◄─────────┐   │
│  │    (OAuth + REST + Webhooks)             │          │   │
│  └──────────────────────────────────────────┘          │   │
└─────────────────────────────────────────────────────────│───┘
                                                          │
                     HTTPS / JSON                         │
                                                          │
                  ┌───────────────────────────────────────┘
                  │
┌─────────────────▼────────────────────────────────────────┐
│              Your Application Layer                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐         │
│  │   OAuth    │  │  Business  │  │  Webhook   │         │
│  │   Client   │  │   Logic    │  │  Handler   │         │
│  └────────────┘  └────────────┘  └────────────┘         │
└──────────────────────────────────────────────────────────┘
```

### Key Characteristics

| Aspect | Details |
|--------|---------|
| **Protocol** | REST over HTTPS |
| **Data Format** | JSON (request and response bodies) |
| **Authentication** | OAuth 2.0 (authorization code flow) |
| **Base URL** | `https://fareharbor.com/api/external/v1/` |
| **OAuth URL** | `https://fareharbor.com/oauth/` |
| **Rate Limiting** | Varies by partner agreement (typically 100-1000 req/min) |
| **Pagination** | Cursor-based for large result sets |
| **Versioning** | URL-based (`/v1/`, `/v2/` future) |
| **Idempotency** | Supported via `Idempotency-Key` header for POST requests |
| **Webhooks** | Event-driven notifications for booking changes |

---

## Authentication Architecture

### OAuth 2.0 Flow Diagram

```mermaid
sequenceDiagram
    participant User as End User
    participant App as Your Application
    participant FH_Auth as FareHarbor OAuth Server
    participant FH_API as FareHarbor API

    Note over User,FH_API: STEP 1: Authorization Request
    User->>App: Clicks "Connect to FareHarbor"
    App->>User: Redirects to FareHarbor
    User->>FH_Auth: GET /oauth/authorize/<br/>?client_id=YOUR_CLIENT_ID<br/>&redirect_uri=YOUR_CALLBACK<br/>&response_type=code

    Note over User,FH_API: STEP 2: User Authorization
    FH_Auth->>User: Shows authorization page
    User->>FH_Auth: Approves access

    Note over User,FH_API: STEP 3: Authorization Code
    FH_Auth->>User: Redirects to callback URL
    User->>App: GET YOUR_CALLBACK?code=AUTH_CODE

    Note over User,FH_API: STEP 4: Token Exchange
    App->>FH_Auth: POST /oauth/token/<br/>{client_id, client_secret, code, grant_type}
    FH_Auth->>App: {access_token, refresh_token, expires_in}

    Note over User,FH_API: STEP 5: API Requests
    App->>FH_API: GET /companies/acme/items/<br/>Authorization: Bearer ACCESS_TOKEN
    FH_API->>App: {items: [...]}

    Note over User,FH_API: STEP 6: Token Refresh (when expired)
    App->>FH_Auth: POST /oauth/token/<br/>{refresh_token, grant_type: refresh_token}
    FH_Auth->>App: {access_token, refresh_token, expires_in}
```

### Authentication Endpoints

#### 1. Authorization URL (User-facing)

```
GET https://fareharbor.com/oauth/authorize/
```

**Query Parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `client_id` | ✅ | Your application's client ID |
| `redirect_uri` | ✅ | Callback URL (must match registered URI) |
| `response_type` | ✅ | Always `"code"` for authorization code flow |
| `state` | ⚠️ Recommended | CSRF protection token (randomly generated) |
| `scope` | ❌ | Future use (currently unused) |

**Example:**
```
https://fareharbor.com/oauth/authorize/?client_id=abc123&redirect_uri=https://myapp.com/callback&response_type=code&state=random_csrf_token
```

#### 2. Token Exchange Endpoint

```
POST https://fareharbor.com/oauth/token/
```

**Request Body (Authorization Code Grant):**

```json
{
  "client_id": "your_client_id",
  "client_secret": "your_client_secret",
  "code": "authorization_code_from_step_3",
  "grant_type": "authorization_code",
  "redirect_uri": "https://yourapp.com/callback"
}
```

**Response:**

```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "50a3f5c8-9a1b-4c2d-8e3f-4a5b6c7d8e9f",
  "scope": "read write"
}
```

**Request Body (Refresh Token Grant):**

```json
{
  "client_id": "your_client_id",
  "client_secret": "your_client_secret",
  "refresh_token": "50a3f5c8-9a1b-4c2d-8e3f-4a5b6c7d8e9f",
  "grant_type": "refresh_token"
}
```

### Using Access Tokens

All API requests require the access token in the `Authorization` header:

```http
GET /api/external/v1/companies/acme-tours/items/ HTTP/1.1
Host: fareharbor.com
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
Content-Type: application/json
```

### Token Lifecycle Management

```mermaid
stateDiagram-v2
    [*] --> NoToken: Application Start
    NoToken --> AuthorizationPending: User initiates OAuth
    AuthorizationPending --> TokenValid: Exchange code for token
    TokenValid --> TokenExpired: Time passes (expires_in)
    TokenExpired --> TokenValid: Refresh token
    TokenValid --> TokenRevoked: User revokes access
    TokenRevoked --> NoToken: Clear credentials
    NoToken --> [*]
```

**Best Practices:**

1. **Store tokens securely** (encrypted database, secret manager, not in code)
2. **Implement token refresh** 5 minutes before expiry
3. **Handle revocation gracefully** (re-initiate OAuth flow)
4. **Use refresh tokens** to avoid re-authenticating users
5. **Implement retry logic** with exponential backoff for 401 errors

---

## Data Model & Entity Relationships

### Core Entity Relationship Diagram

```mermaid
erDiagram
    COMPANY ||--o{ ITEM : offers
    COMPANY ||--o{ LODGING : has
    COMPANY ||--o{ CUSTOMER_TYPE_RATE : defines
    ITEM ||--o{ AVAILABILITY : has
    ITEM ||--o{ CUSTOMER_TYPE_RATE : supports
    ITEM ||--o{ IMAGE : displays
    AVAILABILITY ||--o{ BOOKING : contains
    BOOKING ||--|| CONTACT : has
    BOOKING ||--o{ CUSTOMER : includes
    BOOKING ||--|| CANCELLATION_POLICY : governed_by
    CUSTOMER }o--|| CUSTOMER_TYPE_RATE : categorized_by
    LODGING ||--o{ BOOKING : associated_with

    COMPANY {
        string shortname PK "URL-friendly identifier"
        string name "Display name"
        string about "Description"
        string currency "USD, EUR, etc"
        boolean booking_notes_required
        boolean booking_notes_safe_for_marketing
    }

    ITEM {
        int pk PK "Unique identifier"
        string name "Tour/Activity name"
        string headline "Short tagline"
        string description "Full description"
        string cancellation_policy "Policy text"
        int cancellation_policy_safe_html "HTML version"
        string location "Address/meeting point"
        boolean is_pickup_ever_available
        array image_cdn_urls "Image URLs"
        int customer_prototype_id FK
    }

    AVAILABILITY {
        int pk PK "Unique identifier"
        int capacity "Total spots"
        int customer_count "Booked count"
        datetime start_at "ISO 8601 timestamp"
        datetime end_at "ISO 8601 timestamp"
        boolean online_booking_status "open/closed"
        array customer_type_rates FK
    }

    BOOKING {
        uuid uuid PK "Booking identifier"
        string display_id "Human-readable ID"
        string status "confirmed/cancelled"
        int availability FK
        object contact "Contact details"
        array customers "Customer details"
        string voucher_number "Confirmation code"
        datetime created_at
        string dashboard_url "Link to dashboard"
        string customer_count "Total guests"
        string invoice_price "Total amount"
        string receipt_subtotal
        string receipt_taxes
        string receipt_total
    }

    CONTACT {
        string name "Full name"
        string email "Email address"
        string phone "Phone number"
        string normalized_phone "E.164 format"
        boolean is_subscribed_to_email_list
    }

    CUSTOMER {
        int customer_type_rate FK
        int checkin_status_id
        string checkin_url
    }

    CUSTOMER_TYPE_RATE {
        int pk PK
        int total "Number of this type"
        object customer_type "Type definition"
        object capacity "Min/Max"
        object customer_prototype "Template"
    }

    LODGING {
        int pk PK
        string name "Hotel/Lodge name"
        string address
        boolean is_self_lodging
        string phone
        string url
    }

    CANCELLATION_POLICY {
        string type "hours/days before"
        int cutoff_hours_before
    }
```

### Entity Details

#### 1. **Company**

Represents a tour operator or activity provider using FareHarbor.

**Key Fields:**
- `shortname` - URL-safe identifier (e.g., "acme-tours")
- `name` - Display name (e.g., "Acme Adventure Tours")
- `currency` - ISO 4217 currency code
- `booking_notes_required` - Whether customers must provide notes
- `about` - Company description/bio

**Example:**
```json
{
  "shortname": "acme-tours",
  "name": "Acme Adventure Tours",
  "currency": "usd",
  "about": "Hawaii's premier kayaking and snorkeling tour operator",
  "booking_notes_required": false,
  "booking_notes_safe_for_marketing": true
}
```

#### 2. **Item** (Activity/Tour)

Represents a bookable product/service offered by a company.

**Key Fields:**
- `pk` - Primary key (integer)
- `name` - Tour name (e.g., "Sunset Kayak Tour")
- `description` - Detailed description (HTML safe)
- `location` - Meeting point or pickup location
- `cancellation_policy` - Cancellation terms
- `image_cdn_urls` - Array of image URLs
- `is_pickup_ever_available` - Whether pickup service is offered

**Example:**
```json
{
  "pk": 12345,
  "name": "Sunset Kayak Tour",
  "headline": "Paddle into paradise",
  "description": "<p>Join us for a magical 2-hour sunset kayak experience...</p>",
  "location": "Waikiki Beach, Honolulu, HI",
  "cancellation_policy": "Cancel up to 24 hours in advance for a full refund",
  "is_pickup_ever_available": true,
  "image_cdn_urls": [
    "https://cdn.fareharbor.com/images/acme-tours/sunset-kayak-1.jpg",
    "https://cdn.fareharbor.com/images/acme-tours/sunset-kayak-2.jpg"
  ],
  "customer_prototype_id": 101
}
```

#### 3. **Availability**

Represents a specific time slot when an item can be booked.

**Key Fields:**
- `pk` - Primary key
- `start_at` / `end_at` - ISO 8601 timestamps
- `capacity` - Total available spots
- `customer_count` - Currently booked spots
- `online_booking_status` - "open" or "closed"
- `customer_type_rates` - Pricing for different customer types

**Example:**
```json
{
  "pk": 98765,
  "start_at": "2025-11-15T17:00:00-10:00",
  "end_at": "2025-11-15T19:00:00-10:00",
  "capacity": 20,
  "customer_count": 14,
  "online_booking_status": "open",
  "customer_type_rates": [
    {
      "pk": 201,
      "total": 6,
      "customer_type": {
        "pk": 1,
        "singular": "Adult",
        "plural": "Adults",
        "note": "Ages 13+"
      },
      "capacity": {
        "minimum": 1,
        "maximum": 15
      }
    },
    {
      "pk": 202,
      "total": 20,
      "customer_type": {
        "pk": 2,
        "singular": "Child",
        "plural": "Children",
        "note": "Ages 5-12"
      },
      "capacity": {
        "minimum": 0,
        "maximum": 10
      }
    }
  ]
}
```

#### 4. **Booking**

Represents a confirmed reservation.

**Key Fields:**
- `uuid` - Unique booking identifier
- `display_id` - Human-readable ID (e.g., "ABC123")
- `status` - "confirmed" or "cancelled"
- `contact` - Customer contact information
- `customers` - Array of customer details
- `voucher_number` - Confirmation code
- `invoice_price` - Total amount charged
- `dashboard_url` - Direct link to booking in FareHarbor dashboard

**Example:**
```json
{
  "uuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "display_id": "XYZ789",
  "status": "confirmed",
  "availability": {
    "pk": 98765,
    "start_at": "2025-11-15T17:00:00-10:00"
  },
  "contact": {
    "name": "Jane Smith",
    "email": "jane@example.com",
    "phone": "+1-808-555-1234",
    "normalized_phone": "+18085551234",
    "is_subscribed_to_email_list": true
  },
  "customers": [
    {
      "customer_type_rate": {
        "pk": 201,
        "customer_type": {
          "singular": "Adult",
          "plural": "Adults"
        }
      }
    },
    {
      "customer_type_rate": {
        "pk": 201,
        "customer_type": {
          "singular": "Adult",
          "plural": "Adults"
        }
      }
    },
    {
      "customer_type_rate": {
        "pk": 202,
        "customer_type": {
          "singular": "Child",
          "plural": "Children"
        }
      }
    }
  ],
  "voucher_number": "FH-2025-11-15-XYZ789",
  "invoice_price": "250.00 usd",
  "receipt_subtotal": "250.00 usd",
  "receipt_taxes": "22.50 usd",
  "receipt_total": "272.50 usd",
  "created_at": "2025-11-10T14:23:45-10:00",
  "dashboard_url": "https://fareharbor.com/acme-tours/dashboard/bookings/a1b2c3d4/"
}
```

#### 5. **Customer Type Rate**

Defines pricing tiers (Adult, Child, Senior, etc.) with min/max constraints.

**Example:**
```json
{
  "pk": 201,
  "total": 15,
  "customer_type": {
    "pk": 1,
    "singular": "Adult",
    "plural": "Adults",
    "note": "Ages 13 and up"
  },
  "capacity": {
    "minimum": 1,
    "maximum": 15
  },
  "customer_prototype": {
    "pk": 101,
    "display_name": "Adult",
    "total_including_tax": "125.00 usd",
    "total": "112.50 usd"
  }
}
```

#### 6. **Lodging**

Hotel or accommodation associated with bookings (for pickup services).

**Example:**
```json
{
  "pk": 501,
  "name": "Hilton Hawaiian Village",
  "address": "2005 Kalia Rd, Honolulu, HI 96815",
  "is_self_lodging": false,
  "phone": "+1-808-949-4321",
  "url": "https://www.hiltonhawaiianvillage.com"
}
```

---

## API Endpoints Reference

### Base URL Structure

```
https://fareharbor.com/api/external/v1/
```

All endpoints follow RESTful conventions:
- `GET` - Retrieve resources
- `POST` - Create resources
- `PUT` - Update resources (full replacement)
- `PATCH` - Partial update (not commonly used)
- `DELETE` - Remove resources

### Complete Endpoint Catalog

```
📂 API Root
├── 📁 companies/
│   ├── GET  /companies/                          # List all companies
│   ├── GET  /companies/{shortname}/              # Get company details
│   │
│   ├── 📁 items/
│   │   ├── GET  /companies/{shortname}/items/               # List all items
│   │   ├── GET  /companies/{shortname}/items/{item_pk}/     # Get item details
│   │   │
│   │   ├── 📁 availability/
│   │   │   ├── GET  /companies/{shortname}/items/{item_pk}/minimal/availabilities/date/{YYYY-MM-DD}/
│   │   │   ├── GET  /companies/{shortname}/items/{item_pk}/minimal/availabilities/date-range/{YYYY-MM-DD}/{YYYY-MM-DD}/
│   │   │   │
│   │   │   ├── 📁 bookings/
│   │   │   │   ├── POST /companies/{shortname}/availabilities/{availability_pk}/bookings/  # Create booking
│   │   │
│   ├── 📁 bookings/
│   │   ├── GET    /companies/{shortname}/bookings/{booking_uuid}/              # Get booking
│   │   ├── DELETE /companies/{shortname}/bookings/{booking_uuid}/              # Cancel booking
│   │   ├── POST   /companies/{shortname}/bookings/{booking_uuid}/rebook/       # Rebook (reschedule)
│   │
│   ├── 📁 lodgings/
│   │   ├── GET  /companies/{shortname}/lodgings/                   # List lodgings
│   │   ├── GET  /companies/{shortname}/lodgings/{lodging_pk}/      # Get lodging details
│   │
│   ├── 📁 customer-types/
│   │   ├── GET  /companies/{shortname}/customer-types/             # List customer types
│   │
│   ├── 📁 webhooks/ (Configuration via dashboard or support)
│       ├── Booking Created Event
│       ├── Booking Updated Event
│       ├── Booking Cancelled Event
```

### Detailed Endpoint Documentation

---

#### **1. List All Companies**

```http
GET /api/external/v1/companies/
```

**Description:** Retrieve all companies accessible with your API credentials.

**Authentication:** Bearer token required

**Query Parameters:** None

**Response:**
```json
{
  "companies": [
    {
      "shortname": "acme-tours",
      "name": "Acme Adventure Tours",
      "currency": "usd",
      "about": "Hawaii's premier tour operator",
      "booking_notes_required": false
    },
    {
      "shortname": "island-adventures",
      "name": "Island Adventures LLC",
      "currency": "usd",
      "about": "Explore the Hawaiian islands",
      "booking_notes_required": true
    }
  ]
}
```

**Use Case:** Dashboard showing all available tour operators in your marketplace.

---

#### **2. Get Company Details**

```http
GET /api/external/v1/companies/{shortname}/
```

**Path Parameters:**
- `shortname` - Company identifier (e.g., "acme-tours")

**Response:**
```json
{
  "shortname": "acme-tours",
  "name": "Acme Adventure Tours",
  "currency": "usd",
  "about": "<p>Welcome to Acme Adventure Tours...</p>",
  "about_safe_html": "<p>Welcome to Acme Adventure Tours...</p>",
  "booking_notes_required": false,
  "booking_notes_safe_for_marketing": true,
  "faq": "<h3>How do I prepare?</h3><p>Bring sunscreen...</p>",
  "intro": "Hawaii's #1 rated kayaking tour operator"
}
```

---

#### **3. List All Items (Tours/Activities)**

```http
GET /api/external/v1/companies/{shortname}/items/
```

**Query Parameters:**
- `include_description` (optional) - Include full description HTML
- `include_images` (optional) - Include image URLs

**Response:**
```json
{
  "items": [
    {
      "pk": 12345,
      "name": "Sunset Kayak Tour",
      "headline": "Paddle into paradise at golden hour",
      "description": "<p>Experience the magic...</p>",
      "location": "Waikiki Beach",
      "cancellation_policy": "Cancel up to 24 hours in advance",
      "cancellation_policy_safe_html": "<p>Cancel up to 24 hours...</p>",
      "customer_prototypes": [
        {
          "pk": 101,
          "display_name": "Adult",
          "total": "125.00 usd"
        },
        {
          "pk": 102,
          "display_name": "Child",
          "total": "75.00 usd"
        }
      ],
      "images": [
        {
          "pk": 1001,
          "gallery": "https://cdn.fareharbor.com/...",
          "image_cdn_url": "https://cdn.fareharbor.com/..."
        }
      ],
      "is_pickup_ever_available": true,
      "location_note": "Meet at the beach pavilion",
      "tax_percentage": 9.0
    }
  ]
}
```

**Use Case:** Display catalog of available tours on your website.

---

#### **4. Get Item Details**

```http
GET /api/external/v1/companies/{shortname}/items/{item_pk}/
```

**Path Parameters:**
- `shortname` - Company identifier
- `item_pk` - Item primary key (integer)

**Response:** Same structure as single item in list response, but with more detail.

---

#### **5. Get Availability for a Single Date**

```http
GET /api/external/v1/companies/{shortname}/items/{item_pk}/minimal/availabilities/date/{YYYY-MM-DD}/
```

**Path Parameters:**
- `shortname` - Company identifier
- `item_pk` - Item ID
- `YYYY-MM-DD` - Date (e.g., "2025-11-15")

**Query Parameters:**
- `quantity` (optional) - Filter by minimum available capacity

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
      "customer_type_rates": [
        {
          "pk": 201,
          "total": 15,
          "customer_type": {
            "pk": 1,
            "singular": "Adult",
            "plural": "Adults"
          },
          "capacity": {
            "minimum": 1,
            "maximum": 15
          }
        }
      ],
      "headline": "Morning Tour - 9:00 AM"
    },
    {
      "pk": 98766,
      "start_at": "2025-11-15T17:00:00-10:00",
      "end_at": "2025-11-15T19:00:00-10:00",
      "capacity": 20,
      "customer_count": 14,
      "online_booking_status": "open",
      "customer_type_rates": [...]
    }
  ]
}
```

**Use Case:** Show available time slots for a specific date on booking page.

---

#### **6. Get Availability for Date Range**

```http
GET /api/external/v1/companies/{shortname}/items/{item_pk}/minimal/availabilities/date-range/{start_date}/{end_date}/
```

**Path Parameters:**
- `start_date` / `end_date` - Date range (YYYY-MM-DD format)

**Response:** Array of availabilities across all dates in range.

**Use Case:** Calendar view showing availability for entire month.

---

#### **7. Create a Booking**

```http
POST /api/external/v1/companies/{shortname}/availabilities/{availability_pk}/bookings/
```

**Path Parameters:**
- `shortname` - Company identifier
- `availability_pk` - Availability slot ID

**Request Body:**
```json
{
  "contact": {
    "name": "Jane Smith",
    "phone": "+1-808-555-1234",
    "email": "jane@example.com",
    "is_subscribed_to_email_list": true
  },
  "customers": [
    {
      "customer_type_rate": 201
    },
    {
      "customer_type_rate": 201
    },
    {
      "customer_type_rate": 202
    }
  ],
  "note": "Celebrating our anniversary!",
  "voucher_number": "CUSTOM-VOUCHER-123",
  "external_id": "YOUR_INTERNAL_BOOKING_ID",
  "lodging": 501,
  "pickup": {
    "time": "08:30",
    "location": "Hotel lobby"
  }
}
```

**Request Headers:**
```http
Authorization: Bearer {access_token}
Content-Type: application/json
Idempotency-Key: unique-request-identifier-12345
```

**Response (201 Created):**
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
    "customer_count": "3",
    "pk": 123456789,
    "created_at": "2025-11-10T14:23:45-10:00",
    "availability": {
      "pk": 98765,
      "start_at": "2025-11-15T17:00:00-10:00"
    },
    "contact": {
      "name": "Jane Smith",
      "email": "jane@example.com",
      "phone": "+1-808-555-1234"
    },
    "customers": [...],
    "note": "Celebrating our anniversary!",
    "external_id": "YOUR_INTERNAL_BOOKING_ID"
  }
}
```

**Idempotency:**
- Include `Idempotency-Key` header to prevent duplicate bookings
- Same key + same payload = returns existing booking (no error)
- Recommended: Use UUID v4 for each booking attempt

**Use Case:** Complete the checkout flow and confirm reservation.

---

#### **8. Get Booking Details**

```http
GET /api/external/v1/companies/{shortname}/bookings/{booking_uuid}/
```

**Path Parameters:**
- `shortname` - Company identifier
- `booking_uuid` - Booking UUID

**Response:** Same structure as booking creation response.

**Use Case:** Display booking confirmation page or retrieve booking status.

---

#### **9. Cancel Booking**

```http
DELETE /api/external/v1/companies/{shortname}/bookings/{booking_uuid}/
```

**Path Parameters:**
- `shortname` - Company identifier
- `booking_uuid` - Booking UUID

**Response (204 No Content):** Empty body on success.

**Response (400 Bad Request):** If outside cancellation window.
```json
{
  "error": "cancellation_policy_violation",
  "message": "Cancellations must be made at least 24 hours in advance"
}
```

**Use Case:** Allow customers to cancel their reservations.

---

#### **10. Rebook (Reschedule) Booking**

```http
POST /api/external/v1/companies/{shortname}/bookings/{booking_uuid}/rebook/
```

**Request Body:**
```json
{
  "availability": 98770,
  "note": "Rescheduled due to weather concerns"
}
```

**Response (200 OK):**
```json
{
  "booking": {
    "uuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "availability": {
      "pk": 98770,
      "start_at": "2025-11-16T17:00:00-10:00"
    },
    "rebook_log": [
      {
        "timestamp": "2025-11-10T15:00:00-10:00",
        "from_availability": 98765,
        "to_availability": 98770,
        "note": "Rescheduled due to weather concerns"
      }
    ]
  }
}
```

**Use Case:** Change booking date/time without canceling and rebooking.

---

#### **11. List Lodgings**

```http
GET /api/external/v1/companies/{shortname}/lodgings/
```

**Response:**
```json
{
  "lodgings": [
    {
      "pk": 501,
      "name": "Hilton Hawaiian Village",
      "address": "2005 Kalia Rd, Honolulu, HI 96815",
      "is_self_lodging": false,
      "phone": "+1-808-949-4321",
      "url": "https://www.hiltonhawaiianvillage.com"
    },
    {
      "pk": 502,
      "name": "Other Lodging",
      "is_self_lodging": true
    }
  ]
}
```

**Use Case:** Dropdown menu for pickup location selection during booking.

---

#### **12. List Customer Types**

```http
GET /api/external/v1/companies/{shortname}/customer-types/
```

**Response:**
```json
{
  "customer_types": [
    {
      "pk": 1,
      "singular": "Adult",
      "plural": "Adults",
      "note": "Ages 13 and up"
    },
    {
      "pk": 2,
      "singular": "Child",
      "plural": "Children",
      "note": "Ages 5-12"
    },
    {
      "pk": 3,
      "singular": "Infant",
      "plural": "Infants",
      "note": "Ages 0-4"
    }
  ]
}
```

**Use Case:** Build booking form with correct customer type labels.

---

### Webhooks

FareHarbor can send real-time notifications to your server when bookings change.

**Configuration:** Contact FareHarbor support or configure in dashboard.

**Webhook Events:**

1. **booking.created** - New booking made
2. **booking.updated** - Booking details changed
3. **booking.cancelled** - Booking was cancelled
4. **booking.rebooked** - Booking rescheduled

**Webhook Payload Example:**

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
    "status": "confirmed",
    "external_id": "YOUR_INTERNAL_ID",
    "availability": {
      "pk": 98765,
      "start_at": "2025-11-15T17:00:00-10:00"
    }
  }
}
```

**Webhook Security:**
- Verify signature header: `X-FareHarbor-Signature`
- Use HMAC-SHA256 with shared secret
- Validate timestamp to prevent replay attacks

**Implementation Pattern:**
```elixir
defmodule FareharborWebhookHandler do
  def verify_signature(payload, signature, secret) do
    expected = :crypto.mac(:hmac, :sha256, secret, payload)
    |> Base.encode16(case: :lower)

    Plug.Crypto.secure_compare(signature, expected)
  end

  def handle_webhook(conn, _params) do
    payload = conn.assigns.raw_body
    signature = get_req_header(conn, "x-fareharbor-signature") |> List.first()

    if verify_signature(payload, signature, webhook_secret()) do
      process_webhook(Jason.decode!(payload))
      send_resp(conn, 200, "OK")
    else
      send_resp(conn, 401, "Invalid signature")
    end
  end
end
```

---

## Integration Workflows

### Workflow 1: Search and Book Flow

```mermaid
sequenceDiagram
    participant User
    participant YourApp
    participant FH as FareHarbor API

    Note over User,FH: Discovery Phase
    User->>YourApp: Browse activities
    YourApp->>FH: GET /companies/acme-tours/items/
    FH->>YourApp: List of items
    YourApp->>User: Display tour catalog

    Note over User,FH: Availability Check
    User->>YourApp: Select "Sunset Kayak Tour"<br/>for Nov 15, 2025
    YourApp->>FH: GET /items/12345/availabilities/date/2025-11-15/
    FH->>YourApp: Available time slots
    YourApp->>User: Show 9:00 AM, 5:00 PM slots

    Note over User,FH: Booking Phase
    User->>YourApp: Select 5:00 PM slot<br/>2 Adults, 1 Child
    YourApp->>User: Show booking form
    User->>YourApp: Submit contact info<br/>& payment

    YourApp->>FH: POST /availabilities/98765/bookings/<br/>{contact, customers}
    FH->>YourApp: Booking confirmation
    YourApp->>User: Show confirmation page<br/>with voucher number

    Note over User,FH: Post-Booking
    FH->>YourApp: Webhook: booking.created
    YourApp->>YourApp: Store booking in DB<br/>Send confirmation email
```

### Workflow 2: Calendar Integration

```mermaid
flowchart TD
    A[User Opens Calendar View] --> B[Load Date Range]
    B --> C[GET /date-range/2025-11-01/2025-11-30/]
    C --> D{Parse Availabilities}
    D --> E[Group by Date]
    E --> F[Calculate Aggregate Stats]
    F --> G[Display Calendar]

    G --> H{User Clicks Date}
    H --> I[Show Time Slots]
    I --> J{User Selects Time}
    J --> K[Load Booking Form]
    K --> L[Create Booking]

    style C fill:#e1f5ff
    style L fill:#d4edda
```

### Workflow 3: Multi-Company Marketplace

```mermaid
flowchart LR
    A[User Search:<br/>"kayaking in Hawaii"] --> B[Query Multiple Companies]

    B --> C1[GET /companies/acme-tours/items/]
    B --> C2[GET /companies/island-adventures/items/]
    B --> C3[GET /companies/pacific-tours/items/]

    C1 --> D[Aggregate Results]
    C2 --> D
    C3 --> D

    D --> E[Filter & Sort<br/>by relevance, price, rating]
    E --> F[Display Unified Results]

    F --> G{User Selects Item}
    G --> H[Check Availability<br/>for Selected Item]
    H --> I[Create Booking<br/>with Correct Company]

    style D fill:#fff3cd
    style I fill:#d4edda
```

### Workflow 4: Booking Management Dashboard

```mermaid
stateDiagram-v2
    [*] --> FetchBookings: Load Dashboard
    FetchBookings --> DisplayBookings: GET /bookings/ (if available)
    FetchBookings --> ListenWebhooks: Subscribe to events

    DisplayBookings --> BookingDetails: User clicks booking
    BookingDetails --> [*]: Close details

    BookingDetails --> CancelBooking: User cancels
    CancelBooking --> ConfirmCancel: DELETE /bookings/{uuid}
    ConfirmCancel --> RefreshList: Success

    BookingDetails --> RebookBooking: User reschedules
    RebookBooking --> SelectNewSlot: Show availability
    SelectNewSlot --> ConfirmRebook: POST /bookings/{uuid}/rebook
    ConfirmRebook --> RefreshList: Success

    ListenWebhooks --> WebhookReceived: booking.* event
    WebhookReceived --> RefreshList: Update UI

    RefreshList --> DisplayBookings
```

---

## Use Cases & Business Scenarios

### 1. **OTA/Marketplace Platform** (GetYourGuide, Viator)

**Requirements:**
- Multi-company aggregation
- Real-time availability
- Competitive pricing display
- Review/rating integration
- Commission tracking

**Implementation:**
```elixir
defmodule TourMarketplace do
  def search_activities(location, date, filters) do
    companies = get_companies_by_location(location)

    companies
    |> Task.async_stream(fn company ->
      fetch_items_with_availability(company, date, filters)
    end, max_concurrency: 10)
    |> Enum.to_list()
    |> aggregate_and_rank()
  end

  defp fetch_items_with_availability(company, date, filters) do
    items = FareharborClient.get("/companies/#{company.shortname}/items/")

    items
    |> filter_by_criteria(filters)
    |> Enum.map(fn item ->
      availability = FareharborClient.get(
        "/companies/#{company.shortname}/items/#{item.pk}/availabilities/date/#{date}/"
      )

      %{item: item, availability: availability, company: company}
    end)
  end
end
```

### 2. **Hotel Concierge System**

**Requirements:**
- Guest-specific recommendations
- Automatic pickup location (hotel address)
- Group booking handling
- Room charge integration

**Implementation Flow:**
1. Guest checks in → System loads local activities
2. Concierge recommends tours → Check availability in real-time
3. Guest books → Auto-populate hotel as pickup location
4. Booking confirmed → Charge to room, send voucher to guest

### 3. **Channel Manager** (Distribute FareHarbor inventory to multiple platforms)

**Requirements:**
- Bi-directional sync (availability, bookings)
- Inventory management
- Rate parity enforcement
- Webhook-driven updates

**Architecture:**
```
┌─────────────────────────────────────────────────┐
│          Your Channel Manager                    │
│  ┌───────────────────────────────────────────┐  │
│  │     Central Inventory Database            │  │
│  └───────────────────────────────────────────┘  │
│         ▲                           │            │
│         │                           │            │
│    Sync Availability            Push Updates    │
│         │                           │            │
│  ┌──────┴────────┐         ┌────────▼─────────┐ │
│  │   FareHarbor  │         │  External OTAs   │ │
│  │   API Client  │         │  (Expedia, etc)  │ │
│  └───────────────┘         └──────────────────┘ │
└─────────────────────────────────────────────────┘
```

### 4. **White-Label Booking Widget**

**Requirements:**
- Embeddable JavaScript widget
- Custom branding
- Simplified checkout flow
- Mobile-responsive

**Example Integration:**
```html
<!-- Embed on any website -->
<div id="fareharbor-widget"></div>
<script src="https://yourapp.com/widget.js"></script>
<script>
  FareharborWidget.init({
    container: '#fareharbor-widget',
    company: 'acme-tours',
    theme: {
      primaryColor: '#0066cc',
      fontFamily: 'Arial, sans-serif'
    },
    apiKey: 'YOUR_PUBLIC_KEY'
  });
</script>
```

### 5. **Itinerary Builder** (Multi-day trip planner)

**Requirements:**
- Calendar-based planning
- Conflict detection (overlapping bookings)
- Bundle pricing
- PDF itinerary generation

**User Flow:**
```
Day 1: Kayak Tour (9:00 AM - 11:00 AM)
       Lunch break
       Snorkeling (2:00 PM - 5:00 PM)

Day 2: Volcano Hike (7:00 AM - 3:00 PM)

Day 3: Sunset Dinner Cruise (6:00 PM - 9:00 PM)
```

---

## Architecture Patterns

### Pattern 1: Event-Driven Architecture with Webhooks

```mermaid
flowchart TB
    FH[FareHarbor] -->|Webhook| Q[Message Queue<br/>RabbitMQ/SQS]
    Q --> W1[Worker 1:<br/>Send Email]
    Q --> W2[Worker 2:<br/>Update Database]
    Q --> W3[Worker 3:<br/>Sync to CRM]
    Q --> W4[Worker 4:<br/>Generate Invoice]

    W1 --> Email[Email Service]
    W2 --> DB[(Database)]
    W3 --> CRM[Salesforce/HubSpot]
    W4 --> Accounting[QuickBooks]

    style FH fill:#e1f5ff
    style Q fill:#fff3cd
    style DB fill:#d4edda
```

**Benefits:**
- Decoupled architecture
- Resilient to failures
- Scalable processing
- Audit trail

### Pattern 2: Caching Layer for Performance

```mermaid
flowchart LR
    Client --> Cache{Cache Hit?}
    Cache -->|Yes| ReturnCached[Return Cached Data]
    Cache -->|No| API[FareHarbor API]
    API --> UpdateCache[Update Cache]
    UpdateCache --> ReturnFresh[Return Fresh Data]

    Webhook[Webhook Events] --> InvalidateCache[Invalidate Cache]
    InvalidateCache --> Cache

    style Cache fill:#fff3cd
    style API fill:#e1f5ff
```

**Cache Strategy:**
```elixir
defmodule FareharborCache do
  @ttl_items 3600        # 1 hour
  @ttl_availability 300  # 5 minutes
  @ttl_booking 60        # 1 minute

  def get_items(company_shortname) do
    cache_key = "items:#{company_shortname}"

    case Cachex.get(:fareharbor_cache, cache_key) do
      {:ok, nil} ->
        items = FareharborClient.get("/companies/#{company_shortname}/items/")
        Cachex.put(:fareharbor_cache, cache_key, items, ttl: @ttl_items)
        items

      {:ok, cached_items} ->
        cached_items
    end
  end

  def invalidate_on_webhook(%{"event" => "booking.created", "booking" => booking}) do
    availability_pk = booking["availability"]["pk"]
    Cachex.del(:fareharbor_cache, "availability:#{availability_pk}")
  end
end
```

### Pattern 3: Circuit Breaker for Reliability

```mermaid
stateDiagram-v2
    [*] --> Closed: Normal Operation
    Closed --> Open: Failure Threshold<br/>Exceeded
    Open --> HalfOpen: Timeout Elapsed
    HalfOpen --> Closed: Success
    HalfOpen --> Open: Failure

    note right of Closed
        Requests pass through
        Track failures
    end note

    note right of Open
        Fail fast
        Return cached data
        or fallback response
    end note

    note right of HalfOpen
        Allow limited requests
        Test if service recovered
    end note
```

**Implementation:**
```elixir
defmodule FareharborCircuitBreaker do
  use Fuse

  def call_api(request_fn) do
    case Fuse.call(:fareharbor_api, fn ->
      request_fn.()
    end) do
      {:ok, result} -> {:ok, result}
      {:error, :fuse_blown} ->
        Logger.warn("FareHarbor API circuit breaker opened")
        {:error, :service_unavailable}
    end
  end
end

# Usage
FareharborCircuitBreaker.call_api(fn ->
  FareharborClient.get("/companies/acme-tours/items/")
end)
```

### Pattern 4: Rate Limiting & Throttling

```elixir
defmodule FareharborRateLimiter do
  use GenServer

  # Allow 100 requests per minute
  @max_requests 100
  @window_ms 60_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def check_rate_limit() do
    GenServer.call(__MODULE__, :check_rate_limit)
  end

  def handle_call(:check_rate_limit, _from, state) do
    now = System.system_time(:millisecond)
    window_start = now - @window_ms

    # Remove old timestamps
    recent_requests = Enum.filter(state.requests || [], fn ts -> ts > window_start end)

    if length(recent_requests) < @max_requests do
      {:reply, :ok, %{requests: [now | recent_requests]}}
    else
      {:reply, {:error, :rate_limit_exceeded}, state}
    end
  end
end
```

### Pattern 5: Saga Pattern for Multi-Step Bookings

For complex bookings requiring multiple API calls (e.g., book activity + hotel + transportation):

```mermaid
sequenceDiagram
    participant Orchestrator
    participant FH_Kayak as FareHarbor<br/>Kayak Tour
    participant FH_Dinner as FareHarbor<br/>Dinner Cruise
    participant Payment
    participant DB

    Orchestrator->>FH_Kayak: Reserve kayak tour
    FH_Kayak-->>Orchestrator: Reserved (Step 1 ✓)

    Orchestrator->>FH_Dinner: Reserve dinner cruise
    FH_Dinner-->>Orchestrator: Reserved (Step 2 ✓)

    Orchestrator->>Payment: Charge customer
    Payment-->>Orchestrator: Payment failed ✗

    Note over Orchestrator: Compensating transactions
    Orchestrator->>FH_Kayak: Cancel kayak tour
    Orchestrator->>FH_Dinner: Cancel dinner cruise

    Orchestrator->>DB: Log failed booking
    Orchestrator-->>User: Booking failed, no charge
```

---

## Error Handling & Edge Cases

### HTTP Status Codes

| Status | Meaning | Action |
|--------|---------|--------|
| **200 OK** | Request succeeded | Process response |
| **201 Created** | Booking created | Store booking UUID |
| **204 No Content** | Deletion succeeded | Update UI |
| **400 Bad Request** | Invalid input | Show validation errors |
| **401 Unauthorized** | Token expired/invalid | Refresh token or re-auth |
| **403 Forbidden** | Insufficient permissions | Contact FareHarbor support |
| **404 Not Found** | Resource doesn't exist | Handle gracefully |
| **409 Conflict** | Booking conflict | Show alternative availability |
| **422 Unprocessable Entity** | Validation error | Show specific field errors |
| **429 Too Many Requests** | Rate limit exceeded | Implement exponential backoff |
| **500 Internal Server Error** | FareHarbor issue | Retry with backoff |
| **503 Service Unavailable** | Temporary outage | Use circuit breaker |

### Common Error Responses

#### Validation Error (422)
```json
{
  "error": "validation_error",
  "message": "Invalid customer count",
  "details": {
    "customers": ["At least 1 adult is required"]
  }
}
```

#### Availability Conflict (409)
```json
{
  "error": "availability_conflict",
  "message": "This time slot is no longer available",
  "availability": {
    "pk": 98765,
    "online_booking_status": "closed",
    "customer_count": 20,
    "capacity": 20
  },
  "alternatives": [
    {
      "pk": 98770,
      "start_at": "2025-11-15T19:00:00-10:00",
      "online_booking_status": "open"
    }
  ]
}
```

#### Rate Limit Error (429)
```json
{
  "error": "rate_limit_exceeded",
  "message": "Too many requests",
  "retry_after": 60
}
```

### Edge Cases to Handle

1. **Race Conditions**
   - Problem: Two users book the last spot simultaneously
   - Solution: Use optimistic locking, handle 409 conflicts gracefully

2. **Timezone Confusion**
   - Problem: User in EST books activity in HST timezone
   - Solution: Always display times in activity's local timezone, show UTC offset

3. **Partial Availability**
   - Problem: User wants 10 people, only 8 spots left
   - Solution: Show "Only 8 spots remaining" message, allow partial booking

4. **Payment Failures After Booking**
   - Problem: Booking created but payment fails
   - Solution: Implement compensating transaction (cancel booking)

5. **Webhook Delivery Failures**
   - Problem: Your server is down when webhook fires
   - Solution: FareHarbor retries with exponential backoff; implement idempotent handlers

6. **Cancellation Policy Edge Cases**
   - Problem: Booking made 23.5 hours before activity (24-hour policy)
   - Solution: Display exact cutoff time, block cancellation if past deadline

---

## Performance & Optimization

### Optimization Strategies

#### 1. **Batch Requests**

Instead of:
```elixir
# BAD: N+1 query problem
items = FareharborClient.get("/companies/acme-tours/items/")
availabilities = Enum.map(items, fn item ->
  FareharborClient.get("/items/#{item.pk}/availabilities/date/2025-11-15/")
end)
```

Do:
```elixir
# GOOD: Fetch all items, then batch availability checks
items = FareharborClient.get("/companies/acme-tours/items/")

availabilities = items
|> Enum.chunk_every(5)  # Process 5 at a time
|> Task.async_stream(fn chunk ->
  Enum.map(chunk, fn item ->
    FareharborClient.get("/items/#{item.pk}/availabilities/date/2025-11-15/")
  end)
end, max_concurrency: 3)
|> Enum.flat_map(fn {:ok, results} -> results end)
```

#### 2. **Prefetch Related Data**

```elixir
defmodule FareharborPrefetcher do
  def prefetch_booking_page_data(company_shortname, item_pk, date) do
    # Parallel requests
    tasks = [
      Task.async(fn -> FareharborClient.get("/companies/#{company_shortname}/") end),
      Task.async(fn -> FareharborClient.get("/companies/#{company_shortname}/items/#{item_pk}/") end),
      Task.async(fn -> FareharborClient.get("/companies/#{company_shortname}/lodgings/") end),
      Task.async(fn -> FareharborClient.get("/items/#{item_pk}/availabilities/date/#{date}/") end)
    ]

    [company, item, lodgings, availabilities] = Task.await_many(tasks, 10_000)

    %{
      company: company,
      item: item,
      lodgings: lodgings,
      availabilities: availabilities
    }
  end
end
```

#### 3. **Aggressive Caching with Smart Invalidation**

```elixir
defmodule FareharborSmartCache do
  # Cache keys hierarchy
  # companies:list -> 1 hour
  # companies:{shortname} -> 1 hour
  # items:{shortname}:list -> 30 minutes
  # items:{shortname}:{pk} -> 30 minutes
  # availability:{item_pk}:{date} -> 5 minutes
  # booking:{uuid} -> 1 minute

  def invalidate_cascade(event) do
    case event do
      %{"event" => "booking.created", "booking" => booking} ->
        availability_pk = booking["availability"]["pk"]
        item_pk = booking["item"]["pk"]

        # Invalidate availability cache
        Cachex.del(:fareharbor_cache, "availability:*:#{availability_pk}")

        # Invalidate item cache (capacity changed)
        Cachex.del(:fareharbor_cache, "items:*:#{item_pk}")

      %{"event" => "item.updated", "item" => item} ->
        # Invalidate all caches for this item
        Cachex.del(:fareharbor_cache, "items:*:#{item["pk"]}")
        Cachex.del(:fareharbor_cache, "availability:#{item["pk"]}:*")
    end
  end
end
```

#### 4. **Connection Pooling**

Configure `Req` with connection pool:

```elixir
config :fareharbor_client, :req_options,
  pool_timeout: 5_000,
  receive_timeout: 30_000,
  connect_options: [
    protocols: [:http1, :http2],
    transport_opts: [
      num_acceptors: 100
    ]
  ],
  pool: [
    size: 50,
    max_overflow: 100
  ]
```

### Performance Benchmarks (Typical)

| Operation | Latency (p50) | Latency (p99) |
|-----------|---------------|---------------|
| Get items list | 150ms | 500ms |
| Get availability (single date) | 200ms | 600ms |
| Create booking | 400ms | 1200ms |
| Cancel booking | 300ms | 800ms |
| Webhook delivery | < 2s | < 10s |

---

## Security Considerations

### 1. **Token Storage**

```elixir
# ❌ BAD: Storing in application config
config :my_app, fareharbor_token: "eyJ0eXAi..."

# ✅ GOOD: Environment variable
System.get_env("FAREHARBOR_ACCESS_TOKEN")

# ✅ BETTER: Encrypted database
defmodule TokenStore do
  def get_token(company_id) do
    encrypted_token = Repo.get_by(ApiToken, company_id: company_id)
    Cipher.decrypt(encrypted_token.value)
  end
end

# ✅ BEST: Secret manager (AWS Secrets Manager, HashiCorp Vault)
defmodule TokenStore do
  def get_token(company_id) do
    ExAws.SecretsManager.get_secret_value("fareharbor/#{company_id}/token")
  end
end
```

### 2. **Webhook Signature Verification**

```elixir
defmodule FareharborWebhookPlug do
  import Plug.Conn

  def verify_signature(conn, _opts) do
    payload = conn.assigns.raw_body
    signature = get_req_header(conn, "x-fareharbor-signature") |> List.first()
    secret = Application.get_env(:my_app, :webhook_secret)

    expected_signature =
      :crypto.mac(:hmac, :sha256, secret, payload)
      |> Base.encode16(case: :lower)

    if Plug.Crypto.secure_compare(signature, expected_signature) do
      conn
    else
      conn
      |> send_resp(401, "Invalid signature")
      |> halt()
    end
  end
end
```

### 3. **PII Handling**

```elixir
# Anonymize customer data in logs
defmodule SafeLogger do
  def log_booking(booking) do
    sanitized = %{
      booking
      | contact: %{
          name: redact_name(booking.contact.name),
          email: redact_email(booking.contact.email),
          phone: "***-***-" <> String.slice(booking.contact.phone, -4..-1)
        }
    }

    Logger.info("Booking created: #{inspect(sanitized)}")
  end

  defp redact_name(name) do
    [first | rest] = String.split(name, " ")
    first <> " " <> String.duplicate("*", String.length(Enum.join(rest, " ")))
  end

  defp redact_email(email) do
    [local, domain] = String.split(email, "@")
    String.slice(local, 0..1) <> "***@" <> domain
  end
end
```

### 4. **CSRF Protection for OAuth Flow**

```elixir
defmodule OAuthController do
  def authorize(conn, _params) do
    state = generate_csrf_token()

    # Store state in session
    conn = put_session(conn, :oauth_state, state)

    redirect_url =
      "https://fareharbor.com/oauth/authorize/?" <>
      URI.encode_query(%{
        client_id: client_id(),
        redirect_uri: redirect_uri(),
        response_type: "code",
        state: state
      })

    redirect(conn, external: redirect_url)
  end

  def callback(conn, %{"state" => state, "code" => code}) do
    session_state = get_session(conn, :oauth_state)

    if Plug.Crypto.secure_compare(state, session_state) do
      # Exchange code for token
      exchange_token(code)
    else
      send_resp(conn, 403, "CSRF token mismatch")
    end
  end
end
```

### 5. **Input Validation**

```elixir
defmodule BookingValidator do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :customer_count, :integer
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :email, :phone, :customer_count])
    |> validate_required([:name, :email, :customer_count])
    |> validate_format(:email, ~r/@/)
    |> validate_number(:customer_count, greater_than: 0, less_than: 100)
    |> validate_length(:name, min: 2, max: 100)
    |> sanitize_html()
  end

  defp sanitize_html(changeset) do
    update_change(changeset, :name, &HtmlSanitizeEx.strip_tags/1)
  end
end
```

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1-2)

```
✅ Set up OAuth 2.0 authentication
✅ Implement token storage and refresh logic
✅ Create basic API client with error handling
✅ Set up logging and monitoring
✅ Write unit tests for client
```

### Phase 2: Core Features (Week 3-4)

```
✅ Implement company and item browsing
✅ Build availability checking
✅ Create booking flow
✅ Add cancellation functionality
✅ Implement basic caching
```

### Phase 3: Advanced Features (Week 5-6)

```
✅ Set up webhook handling
✅ Implement rebook/reschedule
✅ Add lodging and pickup support
✅ Build rate limiting
✅ Implement circuit breaker
```

### Phase 4: Optimization (Week 7-8)

```
✅ Optimize caching strategy
✅ Add connection pooling
✅ Implement batch processing
✅ Set up performance monitoring
✅ Load testing and tuning
```

### Phase 5: Production Hardening (Week 9-10)

```
✅ Security audit
✅ Implement comprehensive error handling
✅ Add retry logic with exponential backoff
✅ Set up alerting and on-call procedures
✅ Document API integration patterns
```

---

## Conclusion

The FareHarbor External API v1 provides a **comprehensive, well-designed interface** for building tour and activity booking platforms. Key takeaways:

### Strengths
- ✅ RESTful design with predictable endpoints
- ✅ OAuth 2.0 for secure authentication
- ✅ Webhook support for real-time updates
- ✅ Rich data model covering all booking scenarios
- ✅ Good documentation and developer support

### Challenges
- ⚠️ Rate limiting requires careful planning
- ⚠️ Timezone handling needs attention
- ⚠️ Complex pricing models (customer types, taxes)
- ⚠️ Eventual consistency (webhooks may arrive out of order)

### Best Practices Summary

1. **Always use idempotency keys** for booking creation
2. **Implement caching** with webhook-based invalidation
3. **Handle rate limits** gracefully with exponential backoff
4. **Verify webhook signatures** to prevent spoofing
5. **Store tokens securely** (encrypted, secrets manager)
6. **Display times in local timezone** to avoid confusion
7. **Implement circuit breakers** for resilience
8. **Monitor API performance** and set up alerts
9. **Test cancellation policies** thoroughly
10. **Keep audit logs** of all bookings

### Next Steps

- Review the official FareHarbor API documentation
- Request API credentials from FareHarbor
- Set up a development environment
- Build a proof-of-concept integration
- Test thoroughly in sandbox/staging
- Launch with monitoring and alerting

---

**Questions or Need Help?**

- **Official Docs:** https://developer.fareharbor.com/
- **Support:** support@fareharbor.com
- **API Credentials:** Contact your FareHarbor account manager

---

*Document Version: 1.0 | Last Updated: 2025-11-12*
