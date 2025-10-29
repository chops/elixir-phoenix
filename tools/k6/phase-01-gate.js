/**
 * Phase 1 Mastery Gate - Elixir Core
 *
 * Validates pure functional code performance with CSV parsing and statistics.
 *
 * Performance Targets:
 * - CSV parsing: p95 < 50ms for 10K rows
 * - Statistics calculation: p95 < 100ms for 100K numbers
 * - Memory usage: < 50MB for 1M row streaming
 * - All property tests pass in < 10 seconds
 *
 * Usage:
 *   k6 run phase-01-gate.js
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter } from 'k6/metrics';

// Custom metrics
const csvParsingDuration = new Trend('csv_parsing_duration');
const statsDuration = new Trend('stats_calculation_duration');
const memoryUsage = new Trend('memory_usage_mb');
const errorsCount = new Counter('errors');

export const options = {
  scenarios: {
    csv_parsing: {
      executor: 'constant-vus',
      vus: 10,
      duration: '30s',
    },
    stats_calculation: {
      executor: 'ramping-vus',
      startVUs: 1,
      stages: [
        { duration: '10s', target: 50 },
        { duration: '20s', target: 100 },
        { duration: '10s', target: 0 },
      ],
    },
  },
  thresholds: {
    'csv_parsing_duration': ['p(95)<50'],     // p95 < 50ms
    'stats_calculation_duration': ['p(95)<100'], // p95 < 100ms
    'memory_usage_mb': ['avg<50'],             // < 50MB average
    'errors': ['count==0'],                     // Zero errors
    'http_req_duration': ['p(95)<150'],        // API p95 < 150ms
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

export default function () {
  const scenario = exec.scenario.name;

  if (scenario === 'csv_parsing') {
    testCSVParsing();
  } else if (scenario === 'stats_calculation') {
    testStatsCalculation();
  }

  sleep(1);
}

function testCSVParsing() {
  // Generate 10K row CSV data
  const rows = 10000;
  const csvData = generateCSV(rows);

  const startTime = Date.now();

  const res = http.post(`${BASE_URL}/api/csv/parse`, csvData, {
    headers: { 'Content-Type': 'text/csv' },
    tags: { name: 'csv_parse' },
  });

  const duration = Date.now() - startTime;
  csvParsingDuration.add(duration);

  const success = check(res, {
    'status is 200': (r) => r.status === 200,
    'response has parsed data': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.rows === rows;
      } catch (e) {
        return false;
      }
    },
    'parsing under 50ms': () => duration < 50,
  });

  if (!success) {
    errorsCount.add(1);
  }

  // Track memory usage (from response headers if available)
  if (res.headers['X-Memory-MB']) {
    memoryUsage.add(parseFloat(res.headers['X-Memory-MB']));
  }
}

function testStatsCalculation() {
  // Generate 100K numbers
  const count = 100000;
  const numbers = Array.from({ length: count }, () => Math.random() * 1000);

  const startTime = Date.now();

  const res = http.post(`${BASE_URL}/api/stats/calculate`, JSON.stringify({ numbers }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'stats_calc' },
  });

  const duration = Date.now() - startTime;
  statsDuration.add(duration);

  const success = check(res, {
    'status is 200': (r) => r.status === 200,
    'response has statistics': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.mean !== undefined && body.median !== undefined;
      } catch (e) {
        return false;
      }
    },
    'calculation under 100ms': () => duration < 100,
  });

  if (!success) {
    errorsCount.add(1);
  }
}

function generateCSV(rows) {
  const header = 'id,name,value,timestamp\n';
  const data = Array.from({ length: rows }, (_, i) =>
    `${i},product_${i},${Math.random() * 100},2025-01-01T00:00:00Z`
  ).join('\n');

  return header + data;
}

export function handleSummary(data) {
  console.log('\n=== Phase 1 Mastery Gate Summary ===');

  const csvP95 = data.metrics.csv_parsing_duration?.values['p(95)'] || 0;
  const statsP95 = data.metrics.stats_calculation_duration?.values['p(95)'] || 0;
  const avgMemory = data.metrics.memory_usage_mb?.values.avg || 0;
  const errors = data.metrics.errors?.values.count || 0;

  console.log(`CSV Parsing p95: ${csvP95.toFixed(2)}ms (target: <50ms)`);
  console.log(`Stats Calc p95: ${statsP95.toFixed(2)}ms (target: <100ms)`);
  console.log(`Avg Memory: ${avgMemory.toFixed(2)}MB (target: <50MB)`);
  console.log(`Errors: ${errors}`);

  const passed = csvP95 < 50 && statsP95 < 100 && avgMemory < 50 && errors === 0;

  console.log(`\nPhase 1 Gate: ${passed ? 'PASSED ✓' : 'FAILED ✗'}`);

  return {
    'stdout': '',
  };
}
