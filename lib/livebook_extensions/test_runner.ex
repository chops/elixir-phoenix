defmodule LivebookExtensions.TestRunner do
  @moduledoc """
  A Livebook Smart Cell for running tests in labs_* applications.

  This smart cell provides an interactive interface to:
  - Select which labs_* application to test
  - Choose whether to show coverage
  - Run tests and display results inline
  """

  use Kino.SmartCell, name: "Lab Test Runner"

  @impl true
  def init(_attrs, ctx) do
    # Scan apps/ directory for labs_* apps
    apps = scan_lab_apps()

    fields = %{
      apps: apps,
      selected_app: List.first(apps),
      show_coverage: true
    }

    {:ok, fields, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, ctx.assigns, ctx}
  end

  @impl true
  def handle_event("update_app", %{"app" => app}, ctx) do
    ctx = update(ctx, :selected_app, fn _ -> app end)
    broadcast_update(ctx, ctx.assigns)
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_coverage", %{"coverage" => coverage}, ctx) do
    show_coverage = coverage == "true"
    ctx = update(ctx, :show_coverage, fn _ -> show_coverage end)
    broadcast_update(ctx, ctx.assigns)
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    ctx.assigns
  end

  @impl true
  def to_source(attrs) do
    app = attrs.selected_app || "no_app_selected"
    coverage_flag = if attrs.show_coverage, do: "--cover", else: ""

    """
    # Run tests for #{app}
    app_path = Path.join("apps", "#{app}")

    if File.dir?(app_path) do
      {output, exit_code} = System.cmd(
        "mix",
        ["test", "#{coverage_flag}"],
        cd: app_path,
        stderr_to_stdout: true,
        env: [{"MIX_ENV", "test"}]
      )

      case exit_code do
        0 ->
          Kino.Markdown.new(\"\"\"
          ## ✅ Tests Passed for #{app}

          ```
          \#{output}
          ```
          \"\"\")

        _ ->
          Kino.Markdown.new(\"\"\"
          ## ❌ Tests Failed for #{app}

          ```
          \#{output}
          ```
          \"\"\")
      end
    else
      Kino.Markdown.new("❌ App directory not found: \#{app_path}")
    end
    """
  end

  defp scan_lab_apps do
    apps_path = "apps"

    if File.dir?(apps_path) do
      apps_path
      |> File.ls!()
      |> Enum.filter(&String.starts_with?(&1, "labs_"))
      |> Enum.sort()
    else
      []
    end
  end

  defp update(ctx, key, fun) do
    Map.update!(ctx, :assigns, fn assigns ->
      Map.update!(assigns, key, fun)
    end)
  end

  defp broadcast_update(ctx, assigns) do
    send(ctx.origin, {:broadcast_update, assigns})
  end
end
