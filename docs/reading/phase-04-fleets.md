# Phase 4  Naming & Fleets

Manage dynamic process pools with Registry and DynamicSupervisor.

## Books
- **Adopting Elixir** (Marx, Valim, Tate)

## Docs
- **Registry**
  https://hexdocs.pm/elixir/Registry.html

- **DynamicSupervisor child specs/strategy**
  https://hexdocs.pm/elixir/DynamicSupervisor.html#module-child-processes

## Supplements
- **Registry explainer**
  https://elixirschool.com/en/lessons/advanced/otp-dispatch

---

## Tasks

### Week 1 (Mon-Tue: Books)
- [ ] Read Adopting Elixir chapters on process management and patterns
- [ ] Study Registry use cases

### Week 1 (Wed: Docs)
- [ ] Read Registry module documentation thoroughly
- [ ] Study DynamicSupervisor child spec patterns
- [ ] Review via/name registration strategies

### Week 1 (Thu: Supplements)
- [ ] Work through Registry explainer on Elixir School
- [ ] Study registry dispatch patterns

### Week 1 (Fri: Apply)
- [ ] Create `labs_session_workers` app
- [ ] Implement per-session worker processes
- [ ] Use Registry for process lookup
- [ ] Add DynamicSupervisor for worker spawning
- [ ] Commit notes and open PR: "Reading: Phase 4"

### Week 2
- [ ] Create `pulse_fleet` app
- [ ] Implement per-user cart worker fleet
- [ ] Add fleet management API (start/stop/find)
- [ ] Test process naming edge cases
- [ ] Document process lifecycle

---

## Notes

(Add your learning notes here as you progress)
