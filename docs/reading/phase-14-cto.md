# Phase 14 — CTO Track (Security, Ops Practice)

Security hardening, operational excellence, and team processes.

## Books
- **Adopting Elixir** — team, process, production

## Docs
- **EEF Web App Security Best Practices (BEAM)**
  https://github.com/erlef/security-wg/blob/main/web-app-security-best-practices.md

## Supplements
- **Phoenix security checklist**
  https://hexdocs.pm/phoenix/security_considerations.html

- **Sobelow triage**
  https://hexdocs.pm/sobelow/cli.html---

================================================================================

Phase 14 extracted below.

Adopting Elixir Summary

Outline
	•	Part I — Concept: 1) Team Building, 2) Ensuring Code Consistency, 3) Legacy Systems & Dependencies.  
	•	Part II — Development: 4) Making the Functional Transition, 5) Distributed Elixir, 6) Integrating with External Code.  
	•	Part III — Production: 7) Coordinating Deployments, 8) Metrics & Performance, 9) Production Readiness.  

Chapter/Section Summaries

Team Building

Key Concepts
	•	Train first, hire for mindset; pair junior with senior.  
	•	Interview for FP reasoning, concurrency intuition, supervision basics.  
	•	Set expectations for on-call and incident drills; create an OTP-focused onboarding plan.  

Essential Code Snippets

# n/a

Tips & Pitfalls
	•	Don’t gate on “10y BEAM”; optimize for learning speed.  

Exercises Application
	•	Write a two-week onboarding plan with OTP goals and a shadow rotation.  
	•	Run a 90-minute spike: refactor a loop into a GenServer and supervise it.  

Diagrams

Onboarding → Pairing → OTP spike → Shadow on-call

Ensuring Code Consistency

Key Concepts
	•	Standards, typespecs + Dialyzer, docs, tests, code review.  

Essential Code Snippets

