/**
 * Phase 3 Mastery Gate - GenServer + Supervision
 *
 * Validates GenServer performance and supervision resilience.
 *
 * Performance Targets:
 * - GenServer call: p95 < 5ms, p99 < 20ms
 * - GenServer cast: p95 < 1ms
 * - Throughput: 500+ calls/sec per GenServer
 * - Mailbox depth: < 100 messages under load
 * - Restart time: < 100ms after crash
 *
 * Usage:
 *   k6 run phase-03-gate.js
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter, Rate } from 'k6/metrics';
import exec from 'k6/execution';

// Custom metrics
const callDuration = new Trend('genserver_call_duration');
const castDuration = new Trend('genserver_cast_duration');
const throughput = new Counter('genserver_throughput');
const restartTime = new Trend('supervisor_restart_time');
const mailboxDepth = new Trend('mailbox_depth');
const crashRecoveryRate = new Rate('crash_recovery_success');

export const options = {
  scenarios: {
    genserver_calls: {
      executor: 'constant-arrival-rate',
      rate: 500,                    // 500 calls/sec target
      timeUnit: '1s',
      duration: '30s',
      preAllocatedVUs: 50,
      maxVUs: 100,
    },
    genserver_casts: {
      executor: 'constant-vus',
      vus: 20,
      duration: '30s',
      startTime: '35s',
    },
    crash_recovery: {
      executor: 'shared-iterations',
      vus: 1,
      iterations: 10,
      startTime: '70s',
      maxDuration: '30s',
    },
  },
  thresholds: {
    'genserver_call_duration': ['p(95)<5', 'p(99)<20'],
    'genserver_cast_duration': ['p(95)<1'],
    'genserver_throughput': ['count>15000'], // 500/sec * 30sec
    'mailbox_depth': ['p(95)<100'],
    'supervisor_restart_time': ['p(95)<100'],
    'crash_recovery_success': ['rate==1.0'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

export default function () {
  const scenario = exec.scenario.name;

  if (scenario === 'genserver_calls') {
    testGenServerCall();
  } else if (scenario === 'genserver_casts') {
    testGenServerCast();
  } else if (scenario === 'crash_recovery') {
    testCrashRecovery();
  }
}

function testGenServerCall() {
  const startTime = Date.now();

  const res = http.post(`${BASE_URL}/api/counter/increment`, JSON.stringify({ amount: 1 }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'genserver_call' },
  });

  const duration = Date.now() - startTime;
  callDuration.add(duration);
  throughput.add(1);

  check(res, {
    'call status is 200': (r) => r.status === 200,
    'call under 5ms': () => duration < 5,
  });

  // Track mailbox depth from response header
  if (res.headers['X-Mailbox-Depth']) {
    mailboxDepth.add(parseInt(res.headers['X-Mailbox-Depth']));
  }
}

function testGenServerCast() {
  const startTime = Date.now();

  const res = http.post(`${BASE_URL}/api/counter/increment_async`, JSON.stringify({ amount: 1 }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'genserver_cast' },
  });

  const duration = Date.now() - startTime;
  castDuration.add(duration);

  check(res, {
    'cast status is 202': (r) => r.status === 202,
    'cast under 1ms': () => duration < 1,
  });
}

function testCrashRecovery() {
  console.log('Testing GenServer crash recovery...');

  // Kill the GenServer
  const killRes = http.post(`${BASE_URL}/api/counter/kill`, null, {
    tags: { name: 'kill_genserver' },
  });

  check(killRes, {
    'kill accepted': (r) => r.status === 202,
  });

  // Wait for supervisor restart
  const restartStart = Date.now();
  let recovered = false;

  // Poll for recovery (max 5 seconds)
  for (let i = 0; i < 50; i++) {
    sleep(0.1);

    const healthRes = http.get(`${BASE_URL}/api/counter/health`, {
      tags: { name: 'health_check' },
    });

    if (healthRes.status === 200) {
      const restartDuration = Date.now() - restartStart;
      restartTime.add(restartDuration);
      recovered = true;

      console.log(`  Recovered in ${restartDuration}ms`);

      const passedRestartTime = restartDuration < 100;
      check({ restart: 'complete' }, {
        'restart under 100ms': () => passedRestartTime,
      });

      break;
    }
  }

  crashRecoveryRate.add(recovered ? 1 : 0);

  if (!recovered) {
    console.log('  FAILED to recover within 5 seconds');
  }
}

export function handleSummary(data) {
  console.log('\n=== Phase 3 Mastery Gate Summary ===');

  const callP95 = data.metrics.genserver_call_duration?.values['p(95)'] || 0;
  const callP99 = data.metrics.genserver_call_duration?.values['p(99)'] || 0;
  const castP95 = data.metrics.genserver_cast_duration?.values['p(95)'] || 0;
  const totalCalls = data.metrics.genserver_throughput?.values.count || 0;
  const mailboxP95 = data.metrics.mailbox_depth?.values['p(95)'] || 0;
  const restartP95 = data.metrics.supervisor_restart_time?.values['p(95)'] || 0;
  const recoveryRate = data.metrics.crash_recovery_success?.values.rate || 0;

  console.log(`Call p95: ${callP95.toFixed(2)}ms (target: <5ms)`);
  console.log(`Call p99: ${callP99.toFixed(2)}ms (target: <20ms)`);
  console.log(`Cast p95: ${castP95.toFixed(2)}ms (target: <1ms)`);
  console.log(`Throughput: ${totalCalls} calls (target: >15000)`);
  console.log(`Mailbox p95: ${mailboxP95.toFixed(0)} messages (target: <100)`);
  console.log(`Restart p95: ${restartP95.toFixed(2)}ms (target: <100ms)`);
  console.log(`Recovery rate: ${(recoveryRate * 100).toFixed(1)}% (target: 100%)`);

  const passed = callP95 < 5 && callP99 < 20 && castP95 < 1 &&
                 totalCalls > 15000 && mailboxP95 < 100 &&
                 restartP95 < 100 && recoveryRate === 1.0;

  console.log(`\nPhase 3 Gate: ${passed ? 'PASSED ✓' : 'FAILED ✗'}`);

  return { 'stdout': '' };
}
