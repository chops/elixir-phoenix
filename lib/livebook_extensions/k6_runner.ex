defmodule LivebookExtensions.K6Runner do
  @moduledoc """
  Interactive k6 load test runner using Kino.Control.form.

  This module provides a simple UI to:
  - Select which phase to test
  - Choose test type (smoke, load, stress)
  - Configure virtual users and duration
  - Run k6 tests and display results inline

  ## Usage

  In a Livebook cell:

      LivebookExtensions.K6Runner.render()
  """

  def render(opts \\ []) do
    phases = Enum.map(1..15, &"Phase #{String.pad_leading(to_string(&1), 2, "0")}")
    default_phase = opts[:phase] || List.first(phases)

    form =
      Kino.Control.form(
        [
          phase: {:select, "Select phase to test", phases |> Enum.map(&{&1, &1})},
          test_type:
            {:select, "Test type",
             [
               {"Smoke test (quick validation)", "smoke"},
               {"Load test (sustained load)", "load"},
               {"Stress test (breaking point)", "stress"}
             ], default: "load"},
          vus: {:number, "Virtual users", default: 50},
          duration: {:text, "Duration (e.g., 30s, 1m)", default: "30s"}
        ],
        submit: "Run k6 Test"
      )

    Kino.render(form)

    # Listen for form submission and run k6
    Kino.listen(form, fn %{data: data} ->
      run_k6(data)
    end)

    form
  end

  defp run_k6(data) do
    # Extract phase number from "Phase 01" format
    phase_num = data.phase |> String.split() |> List.last()
    script_path = "tools/k6/phase-#{phase_num}-gate.js"

    result =
      if File.exists?(script_path) do
        {output, exit_code} =
          System.cmd(
            "k6",
            [
              "run",
              "--vus",
              to_string(data.vus),
              "--duration",
              data.duration,
              script_path
            ],
            stderr_to_stdout: true
          )

        metrics = parse_k6_output(output)

        """
        ## k6 Load Test Results: #{data.phase}

        **Configuration:**
        - Test type: #{data.test_type}
        - Virtual users: #{data.vus}
        - Duration: #{data.duration}

        **Metrics:**
        - Requests/sec: #{metrics.rps}
        - p95 Latency: #{metrics.p95}
        - Error Rate: #{metrics.error_rate}

        #{if metrics.error_rate_numeric > 1.0, do: "⚠️ **Error rate above 1%**", else: "✅ **All systems nominal**"}

        ### Full Output

        ```
        #{output}
        ```
        """
      else
        """
        ❌ **k6 script not found:** `#{script_path}`

        Make sure the k6 test scripts exist in `tools/k6/`.

        Available scripts:
        ```
        #{case File.ls("tools/k6") do
          {:ok, files} -> Enum.join(files, "\n")
          {:error, _} -> "tools/k6 directory not found"
        end}
        ```
        """
      end

    Kino.Markdown.new(result) |> Kino.render()
  end

  defp parse_k6_output(output) do
    %{
      rps: extract_metric(output, ~r/http_reqs.*?([\d.]+)\/s/, "N/A"),
      p95: extract_metric(output, ~r/http_req_duration.*?p\(95\)=([\d.]+)ms/, "N/A"),
      error_rate: extract_metric(output, ~r/http_req_failed.*?([\d.]+)%/, "0.0%"),
      error_rate_numeric: extract_numeric(output, ~r/http_req_failed.*?([\d.]+)%/, 0.0)
    }
  end

  defp extract_metric(output, regex, default) do
    case Regex.run(regex, output) do
      [_, value] -> value
      _ -> default
    end
  end

  defp extract_numeric(output, regex, default) do
    case Regex.run(regex, output) do
      [_, value] -> String.to_float(value)
      _ -> default
    end
  end
end
