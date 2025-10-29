# GameDay Drills

GameDay drills are chaos engineering scenarios designed to validate system resilience under realistic failure conditions. These scripts should be run during Phase 9 (Distribution) and Phase 13 (Capstone) mastery gate tests.

## Philosophy

> "Hope is not a strategy." - Traditional SRE wisdom

GameDay drills prove that your system can survive failures that **will** happen in production. Each drill:

1. **Injects a realistic failure** - Node crashes, network partitions, traffic spikes, database failures
2. **Validates recovery targets** - Failover time, error rates, data consistency
3. **Documents blast radius** - What broke? What stayed working?
4. **Improves runbooks** - Turn drill learnings into incident response procedures

## Prerequisites

- Distributed Elixir cluster running (≥3 nodes)
- k6 load testing running in parallel
- Metrics/observability stack active (Prometheus, Grafana)
- Baseline SLOs defined

## Drill Catalog

### Node Failure Drills

#### 1. Kill Node (SIGKILL)
**File:** `kill-node.sh`
**Scenario:** Simulate hardware failure or kernel panic
**Expected:** Cluster detects failure in < 5s, error rate < 1%

#### 2. Graceful Shutdown
**File:** `graceful-shutdown.sh`
**Scenario:** Rolling deploy, planned maintenance
**Expected:** Zero dropped connections, all in-flight requests complete

#### 3. OOM Kill
**File:** `oom-kill.sh`
**Scenario:** Memory leak causes node to run out of memory
**Expected:** Supervisor restarts, cluster recovers, memory leak logged

### Network Drills

#### 4. Network Partition
**File:** `partition-network.sh`
**Scenario:** Split-brain scenario, two halves of cluster can't communicate
**Expected:** Partition tolerance, no data loss, automatic healing

#### 5. Latency Injection
**File:** `inject-latency.sh`
**Scenario:** Network degradation, slow cross-node communication
**Expected:** Graceful degradation, circuit breakers activate, timeouts enforced

#### 6. Packet Loss
**File:** `packet-loss.sh`
**Scenario:** Flaky network dropping packets
**Expected:** Retries succeed, no cascading failures

### Traffic Drills

#### 7. Traffic Spike
**File:** `spike-traffic.sh`
**Scenario:** Sudden 10x traffic increase (flash sale, viral tweet)
**Expected:** Graceful degradation, autoscaling triggers, SLO maintained

#### 8. Slow Client
**File:** `slow-client.sh`
**Scenario:** Client reading responses very slowly (slow loris attack)
**Expected:** Connection timeouts enforced, resources freed

### Database Drills

#### 9. Database Primary Failure
**File:** `db-primary-failure.sh`
**Scenario:** Primary database crashes, must failover to replica
**Expected:** Failover < 10s, zero data loss, connection pool recovers

#### 10. Database Slow Query
**File:** `db-slow-query.sh`
**Scenario:** Expensive query locks table, causes cascading timeouts
**Expected:** Query timeouts enforced, circuit breakers trip, alerts fire

### Dependencies Drills

#### 11. External API Failure
**File:** `external-api-failure.sh`
**Scenario:** Third-party API goes down (payment gateway, email service)
**Expected:** Fallback behavior, retries with backoff, user experience degrades gracefully

#### 12. Cache Flush
**File:** `cache-flush.sh`
**Scenario:** Cache invalidated or Redis restarted
**Expected:** No stampede, gradual reload, database load manageable

## Running Drills

### Single Drill

```bash
# Terminal 1: Start baseline load test
BASE_URL=http://localhost:4000 k6 run tools/k6/phase-09-gate.js

# Terminal 2: Inject failure after 1 minute
sleep 60 && bash tools/gameday/kill-node.sh

# Monitor:
# - Grafana dashboards for latency, error rate, throughput
# - Application logs for errors and recovery
# - Cluster topology for node rejoining
```

### Full GameDay Simulation (Phase 13)

Run all drills in sequence with recovery periods:

```bash
bash tools/gameday/run-all-drills.sh
```

This script:
1. Validates baseline SLOs (pre-drill)
2. Runs each drill with recovery period
3. Validates SLOs after each drill
4. Generates incident timeline report
5. Creates postmortem template

### Automated GameDay (CI)

Add to `.github/workflows/gameday.yml`:

```yaml
name: GameDay Drills

on:
  schedule:
    - cron: '0 10 * * 1'  # Every Monday at 10 AM
  workflow_dispatch:

jobs:
  gameday:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Deploy cluster
        run: docker-compose -f docker-compose.cluster.yml up -d

      - name: Run GameDay drills
        run: bash tools/gameday/run-all-drills.sh

      - name: Generate report
        if: always()
        run: bash tools/gameday/generate-report.sh

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: gameday-results
          path: gameday-report.md
```

