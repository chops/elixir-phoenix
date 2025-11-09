.PHONY: help setup deps test fmt check lint ci db-up db-down cluster-up cluster-down bench load smoke

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies and set up the project
	mix deps.get
	# mix ecto.setup  # Uncomment in Phase 5 when Ecto is added

deps: ## Fetch dependencies
	mix deps.get

test: ## Run all tests
	mix test

fmt: ## Format code
	mix format

check: ## Run formatter check
	mix format --check-formatted

credo: ## Run Credo
	mix credo --strict

dialyzer: ## Run Dialyzer
	mix dialyzer --format short

audit: ## Audit dependencies
	mix deps.audit

sobelow: ## Run security scan
	mix sobelow --exit

lint: ## Run static analysis (credo)
	mix credo --strict

ci: check credo dialyzer audit sobelow test ## Run CI checks locally

docs: ## Generate documentation
	mix docs

db-up: ## Start database containers
	docker-compose -f ops/docker-compose.db.yml up -d

db-down: ## Stop database containers
	docker-compose -f ops/docker-compose.db.yml down

cluster-up: ## Start local cluster
	docker-compose -f ops/docker-compose.cluster.yml up -d

cluster-down: ## Stop local cluster
	docker-compose -f ops/docker-compose.cluster.yml down

bench: ## Run benchmarks
	mix run tools/bench_cache.exs

load: ## Run load tests
	k6 run tools/k6/load.js

smoke: ## Run smoke tests
	k6 run tools/k6/smoke.js

livebook: ## Start Livebook server
	livebook server --home livebooks/
