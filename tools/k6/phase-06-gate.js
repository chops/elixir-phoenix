/**
 * Phase 6 Mastery Gate - Phoenix Web
 *
 * Validates Phoenix/LiveView performance under concurrent load.
 *
 * Performance Targets:
 * - HTTP request: p95 < 50ms
 * - JSON API: p95 < 100ms
 * - LiveView mount: p95 < 150ms
 * - LiveView patch: p95 < 50ms
 * - WebSocket messages: p95 < 100ms
 * - Concurrent connections: 1000+ LiveView, 5000+ WebSocket
 * - Memory per LiveView: < 50KB
 *
 * Usage:
 *   k6 run phase-06-gate.js
 */

import http from 'k6/http';
import ws from 'k6/ws';
import { check, sleep } from 'k6';
import { Trend, Counter, Gauge } from 'k6/metrics';
import exec from 'k6/execution';

// Custom metrics
const httpDuration = new Trend('http_request_duration');
const apiDuration = new Trend('json_api_duration');
const liveViewMountDuration = new Trend('liveview_mount_duration');
const liveViewPatchDuration = new Trend('liveview_patch_duration');
const websocketMsgDuration = new Trend('websocket_msg_duration');
const concurrentLiveViews = new Gauge('concurrent_liveviews');
const concurrentWebSockets = new Gauge('concurrent_websockets');
const memoryPerLiveView = new Trend('memory_per_liveview_kb');

