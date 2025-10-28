# Phase 2  Processes & Mailboxes

Understand message-passing concurrency with raw processes.

## Books
- **Elixir in Action, 2nd ed.** (Saaa Juri)  processes and message passing

## Docs
- **Erlang gen_server manpage**
  https://www.erlang.org/doc/man/gen_server.html

- **OTP Design Principles overview**
  https://www.erlang.org/doc/design_principles/des_princ.html

- **Task.async_stream/3**
  https://hexdocs.pm/elixir/Task.html#async_stream/3

## Supplements
- **OTP Design Principles (PDF aggregate)**
  https://www.erlang.org/doc/design_principles/part_frame.html

---

## Tasks

### Week 1 (Mon-Tue: Books)
- [ ] Read Elixir in Action chapters 4-5 (processes, message passing)
- [ ] Work through all code examples in REPL

### Week 1 (Wed: Docs)
- [ ] Read OTP Design Principles overview
- [ ] Study gen_server manpage (preview for Phase 3)
- [ ] Review Task module documentation

### Week 1 (Thu: Supplements)
- [ ] Read full OTP Design Principles guide
- [ ] Study spawn/send/receive patterns

### Week 1 (Fri: Apply)
- [ ] Create `labs_mailbox_kv` app
- [ ] Implement KV store using raw `spawn`/`send`/`receive`
- [ ] Add process linking and monitoring
- [ ] Test crash scenarios
- [ ] Commit notes and open PR: "Reading: Phase 2"

### Week 2
- [ ] Refactor `pulse_core` to use Task.async_stream for parallel calculations
- [ ] Add telemetry for process lifecycle events
- [ ] Document process boundaries

---

## Notes

(Add your learning notes here as you progress)
