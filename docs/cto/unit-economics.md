# Unit Economics

## Overview
Track costs and value metrics for the learning journey and Pulse app.

## Learning Investment

### Time Investment
**Weekly Allocation**
- Books/Reading: 8 hours
- Coding (labs): 10 hours
- Coding (pulse): 8 hours
- Documentation: 2 hours
- Review: 2 hours
**Total**: 30 hours/week

**Annual Total**: ~1,560 hours

**Opportunity Cost** (at $100/hour): $156,000

---

### Financial Investment

**Books & Resources**
- Programming Elixir: $40
- Learn Functional Programming with Elixir: $35
- Elixir in Action: $45
- Designing for Scalability with Erlang/OTP: $50
- Programming Ecto: $40
- Testing Elixir: $45
- Functional Web Development: $40
- Adopting Elixir: $45
**Subtotal**: ~$340

**Infrastructure**
- Database (local): $0
- Monitoring (local + Grafana Cloud free tier): $0
- GitHub (free tier): $0
- CI/CD (GitHub Actions free tier): $0
**Monthly**: $0-10

**Tools**
- Elixir (free): $0
- VS Code/editor (free): $0
- k6 (free): $0
**Subtotal**: $0

**Total Financial**: ~$340-440 for year

---

## Pulse App Economics (Production Scenario)

### Infrastructure Costs (Monthly)

**Compute**
- 2x app servers (2GB RAM): $24
- 1x database (4GB RAM): $30
- 1x cache server (1GB RAM): $12
**Subtotal**: $66/month

**Monitoring**
- Grafana Cloud: $0 (free tier)
- Log aggregation: $10
**Subtotal**: $10/month

**Total Monthly**: ~$76

---

### Cost Per User

**Assumptions**
- 1,000 active users
- 10 req/user/day
- 100ms avg response time
- 10KB avg response size

**Resource Usage**
- Compute: $66 / 1,000 = $0.066/user
- Monitoring: $10 / 1,000 = $0.010/user
**Total Cost Per User**: $0.076/month

---

### Scaling Economics

| Users | App Servers | Monthly Cost | Cost/User |
|-------|-------------|--------------|-----------|
| 1K    | 2           | $76          | $0.076    |
| 10K   | 4           | $134         | $0.013    |
| 100K  | 16          | $494         | $0.005    |
| 1M    | 64          | $1,864       | $0.002    |

**Observation**: Economics improve with scale due to:
- Shared database costs
- Fixed monitoring costs
- Efficient BEAM VM resource usage

---

### Break-Even Analysis

**Pricing Scenario**: $5/user/month

| Users | Revenue/mo | Cost/mo | Profit/mo | Margin |
|-------|------------|---------|-----------|--------|
| 100   | $500       | $76     | $424      | 85%    |
| 500   | $2,500     | $76     | $2,424    | 97%    |
| 1K    | $5,000     | $76     | $4,924    | 98%    |
| 10K   | $50,000    | $134    | $49,866   | 99.7%  |

**Break-even**: ~16 users

---

## ROI Calculations

### Learning ROI

**Investment**: 1,560 hours + $400 = ~$156,400

**Expected Return** (after mastery):
- Elixir developer salary: $120-180K/year
- Increased earning potential: $20-40K/year
- Consulting rate: $150-250/hour

**Time to ROI**: 6-12 months at increased salary

---

### Pulse App ROI (if commercialized)

**Scenario 1: SaaS Product**
- 500 users at $5/mo
- Monthly revenue: $2,500
- Monthly costs: $76
- Monthly profit: $2,424
- Annual profit: $29,088
- ROI on learning investment: 18.6%

**Scenario 2: Enterprise Contract**
- 1 customer at $50K/year
- Infrastructure: $1,500/year
- Profit: $48,500
- ROI on learning investment: 31%

---

## Key Metrics to Track

### Learning Metrics
- [ ] Hours invested per phase
- [ ] Cost per completed phase
- [ ] Features shipped per week
- [ ] Tests written per week

### Production Metrics (if deployed)
- [ ] Cost per request
- [ ] Cost per user
- [ ] Infrastructure utilization
- [ ] Error budget consumption

### Business Metrics (if commercialized)
- [ ] Customer acquisition cost
- [ ] Lifetime value
- [ ] Churn rate
- [ ] Gross margin

---

## Cost Optimization Strategies

### Short-Term
- Use local development (avoid cloud costs)
- Free tier services (GitHub, Grafana Cloud)
- Open source tools
- Self-learning (books vs courses)

### Long-Term (Production)
- Right-size infrastructure
- Use spot instances
- Implement caching aggressively
- Optimize database queries
- Monitor and alert on cost anomalies

---

## Review Schedule
- **Weekly**: Track time investment
- **Monthly**: Review infrastructure costs
- **Quarterly**: Calculate learning ROI
- **Annually**: Full economic review
