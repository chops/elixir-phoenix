# Labs Gatekeeper

**Phase 0 Deliverable: Tooling Foundation**

This application serves as the foundation for the Elixir Systems Mastery curriculum by enforcing quality gates across the entire repository.

## Purpose

The Gatekeeper doesn't contain business logic. Instead, it validates that the tooling infrastructure is properly configured and that all quality gates are enforced.

## Quality Gates

This app ensures the following checks pass before code can be committed or merged:

1. **Formatting** - `mix format --check-formatted`
2. **Linting** - `mix credo --strict`
3. **Type Checking** - `mix dialyzer`
4. **Security** - `mix sobelow --exit`
5. **Dependency Audit** - `mix deps.audit`
6. **Tests** - `mix test`

## Running Locally

```bash
# Run all gates
make ci

# Run individual gates
mix format --check-formatted
mix credo --strict
mix dialyzer
mix sobelow --exit
mix deps.audit
mix test
```

## CI Integration

All gates are automatically enforced in GitHub Actions (`.github/workflows/ci.yml`). The CI will fail if any gate fails.

## Pre-commit Hook

To run gates before every commit, create `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Running quality gates..."
make ci
```

Then make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

## Phase 0 Success Criteria

Phase 0 is considered complete when:

- [x] All dependencies installed
- [x] `labs_gatekeeper` app created
- [ ] All quality gates pass locally
- [ ] CI is green
- [ ] Pre-commit hook configured
- [ ] Team understands each tool's purpose

## Learning Objectives

By completing this phase, you demonstrate:

- Understanding of the Elixir tooling ecosystem
- Ability to configure CI/CD pipelines
- Discipline to enforce quality standards from day one
- Knowledge of security and dependency management best practices

## Next Steps

After Phase 0 is complete, proceed to Phase 1: Elixir Core, where you'll build `labs_csv_stats` and `pulse_core` to practice functional programming fundamentals.
