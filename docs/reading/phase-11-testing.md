# Phase 11 — Testing Strategy (ExUnit, StreamData, Mox, SQL Sandbox)

Comprehensive testing with unit, integration, property-based, and mock testing.

## Books
- **Testing Elixir** (Andrea Leopardi, Jeffrey Matthias)

## Docs
- **ExUnit**
  https://hexdocs.pm/ex_unit/ExUnit.html

- **ExUnit.Case**
  https://hexdocs.pm/ex_unit/ExUnit.Case.html

- **StreamData / ExUnitProperties**
  https://hexdocs.pm/stream_data/StreamData.html and https://hexdocs.pm/stream_data/ExUnitProperties.html

- **Mox**
  https://hexdocs.pm/mox/readme.html

- **Ecto SQL Sandbox**
  https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.Sandbox.html

## Supplements
- **Property-based testing intro**
  https://dockyard.com/blog/2017/11/03/property-based-testing-with-streamdata

- **Mocks and explicit contracts**
  https://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/---

================================================================================

I can’t open your transcript file due to a tool error. Proceeding with Phase 11 using a complete, ready-to-paste summary synthesized from Testing Elixir and standard Elixir practices. If you need a strict extraction from your notes, say so and I’ll retry with the file tool.

Testing Elixir (Andrea Leopardi, Jeffrey Matthias) Summary

Outline
	•	ExUnit foundations and unit testing
	•	Integration and end-to-end testing
	•	Testing OTP processes and supervision
	•	Testing Ecto schemas and changesets
	•	Testing Ecto queries and contexts
	•	Testing Phoenix with ConnCase and ChannelCase
	•	Property-based testing with StreamData
	•	Cross-chapter testing pyramid and patterns

Chapter/Section Summaries

1) Unit Tests

Key Concepts
	•	ExUnit structure: test/test_helper.exs, *_test.exs
	•	describe/2, setup/1, tags (@tag, @moduletag)
	•	Doctests (doctest Mod) for API examples as tests
	•	Deterministic tests: control time, randomness, external I/O
	•	Pure core + thin shell: test pure functions directly

Essential Code Snippets

# mix.exs (use doctests, async by default)
def project do
  [
    test_coverage: [tool: ExCoveralls],
    preferred_cli_env: ["coveralls.html": :test]
  ]
end

# test/test_helper.exs
ExUnit.start(formatters: [ExUnit.CLIFormatter])

# test/my_app/math_test.exs
defmodule MyApp.MathTest do
  use ExUnit.Case, async: true
  doctest MyApp.Math

  describe "sum/1" do
    test "sums integers" do
      assert MyApp.Math.sum([1,2,3]) == 6
    end

    @tag :slow
    test "handles big lists" do
      assert MyApp.Math.sum(Enum.to_list(1..100_000)) == 5_000_050_000
    end
  end
end

# lib/my_app/math.ex
defmodule MyApp.Math do
  @doc """
  Returns the sum of a list.

      iex> MyApp.Math.sum([1,2,3])
      6
  """
  def sum(list), do: Enum.reduce(list, 0, &+/2)
end

Tips & Pitfalls
	•	Avoid testing private functions; test via public API.
	•	Use async: true only for tests without shared resources.
	•	Replace global state and time with injectable modules.

Exercises Application
	•	Convert utility examples to doctests and unit tests with describe.
	•	Tag slow cases and create an :unit alias in your test task.

Diagrams

Unit tests ──> pure functions and module APIs


⸻

2) Integration and E2E Tests

Key Concepts
	•	Integration tests stitch multiple components with realistic boundaries.
	•	End-to-end tests drive the system at its external interfaces.
	•	Use HTTP stubs for outbound calls, not live internet.
	•	Keep E2E small and critical; prefer traceable, stable selectors.

Essential Code Snippets

# test/support/http_case.ex
defmodule MyApp.HttpCase do
  use ExUnit.CaseTemplate
  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      @endpoint MyAppWeb.Endpoint
    end
  end
end

# Bypass for external HTTP
test "calls upstream API" do
  bypass = Bypass.open()

  Bypass.expect(bypass, "GET", "/v1/items", fn conn ->
    Plug.Conn.resp(conn, 200, ~s|{"items":[1,2,3]}|)
  end)

  url = "http://localhost:#{bypass.port}/v1/items"
  assert {:ok, [1,2,3]} = MyApp.Upstream.fetch_items(url)
end

Tips & Pitfalls
	•	Don’t over-index on E2E; they are slow and flaky.
	•	Assert on behavior and contract, not HTML microstructure.

Exercises Application
	•	Add a smoke E2E that exercises login → create → read flow.

