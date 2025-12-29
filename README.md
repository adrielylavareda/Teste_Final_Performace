# 📊 Testes de Performance com K6 – API

Este repositório contém um projeto de **testes automatizados de performance utilizando o K6**, desenvolvido como parte do desafio do curso.
O objetivo é exercitar uma API REST aplicando conceitos fundamentais de testes de performance, organização de código e boas práticas.

---

## 📁 Estrutura do Projeto

```bash
test/
└── k6/
    ├── config/
    │   └── stages.js
    ├── data/
    │   └── users.json
    ├── helpers/
    │   └── auth.helper.js
    ├── metrics/
    │   └── trends.js
    └── tests/
        └── api.performance.test.js
```

---

## 🚀 Execução do Teste

```bash
BASE_URL=http://localhost:3000 k6 run test/k6/tests/api.performance.test.js
```

> O relatório HTML de execução pode ser gerado utilizando o **k6-reporter** ou integração equivalente conforme configuração do ambiente.

---

## 🧠 Conceitos Aplicados (com evidência no código)

### ✅ 1. Stages (Carga Progressiva)

Arquivo: `test/k6/config/stages.js`

```javascript
export const stages = [
  { duration: '30s', target: 5 },
  { duration: '1m', target: 10 },
  { duration: '30s', target: 0 },
];
```

Define o aumento e redução gradual de usuários virtuais durante o teste.

---

### ✅ 2. Thresholds (Critérios de Aceitação)

Arquivo: `test/k6/config/stages.js`

```javascript
export const defaultThresholds = {
  http_req_duration: ['p(95)<1500'],
  checks: ['rate>0.95'],
};
```

Aplicação no teste:

```javascript
export const options = {
  stages,
  thresholds: {
    ...defaultThresholds,
    custom_response_time: ['p(95)<2000'],
  },
};
```

---

### ✅ 3. Checks (Validações de Resposta)

```javascript
check(res, {
  'checkout success': (r) => r.status === 200,
});
```

---

### ✅ 4. Helpers (Reaproveitamento de Código)

Arquivo: `test/k6/helpers/auth.helper.js`

```javascript
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
```

---

### ✅ 5. Uso de Token de Autenticação

```javascript
const token = loginUser(user.email, user.password);

const headers = {
  headers: {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
  },
};
```

---

### ✅ 6. Groups (Organização dos Cenários)

```javascript
group('Checkout API', function () {
  // fluxo de checkout
});
```

---

### ✅ 7. Data-Driven Testing

Arquivo: `test/k6/data/users.json`

```json
[
  { "name": "User A", "email": "usera@test.com", "password": "123456" },
  { "name": "User B", "email": "userb@test.com", "password": "123456" }
]
```

Uso no teste:

```javascript
const users = JSON.parse(open('test/k6/data/users.json'));
const user = users[Math.floor(Math.random() * users.length)];
```

---

### ✅ 8. Variável de Ambiente

```javascript
const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';
```

---

### ✅ 9. Trends (Métricas Customizadas)

Arquivo: `test/k6/metrics/trends.js`

```javascript
import { Trend } from 'k6/metrics';

export const responseTimeTrend = new Trend('custom_response_time');
export const payloadSizeTrend = new Trend('custom_payload_size');
```

Uso no teste:

```javascript
responseTimeTrend.add(res.timings.duration);
payloadSizeTrend.add(res.body.length);
```

---

### ✅ 10. Reaproveitamento de Resposta

```javascript
const token = res.json('token');
```

---

## 📌 Conclusão

Este projeto atende aos requisitos do desafio proposto, demonstrando a aplicação prática dos principais conceitos de **testes de performance com K6**, com código organizado, reutilizável e bem documentado.
