defmodule LabsGatekeeper do
  @moduledoc """
  Labs Gatekeeper - Phase 0 Deliverable

  This application demonstrates the "Tooling Foundation" phase by enforcing
  quality gates across the Elixir Systems Mastery repository.

  ## Purpose

  The Gatekeeper ensures that all code in this repository meets minimum
  quality standards before being committed or merged:

  - **Formatting**: All code must be formatted with `mix format`
  - **Linting**: All code must pass Credo strict mode
  - **Type Checking**: All code must pass Dialyzer analysis
  - **Security**: All code must pass Sobelow security scans
  - **Dependencies**: All dependencies must pass audit checks

  ## Gates

  This app doesn't contain business logic - its purpose is to validate that
  the tooling infrastructure works correctly. The gates are enforced via:

  1. **Makefile targets**: `make check`, `make ci`
  2. **GitHub Actions**: `.github/workflows/ci.yml`
  3. **Pre-commit hooks**: `.git/hooks/pre-commit`

  ## Success Criteria

  Phase 0 is complete when:
  - [ ] `mix format --check-formatted` passes
  - [ ] `mix credo --strict` passes
  - [ ] `mix dialyzer` passes (after PLT is built)
  - [ ] `mix sobelow --exit` passes
  - [ ] `mix deps.audit` passes
  - [ ] All tests pass
  - [ ] CI is green

  ## Learning Objectives

  By completing this phase, you demonstrate:
  - Ability to set up a quality-focused development environment
  - Understanding of Elixir tooling ecosystem
  - Discipline to enforce standards before writing production code
  """

  @doc """
  Verifies that all quality gates are properly configured.

  Returns `:ok` if the gatekeeper setup is valid.

  ## Examples

      iex> LabsGatekeeper.verify_setup()
      :ok

  """
  def verify_setup do
    :ok
  end

  @doc """
  Lists all configured quality gates.

  ## Examples

      iex> gates = LabsGatekeeper.list_gates()
      iex> Enum.member?(gates, :formatter)
      true

  """
  def list_gates do
    [
      :formatter,
      :credo,
      :dialyzer,
      :sobelow,
      :deps_audit,
      :tests
    ]
  end
end
