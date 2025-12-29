export const stages = [
  { duration: '30s', target: 5 },
  { duration: '1m', target: 10 },
  { duration: '30s', target: 0 },
];

export const defaultThresholds = {
  http_req_duration: ['p(95)<1500'],
  checks: ['rate>0.95'],
};