Diagrams

Browser/HTTP → Phoenix → Contexts → Repo → DB
                 ↑ stubs/fakes for outbound deps


⸻

3) Testing OTP Processes

Key Concepts
	•	Test the public API of GenServer, not its internal state.
	•	Use start_supervised!/1 and @moduletag :capture_log.
	•	Assert on mailbox behavior with assert_receive/2, refute_receive/2.
	•	Kill and restart under supervisor to prove recovery.

Essential Code Snippets

# test/support/otp_case.ex
defmodule MyApp.OTPCase do
  use ExUnit.CaseTemplate
  using do
    quote do
      import ExUnit.CaptureLog
      import ExUnit.Assertions
      import Process, only: [monitor: 1, exit: 2]
    end
  end
end

# test/my_app/counter_server_test.exs
defmodule MyApp.CounterServerTest do
  use ExUnit.Case, async: true

  test "increments and reads" do
    pid = start_supervised!({MyApp.CounterServer, []})
    assert MyApp.CounterServer.get(pid) == 0
    :ok = MyApp.CounterServer.inc(pid)
    assert MyApp.CounterServer.get(pid) == 1
  end

  test "recovers under supervisor" do
    pid = start_supervised!({MyApp.CounterServer, []})
    ref = Process.monitor(pid)
    Process.exit(pid, :kill)
    assert_receive {:DOWN, ^ref, :process, ^pid, :killed}
    # new process started by supervisor
    assert MyApp.CounterServer.get(Process.whereis(MyApp.CounterServer)) == 0
  end
end

Tips & Pitfalls
	•	Avoid :sys.get_state/1 checks; prefer visible effects.
	•	Use handle_continue/2 for risky init work, then test it.

Exercises Application
	•	Write a kill-and-recover test for each supervised server.

Diagrams

Caller → GenServer(API) → Core Logic
          ^ under Supervisor; crash → restart


⸻

4) Testing Ecto Schemas (Changesets)

Key Concepts
	•	Validate with changesets; assert errors via traverse_errors/2.
	•	Prefer DB constraints for uniqueness and FK validity; assert {:error, cs}.
	•	Separate validations (app logic) from constraints (DB truth).

Essential Code Snippets

# test/support/data_case.ex
defmodule MyApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      alias MyApp.Repo

      def errors_on(changeset) do
        Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)
    unless tags[:async], do: Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, {:shared, self()})
    :ok
  end
end

# test/my_app/accounts/user_changeset_test.exs
defmodule MyApp.Accounts.UserChangesetTest do
  use MyApp.DataCase, async: true
  alias MyApp.Accounts.User

  test "email required and valid" do
    cs = User.changeset(%User{}, %{email: ""})
    assert "can't be blank" in errors_on(cs).email
  end

  test "unique email enforced at DB" do
    {:ok, _} = Repo.insert(User.changeset(%User{}, %{email: "a@b.com"}))
    {:error, cs} = Repo.insert(User.changeset(%User{}, %{email: "a@b.com"}))
    assert "has already been taken" in errors_on(cs).email
  end
end

Tips & Pitfalls
	•	Don’t duplicate DB constraints in app logic; use unique_constraint/3.
	•	Use factories sparingly; prefer explicit fixtures.

Exercises Application
	•	Add constraint tests for each unique index and FK.

Diagrams

Changeset(validations) → Repo.insert → DB(constraints)


⸻

5) Testing Ecto Queries and Contexts

Key Concepts
	•	Keep query logic in contexts and test shape and semantics.
	•	Use SQL Sandbox; keep tests async: false only if sharing a connection.
	•	Test read queries with fixtures; test write flows with transactions.

Essential Code Snippets

# test/my_app/orders/query_test.exs
defmodule MyApp.Orders.QueryTest do
  use MyApp.DataCase

  alias MyApp.Orders

  test "recent_orders/1 returns most recent first" do
    insert!(:order, inserted_at: ~N[2025-01-01 00:00:00])
    insert!(:order, inserted_at: ~N[2025-01-02 00:00:00])

    orders = Orders.recent_orders(limit: 1)
    assert length(orders) == 1
    assert hd(orders).inserted_at == ~N[2025-01-02 00:00:00]
  end
end

# lib/my_app/orders.ex
def recent_orders(opts \\ []) do
  limit = Keyword.get(opts, :limit, 10)
  from(o in Order, order_by: [desc: o.inserted_at], limit: ^limit)
  |> Repo.all()
end

Tips & Pitfalls
	•	Use Repo.aggregate/3 for counts in assertions, not length/1 on big sets.
	•	Keep context APIs narrow and business-named.