export const options = {
  scenarios: {
    http_requests: {
      executor: 'ramping-vus',
      startVUs: 10,
      stages: [
        { duration: '30s', target: 100 },
        { duration: '1m', target: 100 },
        { duration: '20s', target: 0 },
      ],
    },
    liveview_connections: {
      executor: 'ramping-vus',
      startVUs: 100,
      stages: [
        { duration: '1m', target: 1000 },
        { duration: '2m', target: 1000 },
        { duration: '30s', target: 0 },
      ],
      startTime: '2m',
    },
    websocket_messaging: {
      executor: 'constant-vus',
      vus: 500,
      duration: '2m',
      startTime: '5m',
    },
  },
  thresholds: {
    'http_request_duration': ['p(95)<50'],
    'json_api_duration': ['p(95)<100'],
    'liveview_mount_duration': ['p(95)<150'],
    'liveview_patch_duration': ['p(95)<50'],
    'websocket_msg_duration': ['p(95)<100'],
    'concurrent_liveviews': ['value>=1000'],
    'concurrent_websockets': ['value>=5000'],
    'memory_per_liveview_kb': ['avg<50'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';
const WS_URL = BASE_URL.replace('http://', 'ws://');

export default function () {
  const scenario = exec.scenario.name;

  if (scenario === 'http_requests') {
    testHTTPRequests();
  } else if (scenario === 'liveview_connections') {
    testLiveViewConnection();
  } else if (scenario === 'websocket_messaging') {
    testWebSocketMessaging();
  }
}

function testHTTPRequests() {
  // Test static HTTP request
  const httpStart = Date.now();
  const httpRes = http.get(`${BASE_URL}/`, {
    tags: { name: 'http_static' },
  });
  httpDuration.add(Date.now() - httpStart);

  check(httpRes, {
    'http status 200': (r) => r.status === 200,
    'http under 50ms': () => (Date.now() - httpStart) < 50,
  });

  sleep(0.5);

  // Test JSON API
  const apiStart = Date.now();
  const apiRes = http.get(`${BASE_URL}/api/products`, {
    headers: { 'Accept': 'application/json' },
    tags: { name: 'json_api' },
  });
  apiDuration.add(Date.now() - apiStart);

  check(apiRes, {
    'api status 200': (r) => r.status === 200,
    'api returns json': (r) => r.headers['Content-Type'].includes('application/json'),
    'api under 100ms': () => (Date.now() - apiStart) < 100,
  });

  sleep(1);
}

function testLiveViewConnection() {
  const mountStart = Date.now();

  // Connect to LiveView
  const res = http.get(`${BASE_URL}/products`, {
    tags: { name: 'liveview_mount' },
  });

  const mountDuration = Date.now() - mountStart;
  liveViewMountDuration.add(mountDuration);

  const mounted = check(res, {
    'liveview mounted': (r) => r.status === 200 && r.body.includes('phx-'),
    'mount under 150ms': () => mountDuration < 150,
  });

  if (mounted) {
    concurrentLiveViews.add(1);

    // Track memory usage from response header
    if (res.headers['X-LiveView-Memory-KB']) {
      memoryPerLiveView.add(parseFloat(res.headers['X-LiveView-Memory-KB']));
    }

    // Simulate LiveView patch (filter products)
    sleep(2);

    const patchStart = Date.now();
    const patchRes = http.post(`${BASE_URL}/products/filter`, JSON.stringify({
      category: 'electronics',
    }), {
      headers: { 'Content-Type': 'application/json' },
      tags: { name: 'liveview_patch' },
    });

    const patchDuration = Date.now() - patchStart;
    liveViewPatchDuration.add(patchDuration);

    check(patchRes, {
      'patch applied': (r) => r.status === 200,
      'patch under 50ms': () => patchDuration < 50,
    });

    sleep(5); // Keep connection alive
  }

  concurrentLiveViews.add(-1);
}

function testWebSocketMessaging() {
  const url = `${WS_URL}/socket/websocket`;

  const response = ws.connect(url, {}, function (socket) {
    concurrentWebSockets.add(1);

    socket.on('open', () => {
      // Join channel
      socket.send(JSON.stringify({
        topic: 'room:lobby',
        event: 'phx_join',
        payload: {},
        ref: '1',
      }));
    });

    socket.on('message', (data) => {
      const msg = JSON.parse(data);

      if (msg.event === 'phx_reply') {
        // Send message after join
        const msgStart = Date.now();

        socket.send(JSON.stringify({
          topic: 'room:lobby',
          event: 'new_msg',
          payload: { body: 'Hello from k6' },
          ref: '2',
        }));

        // Measure round-trip time for broadcast
        socket.on('message', (broadcastData) => {
          const broadcastMsg = JSON.parse(broadcastData);

          if (broadcastMsg.event === 'new_msg') {
            const msgDuration = Date.now() - msgStart;
            websocketMsgDuration.add(msgDuration);

            check({ msg: 'broadcast' }, {
              'message broadcasted': () => true,
              'message under 100ms': () => msgDuration < 100,
            });
          }
        });
      }
    });

    socket.on('close', () => {
      concurrentWebSockets.add(-1);
    });

    sleep(10); // Keep connection alive
  });

  check(response, {
    'websocket connected': (r) => r && r.status === 101,
  });
}

export function handleSummary(data) {
  console.log('\n=== Phase 6 Mastery Gate Summary ===');

  const httpP95 = data.metrics.http_request_duration?.values['p(95)'] || 0;
  const apiP95 = data.metrics.json_api_duration?.values['p(95)'] || 0;
  const mountP95 = data.metrics.liveview_mount_duration?.values['p(95)'] || 0;
  const patchP95 = data.metrics.liveview_patch_duration?.values['p(95)'] || 0;
  const wsP95 = data.metrics.websocket_msg_duration?.values['p(95)'] || 0;
  const maxLiveViews = data.metrics.concurrent_liveviews?.values.max || 0;
  const maxWebSockets = data.metrics.concurrent_websockets?.values.max || 0;
  const avgMemory = data.metrics.memory_per_liveview_kb?.values.avg || 0;

  console.log(`HTTP p95: ${httpP95.toFixed(2)}ms (target: <50ms)`);
  console.log(`API p95: ${apiP95.toFixed(2)}ms (target: <100ms)`);
  console.log(`LiveView mount p95: ${mountP95.toFixed(2)}ms (target: <150ms)`);
  console.log(`LiveView patch p95: ${patchP95.toFixed(2)}ms (target: <50ms)`);
  console.log(`WebSocket msg p95: ${wsP95.toFixed(2)}ms (target: <100ms)`);
  console.log(`Max concurrent LiveViews: ${maxLiveViews} (target: >=1000)`);
  console.log(`Max concurrent WebSockets: ${maxWebSockets} (target: >=5000)`);
  console.log(`Avg memory per LiveView: ${avgMemory.toFixed(2)}KB (target: <50KB)`);

  const passed = httpP95 < 50 && apiP95 < 100 && mountP95 < 150 &&
                 patchP95 < 50 && wsP95 < 100 && maxLiveViews >= 1000 &&
                 maxWebSockets >= 5000 && avgMemory < 50;

  console.log(`\nPhase 6 Gate: ${passed ? 'PASSED ✓' : 'FAILED ✗'}`);

  return { 'stdout': '' };
}
