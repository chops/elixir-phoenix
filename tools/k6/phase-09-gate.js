/**
 * Phase 9 Mastery Gate - Distribution & Clustering
 *
 * Validates distributed system resilience with node failures and network partitions.
 * Run this test while executing chaos drills (kill nodes, partition network).
 *
 * Performance Targets:
 * - Cluster formation: < 10 sec for 10 nodes
 * - RPC call: p95 < 20ms cross-node
 * - Shard lookup: p95 < 5ms via consistent hashing
 * - Failover: < 5 sec to detect node down and reroute
 * - Throughput: 10K+ cross-node messages/sec
 * - Error rate during node kill: < 1%
 *
 * Usage:
 *   k6 run phase-09-gate.js
 *
 * Chaos Drills (run in separate terminal):
 *   bash tools/gameday/kill-node.sh &
 *   bash tools/gameday/partition-network.sh &
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend, Counter, Rate, Gauge } from 'k6/metrics';
import exec from 'k6/execution';

// Custom metrics
const rpcDuration = new Trend('rpc_call_duration');
const shardLookupDuration = new Trend('shard_lookup_duration');
const failoverDuration = new Trend('failover_duration');
const crossNodeThroughput = new Counter('cross_node_messages');
const errorRate = new Rate('request_errors');
const nodesAlive = new Gauge('nodes_alive');

export const options = {
  scenarios: {
    steady_state: {
      executor: 'constant-arrival-rate',
      rate: 1000,                   // 1000 RPS
      timeUnit: '1s',
      duration: '5m',
      preAllocatedVUs: 50,
      maxVUs: 200,
    },
    chaos_injection: {
      executor: 'shared-iterations',
      vus: 1,
      iterations: 5,                 // Kill node 5 times
      startTime: '1m',
      maxDuration: '4m',
    },
  },
  thresholds: {
    'rpc_call_duration': ['p(95)<20'],
    'shard_lookup_duration': ['p(95)<5'],
    'failover_duration': ['p(95)<5000'], // < 5 sec
    'cross_node_messages': ['count>300000'], // 1000/sec * 5min
    'request_errors': ['rate<0.01'],         // < 1% error rate
    'nodes_alive': ['min>=2'],               // At least 2 nodes always alive
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';
const NODES = [
  'http://node1:4000',
  'http://node2:4000',
  'http://node3:4000',
  'http://node4:4000',
  'http://node5:4000',
];

export default function () {
  const scenario = exec.scenario.name;

  if (scenario === 'steady_state') {
    testDistributedOperations();
  } else if (scenario === 'chaos_injection') {
    injectChaos();
  }
}

function testDistributedOperations() {
  // Test shard lookup
  const key = `user_${__VU}_${exec.vu.iterationInScenario}`;
  const shardStart = Date.now();

  const shardRes = http.get(`${BASE_URL}/api/cluster/shard?key=${key}`, {
    tags: { name: 'shard_lookup' },
  });

  const shardDuration = Date.now() - shardStart;
  shardLookupDuration.add(shardDuration);

  let targetNode = BASE_URL;
  const shardSuccess = check(shardRes, {
    'shard lookup successful': (r) => r.status === 200,
    'shard lookup under 5ms': () => shardDuration < 5,
  });

  if (shardSuccess) {
    try {
      const shardBody = JSON.parse(shardRes.body);
      targetNode = shardBody.node_url;
    } catch (e) {
      errorRate.add(1);
      return;
    }
  }

  // Test cross-node RPC call
  const rpcStart = Date.now();

  const rpcRes = http.post(`${targetNode}/api/cluster/rpc`, JSON.stringify({
    key: key,
    operation: 'increment',
    value: 1,
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'rpc_call' },
  });

  const rpcDuration = Date.now() - rpcStart;
  rpcDuration.add(rpcDuration);
  crossNodeThroughput.add(1);

  const rpcSuccess = check(rpcRes, {
    'rpc successful': (r) => r.status === 200,
    'rpc under 20ms': () => rpcDuration < 20,
  });

  if (!rpcSuccess) {
    errorRate.add(1);
  } else {
    errorRate.add(0);
  }

  // Track cluster health
  if (__ITER % 100 === 0) {
    checkClusterHealth();
  }

  sleep(0.01); // Small delay between requests
}

function injectChaos() {
  console.log('=== CHAOS INJECTION: Killing random node ===');

  // Select random node to kill
  const nodeIndex = Math.floor(Math.random() * NODES.length);
  const targetNode = NODES[nodeIndex];

  const failoverStart = Date.now();

  // Kill node
  const killRes = http.post(`${targetNode}/api/cluster/kill`, null, {
    tags: { name: 'kill_node' },
    timeout: '2s',
  });

  console.log(`Killed node: ${targetNode}`);

  // Wait for cluster to detect failure and reroute
  let recovered = false;
  for (let i = 0; i < 100; i++) {
    sleep(0.05);

    // Try to access data that was on killed node
    const testRes = http.get(`${BASE_URL}/api/cluster/health`, {
      tags: { name: 'health_check' },
    });

    if (testRes.status === 200) {
      try {
        const health = JSON.parse(testRes.body);
        if (health.nodes_available >= 2) {
          const failoverTime = Date.now() - failoverStart;
          failoverDuration.add(failoverTime);
          recovered = true;

          console.log(`  Cluster recovered in ${failoverTime}ms`);

          check({ failover: 'complete' }, {
            'failover under 5 sec': () => failoverTime < 5000,
          });

          break;
        }
      } catch (e) {
        // Continue checking
      }
    }
  }

  if (!recovered) {
    console.log('  WARNING: Cluster did not recover within 5 seconds');
    failoverDuration.add(5000);
  }

  // Wait before next chaos injection
  sleep(30);
}

function checkClusterHealth() {
  const healthRes = http.get(`${BASE_URL}/api/cluster/health`, {
    tags: { name: 'cluster_health' },
  });

  if (healthRes.status === 200) {
    try {
      const health = JSON.parse(healthRes.body);
      nodesAlive.add(health.nodes_available);
    } catch (e) {
      nodesAlive.add(0);
    }
  }
}

export function handleSummary(data) {
  console.log('\n=== Phase 9 Mastery Gate Summary ===');

  const rpcP95 = data.metrics.rpc_call_duration?.values['p(95)'] || 0;
  const shardP95 = data.metrics.shard_lookup_duration?.values['p(95)'] || 0;
  const failoverP95 = data.metrics.failover_duration?.values['p(95)'] || 0;
  const totalMessages = data.metrics.cross_node_messages?.values.count || 0;
  const errRate = data.metrics.request_errors?.values.rate || 0;
  const minNodes = data.metrics.nodes_alive?.values.min || 0;

  console.log(`RPC p95: ${rpcP95.toFixed(2)}ms (target: <20ms)`);
  console.log(`Shard lookup p95: ${shardP95.toFixed(2)}ms (target: <5ms)`);
  console.log(`Failover p95: ${(failoverP95 / 1000).toFixed(2)}s (target: <5s)`);
  console.log(`Total cross-node messages: ${totalMessages} (target: >300000)`);
  console.log(`Error rate: ${(errRate * 100).toFixed(2)}% (target: <1%)`);
  console.log(`Min nodes alive: ${minNodes} (target: >=2)`);

  const passed = rpcP95 < 20 && shardP95 < 5 && failoverP95 < 5000 &&
                 totalMessages > 300000 && errRate < 0.01 && minNodes >= 2;

  console.log(`\nPhase 9 Gate: ${passed ? 'PASSED ✓' : 'FAILED ✗'}`);

  if (!passed && errRate >= 0.01) {
    console.log('\nWARNING: Error rate exceeded 1% - cluster may not be handling failures gracefully');
  }

  return { 'stdout': '' };
}
