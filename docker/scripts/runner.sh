#!/bin/bash
set -e

# KodeCD Runner Script
# This script runs the CI/CD runner in Docker

echo "Starting KodeCD Runner..."

# Wait for web service to be ready
echo "Waiting for KodeCD web service..."
until curl -f http://web:3000/health > /dev/null 2>&1; do
    echo "Web service not ready yet, waiting..."
    sleep 5
done

echo "Web service is ready!"

# Load configuration
CONFIG_FILE="/etc/kodecd-runner/config.toml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Runner configuration not found at $CONFIG_FILE"
    exit 1
fi

# Runner main loop
echo "Runner started and waiting for jobs..."
echo "Runner Name: ${RUNNER_NAME:-docker-runner-1}"
echo "KodeCD URL: ${KODECD_URL}"
echo "Concurrent Jobs: ${RUNNER_CONCURRENT_JOBS:-4}"

# Simple polling loop (in production, this would be a proper runner implementation)
while true; do
    # Poll for jobs from the API
    # This is a placeholder - actual implementation would use the KodeCD API
    # to fetch and execute jobs

    # For now, just keep the container running
    sleep 30

    # Health check - make sure web service is still reachable
    if ! curl -f http://web:3000/health > /dev/null 2>&1; then
        echo "WARNING: Cannot reach web service"
    fi
done
