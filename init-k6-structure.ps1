Write-Host "Criando estrutura de testes K6..."

New-Item -ItemType Directory -Force -Path `
test/k6/helpers, `
test/k6/data, `
test/k6/metrics, `
test/k6/config, `
test/k6/tests | Out-Null

# helpers
@"
import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export function registerUser(user) {
  const res = http.post(
    `${BASE_URL}/api/users/register`,
    JSON.stringify(user),
    { headers: { 'Content-Type': 'application/json' } }
  );

  check(res, {
    'user registered': (r) => r.status === 200 || r.status === 201,
  });
}

export function loginUser(email, password) {
  const res = http.post(
    `${BASE_URL}/api/users/login`,
    JSON.stringify({ email, password }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  check(res, {
    'login success': (r) => r.status === 200,
    'token returned': (r) => r.json('token') !== undefined,
  });

  return res.json('token');
}
"@ | Set-Content test/k6/helpers/auth.helper.js

# data
@"
[
  { "name": "User A", "email": "usera@test.com", "password": "123456" },
  { "name": "User B", "email": "userb@test.com", "password": "123456" }
]
"@ | Set-Content test/k6/data/users.json

# metrics
@"
import { Trend } from 'k6/metrics';

export const responseTimeTrend = new Trend('custom_response_time');
export const payloadSizeTrend = new Trend('custom_payload_size');
"@ | Set-Content test/k6/metrics/trends.js

# config
@"
export const stages = [
  { duration: '30s', target: 5 },
  { duration: '1m', target: 10 },
  { duration: '30s', target: 0 },
];

export const defaultThresholds = {
  http_req_duration: ['p(95)<1500'],
  checks: ['rate>0.95'],
};
"@ | Set-Content test/k6/config/stages.js

# test
@"
import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { stages, defaultThresholds } from '../config/stages.js';
import { responseTimeTrend, payloadSizeTrend } from '../metrics/trends.js';
import { registerUser, loginUser } from '../helpers/auth.helper.js';

const users = JSON.parse(open('test/k6/data/users.json'));
const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export const options = {
  stages,
  thresholds: {
    ...defaultThresholds,
    custom_response_time: ['p(95)<2000'],
  },
};

function fakerUser() {
  const id = Math.floor(Math.random() * 100000);
  return {
    name: `User ${id}`,
    email: `user${id}@test.com`,
    password: '123456',
  };
}

export default function () {
  const baseUser = users[__VU % users.length];
  const user = Math.random() > 0.5 ? fakerUser() : baseUser;

  group('Register User', () => {
    registerUser(user);
  });

  let token;

  group('Login User', () => {
    token = loginUser(user.email, user.password);
  });

  const headers = {
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  };

  group('Checkout', () => {
    const payload = JSON.stringify({
      items: [{ productId: 1, quantity: 1 }],
      freight: 20,
      paymentMethod: 'boleto',
    });

    const res = http.post(`${BASE_URL}/api/checkout`, payload, headers);

    check(res, {
      'checkout success': (r) => r.status === 200,
    });

    responseTimeTrend.add(res.timings.duration);
    payloadSizeTrend.add(res.body.length);
  });

  sleep(1);
}
"@ | Set-Content test/k6/tests/api.performance.test.js

Write-Host "Estrutura criada com sucesso!"
