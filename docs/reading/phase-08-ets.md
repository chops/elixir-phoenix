# Phase 8  Caching & ETS

High-performance in-memory caching with ETS.

## Books
- **Designing for Scalability with Erlang/OTP**  ETS usage

## Docs
- **:ets module reference**
  https://www.erlang.org/doc/man/ets.html

## Supplements
- **ETS primer (Elixir School)**
  https://elixirschool.com/en/lessons/storage/ets

- **Learn You Some Erlang  ETS**
  https://learnyousomeerlang.com/ets

---

## Tasks

### Week 1 (Mon-Tue: Books)
- [ ] Read Designing for Scalability ETS chapters
- [ ] Study ETS table types and use cases

### Week 1 (Wed: Docs)
- [ ] Read :ets module documentation thoroughly
- [ ] Study table types (set, ordered_set, bag, duplicate_bag)
- [ ] Review ETS access modes (public, protected, private)

### Week 1 (Thu: Supplements)
- [ ] Work through ETS primer on Elixir School
- [ ] Read Learn You Some Erlang ETS chapter

### Week 1 (Fri: Apply)
- [ ] Create `labs_cache` app
- [ ] Implement read-through cache pattern
- [ ] Add cache invalidation strategies
- [ ] Implement TTL-based expiry
- [ ] Commit notes and open PR: "Reading: Phase 8"

### Week 2
- [ ] Create `pulse_cache` app
- [ ] Implement product catalog cache
- [ ] Add session cache
- [ ] Implement cache warming on startup
- [ ] Run benchmarks (use tools/bench_cache.exs)
- [ ] Monitor cache hit rates

---

## Notes

(Add your learning notes here as you progress)
