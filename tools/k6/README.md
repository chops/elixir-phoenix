# k6 Load Test Templates

This directory contains k6 load test templates for validating mastery gates across all 15 phases of the Elixir Systems Mastery curriculum.

## Overview

Each phase has a corresponding `phase-XX-gate.js` script that validates the performance targets defined in the roadmap. These scripts serve as:

1. **Mastery Validation** - Objective criteria to advance to the next phase
2. **Performance Baselines** - Concrete targets for system performance
3. **Regression Prevention** - Catch performance degradation early
4. **Chaos Engineering** - Some tests inject failures to validate resilience

## Prerequisites

```bash
# Install k6
brew install k6  # macOS
# or
sudo apt-get install k6  # Ubuntu/Debian
# or download from https://k6.io/docs/getting-started/installation/

# Verify installation
k6 version
```

## Usage

### Running Individual Phase Gates

```bash
# Phase 0: Tooling Foundation
k6 run tools/k6/phase-00-gate.js

# Phase 1: Elixir Core
BASE_URL=http://localhost:4000 k6 run tools/k6/phase-01-gate.js

# Phase 3: GenServer + Supervision
BASE_URL=http://localhost:4000 k6 run tools/k6/phase-03-gate.js

# Phase 6: Phoenix Web
BASE_URL=http://localhost:4000 k6 run tools/k6/phase-06-gate.js

# Phase 9: Distribution (run with chaos drills)
BASE_URL=http://localhost:4000 k6 run tools/k6/phase-09-gate.js
```

### Running with Chaos Drills

For phases that test resilience (9, 13), run chaos drills in parallel:

```bash
# Terminal 1: Start load test
BASE_URL=http://localhost:4000 k6 run tools/k6/phase-09-gate.js

# Terminal 2: Inject chaos during test
bash tools/gameday/kill-node.sh
bash tools/gameday/partition-network.sh
```

### Environment Variables

- `BASE_URL` - Base URL of your application (default: `http://localhost:4000`)
- `K6_OUT` - Output format (e.g., `json=results.json`, `influxdb=http://localhost:8086`)
- `K6_VUS` - Override default VUs for quick tests
- `K6_DURATION` - Override test duration

### Interpreting Results

k6 provides a summary at the end of each test:

```
Phase X Gate: PASSED ✓

checks.........................: 100.00% ✓ 1000  ✗ 0
data_received..................: 1.2 MB  20 kB/s
data_sent......................: 100 kB  1.7 kB/s
http_req_blocked...............: avg=1.2ms    p(95)=3ms
http_req_duration..............: avg=45ms     p(95)=120ms p(99)=200ms
http_reqs......................: 1000    16.67/s
iteration_duration.............: avg=1.01s    p(95)=1.5s
iterations.....................: 1000    16.67/s
vus............................: 100     min=10  max=100
```

Key metrics to watch:
- **checks** - Should be 100% for passing gates
- **p(95)** - 95th percentile latency (must meet targets)
- **p(99)** - 99th percentile latency
- **error rate** - Should be < 1% for resilience tests

## Phase-by-Phase Guide

### Phase 0: Tooling Foundation
**File:** `phase-00-gate.js`
**Targets:** CI pipeline < 5 min, all quality gates pass
**Validation:** All 6 tools (format, credo, dialyzer, sobelow, deps.audit, test) execute successfully

### Phase 1: Elixir Core
**File:** `phase-01-gate.js`
**Targets:** CSV parsing p95 < 50ms, stats p95 < 100ms, memory < 50MB
**Validation:** Pure function performance with large datasets

### Phase 2: Processes & Mailboxes
**File:** `phase-02-gate.js`
**Targets:** Message passing p95 < 1ms, process spawn p95 < 0.5ms
**Validation:** Actor model fundamentals and mailbox management

### Phase 3: GenServer + Supervision
**File:** `phase-03-gate.js`
**Targets:** GenServer call p95 < 5ms, p99 < 20ms, throughput 500+ calls/sec
**Validation:** GenServer performance and supervisor recovery < 100ms

### Phase 4: Naming & Fleets
**File:** `phase-04-gate.js`
**Targets:** Registry lookup p95 < 1ms, worker churn 1000+ start/stop per sec
**Validation:** Dynamic process management and lifecycle

### Phase 5: Data & Ecto
**File:** `phase-05-gate.js`
**Targets:** Simple query p95 < 10ms, complex query p95 < 50ms, throughput 500+ writes/sec
**Validation:** Database performance and transaction handling

### Phase 6: Phoenix Web
**File:** `phase-06-gate.js`
**Targets:** HTTP p95 < 50ms, LiveView mount p95 < 150ms, 1000+ concurrent LiveViews
**Validation:** Real-time web performance at scale

### Phase 7: Jobs & Ingestion
**File:** `phase-07-gate.js`
**Targets:** Broadway 10K events/sec, Oban job latency p95 < 5 sec
**Validation:** Pipeline throughput and backpressure handling

### Phase 8: Caching & ETS
**File:** `phase-08-gate.js`
**Targets:** ETS read p95 < 0.5ms, throughput 100K+ reads/sec, hit rate > 90%
**Validation:** Cache performance and stampede protection

