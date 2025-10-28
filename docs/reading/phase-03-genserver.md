# Phase 3  GenServer + Supervision

Build fault-tolerant stateful services with GenServer and supervisors.

## Books
- **Designing for Scalability with Erlang/OTP** (Cesarini & Vinoski)

## Docs
- **DynamicSupervisor**
  https://hexdocs.pm/elixir/DynamicSupervisor.html

- **OTP behaviours/supervision**
  https://www.erlang.org/doc/design_principles/des_princ.html#behaviours and https://www.erlang.org/doc/design_principles/sup_princ.html

## Supplements
- **Boot patterns with DynamicSupervisor (discussion)**
  https://elixirforum.com/t/dynamicsupervisor-best-practices/15062

---

## Tasks

### Week 1 (Mon-Tue: Books)
- [ ] Read Designing for Scalability chapters 1-4 (OTP, GenServer, supervision)
- [ ] Implement example GenServers from the book

### Week 1 (Wed: Docs)
- [ ] Study GenServer behaviour documentation
- [ ] Review Supervisor restart strategies
- [ ] Read DynamicSupervisor documentation

### Week 1 (Thu: Supplements)
- [ ] Read DynamicSupervisor best practices thread
- [ ] Review supervision tree design patterns

### Week 1 (Fri: Apply)
- [ ] Create `labs_counter_ttl` app
- [ ] Implement counter GenServer with auto-expiry
- [ ] Add Supervisor with different restart strategies
- [ ] Test state recovery scenarios
- [ ] Commit notes and open PR: "Reading: Phase 3"

### Week 2
- [ ] Create `pulse_cart` app
- [ ] Implement shopping cart as GenServer
- [ ] Add TTL-based expiry mechanism
- [ ] Build supervision tree
- [ ] Use GenServer design checklist (docs/checklists/)

---

## Notes

(Add your learning notes here as you progress)