Exercises Application
	•	Write a query test per public context function.

Diagrams

Context API → Ecto.Query → Repo → DB


⸻

6) Testing Phoenix (ConnCase, ChannelCase)

Key Concepts
	•	ConnCase: request/response testing with Phoenix.ConnTest.
	•	ChannelCase: socket channels with Phoenix.ChannelTest.
	•	LiveViewTest for LiveView flows when applicable.
	•	Session, CSRF, JSON helpers.

Essential Code Snippets

# test/support/conn_case.ex
defmodule MyAppWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      import Plug.Conn
      alias MyAppWeb.Router.Helpers, as: Routes
      @endpoint MyAppWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end

# test/my_app_web/controllers/item_controller_test.exs
defmodule MyAppWeb.ItemControllerTest do
  use MyAppWeb.ConnCase, async: true

  test "GET /items renders list", %{conn: conn} do
    conn = get(conn, Routes.item_path(conn, :index))
    assert html_response(conn, 200) =~ "Items"
  end
end

# test/support/channel_case.ex
defmodule MyAppWeb.ChannelCase do
  use ExUnit.CaseTemplate
  using do
    quote do
      use Phoenix.ChannelTest
      @endpoint MyAppWeb.Endpoint
    end
  end
end

# test/my_app_web/channels/room_channel_test.exs
defmodule MyAppWeb.RoomChannelTest do
  use MyAppWeb.ChannelCase, async: true

  test "broadcast and receive" do
    {:ok, _, socket} = connect(UserSocket, %{})
    {:ok, _, socket} = subscribe_and_join(socket, "room:lobby", %{})
    push(socket, "ping", %{"msg" => "hi"})
    assert_broadcast "pong", %{"msg" => "hi"}
  end
end

Tips & Pitfalls
	•	Keep controllers thin; assert on rendered body or JSON contract.
	•	Use @endpoint for helpers; avoid hardcoding URLs.

Exercises Application
	•	Add ConnCase tests for auth and audit endpoints.

Diagrams

ConnCase: build_conn → route → controller → view
ChannelCase: connect → subscribe_and_join → push/broadcast


⸻

7) Property-Based Testing with StreamData

Key Concepts
	•	Generators (integer(), string(:printable), list_of/1, map_of/2)
	•	check all macro, shrinking on failure
	•	Invariants and round-trip properties
	•	Composing generators with bind/2, map/2, filter/2

Essential Code Snippets

# mix.exs
defp deps do
  [
    {:stream_data, "~> 0.6", only: :test}
  ]
end

# test/my_app/properties/string_props_test.exs
defmodule MyApp.Properties.StringPropsTest do
  use ExUnit.Case
  use ExUnitProperties

  property "String.upcase/1 is idempotent" do
    check all s <- string(:printable) do
      assert String.upcase(String.upcase(s)) == String.upcase(s)
    end
  end

  property "encode/decode round trip" do
    check all m <- map_of(string(:alphanumeric), integer()) do
      assert m |> MyApp.Codec.encode() |> MyApp.Codec.decode() == {:ok, m}
    end
  end
end

# Custom generator for emails
defmodule MyApp.Generators do
  import StreamData

  def email do
    bind({string(:alphanumeric, min_length: 1), string(:alphanumeric, min_length: 2)}, fn {user, domain} ->
      constant("#{user}@#{domain}.com")
    end)
  end
end

Tips & Pitfalls
	•	Start with simple invariants; let shrinking find edge cases.
	•	Keep properties fast; avoid DB and network in properties.

Exercises Application
	•	Add property tests for parser/codec modules and idempotent ops.

Diagrams

Generators → Properties → Shrinkers → Minimal failing example


⸻

Cross-Chapter Checklist
	•	Use start_supervised!/1 for process tests; prove restart.
	•	Prefer DB constraints; assert changeset errors, not manual uniqueness checks.
	•	Keep HTTP external calls behind behaviors; test with Mox fakes.
	•	Use SQL Sandbox in DataCase; async where possible.
	•	Keep E2E minimal; rely on unit + integration fast tests for most coverage.
	•	Add @tag :integration and run in CI nightly; keep unit tests in PR gate.
	•	Control time and randomness via injectable modules.
	•	Property tests for invariants and codecs; unit tests for examples; integration for seams.

Quick Reference Crib

# ExUnit
ExUnit.start()
use ExUnit.Case, async: true
describe "feature" do ... end
setup do {:ok, foo: 1} end
@tag :integration

# DataCase
Ecto.Adapters.SQL.Sandbox.checkout(Repo)
Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
traverse_errors(cs, fun)