### Phase 9: Distribution
**File:** `phase-09-gate.js`
**Targets:** RPC call p95 < 20ms, failover < 5 sec, error rate < 1% during node kill
**Validation:** Cluster resilience under chaos

### Phase 10: Observability & SLOs
**File:** `phase-10-gate.js`
**Targets:** Metrics export < 5ms overhead, SLO tracking 99.9% availability
**Validation:** Telemetry performance and alerting

### Phase 11: Testing Strategy
**File:** `phase-11-gate.js`
**Targets:** Test suite < 30 sec, coverage > 90%, flake rate 0%
**Validation:** Test effectiveness and speed

### Phase 12: Delivery & Ops
**File:** `phase-12-gate.js`
**Targets:** Health check p95 < 100ms, graceful shutdown < 30 sec, zero downtime deploy
**Validation:** Production deployment patterns

### Phase 13: Capstone Integration
**File:** `phase-13-gate.js`
**Targets:** End-to-end p95 < 200ms, 1000 RPS sustained, survive all chaos drills
**Validation:** Full system resilience under combined failures

### Phase 14: CTO Track
**File:** `phase-14-gate.js`
**Targets:** Audit log < 5ms overhead, SBOM generation < 2 min, DR recovery < 4 hours
**Validation:** Security and compliance controls

### Phase 15: AI/ML Integration
**File:** `phase-15-gate.js`
**Targets:** Inference p95 < 200ms, batch throughput 100+ items/sec, model swap < 1 sec
**Validation:** ML model serving performance

## Creating Stub Templates

For phases without full templates yet, use this structure:

```javascript
/**
 * Phase X Mastery Gate - [Phase Name]
 *
 * [Description]
 *
 * Performance Targets:
 * - [Target 1]
 * - [Target 2]
 * - [Target 3]
 *
 * Usage:
 *   k6 run phase-XX-gate.js
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter, Rate } from 'k6/metrics';

// Custom metrics
const metricName = new Trend('metric_name');

export const options = {
  scenarios: {
    default: {
      executor: 'ramping-vus',
      startVUs: 10,
      stages: [
        { duration: '30s', target: 100 },
        { duration: '1m', target: 100 },
        { duration: '20s', target: 0 },
      ],
    },
  },
  thresholds: {
    'metric_name': ['p(95)<TARGET'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

export default function () {
  // Test implementation
  const res = http.get(`${BASE_URL}/api/endpoint`);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1);
}

export function handleSummary(data) {
  console.log('\n=== Phase X Mastery Gate Summary ===');

  const p95 = data.metrics.metric_name?.values['p(95)'] || 0;
  console.log(`Metric p95: ${p95.toFixed(2)}ms (target: <TARGET)`);

  const passed = p95 < TARGET;
  console.log(`\nPhase X Gate: ${passed ? 'PASSED ✓' : 'FAILED ✗'}`);

  return { 'stdout': '' };
}
```

## Integration with CI/CD

Add to `.github/workflows/mastery-gates.yml`:

```yaml
name: Mastery Gates

on:
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  phase-gates:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        phase: [0, 1, 3, 6, 9]

    steps:
      - uses: actions/checkout@v3

      - name: Setup k6
        run: |
          sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
          echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install k6

      - name: Start application
        run: docker-compose up -d

      - name: Wait for health
        run: |
          timeout 60 bash -c 'until curl -f http://localhost:4000/health; do sleep 2; done'

      - name: Run Phase ${{ matrix.phase }} Gate
        run: |
          k6 run tools/k6/phase-${{ matrix.phase }}-gate.js

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: k6-results-phase-${{ matrix.phase }}
          path: k6-results.json
```

## Best Practices

1. **Run locally first** - Validate performance on your machine before CI
2. **Use realistic data** - Test with production-like datasets
3. **Iterate quickly** - Start with short durations, increase gradually
4. **Monitor resources** - Watch CPU, memory, network during tests
5. **Fail fast** - If a gate fails, stop and fix before advancing
6. **Document baselines** - Record results for regression detection
7. **Test under load** - Gates should pass under realistic traffic

## Troubleshooting

### Test times out
- Check if application is running (`curl http://localhost:4000/health`)
- Reduce VUs or duration for debugging
- Check application logs for errors

### Performance doesn't meet targets
- Profile application with `:observer`, `telemetry`, or `flamegraph`
- Check database query performance with `EXPLAIN ANALYZE`
- Review GenServer callback durations
- Verify no blocking I/O in critical paths

### Flaky tests
- Add retries for external dependencies
- Use health checks before load tests
- Ensure database is seeded consistently
- Check for resource exhaustion (file descriptors, connections)

## Resources

- [k6 Documentation](https://k6.io/docs/)
- [k6 Examples](https://k6.io/docs/examples/)
- [Performance Testing Best Practices](https://k6.io/docs/testing-guides/api-load-testing/)
- [k6 Thresholds](https://k6.io/docs/using-k6/thresholds/)
- [k6 Metrics](https://k6.io/docs/using-k6/metrics/)
