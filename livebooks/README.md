# Livebook Learning Materials

Interactive, executable notebooks for Elixir Systems Mastery.

## 🎯 Overview

This directory contains **Livebook notebooks** that transform static workbooks into interactive learning experiences. Each notebook allows you to execute code directly, experiment with examples, and track your progress through self-assessments.

## 📂 Directory Structure

```
livebooks/
├── setup.livemd                    # Start here! Setup and orientation
├── dashboard.livemd                # Progress tracking across all phases
├── .progress.json                  # Your progress data
│
├── phase-01-core/                  # Phase 1: Elixir Core (7 checkpoints)
│   ├── 01-pattern-matching.livemd
│   ├── 02-recursion.livemd
│   ├── 03-enum-stream.livemd
│   ├── 04-error-handling.livemd
│   ├── 05-property-testing.livemd
│   ├── 06-pipe-operator.livemd
│   └── 07-advanced-patterns.livemd
│
├── phase-02-processes/             # Phase 2: Processes & Mailboxes
├── phase-03-genserver/             # Phase 3: GenServer + Supervision
├── phase-04-naming/                # Phase 4: Naming & Fleets
├── phase-05-data/                  # Phase 5: Data & Ecto
├── phase-06-phoenix/               # Phase 6: Phoenix Web
├── phase-07-jobs/                  # Phase 7: Jobs & Ingestion
├── phase-08-caching/               # Phase 8: Caching & ETS
├── phase-09-distribution/          # Phase 9: Distribution
├── phase-10-observability/         # Phase 10: Observability & SLOs
├── phase-11-testing/               # Phase 11: Testing Strategy
├── phase-12-delivery/              # Phase 12: Delivery & Ops
├── phase-13-capstone/              # Phase 13: Capstone Integration
├── phase-14-cto/                   # Phase 14: CTO Track
└── phase-15-ai/                    # Phase 15: AI/ML Integration
```

## 🚀 Getting Started

### 1. Install Dependencies

```bash
# From the repository root
mix deps.get
```

This installs:
- `kino` - Livebook interactive widgets
- `kino_vega_lite` - Data visualization
- `kino_db` - Database connectivity (for later phases)
- `stream_data` - Property-based testing

### 2. Start Livebook

```bash
# From the repository root
make livebook

# Or directly:
livebook server --home livebooks/
```

### 3. Open Your Browser

Navigate to `http://localhost:8080` (Livebook will usually open this automatically)

### 4. Begin Learning

Open `setup.livemd` for orientation, then proceed to Phase 1, Checkpoint 1.

## 📚 How to Use Livebooks

### Basic Operations

**Evaluate a code cell:**
- Click the "Evaluate" button
- Or press `Ctrl+Enter` (Mac: `Cmd+Enter`)

**Navigate:**
- Use the sidebar to jump between sections
- Follow "Next Steps" links at the bottom of each notebook

**Experiment:**
- All code cells can be modified
- Re-evaluate to see changes immediately
- Don't worry about breaking things - just refresh!

### Learning Flow

1. **Read the concept** sections to understand theory
2. **Run the examples** to see code in action
3. **Complete exercises** by modifying code cells
4. **Check your understanding** with self-assessment forms
5. **Track progress** in the dashboard

## 🎓 Phase 1: Elixir Core

Phase 1 is fully interactive with 7 checkpoints:

| Checkpoint | Topic | Key Concepts |
|------------|-------|--------------|
| 1 | Pattern Matching & Guards | Tuples, lists, maps, function heads |
| 2 | Recursion | Tail-call optimization, accumulators |
| 3 | Enum vs Stream | Eager vs lazy, pipelines, streaming |
| 4 | Error Handling | Tagged tuples, `with` statements |
| 5 | Property Testing | StreamData, invariants, generators |
| 6 | Pipe Operator | Data structures, CSV parsing |
| 7 | Advanced Patterns | Final challenge: Statistics calculator |

**Time Estimate:** 6-9 days of focused practice

## 📊 Progress Tracking

### Dashboard

