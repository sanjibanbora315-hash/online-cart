import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

// Stress test configuration - push the system to its limits
export const options = {
    stages: [
        { duration: '2m', target: 100 },   // Ramp up to 100 users
        { duration: '5m', target: 100 },   // Stay at 100 users
        { duration: '2m', target: 200 },   // Ramp up to 200 users
        { duration: '5m', target: 200 },   // Stay at 200 users
        { duration: '2m', target: 300 },   // Ramp up to 300 users
        { duration: '5m', target: 300 },   // Stay at 300 users
        { duration: '2m', target: 400 },   // Ramp up to 400 users
        { duration: '5m', target: 400 },   // Stay at 400 users
        { duration: '5m', target: 0 },     // Ramp down
    ],
    thresholds: {
        http_req_duration: ['p(99)<2000'], // 99% of requests must complete below 2s
        errors: ['rate<0.2'],               // Error rate must be less than 20%
    },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export default function () {
    // Mix of read operations (most common)
    const rand = Math.random();

    if (rand < 0.7) {
        // 70% - Product browsing
        const res = http.get(`${BASE_URL}/api/products`);
        check(res, { 'products status 200': (r) => r.status === 200 });
        errorRate.add(res.status !== 200);
    } else if (rand < 0.9) {
        // 20% - Health checks
        const res = http.get(`${BASE_URL}/actuator/health`);
        check(res, { 'health status 200': (r) => r.status === 200 });
        errorRate.add(res.status !== 200);
    } else {
        // 10% - Search
        const res = http.get(`${BASE_URL}/api/products/search?name=phone`);
        check(res, { 'search status 200': (r) => r.status === 200 });
        errorRate.add(res.status !== 200);
    }

    sleep(0.5);
}
