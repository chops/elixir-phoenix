# Phase 0 — Tooling Foundation

Set up development environment, linters, and CI/CD automation.

## Books
None.

## Docs
- **Elixir docs hub and Getting Started**
  https://elixir-lang.org/ and https://elixir-lang.org/getting-started/introduction.html

- **Credo overview and usage**
  https://hexdocs.pm/credo/readme.html

- **Dialyxir tasks and "explain"**
  https://hexdocs.pm/dialyxir/readme.html

- **mix_audit docs**
  https://hexdocs.pm/mix_audit/readme.html

- **Sobelow docs**
  https://hexdocs.pm/sobelow/readme.html

## Supplements
- **Elixir CI with GitHub Actions**
  https://github.com/erlef/setup-beam

- **Sobelow site (tool overview)**
  https://sobelow.io

---

## Tooling Setup Guide

### Dev Dependencies (mix.exs)

Add these to your umbrella root `mix.exs`:

```elixir
# dev/test/tooling deps (umbrella root)
defp deps do
  [
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.34", only: :dev, runtime: false},
    {:sobelow, "~> 0.13", only: :dev, runtime: false},
    {:mix_audit, "~> 2.1", only: :dev, runtime: false},
    {:benchee, "~> 1.3", only: :dev},
    {:stream_data, "~> 0.6", only: :test},
    {:mox, "~> 1.1", only: :test}
  ]
end
```

### Makefile Quality Gates

Create a `Makefile` in your repository root:

```makefile
check: fmt credo dialyzer audit sobelow test

fmt:
	mix format --check-formatted

credo:
	mix credo --strict

dialyzer:
	mix dialyzer --format short

audit:
	mix deps.audit

sobelow:
	mix sobelow --exit

test:
	mix test

bench:
	MIX_ENV=test mix run tools/bench_cache.exs

docs:
	mix docs
```

### GitHub Actions CI

Create `.github/workflows/ci.yml`:

```yaml
name: ci
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        otp: [26, 27]
        elixir: [1.16.2]
    steps:
      - uses: actions/checkout@v4
      - uses: erlef/setup-beam@v1
        with:
          otp-version: ${{ matrix.otp }}
          elixir-version: ${{ matrix.elixir }}
      - run: mix local.hex --force && mix local.rebar --force
      - run: mix deps.get
      - run: make check
```

**Note:** CI jobs include format, credo, dialyzer, tests, sobelow, and mix_audit checks.

### Credo Setup

**Run locally:**
```bash
mix credo --strict
```

**Best practices:**
- Enforce standards, typespecs + Dialyzer, docs, tests, code review
- Fail CI on warnings
- Keep credo configuration strict for consistency

### Dialyzer Configuration

**Typespec example:**
```elixir
@spec total(number, number) :: number
def total(net, rate), do: net * (1 + rate)
```

**Guidance:**
- Keep specs on public API only
- Fix warnings or suppress with care
- Make pre-commit run format+credo+dialyzer+tests

**Run locally:**
```bash
mix dialyzer
```

### Mix Audit and Sobelow

**Run dependency audit:**
```bash
mix deps.audit
```

**Run security scan:**
```bash
mix sobelow --exit
```

Both tools are integrated as CI gates to catch vulnerabilities and security issues early.

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
set -euo pipefail
make check
```

**Make executable:**
```bash
chmod +x .git/hooks/pre-commit
```

This ensures all quality checks pass before committing code.

### Success Criteria

**Phase 0 is complete when:**
- [ ] All dev dependencies installed
- [ ] `make check` runs successfully locally
- [ ] GitHub Actions CI is green
- [ ] Pre-commit hook is configured
- [ ] Team understands each tool's purpose
- [ ] Dialyzer PLT is built and cached

### Common Pitfalls

- **Dialyzer PLT not cached**: First run is slow; cache `.dialyzer/` in CI
- **Credo too strict initially**: Start with warnings, then enforce strict
- **Sobelow false positives**: Review and suppress known-safe patterns
- **Pre-commit hook skipped**: Team needs to understand `--no-verify` risks