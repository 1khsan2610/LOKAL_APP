#!/bin/bash

# Uptime Monitoring Setup Script
# Sets up health check endpoint dan monitoring configuration
# Target: >= 99.5% uptime per bulan (SRS Bab 5.4)

MONITORING_DIR="/app/storage/monitoring"
HEALTH_CHECK_LOG="$MONITORING_DIR/health-check.log"

# Create monitoring directory
mkdir -p "$MONITORING_DIR"

# Function to perform health check
health_check() {
    local endpoint="${1:-http://localhost/api/v1/test}"
    local timeout=10
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout $timeout "$endpoint")
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ "$response_code" == "200" ]; then
        echo "[$timestamp] ✓ Health check passed (HTTP $response_code)" >> "$HEALTH_CHECK_LOG"
        return 0
    else
        echo "[$timestamp] ✗ Health check failed (HTTP $response_code)" >> "$HEALTH_CHECK_LOG"
        return 1
    fi
}

# Function to calculate uptime percentage
calculate_uptime() {
    local log_file="${1:-$HEALTH_CHECK_LOG}"
    local days="${2:-30}"
    
    if [ ! -f "$log_file" ]; then
        echo "Log file not found: $log_file"
        return 1
    fi
    
    local total_checks=$(wc -l < "$log_file")
    local passed_checks=$(grep -c "passed" "$log_file")
    
    if [ $total_checks -eq 0 ]; then
        echo "No checks found"
        return 1
    fi
    
    local uptime_percent=$(echo "scale=2; ($passed_checks / $total_checks) * 100" | bc)
    echo "Uptime: ${uptime_percent}% (${passed_checks}/${total_checks} checks passed)"
}

# Run health check
health_check

# Output uptime statistics
if [ "$1" == "--stats" ]; then
    calculate_uptime
fi
