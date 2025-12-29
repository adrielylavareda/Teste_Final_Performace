import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { stages, defaultThresholds } from '../config/stages.js';
import { responseTimeTrend, payloadSizeTrend } from '../metrics/trends.js';
import { registerUser, loginUser } from '../helpers/auth.helper.js';

// Importação do gerador de relatório HTML
import { htmlReport } from "../helpers/bundle.js";

// O caminho do open é relativo a onde você executa o k6
const users = JSON.parse(open('../data/users.json'));
const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export const options = {
  stages,
  thresholds: {
    ...defaultThresholds,
    custom_response_time: ['p(95)<2000'],
  },
};

function fakerUser() {
  const id = Math.floor(Math.random() * 1000000);
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

    check(res, { 'checkout success': (r) => r.status === 200 });

    responseTimeTrend.add(res.timings.duration);
    payloadSizeTrend.add(res.body.length);
  });

  sleep(1);
}

// Esta função cria o arquivo HTML após o término do teste
export function handleSummary(data) {
  return {
    "summary.html": htmlReport(data),
  };
}