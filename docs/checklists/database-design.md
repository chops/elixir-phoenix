# Database Design Checklist

Use this checklist when designing database schemas and migrations.

## Schema Design
- [ ] Primary keys defined
- [ ] Foreign keys with proper references
- [ ] Indexes on frequently queried columns
- [ ] Unique constraints where appropriate
- [ ] Check constraints for data validation
- [ ] Timestamps (inserted_at, updated_at)

## Migrations
- [ ] Up migration tested
- [ ] Down migration tested
- [ ] Data migration strategy (if needed)
- [ ] Safe for zero-downtime deployment
- [ ] Indexes added concurrently (for large tables)

## Changesets
- [ ] Required fields validated
- [ ] Format validations (email, URL, etc.)
- [ ] Length constraints
- [ ] Custom validations implemented
- [ ] Association handling
- [ ] Error messages user-friendly

## Performance
- [ ] N+1 queries identified and fixed
- [ ] Appropriate use of `preload`
- [ ] Query plans reviewed (EXPLAIN)
- [ ] Pagination for large result sets
- [ ] Connection pool sized appropriately

## Transactions
- [ ] Transaction boundaries clear
- [ ] Ecto.Multi used for complex transactions
- [ ] Rollback scenarios tested
- [ ] Idempotency considered

## Security
- [ ] No raw SQL with user input
- [ ] Sensitive data encrypted at rest
- [ ] PII handling compliant
- [ ] Access control enforced at DB level
