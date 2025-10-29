# Phase 5 — Data & Ecto

Persistent data with schemas, changesets, transactions, and constraints.

## Books
- **Programming Ecto** (Darin Wilson, Eric Meadows-Jönsson)

## Docs
- **Ecto Getting Started**
  https://hexdocs.pm/ecto/getting-started.html

- **Ecto API index**
  https://hexdocs.pm/ecto/Ecto.html

- **Elixir School Ecto basics**
  https://elixirschool.com/en/lessons/ecto/basics

## Supplements
- **Ecto for Beginners**
  https://fly.io/phoenix-files/ecto-for-beginners/---

================================================================================

Programming Ecto Summary

Outline
	•	Part I: Fundamentals — 1) Repo 2) Querying 3) Schemas 4) Changesets 5) Transactions & Ecto.Multi 6) Migrations.  
	•	Part II: Applied — non-Phoenix apps, Phoenix forms + changesets, SQL sandboxes, custom types, upserts, design patterns.  

Chapter/Section Summaries

1) Repo (your DB gateway)

Key Concepts
	•	Repository pattern. Single module mediates DB ops. Configure app env, pool, URL. Put Repo under supervision. Tune pool per env.    

Essential Code Snippets

# config/config.exs
config :my_app, MyApp.Repo, url: System.fetch_env!("DATABASE_URL"), pool_size: 10

# lib/my_app/repo.ex
defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :my_app, adapter: Ecto.Adapters.Postgres
end



Tips & Pitfalls
	•	Supervise Repo; size pool correctly.  

Exercises Application
	•	Stand up a repo, run inserts/queries, customize config.  

Diagrams

Your code → Repo → (Adapter) → DB



⸻

2) Querying (composable DB reads)

Key Concepts
	•	Build queries with Ecto.Query macros. Compose where/join/select. Lazy until Repo.*.  

Essential Code Snippets

import Ecto.Query

base = from u in User, where: u.active == true
q = from u in base,
  join: p in assoc(u, :posts),
  where: p.published == true,
  select: {u.id, count(p.id)}
Repo.all(q)



Tips & Pitfalls
	•	Keep filters composable. Preload or join to avoid N+1.  

Exercises Application
	•	Build queries with multiple wheres/joins and composition.  

Diagrams

Base query + filters + joins ⇒ Repo.all/one/stream



⸻

3) Schemas (map tables ↔ structs)

Key Concepts
	•	schema/2 fields and types. Associations. Embeds for JSON. Use schemas in queries/inserts/deletes/seed. Align Ecto types to DB. Index FKs and query keys. Prefer embedded_schema for JSON.    

Essential Code Snippets

defmodule MyApp.Blog.Post do
  use Ecto.Schema
  schema "posts" do
    field :title, :string
    field :published_at, :utc_datetime
    belongs_to :user, MyApp.Accounts.User
    has_many :comments, MyApp.Blog.Comment
    timestamps()
  end
end



Tips & Pitfalls
	•	Match types. Add FKs and indexes in migrations. Use embeds for JSON.  

Exercises Application
	•	Define schemas and associations; query via schemas; seed data.  

Diagrams

Table ↔ Schema struct with arrows for associations.



⸻

4) Changesets (validate and cast writes)

Key Concepts
	•	Changeset pipelines: cast → validate → constrain → insert/update. Works with or without schemas. Surfaces errors. Use constraint helpers to mirror DB invariants. For nested writes use cast_assoc/3 or cast_embed/3.    

Essential Code Snippets

import Ecto.Changeset

def changeset(%User{} = u, attrs) do
  u
  |> cast(attrs, [:email, :name])
  |> validate_required([:email])
  |> validate_format(:email, ~r/@/)
  |> unique_constraint(:email)
end

{:ok, user} = %User{} |> changeset(params) |> MyApp.Repo.insert()



Tips & Pitfalls
	•	Prefer DB constraints via *_constraint/3. Validate before DB. Handle nested writes with cast helpers.  

Exercises Application
	•	Build validations, capture errors, write nested data.  

Diagrams

attrs → cast → validate → constraints → Repo.insert/update



⸻

5) Transactions & Ecto.Multi (all-or-nothing units)

Key Concepts
	•	Wrap multi-step writes atomically with Repo.transaction/1. Orchestrate steps with Ecto.Multi. Keep steps small and deterministic. Prefer DB constraints to avoid races.  

