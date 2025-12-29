import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export function registerUser(user) {
  const res = http.post(
    `${BASE_URL}/api/users/register`, // Usei crases aqui
    JSON.stringify(user),
    { headers: { 'Content-Type': 'application/json' } }
  );

  check(res, {
    'user registered': (r) => r.status === 200 || r.status === 201,
  });
}

export function loginUser(email, password) {
  const res = http.post(
    `${BASE_URL}/api/users/login`, // Usei crases aqui
    JSON.stringify({ email, password }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  check(res, {
    'login success': (r) => r.status === 200,
    'token returned': (r) => r.json('token') !== undefined,
  });

  return res.json('token');
}