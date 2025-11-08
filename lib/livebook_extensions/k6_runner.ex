defmodule LivebookExtensions.K6Runner do
  @moduledoc """
  A Livebook Smart Cell for running k6 load tests.

  This smart cell provides an interactive interface to:
  - Select which phase to test
  - Choose the test type (smoke, load, stress, etc.)
  - Run k6 tests and display results inline
  """

  use Kino.SmartCell, name: "k6 Load Test"

  @impl true
  def init(_attrs, ctx) do
    fields = %{
      phase: 1,
      test_type: "load"
    }

    {:ok, fields, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, ctx.assigns, ctx}
  end

  @impl true
  def handle_event("update_phase", %{"phase" => phase}, ctx) do
    phase_num = String.to_integer(phase)
    ctx = update(ctx, :phase, fn _ -> phase_num end)
    broadcast_update(ctx, ctx.assigns)
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_test_type", %{"test_type" => test_type}, ctx) do
    ctx = update(ctx, :test_type, fn _ -> test_type end)
    broadcast_update(ctx, ctx.assigns)
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    ctx.assigns
  end

  @impl true
  def to_source(attrs) do
    phase = attrs.phase || 1
    test_type = attrs.test_type || "load"

    phase_padded = String.pad_leading(to_string(phase), 2, "0")
    script_name = "phase-#{phase_padded}-gate.js"
    script_path = Path.join(["tools", "k6", script_name])

    """
    # Run k6 #{test_type} test for Phase #{phase}
    script_path = "#{script_path}"

    if File.exists?(script_path) do
      {output, exit_code} = System.cmd(
        "k6",
        ["run", script_path],
        stderr_to_stdout: true,
        env: [{"K6_TEST_TYPE", "#{test_type}"}]
      )

      case exit_code do
        0 ->
          Kino.Markdown.new(\"\"\"
          ## ✅ k6 Load Test Passed (Phase #{phase})

          ### Test Type: #{test_type}

          ```
          \#{output}
          ```
          \"\"\")

        _ ->
          Kino.Markdown.new(\"\"\"
          ## ⚠️ k6 Load Test Results (Phase #{phase})

          ### Test Type: #{test_type}

          ```
          \#{output}
          ```
          \"\"\")
      end
    else
      Kino.Markdown.new(\"\"\"
      ❌ **k6 script not found**

      Looking for: `\#{script_path}`

      Available k6 scripts:
      ```
      \#{case File.ls("tools/k6") do
        {:ok, files} -> Enum.join(files, "\\n")
        {:error, _} -> "tools/k6 directory not found"
      end}
      ```
      \"\"\")
    end
    """
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