# mix.exs
def deps, do: [
  {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
  {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
  {:ex_doc, "~> 0.34", only: :dev, runtime: false}
]
# dialyzer
@spec total(number, number) :: number
def total(net, rate), do: net * (1 + rate)
# docs + doctest
@doc "Adds tax\n\n## Examples\n    iex> total(100, 0.1)\n    110.0"



Tips & Pitfalls
	•	Keep specs on public API; fix or justify suppressions. Make pre-commit run format, credo, dialyzer, tests.  

Exercises Application
	•	Add Credo, Dialyzer, ExDoc; fail CI on warnings; add doctests to three modules.  

Diagrams

Commit → Pre-commit hooks → CI gates → Docs publish

Legacy Systems & Dependencies

Key Concepts
	•	Incremental replacement, stable interfaces, feature toggles; umbrella apps as a middle ground. Vet, pin, and watch transitive risk.  

Essential Code Snippets

mix new my_app --umbrella
cd apps/core && mix new core
cd ../web && mix phx.new web --no-ecto --app web
# web depends on core in its mix.exs



Tips & Pitfalls
	•	Don’t split too early; wrap vendor APIs with behaviours and inject adapters.  

Exercises Application
	•	Carve a legacy endpoint into umbrella web + core; add behaviour + fake for an HTTP client.  

Diagrams

Legacy svc → Behaviour (adapter) → Core → Web

Making the Functional Transition

Key Concepts
	•	Pure core, immutable data, explicit outcomes; OTP primitives.  

Essential Code Snippets

# pure core
def validate(%{qty: q}) when q > 0, do: {:ok, q}
def validate(_), do: {:error, :bad_qty}



Tips & Pitfalls
	•	Keep side effects at the edges; keep callbacks thin.  

Exercises Application
	•	Move business rules to pure modules; expose explicit {:ok, _} | {:error, _}.  

Diagrams

Client → Pure Core ↔ Result │ Side-effects at edges

Production: Coordinating Deployments

Key Concepts
	•	mix release, runtime env, health/readiness endpoints, graceful shutdown, blue-green/rolling, systemd.  

Essential Code Snippets

# endpoints and rollout are defined in ops/runbooks and systemd units

Tips & Pitfalls
	•	Zero-downtime rollout; rollback < 2 min; readiness gates migrations.  

Exercises Application
	•	Build release with runtime config; add /health and /ready; practice rollback.  

Diagrams

CI → Build release → Blue/Green (A↔B) → Switch → Rollback path

Production: Metrics & Performance

Key Concepts
	•	OTEL for web/Ecto/Oban/Broadway; Prometheus exporter; dashboards with RPS, p95, error rate, saturation; SLOs and burn alerts.  

Essential Code Snippets

# instrumentation and exporters configured per service; see observability/grafana/*.json

Tips & Pitfalls
	•	Alert on burn rate and mailbox/ETS gauges; test under load with k6.  

Exercises Application
	•	Add Telemetry handlers and Prometheus export; verify dashboards under k6 load.  

Diagrams

Phoenix/Ecto/Jobs/Ing → Telemetry → OTEL → Prometheus → Grafana

Production Readiness: Security, Authorization, Audit, Compliance

Key Concepts
	•	Enforce least-privilege by context functions requiring actor+scope. Secrets only at runtime.  
	•	Static analysis and supply-chain hygiene: Sobelow, mix_audit; generate SBOM.  
	•	Append-only audit log with verifier.  
	•	Threat modeling, dependency scanning, AuthZ boundaries, audit trails, SOC2 and basic ISO mappings.  

Essential Code Snippets

# tests prove unauthorized calls fail; scanners run in CI; audit log verifier passes

Tips & Pitfalls
	•	No compile-time secrets; lock down admin endpoints with caps.  

Exercises Application
	•	Add role scopes to context functions; write failing tests for unauthorized access; wire Sobelow + mix_audit + SBOM in CI; implement append-only audit log with verifier.  

Diagrams

Request → Context(scope check) → Repo
                 ↘ Audit log (append-only)
Scanners: Sobelow/mix_audit → CI gate

CTO Track: Hiring, Structure, Incident Response, Risks, Ops Docs

Key Concepts
	•	Annual plan with Core, Scale, Compliance swimlanes; hiring loop and job ladder; vendor due diligence; risk register; incident response; unit economics.  
	•	Produce docs: /docs/cto/{plan.md, ladder.md, hiring-loop.md, risks.md, unit-economics.md}.  
	•	Incident drills and GameDay scripts to validate ops.  

Essential Code Snippets

# docs/cto/plan.md, hiring-loop.md, risks.md, unit-economics.md
# docs/runbook/gameday.md links drills to alerts and dashboards

Tips & Pitfalls
	•	Tie each risk to mitigations and owners; review monthly.  

Exercises Application
	•	Author the four CTO docs; add Incident Drill CLI that runs failure drills and verifies dashboards/alerts/runbooks.  

Diagrams

CTO Docs → Plan | Hiring Loop | Risks | Unit Economics
            ↘ Ops Runbooks ↘ Incident Drills ↘ Dashboards/Alerts

Cross-Chapter Checklist
	•	Pure cores; explicit results; pattern matching.  
	•	Keep GenServer thin; name with Registry; scale with DynamicSupervisor.  
	•	Measure first; SLOs and dashboards per service; test rollouts and rollbacks.  

Quick Reference Crib

Pipeline : input → map → filter → [Enum.*] → output
Recursion: loop(state) → receive → new_state → loop(new_state)
Concurrency: Parent ⇆(link) Child | Parent ←(monitor) Child
OTP      : Client → GenServer ↔ State   under Supervisor/Registry



Phase-Specific Hooks (CTO Track)
	•	Deliver /docs/cto/{plan.md,hiring-loop.md,risks.md,unit-economics.md}; acceptance: docs complete, risks mapped to mitigations/owners.  
	•	Security gates: sobelow, mix_audit, SBOM on CI; tests enforce least-privilege; append-only audit log.  

Done.


---

## Drills


## Phase 14 Drills

### Core Skills to Practice
- Write a one-page annual plan with three swimlanes: **Core**, **Scale**, **Compliance**.
- Define SLOs for web, jobs, and ingestion; wire burn-rate alerts.
- Create a headcount plan and a repeatable interview loop.
- Publish one ADR per sprint.
- Run a monthly GameDay with fail/recover scripts.

### Exercises
1. **Annual plan (Core/Scale/Compliance)**
   - Create `docs/cto/plan-YYYY.md` with three swimlanes and quarterly milestones.
   - Include: top risks, dependencies, budget ranges, measurable outcomes.
   - **Expected:** One page, three tables, each item has an owner and a date.
   - **Template**
     ```markdown
     # Annual Plan YYYY

     ## Core
     | Q | Initiative | Outcome | Owner | Budget |
     |---|------------|---------|-------|--------|
     | Q1 | Ship LiveView checkout v2 | p95 < 120ms | Web Lead | $15k |

     ## Scale
     | Q | Initiative | Outcome | Owner | Budget |
     |---|------------|---------|-------|--------|
     | Q2 | Shard jobs by account | 0 DLQ spikes | Platform | $8k |

     ## Compliance
     | Q | Initiative | Outcome | Owner | Budget |
     |---|------------|---------|-------|--------|
     | Q3 | SOC2 Type I | Audit pass | CTO | $25k |
     ```

2. **SLOs + alerts**
   - Create `docs/slo/phase14.md` with SLOs and alert policies.
   - **Targets**
     - Web: availability 99.9%, p95 < 150ms, p99 < 300ms, error rate < 0.1%.
     - Jobs (Oban): success > 99.5%/h, TTI p95 < 60s, DLQ < 0.05%.
     - Ingestion (Broadway): end-to-end p95 < 5s, backlog < 1× hourly rate.
   - Add burn alerts: 2%/1h, 5%/6h, 10%/24h.
   - **Expected:** Queries and Grafana panels listed per SLI.

3. **Headcount plan + interview loop**
   - Create `docs/people/headcount-YYYY.md` with quarterly hiring goals, costs, and ramp plans.
   - Create `docs/people/interview-loop.md` describing stages, rubrics, and pass bars.
   - **Loop**
     - Recruit screen → Tech screen (FP/OTP) → Pairing (Phoenix/OTP) → Systems design → Values → Reference.
   - **Expected:** Each stage has timebox, rubric, and decision rule.
   - **Rubric snippet**
     ```markdown
     ### OTP Supervision (Pass bar)
     - Identifies one_for_one vs rest_for_one correctly
     - Can design restart strategy with intensity/backoff
     - Explains `handle_continue` vs `init` failure
     ```

4. **ADRs per sprint**
   - Policy file `docs/adr/README.md`: “≥1 ADR per sprint. Status tracked.”
   - Create `docs/adr/ADR-YYYY-##-example.md` with context → decision → consequences.
   - **Expected:** ADR links from PR description; ADR state updated on release.

5. **Monthly GameDay**
   - Create `docs/runbook/gameday.md` with 60-minute script and rollback steps.
   - **Scenarios**
     - Kill a web node during load; verify SLO holds.
     - Break DB primary; confirm read-replica failover or fast failure.
     - Spike external latency; verify circuit breaker and user fallback.
   - **Checklist**
     ```markdown
     - [ ] Preload test data
     - [ ] Start k6 test @ 200 RPS for 10 min
     - [ ] `pkill -9 beam.smp` on node-2 minute 3
     - [ ] Observe p95 < 150ms, error < 0.1%
     - [ ] Rollback to Release N-1 in < 2 min
     ```

### Common Pitfalls
- Confusing SLOs with SLAs; set internal SLOs tighter than contracts.
- Swimlanes with initiatives but no measurable outcomes or owners.
- Interview loop without rubrics; produces noisy hires.
- ADRs written post-facto; must precede implementation.
- GameDay without rollback; drills should always practice rollback.