## Drill Template

Each drill script follows this structure:

```bash
#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# GameDay Drill: [Drill Name]
# ==============================================================================
#
# Scenario: [What failure is being simulated]
# Expected: [What should happen]
# Recovery: [How system should recover]
#
# Usage:
#   bash tools/gameday/drill-name.sh
#
# Prerequisites:
#   - Cluster running with ≥3 nodes
#   - k6 load test active
#   - Metrics collection enabled
# ==============================================================================

DRILL_NAME="[drill-name]"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="gameday-${DRILL_NAME}-${TIMESTAMP}.log"

echo "=== GameDay Drill: ${DRILL_NAME} ===" | tee -a "${LOG_FILE}"
echo "Started: $(date)" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# 1. Record baseline metrics
echo "[1/5] Recording baseline metrics..." | tee -a "${LOG_FILE}"
# TODO: Query Prometheus for current error rate, latency, throughput

# 2. Inject failure
echo "[2/5] Injecting failure..." | tee -a "${LOG_FILE}"
# TODO: Execute failure injection

# 3. Wait for detection
echo "[3/5] Waiting for failure detection..." | tee -a "${LOG_FILE}"
# TODO: Poll for failure detection in logs/metrics

# 4. Validate recovery
echo "[4/5] Validating recovery..." | tee -a "${LOG_FILE}"
# TODO: Check recovery metrics

# 5. Generate report
echo "[5/5] Generating report..." | tee -a "${LOG_FILE}"
# TODO: Compare before/after metrics

echo "" | tee -a "${LOG_FILE}"
echo "Completed: $(date)" | tee -a "${LOG_FILE}"
echo "Log: ${LOG_FILE}" | tee -a "${LOG_FILE}"
```

## Drill Results

After each drill, capture:

1. **Timeline**
   - T+0s: Failure injected
   - T+Xs: Failure detected (alert fired)
   - T+Ys: Recovery initiated
   - T+Zs: System healthy (SLOs met)

2. **Metrics**
   - Error rate: Before X%, during Y%, after Z%
   - Latency: p95 before Xms, during Yms, after Zms
   - Throughput: Before X RPS, during Y RPS, after Z RPS
   - Availability: X% during incident

3. **Blast Radius**
   - What failed? (specific services, endpoints)
   - What stayed working? (degraded mode features)
   - Data loss? (transactions, events)

4. **Learnings**
   - Did recovery meet targets?
   - Were runbooks accurate?
   - What monitoring gaps exist?
   - What could be automated?

## Success Criteria

A GameDay drill **passes** when:

- [ ] System detects failure within target time (< 5s for node failure)
- [ ] Error rate stays below threshold (< 1% for node failure)
- [ ] Recovery completes within target time (< 30s for most drills)
- [ ] No data loss for transactions in flight
- [ ] Alerts fire with correct severity and runbook links
- [ ] Team can execute runbook without gaps

A GameDay drill **fails** when:

- [ ] System doesn't detect failure (silent failure)
- [ ] Cascading failures occur (blast radius > expected)
- [ ] Data loss occurs
- [ ] Recovery requires manual intervention not in runbook
- [ ] SLOs breached beyond error budget

## Best Practices

1. **Start small** - Single node kill before full cluster chaos
2. **Run during business hours** - Team available to learn and respond
3. **Announce drills** - Build muscle memory, not panic
4. **Rotate drill leader** - Spread knowledge across team
5. **Update runbooks immediately** - Capture learnings while fresh
6. **Increment difficulty** - Once drill passes consistently, make it harder
7. **Automate recovery** - Manual steps become automation over time

## Drill Schedule

Recommended cadence:

- **Weekly**: Single drill (node kill, traffic spike)
- **Monthly**: Full GameDay (all drills)
- **Quarterly**: Multi-region drill (datacenter failure)
- **Annually**: Disaster recovery (restore from backup)

## References

- [Chaos Engineering Principles](https://principlesofchaos.org/)
- [Google SRE Book - Testing for Reliability](https://sre.google/sre-book/testing-reliability/)
- [Netflix Chaos Monkey](https://netflix.github.io/chaosmonkey/)
- [AWS GameDays](https://aws.amazon.com/gameday/)
- [Gremlin Chaos Engineering](https://www.gremlin.com/chaos-engineering/)
