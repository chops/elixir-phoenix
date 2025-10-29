defmodule LabsGatekeeperTest do
  use ExUnit.Case, async: true
  doctest LabsGatekeeper

  describe "verify_setup/0" do
    test "returns :ok when setup is valid" do
      assert LabsGatekeeper.verify_setup() == :ok
    end
  end

  describe "list_gates/0" do
    test "returns list of all configured gates" do
      gates = LabsGatekeeper.list_gates()

      assert is_list(gates)
      assert length(gates) == 6
    end

    test "includes all expected gates" do
      gates = LabsGatekeeper.list_gates()

      assert :formatter in gates
      assert :credo in gates
      assert :dialyzer in gates
      assert :sobelow in gates
      assert :deps_audit in gates
      assert :tests in gates
    end
  end
end
