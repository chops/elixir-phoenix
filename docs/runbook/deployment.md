# Deployment Runbook

## Pre-Deployment Checklist
- [ ] All tests passing
- [ ] CI/CD pipeline green
- [ ] Database migrations reviewed
- [ ] Environment variables updated
- [ ] Secrets rotated (if needed)
- [ ] Rollback plan prepared

## Deployment Steps

### 1. Build Release
```bash
MIX_ENV=prod mix release
```

### 2. Run Migrations
```bash
_build/prod/rel/elixir_systems_mastery/bin/elixir_systems_mastery eval "ElixirSystemsMastery.Release.migrate()"
```

### 3. Deploy New Version
```bash
# Copy release to target server
scp -r _build/prod/rel/elixir_systems_mastery user@server:/opt/app/releases/

# On server: stop old version
systemctl stop elixir_systems_mastery

# Start new version
systemctl start elixir_systems_mastery
```

### 4. Verify Deployment
```bash
# Check health endpoint
curl https://app.example.com/health

# Check logs
journalctl -u elixir_systems_mastery -f
```

## Rollback Procedure
```bash
# Revert to previous release
systemctl stop elixir_systems_mastery
ln -sf /opt/app/releases/previous /opt/app/current
systemctl start elixir_systems_mastery

# Rollback migrations (if needed)
_build/prod/rel/elixir_systems_mastery/bin/elixir_systems_mastery eval "ElixirSystemsMastery.Release.rollback()"
```

## Post-Deployment
- [ ] Monitor error rates
- [ ] Check key metrics (response time, throughput)
- [ ] Verify critical user flows
- [ ] Update documentation
