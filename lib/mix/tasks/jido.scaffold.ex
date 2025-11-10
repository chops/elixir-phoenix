defmodule Mix.Tasks.Jido.Scaffold do
  @moduledoc """
  Scaffolds a new lab project with best practices for learning.

  Generates project structure following Elixir Systems Mastery patterns,
  including proper supervision trees, test stubs, and documentation templates.

  ## Usage

      # Basic GenServer project
      mix jido.scaffold --type genserver --name UserCache --phase 3

      # With features
      mix jido.scaffold --type genserver --name SessionStore --phase 4 --features ttl,persistence

      # Process-based project
      mix jido.scaffold --type process --name Counter --phase 2

      # Supervised worker pool
      mix jido.scaffold --type worker_pool --name TaskRunner --phase 4

  ## Options

    * `--type` - Project type: genserver, process, worker_pool, phoenix_live, ecto_schema
    * `--name` - Module name (e.g., UserCache, SessionStore)
    * `--phase` - Learning phase (1-15)
    * `--features` - Comma-separated features (e.g., ttl,persistence,telemetry)

  ## Project Types

    * `genserver` - GenServer with supervision (Phase 3+)
    * `process` - Basic process with message passing (Phase 2+)
    * `worker_pool` - DynamicSupervisor worker pool (Phase 4+)
    * `phoenix_live` - LiveView component (Phase 6+)
    * `ecto_schema` - Ecto schema with changesets (Phase 5+)

  ## Features

    * `ttl` - Time-to-live expiration
    * `persistence` - Data persistence (ETS, file, or DB)
    * `telemetry` - OpenTelemetry instrumentation
    * `property_tests` - StreamData property tests
    * `benchmarks` - Benchee performance tests

  ## Examples

      # Simple GenServer for Phase 3
      mix jido.scaffold --type genserver --name Counter --phase 3

      # GenServer with TTL for Phase 3 labs
      mix jido.scaffold --type genserver --name CacheTTL --phase 3 --features ttl

      # Worker pool with telemetry for Phase 4
      mix jido.scaffold --type worker_pool --name JobRunner --phase 4 --features telemetry

      # Ecto schema with validations for Phase 5
      mix jido.scaffold --type ecto_schema --name User --phase 5 --features validations
  """

  use Mix.Task

  @shortdoc "Scaffolds a new lab project"

  @impl Mix.Task
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [
          type: :string,
          name: :string,
          phase: :integer,
          features: :string
        ],
        aliases: [
          t: :type,
          n: :name,
          p: :phase,
          f: :features
        ]
      )

    type = parse_type(Keyword.get(opts, :type))
    name = Keyword.get(opts, :name)
    phase = Keyword.get(opts, :phase, 1)
    features = parse_features(Keyword.get(opts, :features, ""))

    if !type || !name do
      show_usage()
      System.halt(1)
    end

    Mix.shell().info("")
    Mix.shell().info("🏗️  Jido Project Scaffolder")
    Mix.shell().info("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    Mix.shell().info("")
    Mix.shell().info("Type: #{type}")
    Mix.shell().info("Name: #{name}")
    Mix.shell().info("Phase: #{phase}")

    if features != [] do
      Mix.shell().info("Features: #{Enum.join(features, ", ")}")
    end

    Mix.shell().info("")

    # Generate project
    app_name = "labs_#{Macro.underscore(name)}"
    app_path = Path.join("apps", app_name)

    if File.dir?(app_path) do
      Mix.shell().error("App already exists: #{app_path}")
      System.halt(1)
    end

    Mix.shell().info("Creating app: #{app_name}")

    case scaffold_project(type, name, phase, features, app_path) do
      :ok ->
        Mix.shell().info("")
        Mix.shell().info("✅ Project scaffolded successfully!")
        Mix.shell().info("")
        Mix.shell().info("Next steps:")
        Mix.shell().info("  1. cd #{app_path}")
        Mix.shell().info("  2. Review generated code")
        Mix.shell().info("  3. Implement TODOs")
        Mix.shell().info("  4. Run tests: mix test")
        Mix.shell().info("  5. Run grader: mix jido.grade --app #{app_name}")
        Mix.shell().info("")

      {:error, reason} ->
        Mix.shell().error("Failed to scaffold project: #{reason}")
        System.halt(1)
    end
  end

  defp show_usage do
    Mix.shell().info("")
    Mix.shell().info("Usage: mix jido.scaffold --type TYPE --name NAME --phase PHASE")
    Mix.shell().info("")
    Mix.shell().info("Examples:")
    Mix.shell().info("  mix jido.scaffold --type genserver --name Counter --phase 3")
    Mix.shell().info("  mix jido.scaffold --type genserver --name Cache --phase 3 --features ttl")

    Mix.shell().info(
      "  mix jido.scaffold --type worker_pool --name TaskRunner --phase 4 --features telemetry"
    )

    Mix.shell().info("")
  end

  defp parse_type("genserver"), do: :genserver
  defp parse_type("process"), do: :process
  defp parse_type("worker_pool"), do: :worker_pool
  defp parse_type("phoenix_live"), do: :phoenix_live
  defp parse_type("ecto_schema"), do: :ecto_schema
  defp parse_type(_), do: nil

  defp parse_features(""), do: []

  defp parse_features(features) do
    features
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_atom/1)
  end

  defp scaffold_project(type, name, phase, features, app_path) do
    with :ok <- create_directory_structure(app_path),
         :ok <- generate_mix_exs(type, name, app_path),
         :ok <- generate_application(type, name, features, app_path),
         :ok <- generate_main_module(type, name, features, app_path),
         :ok <- generate_tests(type, name, features, app_path),
         :ok <- generate_readme(type, name, phase, features, app_path) do
      {:ok, app_path}
    end
  end

  defp create_directory_structure(app_path) do
    File.mkdir_p!(Path.join(app_path, "lib"))
    File.mkdir_p!(Path.join(app_path, "test"))
    :ok
  end

  defp generate_mix_exs(_type, name, app_path) do
    app_name = "labs_#{Macro.underscore(name)}"
    module_name = "Labs#{name}"

    content = """
    defmodule #{module_name}.MixProject do
      use Mix.Project

      def project do
        [
          app: :#{app_name},
          version: "0.1.0",
          build_path: "../../_build",
          config_path: "../../config/config.exs",
          deps_path: "../../deps",
          lockfile: "../../mix.lock",
          elixir: "~> 1.17",
          start_permanent: Mix.env() == :prod,
          deps: deps(),
          elixirc_paths: elixirc_paths(Mix.env())
        ]
      end

      def application do
        [
          extra_applications: [:logger],
          mod: {#{module_name}.Application, []}
        ]
      end

      defp elixirc_paths(:test), do: ["lib", "test/support"]
      defp elixirc_paths(_), do: ["lib"]

      defp deps do
        [
          {:stream_data, "~> 0.6", only: :test},
          {:benchee, "~> 1.3", only: :dev}
        ]
      end
    end
    """

    File.write!(Path.join(app_path, "mix.exs"), content)
    :ok
  end

  defp generate_application(:genserver, name, _features, app_path) do
    module_name = "Labs#{name}"

    content = """
    defmodule #{module_name}.Application do
      @moduledoc false

      use Application

      @impl true
      def start(_type, _args) do
        children = [
          # TODO: Add your GenServer here
          # {#{module_name}.Server, name: #{module_name}.Server}
        ]

        opts = [strategy: :one_for_one, name: #{module_name}.Supervisor]
        Supervisor.start_link(children, opts)
      end
    end
    """

    File.write!(Path.join([app_path, "lib", "#{Macro.underscore(name)}_application.ex"]), content)
    :ok
  end

  defp generate_application(_, name, _, app_path) do
    module_name = "Labs#{name}"

    content = """
    defmodule #{module_name}.Application do
      @moduledoc false

      use Application

      @impl true
      def start(_type, _args) do
        children = []

        opts = [strategy: :one_for_one, name: #{module_name}.Supervisor]
        Supervisor.start_link(children, opts)
      end
    end
    """

    File.write!(Path.join([app_path, "lib", "#{Macro.underscore(name)}_application.ex"]), content)
    :ok
  end

  defp generate_main_module(:genserver, name, features, app_path) do
    module_name = "Labs#{name}"
    has_ttl = :ttl in features

    content = """
    defmodule #{module_name}.Server do
      @moduledoc \"\"\"
      A GenServer implementing #{name} functionality.

      ## Features
      #{if has_ttl, do: "- TTL (Time-to-live) expiration", else: ""}

      ## Examples

          {:ok, pid} = #{module_name}.Server.start_link([])
          # TODO: Add usage examples
      \"\"\"

      use GenServer

      require Logger

      ## Client API

      @doc \"\"\"
      Starts the #{name} server.
      \"\"\"
      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
      end

      # TODO: Add your client API functions here
      # Example:
      # def get(key) do
      #   GenServer.call(__MODULE__, {:get, key})
      # end

      ## Server Callbacks

      @impl true
      def init(_opts) do
        state = %{
          # TODO: Define your initial state
        }

        {:ok, state}
      end

      @impl true
      def handle_call({:get, key}, _from, state) do
        # TODO: Implement get logic
        {:reply, {:error, :not_implemented}, state}
      end

      @impl true
      def handle_cast({:put, key, value}, state) do
        # TODO: Implement put logic
        {:noreply, state}
      end

      @impl true
      def handle_info(:cleanup, state) do
        # TODO: Implement cleanup logic (useful for TTL)
        {:noreply, state}
      end

      ## Private Functions

      # TODO: Add helper functions here
    end
    """

    File.write!(Path.join([app_path, "lib", "#{Macro.underscore(name)}_server.ex"]), content)
    :ok
  end

  defp generate_main_module(_, name, _, app_path) do
    module_name = "Labs#{name}"

    content = """
    defmodule #{module_name} do
      @moduledoc \"\"\"
      #{name} implementation.
      \"\"\"

      # TODO: Implement your module
    end
    """

    File.write!(Path.join([app_path, "lib", "#{Macro.underscore(name)}.ex"]), content)
    :ok
  end

  defp generate_tests(:genserver, name, features, app_path) do
    module_name = "Labs#{name}"
    has_property_tests = :property_tests in features

    content = """
    defmodule #{module_name}.ServerTest do
      use ExUnit.Case
      #{if has_property_tests, do: "use ExUnitProperties", else: ""}

      alias #{module_name}.Server

      setup do
        {:ok, pid} = Server.start_link([])
        %{server: pid}
      end

      test "server starts successfully", %{server: pid} do
        assert Process.alive?(pid)
      end

      # TODO: Add your tests here

      #{if has_property_tests do
      """
      property "property test example" do
        check all value <- integer() do
          # TODO: Implement property test
          assert true
        end
      end
      """
    else
      ""
    end}
    end
    """

    File.write!(
      Path.join([app_path, "test", "#{Macro.underscore(name)}_server_test.exs"]),
      content
    )

    # test_helper
    File.write!(Path.join([app_path, "test", "test_helper.exs"]), "ExUnit.start()\n")

    :ok
  end

  defp generate_tests(_, name, _, app_path) do
    module_name = "Labs#{name}"

    content = """
    defmodule #{module_name}Test do
      use ExUnit.Case

      # TODO: Add your tests here
    end
    """

    File.write!(Path.join([app_path, "test", "#{Macro.underscore(name)}_test.exs"]), content)
    File.write!(Path.join([app_path, "test", "test_helper.exs"]), "ExUnit.start()\n")

    :ok
  end

  defp generate_readme(type, name, phase, features, app_path) do
    app_name = "labs_#{Macro.underscore(name)}"

    content = """
    # Labs: #{name}

    **Phase #{phase}** - Generated by Jido Scaffolder

    ## Overview

    #{description_for_type(type)}

    ## Features

    #{if features == [], do: "- Basic implementation", else: Enum.map_join(features, "\n", fn f -> "- #{f}" end)}

    ## Implementation Tasks

    - [ ] Complete TODOs in lib/#{Macro.underscore(name)}.ex
    - [ ] Add tests in test/
    - [ ] Implement error handling
    - [ ] Add documentation
    - [ ] Achieve >90% test coverage
    - [ ] Pass dialyzer checks

    ## Running

    \`\`\`bash
    # Run tests
    mix test

    # Check coverage
    mix test --cover

    # Run in IEx
    iex -S mix

    # Grade your work
    cd ../.. && mix jido.grade --app #{app_name}
    \`\`\`

    ## Learning Objectives

    By completing this lab, you will:

    #{learning_objectives_for_type(type, phase)}

    ## Resources

    - Phase #{phase} Livebook
    - Phase #{phase} Study Guide
    - Official Elixir Documentation

    ## Next Steps

    1. Implement the core functionality
    2. Add comprehensive tests
    3. Document your code
    4. Run the grader
    5. Move to next checkpoint
    """

    File.write!(Path.join(app_path, "README.md"), content)
    :ok
  end

  defp description_for_type(:genserver) do
    "A GenServer-based application demonstrating stateful processes and supervision."
  end

  defp description_for_type(:process) do
    "A process-based application demonstrating message passing and concurrency."
  end

  defp description_for_type(:worker_pool) do
    "A worker pool using DynamicSupervisor for dynamic process management."
  end

  defp description_for_type(_), do: "An Elixir application for learning."

  defp learning_objectives_for_type(:genserver, _phase) do
    """
    - Understand GenServer callbacks (init, handle_call, handle_cast, handle_info)
    - Implement stateful processes
    - Handle synchronous and asynchronous messages
    - Integrate with supervision trees
    """
  end

  defp learning_objectives_for_type(:process, _phase) do
    """
    - Spawn and manage processes
    - Send and receive messages
    - Handle process crashes
    - Understand process isolation
    """
  end

  defp learning_objectives_for_type(_, _), do: "- Master the concepts for this phase"
end
