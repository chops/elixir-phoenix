import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');
const BASE_URL = __ENV.BASE_URL || 'http://localhost:4000';

export const options = {
  stages: [
    { duration: '2m', target: 100 }, // ramp up to 100 users
    { duration: '5m', target: 100 }, // stay at 100 users for 5 minutes
    { duration: '2m', target: 200 }, // ramp up to 200 users
    { duration: '5m', target: 200 }, // stay at 200 users for 5 minutes
    { duration: '2m', target: 0 },   // ramp down to 0 users
  ],
  thresholds: {
    errors: ['rate<0.05'],                                 // error rate must be less than 5%
    http_req_duration: ['p(95)<1000', 'p(99)<2000'],      // 95% < 1s, 99% < 2s
  },
};

export default function () {
  // Simulate user browsing products
  const productsRes = http.get(`${BASE_URL}/api/products`);
  const productsCheck = check(productsRes, {
    'products loaded': (r) => r.status === 200,
  });
  errorRate.add(!productsCheck);
  sleep(1);

  // Add item to cart
  const payload = JSON.stringify({
    product_id: Math.floor(Math.random() * 100) + 1,
    quantity: Math.floor(Math.random() * 3) + 1,
  });
  const params = {
    headers: { 'Content-Type': 'application/json' },
  };
  const cartRes = http.post(`${BASE_URL}/api/cart/items`, payload, params);
  const cartCheck = check(cartRes, {
    'item added to cart': (r) => r.status === 200 || r.status === 201,
  });
  errorRate.add(!cartCheck);
  sleep(2);

  // View cart
  const viewCartRes = http.get(`${BASE_URL}/api/cart`);
  const viewCartCheck = check(viewCartRes, {
    'cart viewed': (r) => r.status === 200,
  });
  errorRate.add(!viewCartCheck);
  sleep(1);
}