Open `dashboard.livemd` to:
- View completion status for all phases
- See visual progress charts
- Mark checkpoints as complete
- Navigate quickly to any phase

### Manual Progress

Your progress is stored in `.progress.json`. The dashboard provides an interface to update this, but you can also edit it manually:

```json
{
  "phase-01-core": {
    "checkpoint-01": true,
    "checkpoint-02": true,
    "checkpoint-03": false
  }
}
```

## 🔧 Troubleshooting

### Livebook Won't Start

**Problem:** `livebook: command not found`

**Solution:** Install Livebook globally:
```bash
mix escript.install hex livebook
```

Make sure `~/.mix/escripts` is in your PATH.

### Dependencies Not Found

**Problem:** Kino or other packages not available

**Solution:** Install from the repository root:
```bash
mix deps.get
```

### Code Cells Won't Execute

**Problem:** Cell shows "Stale" or won't evaluate

**Solution:**
1. Try evaluating all cells in order (use "Evaluate all" from menu)
2. Check if previous cells need to be evaluated first
3. Restart the Livebook runtime (Runtime → Restart)

### Visualizations Don't Appear

**Problem:** VegaLite charts don't render

**Solution:**
1. Ensure `kino_vega_lite` is installed (`mix deps.get`)
2. Re-evaluate the cell
3. Check browser console for errors

## 🎨 Livebook Features Used

### Kino Widgets

- **Forms:** Interactive checkboxes for self-assessment
- **Inputs:** Text fields for user input
- **Markdown:** Dynamic markdown rendering
- **Tables:** Data display

### VegaLite Charts

- Bar charts for progress visualization
- Line charts for benchmark comparisons
- Interactive tooltips

### Smart Cells

Custom smart cells are defined in `lib/livebook_extensions/`:

- **Test Runner:** Execute Mix tests for labs_* apps
- **k6 Runner:** Run load tests for different phases

## 📖 Learning Resources

### Official Documentation

- **Livebook:** https://livebook.dev
- **Kino:** https://hexdocs.pm/kino
- **VegaLite:** https://hexdocs.pm/vega_lite
- **StreamData:** https://hexdocs.pm/stream_data

### Repository Documentation

- **Main README:** `../README.md`
- **Roadmap:** `../docs/roadmap.md`
- **Curriculum Map:** `../docs/curriculum-map.md`
- **Lesson Planning System:** `../docs/LESSON-PLANNING-SYSTEM.md`

### Parallel Learning Materials

Livebooks complement the existing materials:

- **Workbooks** (`docs/workbooks/`) - Static exercises with solutions
- **Study Guides** (`docs/guides/`) - Reading schedules and daily plans
- **Lesson Plans** (`docs/lessons/`) - Teaching materials and facilitation guides

**Recommendation:** Use Livebooks as your primary learning tool, referencing workbooks for additional practice problems.

## 🤝 Contributing

Found a typo or have an improvement?

1. The source files are `.livemd` (Livebook Markdown)
2. Edit directly or through Livebook's interface
3. Test all code cells work correctly
4. Submit a pull request

## ❓ FAQ

**Q: Do I need to complete workbooks AND livebooks?**

A: No! Livebooks are the interactive version of workbooks. Choose one approach, though you may reference both.

**Q: Can I use Livebook without the browser?**

A: Livebook is designed for the browser, but you can export notebooks to `.ex` files for running in IEx.

**Q: How do I share my progress?**

A: Export completed notebooks (File → Export) or share your `.progress.json` file.

**Q: Are Smart Cells required?**

A: No, they're optional conveniences for running tests and load tests. You can still use `mix test` and `k6` directly.

**Q: Can I create my own notebooks?**

A: Absolutely! Add new `.livemd` files to any phase directory.

## 🎯 Next Steps

1. **Start here:** Open `setup.livemd`
2. **Begin learning:** Phase 1, Checkpoint 1
3. **Track progress:** Use `dashboard.livemd`
4. **Get help:** Elixir Forum, Slack, GitHub Issues

**Happy learning!** 🚀

---

*For questions or issues, see the main repository README or open an issue on GitHub.*
