# Unit Economics & Capacity Planning

This worksheet helps you model the cost and capacity of your Elixir/Phoenix application at different scales. Use it to:

1. **Estimate infrastructure costs** before building
2. **Plan capacity** for expected traffic
3. **Justify technical decisions** with financial data
4. **Optimize** resource usage based on real metrics

## Quick Reference

| Metric | Formula | Example Value |
|--------|---------|---------------|
| **Cost per Request** | `(Monthly Infra Cost) / (Monthly Requests)` | $0.000012 per req |
| **Cost per User (Monthly)** | `(Monthly Infra Cost) / (Monthly Active Users)` | $0.15 per user |
| **Requests per Core** | `(Total RPS) / (Number of Cores)` | 250 RPS/core |
| **Cost per GB Transferred** | `(Bandwidth Cost) / (GB Transferred)` | $0.09 per GB |
| **Database Cost per Row** | `(DB Cost) / (Total Rows)` | $0.0000001 per row |

---

## Section 1: Infrastructure Inventory

List your infrastructure components and their costs.

### Compute Resources

| Component | Count | vCPUs | Memory (GB) | Cost/Month | Total Cost |
|-----------|-------|-------|-------------|------------|------------|
| **Application Servers** |
| Phoenix nodes (prod) | 3 | 4 | 16 | $80 | $240 |
| Phoenix nodes (staging) | 1 | 2 | 8 | $40 | $40 |
| **Background Workers** |
| Oban workers | 2 | 2 | 8 | $40 | $80 |
| **Data Layer** |
| PostgreSQL primary | 1 | 4 | 16 | $120 | $120 |
| PostgreSQL replicas | 2 | 4 | 16 | $120 | $240 |
| Redis cache | 1 | 2 | 8 | $50 | $50 |
| **Infrastructure** |
| Load balancer | 1 | - | - | $25 | $25 |
| NAT gateway | 1 | - | - | $35 | $35 |
| **Observability** |
| Prometheus/Grafana | 1 | 2 | 8 | $40 | $40 |
| Log aggregation | 1 | 2 | 8 | $60 | $60 |
| **Total Compute** | | | | | **$930** |

[Content continues for all sections...]