# ConnCase
use Phoenix.ConnTest
conn = build_conn() |> get(Routes.page_path(conn, :index))
html_response(conn, 200)

# ChannelCase
use Phoenix.ChannelTest
{:ok, _, socket} = subscribe_and_join(socket, "topic", %{})
push(socket, "event", %{}); assert_broadcast "event", _

# OTP testing
pid = start_supervised!({Mod, args})
assert_receive {:event, _}, 50
Process.exit(pid, :kill)

# Mox
Mox.defmock(MyApp.HTTPMock, for: MyApp.HTTP)
setup :verify_on_exit!
expect(MyApp.HTTPMock, :get, fn _url -> {:ok, %{status: 200}} end)

# StreamData
use ExUnitProperties
check all x <- list_of(integer()) do
  assert Enum.reverse(Enum.reverse(x)) == x
end

Testing Pyramid

        [ E2E / System ]
        few, critical, slow
      ----------------------
      [  Integration  ]
      medium, stable seams
    --------------------------
    [       Unit       ]
    many, fast, pure cores

Test Case Templates (drop into test/support)

# test/support/data_case.ex  (SQL Sandbox + helpers)  ← see snippet above
# test/support/conn_case.ex  (Phoenix.ConnTest)       ← see snippet above
# test/support/channel_case.ex (Phoenix.ChannelTest)  ← see snippet above

# test/support/mox_case.ex
defmodule MyApp.MoxCase do
  use ExUnit.CaseTemplate
  using do
    quote do
      import Mox
      setup :verify_on_exit!
    end
  end
end

# test/support/stream_data_case.ex
defmodule MyApp.StreamDataCase do
  use ExUnit.CaseTemplate
  using do
    quote do
      use ExUnitProperties
      import StreamData
    end
  end
end

Notes
	•	Run unit and property tests in PR. Gate on coverage and speed. Run integration and E2E in CI scheduled jobs.
	•	Map this to your repo’s Phase 11 labs: labs_authz_audit and affected pulse_* contexts.


---

## Drills


Phase 11 Drills

Core Skills to Practice
	•	Prove GenServer invariants with stateful properties using StreamData.    
	•	Test DB constraints against a real Postgres using SQL Sandbox and DataCase.    
	•	Replace HTTP calls with a behaviour and a test fake.    
	•	Use Mox to enforce explicit contracts and expectations.  

Exercises
	1.	GenServer invariants via properties
	•	Build a Counter or Bank GenServer. Start it with start_supervised/1. Drive API via messages.    
	•	Write a stateful property: generate operation sequences, model expected state, assert postconditions hold at each step. Invariants: nonnegative balance, idempotent reads, monotonic version.  
	•	Kill the process and assert supervisor restart restores semantics.  
	•	Expected: Properties pass across 1k sequences; restart test green.
	2.	Constraints with real DB
	•	Add unique_constraint/3 and FK constraints to a schema. Test constraint errors and happy paths using DataCase with SQL Sandbox.      
	•	Keep validation-only tests DB-free; use factories for query tests.    
	•	Expected: All constraint tests pass; scope tests assert exact result sets.  
	3.	Replace HTTP with behaviour and fake
	•	Define @behaviour MyApp.HTTPClient. Provide ProdHTTP and TestHTTP implementations. Wire through dependency injection. Diagram: Your code -> Behaviour -> [Fake in test | Real in prod].  
	•	Write request tests at resource edges; avoid real external calls.  
	•	Expected: Tests run offline; behaviour boundary isolated.
	4.	Mox contracts
	•	Create a Mox mock for the HTTP behaviour. Set expectations per test. Verify on exit. Keep mocks local to the example.  
	•	Assert exact call count, args, and return handling in your code path. Use the fake for broad happy-path tests and Mox for strict contract tests.  
	•	Expected: All expectations verified; failures pinpoint interface drift.

Common Pitfalls
	•	Peeking into private GenServer state. Test via public API and messages.  
	•	Using :timer.sleep/… in tests. Drive messages and time explicitly.  
	•	Mixing DB in changeset unit tests without a constraint to assert.  
	•	Skipping the behaviour boundary and mocking HTTP clients directly. Prefer behaviours and injected doubles.  
	•	Not isolating DB with SQL Sandbox or misusing async: true.  

Success Criteria
	•	One stateful StreamData property proves a GenServer invariant and survives restarts.    
	•	Constraint tests hit a real DB using DataCase and Sandbox.    
	•	All external HTTP calls flow through a behaviour with a test fake.  
	•	Mox enforces explicit call contracts and verifies expectations.  
	•	No sleeps in tests; messages and time are driven deterministically.  

