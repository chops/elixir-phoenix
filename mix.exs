defmodule ElixirSystemsMastery.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: releases(),
      dialyzer: dialyzer(),
      test_coverage: [
        tool: ExCoveralls,
        export: "cov"
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  defp deps do
    [
      # Dev/test tools
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false, override: true},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.3", only: :dev},
      {:excoveralls, "~> 0.18", only: :test},
      {:stream_data, "~> 0.6", only: :test},
      {:mox, "~> 1.1", only: :test},
      {:opentelemetry, "~> 1.4"},
      {:opentelemetry_exporter, "~> 1.7"},
      # Livebook dependencies
      {:kino, "~> 0.12"},
      {:kino_vega_lite, "~> 0.1"},
      {:kino_db, "~> 0.2"},
      # Jido AI Agent Framework - using main branch for Dialyzer fixes
      {:jido, github: "agentjido/jido", branch: "main"},
      {:instructor, "~> 0.1.0"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      # Uncomment when Ecto is added in Phase 5:
      # "ecto.setup": ["ecto.create", "ecto.migrate", "run apps/pulse_data/priv/repo/seeds.exs"],
      # "ecto.reset": ["ecto.drop", "ecto.setup"],
      # test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      test: ["test"],
      fmt: ["format"]
    ]
  end

  defp releases do
    [
      elixir_systems_mastery: [
        include_executables_for: [:unix],
        applications: [
          runtime_tools: :permanent
        ]
      ]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:mix, :ex_unit],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end
end
