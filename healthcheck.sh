#!/bin/bash

# Health Check Script for Express CI Demo Application
# This script verifies the application container is running and healthy

set -e

APP_URL="http://localhost:3000"
HEALTH_ENDPOINT="${APP_URL}/health"
CONTAINER_NAME="express-ci-demo"
MAX_RETRIES=15
RETRY_INTERVAL=2

echo "======================================"
echo "Starting Health Check"
echo "======================================"
echo "Container: ${CONTAINER_NAME}"
echo "Health Endpoint: ${HEALTH_ENDPOINT}"
echo ""

# Check if container is running
echo "→ Checking if container is running..."
if ! docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "${CONTAINER_NAME}"; then
    echo "✗ ERROR: Container '${CONTAINER_NAME}' is not running!"
    echo ""
    echo "Available containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}"
    exit 1
fi
echo "✓ Container is running"

# Check container health status
echo ""
echo "→ Checking Docker health status..."
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' ${CONTAINER_NAME} 2>/dev/null || echo "none")
echo "  Docker Health Status: ${HEALTH_STATUS}"

# Try to reach the health endpoint
echo ""
echo "→ Testing health endpoint (max retries: ${MAX_RETRIES})..."
SUCCESS=false

for i in $(seq 1 $MAX_RETRIES); do
    echo "  Attempt $i/$MAX_RETRIES..."
    
    if curl -sf "${HEALTH_ENDPOINT}" > /dev/null 2>&1; then
        RESPONSE=$(curl -s "${HEALTH_ENDPOINT}")
        echo "✓ Health endpoint responded successfully!"
        echo "  Response: ${RESPONSE}"
        SUCCESS=true
        break
    else
        echo "  × Health check failed, retrying in ${RETRY_INTERVAL}s..."
        sleep $RETRY_INTERVAL
    fi
done

if [ "$SUCCESS" = false ]; then
    echo ""
    echo "✗ ERROR: Health check failed after ${MAX_RETRIES} attempts!"
    echo ""
    echo "Container logs (last 20 lines):"
    echo "======================================"
    docker logs --tail 20 ${CONTAINER_NAME}
    echo "======================================"
    exit 1
fi

# Test main endpoint
echo ""
echo "→ Testing main endpoint..."
MAIN_RESPONSE=$(curl -s "${APP_URL}/")
if echo "${MAIN_RESPONSE}" | grep -q "Hello World"; then
    echo "✓ Main endpoint is responding correctly"
    echo "  Response: ${MAIN_RESPONSE}"
else
    echo "✗ WARNING: Main endpoint response unexpected"
    echo "  Response: ${MAIN_RESPONSE}"
fi

# Display container info
echo ""
echo "======================================"
echo "Container Information"
echo "======================================"
docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "======================================"
echo "✓ HEALTH CHECK PASSED"
echo "======================================"
echo "Application Status: HEALTHY"
echo "Application URL: ${APP_URL}"
echo "Health Check URL: ${HEALTH_ENDPOINT}"
echo "======================================"

exit 0
