#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# GameDay Drill: Traffic Spike
# ==============================================================================
#
# Scenario: Sudden 10x traffic increase (flash sale, viral content)
# Expected: Graceful degradation, autoscaling triggers, SLO maintained
# Recovery: Traffic returns to normal, no cascading failures
#
# Usage:
#   bash tools/gameday/spike-traffic.sh
#
# Prerequisites:
#   - Application running
#   - k6 installed
#   - Metrics collection enabled
# ==============================================================================

DRILL_NAME="spike-traffic"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="gameday-${DRILL_NAME}-${TIMESTAMP}.log"

BASE_URL="${BASE_URL:-http://localhost:4000}"
SPIKE_MULTIPLIER="${SPIKE_MULTIPLIER:-10}"
SPIKE_DURATION="${SPIKE_DURATION:-60}"  # seconds

echo "=== GameDay Drill: Traffic Spike ===" | tee -a "${LOG_FILE}"
echo "Started: $(date)" | tee -a "${LOG_FILE}"
echo "Spike: ${SPIKE_MULTIPLIER}x traffic for ${SPIKE_DURATION}s" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 1: Record baseline
# ==============================================================================
echo "[1/4] Recording baseline metrics..." | tee -a "${LOG_FILE}"

# Run short baseline test
k6 run --quiet --no-summary - <<EOF > /tmp/baseline.txt 2>&1
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '10s',
};

export default function () {
  http.get('${BASE_URL}/');
  sleep(1);
}
EOF

BASELINE_RPS=$(grep "http_reqs" /tmp/baseline.txt | awk '{print $2}')
echo "  Baseline RPS: ${BASELINE_RPS}" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 2: Inject traffic spike
# ==============================================================================
echo "[2/4] Injecting ${SPIKE_MULTIPLIER}x traffic spike..." | tee -a "${LOG_FILE}"

SPIKE_START=$(date +%s)

# Calculate target VUs
SPIKE_VUS=$((10 * SPIKE_MULTIPLIER))

echo "  Spiking to ${SPIKE_VUS} VUs" | tee -a "${LOG_FILE}"

# Run spike test
k6 run --quiet - <<EOF > /tmp/spike.txt 2>&1
import http from 'k6/http';
import { sleep, check } from 'k6';
import { Rate } from 'k6/metrics';

const errors = new Rate('errors');

export const options = {
  stages: [
    { duration: '5s', target: ${SPIKE_VUS} },      // Ramp up fast
    { duration: '${SPIKE_DURATION}s', target: ${SPIKE_VUS} }, // Hold spike
    { duration: '10s', target: 10 },                // Ramp down
  ],
  thresholds: {
    'http_req_duration': ['p(95)<500'],  // Degraded but still functional
    'errors': ['rate<0.1'],               // < 10% error rate acceptable during spike
  },
};

export default function () {
  const res = http.get('${BASE_URL}/');

  const success = check(res, {
    'status is 200 or 429 or 503': (r) => [200, 429, 503].includes(r.status),
  });

  if (!success) {
    errors.add(1);
  }

  sleep(1);
}
EOF

SPIKE_DURATION_ACTUAL=$(($(date +%s) - SPIKE_START))

echo "  Spike completed (${SPIKE_DURATION_ACTUAL}s)" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 3: Parse results
# ==============================================================================
echo "[3/4] Analyzing results..." | tee -a "${LOG_FILE}"

# Extract metrics from k6 output
SPIKE_RPS=$(grep "http_reqs" /tmp/spike.txt | awk '{print $2}' | cut -d'/' -f1)
SPIKE_P95=$(grep "http_req_duration.*p(95)" /tmp/spike.txt | awk '{print $3}' | sed 's/ms//')
ERROR_RATE=$(grep "errors" /tmp/spike.txt | awk '{print $3}' | sed 's/%//')
STATUS_429=$(grep -o "status 429" /tmp/spike.txt | wc -l)
STATUS_503=$(grep -o "status 503" /tmp/spike.txt | wc -l)

echo "  Peak RPS: ${SPIKE_RPS}" | tee -a "${LOG_FILE}"
echo "  Latency p95: ${SPIKE_P95}ms" | tee -a "${LOG_FILE}"
echo "  Error rate: ${ERROR_RATE}%" | tee -a "${LOG_FILE}"
echo "  Rate limit responses (429): ${STATUS_429}" | tee -a "${LOG_FILE}"
echo "  Service unavailable (503): ${STATUS_503}" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 4: Generate report
# ==============================================================================
echo "[4/4] Generating report..." | tee -a "${LOG_FILE}"

# Determine pass/fail
LATENCY_OK=false
ERROR_RATE_OK=false
NO_CASCADING_FAILURE=false

# Latency should degrade gracefully (< 500ms p95)
[ "$(echo "${SPIKE_P95} < 500" | bc -l)" -eq 1 ] && LATENCY_OK=true

# Error rate < 10% acceptable during spike
ERROR_RATE_NUM=$(echo "${ERROR_RATE}" | sed 's/%//')
[ "$(echo "${ERROR_RATE_NUM} < 10" | bc -l)" -eq 1 ] && ERROR_RATE_OK=true

# No cascading failure (503s should be minimal if rate limiting working)
[ "${STATUS_503}" -lt 100 ] && NO_CASCADING_FAILURE=true

DRILL_PASSED=false
[ "${LATENCY_OK}" == "true" ] && [ "${ERROR_RATE_OK}" == "true" ] && [ "${NO_CASCADING_FAILURE}" == "true" ] && DRILL_PASSED=true

echo "=== RESULTS ===" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"
echo "Graceful degradation (p95 < 500ms): [$([ "${LATENCY_OK}" == "true" ] && echo "PASS ✓" || echo "FAIL ✗")]" | tee -a "${LOG_FILE}"
echo "  Actual p95: ${SPIKE_P95}ms" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"
echo "Error rate (< 10%): [$([ "${ERROR_RATE_OK}" == "true" ] && echo "PASS ✓" || echo "FAIL ✗")]" | tee -a "${LOG_FILE}"
echo "  Actual error rate: ${ERROR_RATE}%" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"
echo "No cascading failures (503 < 100): [$([ "${NO_CASCADING_FAILURE}" == "true" ] && echo "PASS ✓" || echo "FAIL ✗")]" | tee -a "${LOG_FILE}"
echo "  Actual 503 count: ${STATUS_503}" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"
echo "Overall: $([ "${DRILL_PASSED}" == "true" ] && echo "PASSED ✓" || echo "FAILED ✗")" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

echo "Completed: $(date)" | tee -a "${LOG_FILE}"
echo "Log: ${LOG_FILE}" | tee -a "${LOG_FILE}"

# Exit with error if drill failed
[ "${DRILL_PASSED}" == "true" ] && exit 0 || exit 1
