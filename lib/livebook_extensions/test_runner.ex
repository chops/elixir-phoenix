defmodule LivebookExtensions.TestRunner do
  @moduledoc """
  Interactive test runner for labs_* applications using Kino.Control.form.

  This module provides a simple UI to:
  - Select which labs_* application to test
  - Choose whether to show coverage
  - Run tests and display results inline

  ## Usage

  In a Livebook cell:

      LivebookExtensions.TestRunner.render()
  """

  def render(opts \\ []) do
    apps = scan_lab_apps()
    default_app = opts[:app] || List.first(apps) || "no_apps_found"

    form =
      Kino.Control.form(
        [
          app: {:select, "Select lab app to test", apps |> Enum.map(&{&1, &1})},
          coverage: {:checkbox, "Show test coverage", default: true}
        ],
        submit: "Run Tests"
      )

    Kino.render(form)

    # Listen for form submission and run tests
    Kino.listen(form, fn %{data: data} ->
      run_tests(data.app, data.coverage)
    end)

    form
  end

  defp run_tests(app, show_coverage) do
    app_path = Path.join("apps", app)

    result =
      if File.dir?(app_path) do
        args = if show_coverage, do: ["test", "--cover"], else: ["test"]

        {output, exit_code} =
          System.cmd(
            "mix",
            args,
            cd: app_path,
            stderr_to_stdout: true,
            env: [{"MIX_ENV", "test"}]
          )

        case exit_code do
          0 ->
            """
            ## ✅ Tests Passed for #{app}

            ```
            #{output}
            ```
            """

          _ ->
            """
            ## ❌ Tests Failed for #{app}

            ```
            #{output}
            ```
            """
        end
      else
        "❌ App directory not found: #{app_path}"
      end

    Kino.Markdown.new(result) |> Kino.render()
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
end
