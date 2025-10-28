# Service Level Objectives (SLOs)

## Availability SLOs

| Service | Target | Measurement Window |
|---------|--------|-------------------|
| Web API | 99.9% | 30 days |
| Background Jobs | 99.5% | 30 days |
| Database | 99.95% | 30 days |

## Latency SLOs

| Endpoint | p50 | p95 | p99 |
|----------|-----|-----|-----|
| GET /products | <50ms | <150ms | <300ms |
| POST /orders | <200ms | <500ms | <1s |
| WebSocket messages | <100ms | <300ms | <500ms |

## Error Budget

- **Monthly error budget**: 43 minutes downtime (99.9%)
- **Alert threshold**: 50% of budget consumed
- **Freeze deployments**: If 80% budget consumed

## Alerting Rules

### Critical Alerts (Page on-call)
- Availability drops below 99.5%
- p99 latency exceeds SLO by 2x
- Error rate > 5%
- Database connection pool exhausted

### Warning Alerts (Ticket)
- Approaching error budget (80%)
- p95 latency degradation
- Elevated 4xx rate

## Review Cadence
- Weekly: Review SLI metrics
- Monthly: Assess error budget burn
- Quarterly: Adjust SLOs based on user needs
