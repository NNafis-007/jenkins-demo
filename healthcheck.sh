#!/bin/bash

# Health Check Script for Express Demo Application

APP_URL="http://localhost:3000"
HEALTH_ENDPOINT="${APP_URL}/health"
CONTAINER_NAME="express-demo-app"
MAX_RETRIES=15
RETRY_INTERVAL=2

echo "======================================"
echo "Health Check Script"
echo "======================================"
echo "Container: ${CONTAINER_NAME}"
echo "Health Endpoint: ${HEALTH_ENDPOINT}"
echo ""

# Check if container is running
echo "→ Checking if container is running..."
if ! docker ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" | grep -q "${CONTAINER_NAME}"; then
    echo "✗ ERROR: Container '${CONTAINER_NAME}' is not running!"
    exit 1
fi
echo "✓ Container is running"

# Check health endpoint
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
    docker logs --tail 20 ${CONTAINER_NAME}
    exit 1
fi

# Test main endpoint
echo ""
echo "→ Testing main endpoint..."
MAIN_RESPONSE=$(curl -s "${APP_URL}/")
echo "✓ Main endpoint response: ${MAIN_RESPONSE}"

echo ""
echo "======================================"
echo "✓ HEALTH CHECK PASSED"
echo "======================================"
echo "Application URL: ${APP_URL}"
echo "Health Check URL: ${HEALTH_ENDPOINT}"
echo "Status: HEALTHY"
echo "======================================"

exit 0
