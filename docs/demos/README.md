# Demo Scripts

This directory contains demo scripts showcasing various features of the system.

## Structure
```
demos/
├── 01-basic-cart.exs          # Basic cart operations
├── 02-concurrent-carts.exs    # Multi-user cart concurrency
├── 03-database-transactions.exs # Ecto.Multi demo
├── 04-realtime-updates.exs    # LiveView updates
├── 05-pipeline-ingestion.exs  # Broadway pipeline
└── outputs/                   # Expected outputs
```

## Running Demos

```bash
# Run a specific demo
mix run docs/demos/01-basic-cart.exs

# Run all demos
for script in docs/demos/*.exs; do
  echo "Running $script..."
  mix run "$script"
done
```

## Adding New Demos
1. Create a new `.exs` file
2. Include clear comments explaining the demo
3. Add expected output to `outputs/` directory
4. Update this README
