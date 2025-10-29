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

  describe "CI validation" do
    @tag :tmp_failing_test
    @tag :skip
    test "TEMPORARY: This test intentionally fails to prove CI catches failures" do
      # This test is designed to fail when unskipped.
      # To prove CI works:
      # 1. Remove @tag :skip from this test
      # 2. Commit and push
      # 3. Watch CI fail (as expected)
      # 4. Re-add @tag :skip
      # 5. Commit and push again
      # 6. Watch CI pass
      #
      # This proves the CI pipeline correctly identifies and reports test failures.
      assert 1 + 1 == 3, "This assertion is intentionally false to validate CI"
    end
  end
end
