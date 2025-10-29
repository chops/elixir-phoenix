
# Database Design Checklist

## Overview
Use before merging any Ecto schema, query, or migration. Grounded in Phase 5 (lines 1–279) and the “Quick cross-chapter heuristics”.

## Schema Design
- [ ] All required fields `null: false` in migrations (review diff)
- [ ] Every foreign key declared with `references/2` and `on_delete` set (e.g., `:delete_all`)
- [ ] 100% FK columns indexed (`create index(:table, [:fk_id])`)
- [ ] All natural keys have DB unique indexes (not just app validation)
- [ ] Each uniqueness rule mirrored by `unique_constraint/3` name matching the DB index
- [ ] Composite indexes added for frequent filter shapes (match real `where` clauses)
- [ ] Schema types align with DB types (e.g., `:utc_datetime`, `:decimal` where needed)
- [ ] Associations modeled explicitly (`belongs_to/has_many/has_one`) and named consistently

## Changesets
- [ ] `cast/3` only whitelists intended fields
- [ ] `validate_required/2` covers all non-null columns
- [ ] Format/length/number validations present where user input exists
- [ ] DB invariants enforced with constraints: `unique_constraint`, `foreign_key_constraint`, `check_constraint`
- [ ] Nested writes use `cast_assoc/3` or `cast_embed/3` with `required: true` when needed
- [ ] Changeset returns actionable errors (assert specific `:constraint` errors in tests)
- [ ] No business side effects inside changeset functions (keep deterministic)

## Queries
- [ ] Queries composed via functions; no inline string SQL
- [ ] N+1 eliminated: use `join` or `preload` deliberately for each list view
- [ ] Query count for a representative page is O(1) as item count scales (measure with `ecto.repo.query` Telemetry or log capture)
- [ ] `select` limits columns to what is used (avoid loading blobs)
- [ ] Association joins prefer `assoc/2` to keep keys correct
- [ ] Reusable base queries defined and piped (`from/2` or `Ecto.Query` macros) until a single `Repo.all/one/stream` call

## Migrations
- [ ] `change/0` is reversible; if not, provide explicit `up/0` and `down/0`
- [ ] All FKs and frequent filters indexed in same PR as the table change
- [ ] Large writes split into small, deterministic steps (favor structure first, then data)
- [ ] Migration names and constraint names match changeset constraint names
- [ ] Dry run on staging completes < 60s per migration (target quick, book says “keep quick”)
- [ ] Rollback tested locally: `mix ecto.rollback --step 1` succeeds

## Testing (SQL Sandbox)
- [ ] `Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)` set in `test_helper.exs`
- [ ] Each DB test checks out a connection; shared mode used when processes need it
- [ ] `async: true` only for tests that do not touch the DB
- [ ] Constraint behavior asserted using real DB (e.g., uniqueness raises changeset error)
- [ ] Multi-step writes tested with `Ecto.Multi` success and failure paths

## Common Mistakes to Avoid
- Validating uniqueness only in the app. Fix: add DB unique index + `unique_constraint/3`.
- Preloading inside loops. Fix: join or preload once and keep query count O(1).
