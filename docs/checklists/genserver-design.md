# GenServer Design Checklist

Use this checklist when designing a new GenServer.

## State Design
- [ ] State structure clearly defined
- [ ] State transitions documented
- [ ] Default state defined
- [ ] State recovery strategy considered

## API Design
- [ ] Public API functions use `call` vs `cast` appropriately
- [ ] Function names clearly indicate sync/async behavior
- [ ] Timeouts specified for synchronous calls
- [ ] Return values documented

## Supervision
- [ ] Supervision strategy chosen (one_for_one, rest_for_one, etc.)
- [ ] Restart strategy defined (:permanent, :temporary, :transient)
- [ ] Max restart intensity configured
- [ ] Child spec implemented

## Error Handling
- [ ] Invalid messages handled gracefully
- [ ] Crash scenarios identified
- [ ] Recovery logic implemented
- [ ] Error logging in place

## Performance
- [ ] Long-running operations moved to async calls
- [ ] State size bounded (no unbounded growth)
- [ ] Bottleneck potential assessed
- [ ] Benchmarks written for critical paths

## Testing
- [ ] Unit tests for state transitions
- [ ] Integration tests for supervision
- [ ] Crash recovery tests
- [ ] Concurrency tests
