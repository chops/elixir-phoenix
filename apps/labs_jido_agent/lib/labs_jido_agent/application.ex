defmodule LabsJidoAgent.Application do
  @moduledoc """
  Application for Jido Agent labs demonstrating AI agent patterns in Elixir.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Agent registry for dynamic agent management
      {Registry, keys: :unique, name: LabsJidoAgent.Registry}
    ]

    opts = [strategy: :one_for_one, name: LabsJidoAgent.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
