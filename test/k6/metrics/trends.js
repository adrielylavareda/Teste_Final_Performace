import { Trend } from 'k6/metrics';

export const responseTimeTrend = new Trend('custom_response_time');
export const payloadSizeTrend = new Trend('custom_payload_size');
