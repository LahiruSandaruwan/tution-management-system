#!/bin/bash
# Health Endpoints Verification Script
# Verifies all health check endpoints are working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="${BASE_URL:-http://localhost:8000}"
VERBOSE="${VERBOSE:-false}"

# Function to log messages
log_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Function to test endpoint
test_endpoint() {
    local name="$1"
    local url="$2"
    local expected_status="${3:-200}"
    local check_keyword="$4"

    echo -n "Testing $name... "

    # Make request and capture response
    response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null || echo "000")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    # Check HTTP status code
    if [ "$http_code" -eq "$expected_status" ]; then
        # Check for keyword if provided
        if [ -n "$check_keyword" ]; then
            if echo "$body" | grep -q "$check_keyword"; then
                log_info "PASS (HTTP $http_code, keyword found)"
                if [ "$VERBOSE" = "true" ]; then
                    echo "Response: $body" | head -c 200
                    echo ""
                fi
                return 0
            else
                log_error "FAIL (HTTP $http_code, keyword '$check_keyword' not found)"
                echo "Response: $body"
                return 1
            fi
        else
            log_info "PASS (HTTP $http_code)"
            if [ "$VERBOSE" = "true" ]; then
                echo "Response: $body" | head -c 200
                echo ""
            fi
            return 0
        fi
    else
        log_error "FAIL (Expected HTTP $expected_status, got $http_code)"
        echo "Response: $body"
        return 1
    fi
}

# Function to test response time
test_response_time() {
    local name="$1"
    local url="$2"
    local max_time="$3"  # in milliseconds

    echo -n "Testing $name response time... "

    # Measure response time
    response_time=$(curl -o /dev/null -s -w '%{time_total}' "$url" 2>/dev/null || echo "999")
    response_time_ms=$(echo "$response_time * 1000" | bc | cut -d'.' -f1)

    if [ "$response_time_ms" -lt "$max_time" ]; then
        log_info "PASS (${response_time_ms}ms < ${max_time}ms)"
        return 0
    else
        log_warning "SLOW (${response_time_ms}ms > ${max_time}ms)"
        return 1
    fi
}

# Start verification
log_section "Health Endpoints Verification"
echo "Base URL: $BASE_URL"
echo "Date: $(date)"
echo ""

# Counter for results
total_tests=0
passed_tests=0
failed_tests=0

# Test 1: Basic Health Check
log_section "Test 1: Basic Health Check"
if test_endpoint "GET /api/health" "$BASE_URL/api/health" 200 "ok"; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

if test_response_time "GET /api/health" "$BASE_URL/api/health" 100; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 2: Detailed Health Check
log_section "Test 2: Detailed Health Check"
if test_endpoint "GET /api/health/detailed" "$BASE_URL/api/health/detailed" 200 "healthy"; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

if test_response_time "GET /api/health/detailed" "$BASE_URL/api/health/detailed" 500; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 3: Database Health Check
log_section "Test 3: Database Health Check"
if test_endpoint "GET /api/health/database" "$BASE_URL/api/health/database" 200 "successful"; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

if test_response_time "GET /api/health/database" "$BASE_URL/api/health/database" 300; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 4: Cache Health Check
log_section "Test 4: Cache Health Check"
if test_endpoint "GET /api/health/cache" "$BASE_URL/api/health/cache" 200 "successful"; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

if test_response_time "GET /api/health/cache" "$BASE_URL/api/health/cache" 200; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 5: JSON Structure Validation
log_section "Test 5: JSON Structure Validation"

echo -n "Validating /api/health JSON structure... "
health_json=$(curl -s "$BASE_URL/api/health")
if echo "$health_json" | jq -e '.status' > /dev/null 2>&1; then
    log_info "PASS (valid JSON with 'status' field)"
    ((passed_tests++))
else
    log_error "FAIL (invalid JSON or missing 'status' field)"
    ((failed_tests++))
fi
((total_tests++))

echo -n "Validating /api/health/detailed JSON structure... "
detailed_json=$(curl -s "$BASE_URL/api/health/detailed")
if echo "$detailed_json" | jq -e '.status, .checks, .application' > /dev/null 2>&1; then
    log_info "PASS (valid JSON with required fields)"
    ((passed_tests++))
else
    log_error "FAIL (invalid JSON or missing required fields)"
    ((failed_tests++))
fi
((total_tests++))

# Test 6: Concurrent Requests (Simple Load Test)
log_section "Test 6: Concurrent Requests"

echo -n "Testing 10 concurrent requests to /api/health... "
concurrent_test() {
    for i in {1..10}; do
        curl -s -o /dev/null -w "%{http_code}\n" "$BASE_URL/api/health" &
    done
    wait
}

results=$(concurrent_test)
success_count=$(echo "$results" | grep -c "200" || echo "0")

if [ "$success_count" -eq "10" ]; then
    log_info "PASS (10/10 requests successful)"
    ((passed_tests++))
else
    log_error "FAIL (${success_count}/10 requests successful)"
    ((failed_tests++))
fi
((total_tests++))

# Test 7: HTTPS (if applicable)
log_section "Test 7: HTTPS Verification"

if [[ $BASE_URL == https://* ]]; then
    echo -n "Verifying SSL/TLS certificate... "
    if curl -s -o /dev/null "$BASE_URL/api/health"; then
        log_info "PASS (valid certificate)"
        ((passed_tests++))
    else
        log_error "FAIL (certificate issue)"
        ((failed_tests++))
    fi
    ((total_tests++))
else
    log_warning "SKIPPED (not using HTTPS)"
fi

# Summary
log_section "Test Summary"

echo "Total Tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"
echo ""

success_rate=$(echo "scale=2; $passed_tests * 100 / $total_tests" | bc)
echo "Success Rate: ${success_rate}%"

if [ "$failed_tests" -eq "0" ]; then
    log_info "All health check endpoints are working correctly!"
    echo ""
    echo "✅ System is ready for monitoring setup"
    echo "✅ UptimeRobot can be configured"
    echo "✅ Production deployment can proceed"
    exit 0
else
    log_error "Some health check endpoints failed verification"
    echo ""
    echo "⚠️  Fix issues before proceeding with deployment"
    echo "⚠️  Check application logs for errors"
    exit 1
fi
