# Risk Register

## Overview
Track and manage risks for the Elixir Systems Mastery project.

## Risk Assessment Scale
- **Probability**: Low (1) / Medium (2) / High (3)
- **Impact**: Low (1) / Medium (2) / High (3)
- **Score**: Probability × Impact (max 9)

---

## Technical Risks

### R1: Insufficient OTP Understanding
**Probability**: Medium (2)
**Impact**: High (3)
**Score**: 6

**Description**
May not fully grasp supervision strategies and fault tolerance patterns.

**Mitigation**
- Follow structured learning path
- Build labs apps for each pattern
- Practice with intentional failures
- Review with experienced Elixir developers

**Owner**: Self
**Status**: Active

---

### R2: Performance Bottlenecks in Pulse App
**Probability**: Medium (2)
**Impact**: Medium (2)
**Score**: 4

**Description**
May not identify or optimize critical performance paths.

**Mitigation**
- Establish baseline metrics early
- Regular benchmarking with Benchee
- Load testing with k6
- Profiling with :fprof/eprof

**Owner**: Self
**Status**: Monitoring

---

### R3: Incomplete Test Coverage
**Probability**: Low (1)
**Impact**: High (3)
**Score**: 3

**Description**
Gaps in testing may lead to undetected bugs.

**Mitigation**
- Enforce >80% coverage from start
- Use property-based testing
- Integration tests for critical paths
- CI enforcement

**Owner**: Self
**Status**: Mitigated

---

## Operational Risks

### R4: Inadequate Monitoring
**Probability**: Medium (2)
**Impact**: High (3)
**Score**: 6

**Description**
May not detect issues in production without proper observability.

**Mitigation**
- Implement OpenTelemetry early
- Define SLOs in Phase 10
- Create dashboards
- Set up alerts

**Owner**: Self
**Status**: Active

---

### R5: Security Vulnerabilities
**Probability**: Medium (2)
**Impact**: High (3)
**Score**: 6

**Description**
May introduce security flaws without proper scanning and practices.

**Mitigation**
- Run Sobelow on every commit
- Dependency audits with mix_audit
- Follow security checklists
- Security review in Phase 14

**Owner**: Self
**Status**: Active

---

## Learning Risks

### R6: Scope Creep in Phases
**Probability**: High (3)
**Impact**: Medium (2)
**Score**: 6

**Description**
May try to learn too much in each phase, delaying progress.

**Mitigation**
- Stick to weekly cadence
- Complete labs apps before moving on
- Use checklists to define "done"
- Time-box each phase

**Owner**: Self
**Status**: Active

---

### R7: Insufficient Depth in Books
**Probability**: Low (1)
**Impact**: Medium (2)
**Score**: 2

**Description**
May skim books rather than deeply understanding concepts.

**Mitigation**
- Complete all exercises
- Take notes in phase files
- Build examples from books
- Review quarterly

**Owner**: Self
**Status**: Monitoring

---

## Resource Risks

### R8: Time Constraints
**Probability**: High (3)
**Impact**: High (3)
**Score**: 9

**Description**
May not have sufficient time to complete all phases in 12 months.

**Mitigation**
- Allocate 20-30 hours/week
- Track progress weekly
- Adjust pace as needed
- Prioritize critical phases

**Owner**: Self
**Status**: Active - HIGHEST PRIORITY

---

### R9: Infrastructure Costs
**Probability**: Low (1)
**Impact**: Low (1)
**Score**: 1

**Description**
Cloud/infrastructure costs may exceed budget.

**Mitigation**
- Use free tiers where possible
- Local development primary
- Monitor costs monthly
- Shut down unused resources

**Owner**: Self
**Status**: Mitigated

---

## Risk Summary

| ID | Risk | Score | Status |
|----|------|-------|--------|
| R8 | Time Constraints | 9 | Active |
| R1 | OTP Understanding | 6 | Active |
| R4 | Inadequate Monitoring | 6 | Active |
| R5 | Security Vulnerabilities | 6 | Active |
| R6 | Scope Creep | 6 | Active |
| R2 | Performance Bottlenecks | 4 | Monitoring |
| R3 | Test Coverage | 3 | Mitigated |
| R7 | Book Depth | 2 | Monitoring |
| R9 | Infrastructure Costs | 1 | Mitigated |

## Review Cadence
- **Weekly**: Check high-priority risks (score ≥6)
- **Monthly**: Review all risks, update mitigation
- **Quarterly**: Add new risks, retire old ones
