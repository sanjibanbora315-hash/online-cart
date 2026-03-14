import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const productListTrend = new Trend('product_list_duration');
const orderCreateTrend = new Trend('order_create_duration');

// Test configuration
export const options = {
    stages: [
        { duration: '30s', target: 10 },   // Ramp up to 10 users
        { duration: '1m', target: 10 },    // Stay at 10 users
        { duration: '30s', target: 50 },   // Ramp up to 50 users
        { duration: '1m', target: 50 },    // Stay at 50 users
        { duration: '30s', target: 100 },  // Ramp up to 100 users
        { duration: '1m', target: 100 },   // Stay at 100 users
        { duration: '30s', target: 0 },    // Ramp down
    ],
    thresholds: {
        http_req_duration: ['p(95)<500'],  // 95% of requests must complete below 500ms
        errors: ['rate<0.1'],               // Error rate must be less than 10%
    },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

// Helper function for headers
function getHeaders() {
    return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    };
}

export default function () {

    group('Health Checks', function () {
        const healthRes = http.get(`${BASE_URL}/actuator/health`);
        check(healthRes, {
            'health check status is 200': (r) => r.status === 200,
            'health status is UP': (r) => r.json('status') === 'UP',
        });
        errorRate.add(healthRes.status !== 200);
    });

    group('Product Operations', function () {
        // Get all products
        const startTime = Date.now();
        const productsRes = http.get(`${BASE_URL}/api/products`);
        productListTrend.add(Date.now() - startTime);

        const productsOk = check(productsRes, {
            'products list status is 200': (r) => r.status === 200,
            'products list is array': (r) => Array.isArray(r.json()),
        });
        errorRate.add(!productsOk);

        // Get single product if products exist
        if (productsRes.status === 200 && productsRes.json().length > 0) {
            const productId = productsRes.json()[0].id;
            const productRes = http.get(`${BASE_URL}/api/products/${productId}`);
            check(productRes, {
                'single product status is 200': (r) => r.status === 200,
                'product has id': (r) => r.json('id') !== undefined,
            });
        }

        // Search products
        const searchRes = http.get(`${BASE_URL}/api/products/search?name=phone`);
        check(searchRes, {
            'search status is 200': (r) => r.status === 200,
        });
    });

    sleep(1);

    group('User Operations', function () {
        // Register a user with unique email
        const uniqueId = `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
        const registerPayload = JSON.stringify({
            username: `loadtest_${uniqueId}`,
            email: `loadtest_${uniqueId}@example.com`,
            password: 'LoadTest123!',
            firstName: 'Load',
            lastName: 'Test',
        });

        const registerRes = http.post(
            `${BASE_URL}/api/users/register`,
            registerPayload,
            { headers: getHeaders() }
        );

        const registerOk = check(registerRes, {
            'register status is 200 or 201': (r) => r.status === 200 || r.status === 201,
        });
        errorRate.add(!registerOk);

        // Get user if registration successful
        if (registerRes.status === 200 || registerRes.status === 201) {
            const userId = registerRes.json('id');
            if (userId) {
                const userRes = http.get(`${BASE_URL}/api/users/${userId}`);
                check(userRes, {
                    'get user status is 200': (r) => r.status === 200,
                });

                // Cleanup - delete the test user
                http.del(`${BASE_URL}/api/users/${userId}`);
            }
        }
    });

    sleep(1);
}

// Separate scenario for order load testing
export function orderLoadTest() {
    group('Order Operations', function () {
        // This requires existing user and product
        const userId = 1;
        const productId = 1;

        // Add to cart
        const cartPayload = JSON.stringify({
            userId: userId,
            productId: productId,
            quantity: 1,
        });

        const cartRes = http.post(
            `${BASE_URL}/api/orders/cart/items`,
            cartPayload,
            { headers: getHeaders() }
        );

        check(cartRes, {
            'add to cart successful': (r) => r.status === 200 || r.status === 201,
        });

        // Create order
        const orderPayload = JSON.stringify({
            userId: userId,
            shippingAddress: '123 Load Test Street',
            paymentMethod: 'CREDIT_CARD',
        });

        const startTime = Date.now();
        const orderRes = http.post(
            `${BASE_URL}/api/orders`,
            orderPayload,
            { headers: getHeaders() }
        );
        orderCreateTrend.add(Date.now() - startTime);

        check(orderRes, {
            'order created successfully': (r) => r.status === 200 || r.status === 201,
        });
    });

    sleep(2);
}
