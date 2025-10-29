#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# GameDay Drill: Kill Node (SIGKILL)
# ==============================================================================
#
# Scenario: Simulate hardware failure or kernel panic by killing a random node
# Expected: Cluster detects failure < 5s, error rate < 1%, recovery automatic
# Recovery: Supervisor restarts node, cluster topology heals
#
# Usage:
#   bash tools/gameday/kill-node.sh [node_name]
#
# Prerequisites:
#   - Cluster running with ≥3 nodes
#   - k6 load test active
#   - Metrics collection enabled
# ==============================================================================

DRILL_NAME="kill-node"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="gameday-${DRILL_NAME}-${TIMESTAMP}.log"
METRICS_FILE="gameday-${DRILL_NAME}-${TIMESTAMP}-metrics.json"

# Configuration
PROMETHEUS_URL="${PROMETHEUS_URL:-http://localhost:9090}"
CLUSTER_NODES="${CLUSTER_NODES:-node1@localhost node2@localhost node3@localhost}"
TARGET_NODE="${1:-}"

echo "=== GameDay Drill: Kill Node (SIGKILL) ===" | tee -a "${LOG_FILE}"
echo "Started: $(date)" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# Select random node if not specified
if [ -z "${TARGET_NODE}" ]; then
  NODES_ARRAY=(${CLUSTER_NODES})
  TARGET_NODE="${NODES_ARRAY[$RANDOM % ${#NODES_ARRAY[@]}]}"
fi

echo "Target node: ${TARGET_NODE}" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 1: Record baseline metrics
# ==============================================================================
echo "[1/5] Recording baseline metrics..." | tee -a "${LOG_FILE}"

# Query Prometheus for baseline
BASELINE_ERROR_RATE=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=rate(http_requests_total{status=~\"5..\"}[1m])" | jq -r '.data.result[0].value[1] // "0"')
BASELINE_LATENCY_P95=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[1m]))" | jq -r '.data.result[0].value[1] // "0"')
BASELINE_THROUGHPUT=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=rate(http_requests_total[1m])" | jq -r '.data.result[0].value[1] // "0"')

echo "  Error rate: ${BASELINE_ERROR_RATE}" | tee -a "${LOG_FILE}"
echo "  Latency p95: ${BASELINE_LATENCY_P95}s" | tee -a "${LOG_FILE}"
echo "  Throughput: ${BASELINE_THROUGHPUT} req/s" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 2: Inject failure (SIGKILL the node)
# ==============================================================================
echo "[2/5] Injecting failure (SIGKILL)..." | tee -a "${LOG_FILE}"

FAILURE_TIME=$(date +%s)

# Find BEAM process for target node
NODE_PID=$(pgrep -f "name ${TARGET_NODE}" | head -1)

if [ -z "${NODE_PID}" ]; then
  echo "ERROR: Could not find process for node ${TARGET_NODE}" | tee -a "${LOG_FILE}"
  exit 1
fi

echo "  Killing PID ${NODE_PID} for node ${TARGET_NODE}" | tee -a "${LOG_FILE}"
kill -9 "${NODE_PID}"

echo "  Node killed at $(date)" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 3: Wait for failure detection
# ==============================================================================
echo "[3/5] Waiting for failure detection..." | tee -a "${LOG_FILE}"

DETECTED=false
DETECTION_TIME=0

for i in {1..10}; do
  sleep 1

  # Check if alert fired
  ALERT_STATUS=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=ALERTS{alertname=\"NodeDown\",instance=\"${TARGET_NODE}\"}" | jq -r '.data.result[0].value[1] // "0"')

  if [ "${ALERT_STATUS}" == "1" ]; then
    DETECTED=true
    DETECTION_TIME=$(($(date +%s) - FAILURE_TIME))
    echo "  Failure detected after ${DETECTION_TIME}s" | tee -a "${LOG_FILE}"
    break
  fi

  echo "  Waiting for detection... (${i}s)" | tee -a "${LOG_FILE}"
done

if [ "${DETECTED}" == "false" ]; then
  echo "  WARNING: Failure not detected within 10s!" | tee -a "${LOG_FILE}"
fi

echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 4: Validate recovery
# ==============================================================================
echo "[4/5] Validating recovery..." | tee -a "${LOG_FILE}"

# Wait for recovery (supervisor restart)
RECOVERED=false
RECOVERY_TIME=0

for i in {1..60}; do
  sleep 1

  # Check if node is back in cluster
  NODE_STATUS=$(curl -s "http://localhost:4000/api/cluster/nodes" | jq -r ".nodes[] | select(.name==\"${TARGET_NODE}\") | .status // \"down\"")

  if [ "${NODE_STATUS}" == "up" ]; then
    RECOVERED=true
    RECOVERY_TIME=$(($(date +%s) - FAILURE_TIME))
    echo "  Node recovered after ${RECOVERY_TIME}s" | tee -a "${LOG_FILE}"
    break
  fi

  if [ $((i % 5)) == 0 ]; then
    echo "  Waiting for recovery... (${i}s)" | tee -a "${LOG_FILE}"
  fi
done

