import Config

# Configure Mix tasks and generators
config :elixir_systems_mastery,
  generators: [timestamp_type: :utc_datetime]

# Import environment specific config
if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
