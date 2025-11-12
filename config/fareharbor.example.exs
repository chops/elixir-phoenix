import Config

# FareHarbor API Configuration Example
# Copy this to your config/config.exs or config/runtime.exs

# Option 1: Using environment variables (recommended for production)
config :elixir_systems_mastery, FareharborClient,
  client_id: System.get_env("FAREHARBOR_CLIENT_ID"),
  client_secret: System.get_env("FAREHARBOR_CLIENT_SECRET"),
  base_url: System.get_env("FAREHARBOR_BASE_URL", "https://fareharbor.com/api/external/v1")

# Option 2: Direct configuration (not recommended for production)
# config :elixir_systems_mastery, FareharborClient,
#   client_id: "your_client_id_here",
#   client_secret: "your_client_secret_here",
#   base_url: "https://fareharbor.com/api/external/v1"

# For development, you might want to add:
# config :elixir_systems_mastery, FareharborClient,
#   client_id: System.get_env("FAREHARBOR_CLIENT_ID"),
#   client_secret: System.get_env("FAREHARBOR_CLIENT_SECRET"),
#   base_url: "https://fareharbor.com/api/external/v1",
#   # Optional: Add timeout settings
#   timeout: 30_000,
#   # Optional: Add retry settings
#   retry: :transient,
#   max_retries: 3

# For production (in config/runtime.exs):
# import Config
#
# if config_env() == :prod do
#   config :elixir_systems_mastery, FareharborClient,
#     client_id: System.fetch_env!("FAREHARBOR_CLIENT_ID"),
#     client_secret: System.fetch_env!("FAREHARBOR_CLIENT_SECRET"),
#     base_url: System.get_env("FAREHARBOR_BASE_URL", "https://fareharbor.com/api/external/v1")
# end