Essential Code Snippets

Multi.new()
|> Multi.insert(:user, User.changeset(%User{}, params))
|> Multi.run(:welcome, fn _repo, %{user: u} -> deliver_welcome(u) end)
|> Repo.transaction()



Tips & Pitfalls
	•	Small steps. Deterministic operations. Constraints over app checks.  

Exercises Application
	•	Convert multi-write flows to Multi; handle step errors.  

Diagrams

Multi(step1 → step2 → …) → Repo.transaction



⸻

6) Migrations (evolving schema safely)

Key Concepts
	•	Create/alter tables. Add indexes. Reversible ops. Data + structure changes. Use explicit up/0 and down/0 when not reversible. Keep migrations fast and idempotent. Always index FKs and query keys.  

Essential Code Snippets

def change do
  create table(:posts) do
    add :title, :string, null: false
    add :user_id, references(:users, on_delete: :delete_all)
    timestamps()
  end
  create index(:posts, [:user_id])
end



Tips & Pitfalls
	•	Idempotent and quick. Explicit up/down for non-reversible steps. Index FKs and query keys.  

Exercises Application
	•	Write first migration; rollback; add indexes; adjust defaults.  

Diagrams

Repo.Migrations/ChangeSet → DB schema history



⸻

7) Ecto in non-Phoenix apps

Key Concepts
	•	Add deps. Define Repo. Attach to supervision tree. Support multiple repos.  

Exercises Application
	•	Initialize a plain Mix app with Ecto and start it under a supervisor.  

⸻

8) Phoenix forms + changesets

Key Concepts
	•	Use changesets to render forms and errors. Build forms for single and associated schemas.  

Exercises Application
	•	Wire a form to a changeset. Display validation and constraint errors. Handle nested forms.  

⸻

9) Testing with SQL sandboxes

Key Concepts
	•	SQL sandbox isolates DB per test. Ownership modes allow async and shared connections.  

Essential Code Snippets

# test/test_helper.exs
Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)

setup do
  :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)
  Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, {:shared, self()})
  :ok
end



Exercises Application
	•	Make tests async. Change ownership modes. Share connections safely.  

⸻

10) Custom types

Key Concepts
	•	Implement Ecto.Type to encode/decode domain types or wrap built-ins.  

Exercises Application
	•	Create a custom type and use it in a schema field.  

⸻

11) Upserts

Key Concepts
	•	Insert or update in one call. Use on_conflict and conflict_target. Works with or without schemas.  

Essential Code Snippets

Repo.insert(
  User.changeset(%User{}, attrs),
  on_conflict: {:replace, [:name, :updated_at]},
  conflict_target: :email
)



Exercises Application
	•	Implement idempotent writes via upsert.  

⸻

12) Design patterns (contexts, purity)

Key Concepts
	•	Separate pure transformations from impure Repo calls. Group operations into contexts.  

Exercises Application
	•	Refactor modules into contexts. Isolate DB boundaries.  

⸻

Cross-Chapter Checklist
	•	Prefer DB constraints + *_constraint/3 to guarantee invariants and reduce races. Compose queries and hit DB at the end. Use Ecto.Multi for multi-step writes. Index FKs and frequent filters, then measure. In tests use SQL sandbox with proper ownership.  

Quick Reference Crib

[attrs] → cast → validate → constraints → Repo.insert/update   (Changeset flow)
Schema ──belongs_to/has_many──> Schema                         (Associations)
Query pieces (where/join/select) → Repo.all/one/stream         (Query flow)
Supervisor → Repo → Adapter → DB                               (Runtime)
Multi(step1 → step2 → ...) → Repo.transaction                  (Transactions)



Further pointers: book site outlines, Changeset/Transaction/Sandbox docs, and official Ecto.Changeset API for exact option names.  


---

## Drills


Phase 5 Drills

Core Skills to Practice
	•	Model aggregates with DB constraints and mirrored changeset validations.
	•	Write an upsert using on_conflict and conflict_target.
	•	Wrap a 3-step write in Ecto.Multi and run in a single transaction.
	•	Add composite and partial indexes that match query shapes.
	•	Prevent N+1 by using targeted preload or join + preload correctly.

Exercises
	1.	Order aggregate with constraints
