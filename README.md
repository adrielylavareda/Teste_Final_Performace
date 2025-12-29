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

Arquivo: `test/k6/config/stages.js
