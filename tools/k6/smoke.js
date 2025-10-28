import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 1,
  duration: '1m',
  thresholds: {
    http_req_failed: ['rate<0.01'], // http errors should be less than 1%
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

export default function () {
  // Health check
  let healthRes = http.get(`${BASE_URL}/health`);
  check(healthRes, {
    'health check status is 200': (r) => r.status === 200,
  });

  sleep(1);

  // List products
  let productsRes = http.get(`${BASE_URL}/api/products`);
  check(productsRes, {
    'products status is 200': (r) => r.status === 200,
    'products response has data': (r) => r.json().data !== undefined,
  });

  sleep(1);
}