Build Order (aggregate root) and OrderItem with DB-level constraints and matching changesets.

# migration
def change do
  create table(:orders) do
    add :order_no, :string, null: false
    add :user_id, references(:users, on_delete: :restrict), null: false
    add :total_cents, :bigint, null: false, default: 0
    add :archived, :boolean, null: false, default: false
    timestamps()
  end

  create unique_index(:orders, [:order_no])
  create constraint(:orders, :total_non_negative, check: "total_cents >= 0")
  create index(:orders, [:user_id, :inserted_at], order: [user_id: :asc, inserted_at: :desc])
  create index(:orders, [:user_id], where: "archived = false", name: :orders_user_active_idx)
  
  create table(:order_items) do
    add :order_id, references(:orders, on_delete: :delete_all), null: false
    add :sku, :string, null: false
    add :qty, :integer, null: false
    add :price_cents, :bigint, null: false
    timestamps()
  end

  create index(:order_items, [:order_id])
end

# schemas + changesets
defmodule Shop.Order do
  use Ecto.Schema
  import Ecto.Changeset
  schema "orders" do
    field :order_no, :string
    field :total_cents, :integer
    field :archived, :boolean, default: false
    belongs_to :user, Shop.User
    has_many :items, Shop.OrderItem
    timestamps()
  end
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_no, :user_id, :total_cents, :archived])
    |> validate_required([:order_no, :user_id])
    |> validate_number(:total_cents, greater_than_or_equal_to: 0)
    |> unique_constraint(:order_no)
    |> foreign_key_constraint(:user_id)
    |> check_constraint(:total_cents, name: :total_non_negative)
  end
end


	2.	Inventory upsert
Insert inventory rows by sku or atomically increment qty on conflict.

attrs = %{sku: sku, qty: delta}
Repo.insert(
  %Inventory{} |> Inventory.changeset(attrs),
  on_conflict: [inc: [qty: delta]],
  conflict_target: :sku,
  returning: true
)


	3.	3-step write with Ecto.Multi
Create order → insert items → recalc total. Roll back on any failure.

alias Ecto.Multi

multi =
  Multi.new()
  |> Multi.insert(:order, Order.changeset(%Order{}, order_attrs))
  |> Multi.insert_all(:items, OrderItem, items_rows)
  |> Multi.update(:recalc, fn %{order: order} ->
    total = items_rows |> Enum.map(&(&1.qty * &1.price_cents)) |> Enum.sum()
    Order.changeset(order, %{total_cents: total})
  end)

case Repo.transaction(multi) do
  {:ok, %{order: order}} -> {:ok, order}
  {:error, _step, reason, _changes} -> {:error, reason}
end


	4.	Index to match query shape
Optimize: “recent orders for user.” Verify index selection in EXPLAIN.

# query uses [:user_id, :inserted_at DESC]
from(o in Order,
  where: o.user_id == ^user_id and not o.archived,
  order_by: [desc: o.inserted_at],
  limit: 50
)
|> Repo.all()


	5.	Eliminate N+1
Compare naive preload vs join+preload for filtered associations.

# Two-query preload (good default, avoids N+1)
orders =
  Order
  |> where([o], o.user_id == ^user_id)
  |> preload([o], [:items])
  |> Repo.all()

# Single-query join when filtering/sorting children
orders =
  from(o in Order,
    where: o.user_id == ^user_id,
    join: i in assoc(o, :items),
    where: i.qty > 0,
    preload: [items: i],
    order_by: [desc: o.inserted_at]
  )
  |> Repo.all()



Common Pitfalls
	•	Validating only in app, not in DB. Add DB constraints and surface them via *_constraint/3.
	•	N+1 from naive preloads. Use one preload per association or join + preload when filtering children.
	•	Non-atomic multi-step writes. Use Ecto.Multi inside a transaction.
	•	Missing composite/partial indexes that match hot queries.

Success Criteria
	•	Aggregate root enforces invariants in DB (unique_constraint, check_constraint, FKs) and in changesets.
	•	Upsert is race-safe and idempotent under concurrent load.
	•	Ecto.Multi commits all three steps or rolls back with no partial writes; tests cover failure at each step.
	•	Queries use intended indexes for hot paths; partial and composite indexes exist for primary query shapes.
	•	List endpoints execute a bounded number of queries with correct preload/join usage, no N+1.