if [ "${RECOVERED}" == "false" ]; then
  echo "  ERROR: Node did not recover within 60s!" | tee -a "${LOG_FILE}"
  exit 1
fi

# Wait 10s more for metrics to stabilize
echo "  Waiting 10s for metrics to stabilize..." | tee -a "${LOG_FILE}"
sleep 10

# Query post-recovery metrics
POST_ERROR_RATE=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=rate(http_requests_total{status=~\"5..\"}[1m])" | jq -r '.data.result[0].value[1] // "0"')
POST_LATENCY_P95=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[1m]))" | jq -r '.data.result[0].value[1] // "0"')
POST_THROUGHPUT=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=rate(http_requests_total[1m])" | jq -r '.data.result[0].value[1] // "0"')

echo "" | tee -a "${LOG_FILE}"
echo "  Post-recovery metrics:" | tee -a "${LOG_FILE}"
echo "    Error rate: ${POST_ERROR_RATE}" | tee -a "${LOG_FILE}"
echo "    Latency p95: ${POST_LATENCY_P95}s" | tee -a "${LOG_FILE}"
echo "    Throughput: ${POST_THROUGHPUT} req/s" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

# ==============================================================================
# Step 5: Generate report
# ==============================================================================
echo "[5/5] Generating report..." | tee -a "${LOG_FILE}"

# Calculate max error rate during incident
MAX_ERROR_RATE=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=max_over_time(rate(http_requests_total{status=~\"5..\"}[1m])[${RECOVERY_TIME}s:5s])" | jq -r '.data.result[0].value[1] // "0"')

# Determine pass/fail
DETECTION_PASSED=false
ERROR_RATE_PASSED=false
RECOVERY_PASSED=false

[ "${DETECTION_TIME}" -lt 5 ] && DETECTION_PASSED=true
[ "$(echo "${MAX_ERROR_RATE} < 0.01" | bc)" -eq 1 ] && ERROR_RATE_PASSED=true
[ "${RECOVERY_TIME}" -lt 30 ] && RECOVERY_PASSED=true

DRILL_PASSED=false
[ "${DETECTION_PASSED}" == "true" ] && [ "${ERROR_RATE_PASSED}" == "true" ] && [ "${RECOVERY_PASSED}" == "true" ] && DRILL_PASSED=true

# Write summary
cat > "${METRICS_FILE}" <<JSON
{
  "drill": "kill-node",
  "timestamp": "${TIMESTAMP}",
  "target_node": "${TARGET_NODE}",
  "timeline": {
    "failure_injected": "${FAILURE_TIME}",
    "failure_detected_seconds": ${DETECTION_TIME},
    "recovery_completed_seconds": ${RECOVERY_TIME}
  },
  "metrics": {
    "baseline": {
      "error_rate": ${BASELINE_ERROR_RATE},
      "latency_p95": ${BASELINE_LATENCY_P95},
      "throughput": ${BASELINE_THROUGHPUT}
    },
    "during_incident": {
      "max_error_rate": ${MAX_ERROR_RATE}
    },
    "post_recovery": {
      "error_rate": ${POST_ERROR_RATE},
      "latency_p95": ${POST_LATENCY_P95},
      "throughput": ${POST_THROUGHPUT}
    }
  },
  "targets": {
    "detection_time_target_seconds": 5,
    "detection_time_actual_seconds": ${DETECTION_TIME},
    "detection_passed": ${DETECTION_PASSED},
    "error_rate_target": 0.01,
    "error_rate_actual": ${MAX_ERROR_RATE},
    "error_rate_passed": ${ERROR_RATE_PASSED},
    "recovery_time_target_seconds": 30,
    "recovery_time_actual_seconds": ${RECOVERY_TIME},
    "recovery_passed": ${RECOVERY_PASSED}
  },
  "result": "${DRILL_PASSED}"
}
JSON

echo "" | tee -a "${LOG_FILE}"
echo "=== RESULTS ===" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"
echo "Detection: ${DETECTION_TIME}s (target: <5s) [$([ "${DETECTION_PASSED}" == "true" ] && echo "PASS ✓" || echo "FAIL ✗")]" | tee -a "${LOG_FILE}"
echo "Error rate: ${MAX_ERROR_RATE} (target: <0.01) [$([ "${ERROR_RATE_PASSED}" == "true" ] && echo "PASS ✓" || echo "FAIL ✗")]" | tee -a "${LOG_FILE}"
echo "Recovery: ${RECOVERY_TIME}s (target: <30s) [$([ "${RECOVERY_PASSED}" == "true" ] && echo "PASS ✓" || echo "FAIL ✗")]" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"
echo "Overall: $([ "${DRILL_PASSED}" == "true" ] && echo "PASSED ✓" || echo "FAILED ✗")" | tee -a "${LOG_FILE}"
echo "" | tee -a "${LOG_FILE}"

echo "Completed: $(date)" | tee -a "${LOG_FILE}"
echo "Log: ${LOG_FILE}" | tee -a "${LOG_FILE}"
echo "Metrics: ${METRICS_FILE}" | tee -a "${LOG_FILE}"

# Exit with error if drill failed
[ "${DRILL_PASSED}" == "true" ] && exit 0 || exit 1
