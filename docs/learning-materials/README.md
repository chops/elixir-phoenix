# Learning Materials Overview

**Comprehensive guide to all learning resources in this repository**

---

## 🎯 Quick Navigation

| I want to... | Go to... |
|-------------|----------|
| **Understand the overall system** | [LESSON-PLANNING-SYSTEM.md](../LESSON-PLANNING-SYSTEM.md) |
| **See the big picture** | [curriculum-map.md](../curriculum-map.md) |
| **Start Phase 1** | [phase-01-study-guide.md](../guides/phase-01-study-guide.md) |
| **Practice exercises** | [phase-01-workbook.md](../workbooks/phase-01-workbook.md) |
| **Teach Phase 1** | [phase-01-lesson-plan.md](../lessons/phase-01-lesson-plan.md) |
| **Read theory** | [phase-01-core.md](../reading/phase-01-core.md) |
| **Check requirements** | [roadmap.md](../roadmap.md) |

---

## 📚 Material Types

### 📘 Workbooks (`docs/workbooks/`)
Interactive exercises with fill-in-the-blank code, self-assessment checkpoints, and solutions.

**Use when:** You want hands-on practice with immediate feedback

**Current:** Phase 1 workbook complete

### 📗 Study Guides (`docs/guides/`)
Day-by-day reading schedules with morning/afternoon sessions and completion checklists.

**Use when:** You need a structured learning schedule

**Current:** Phase 1 study guide complete (10-day plan)

### 📕 Lesson Plans (`docs/lessons/`)
Detailed teaching materials with methodology, assessment rubrics, and instructor notes.

**Use when:** You're teaching or need comprehensive reference

**Current:** Phase 1 lesson plan complete

### 📊 Curriculum Map (`docs/curriculum-map.md`)
Visual dependency graphs, learning tracks, and skill progression matrix.

**Use when:** You need to see the big picture or choose a learning path

### 📖 Reading Notes (`docs/reading/`)
Book summaries, key concepts, code snippets, and exercises from primary texts.

**Use when:** You want theory and concept explanations

**Current:** All 17 phases have reading notes

---

## 🚀 Getting Started

### For Self-Learners

```
Step 1: Read curriculum-map.md
        → Choose your learning path
        → Understand phase dependencies

Step 2: Open phase-N-study-guide.md
        → See 10-day schedule
        → Gather required books

Step 3: Follow daily schedule
        → Read assigned materials
        → Complete workbook exercises
        → Build required apps

Step 4: Verify completion
        → Run `make ci`
        → Check success criteria
        → Advance to next phase
```

**Start here:** [Phase 1 Study Guide](../guides/phase-01-study-guide.md)

### For Instructors

```
Step 1: Read phase-N-lesson-plan.md
        → Understand learning objectives
        → Review teaching methodology
        → Study assessment rubric

Step 2: Prepare materials
        → Set up code examples
        → Create grading spreadsheet
        → Review common pitfalls

Step 3: Teach Week 1 (Theory)
        → Assign readings from study guide
        → Facilitate workbook exercises
        → Answer questions

Step 4: Teach Week 2 (Practice)
        → Guide project implementation
        → Conduct code reviews
        → Grade with rubric

Step 5: Assess completion
        → Verify mastery gate
        → Review performance targets
        → Make advancement decisions
```

**Start here:** [Phase 1 Lesson Plan](../lessons/phase-01-lesson-plan.md)

### For Curriculum Designers

```
Step 1: Update roadmap.md
        → Add new phase details
        → Define learning objectives

Step 2: Create reading notes
        → Summarize books and docs
        → Extract key concepts

Step 3: Generate materials
        → Create workbook from drills
        → Build study guide from readings
        → Write lesson plan

Step 4: Update curriculum map
        → Add dependencies
        → Update time estimates

Step 5: Pilot and iterate
        → Test with students
        → Gather feedback
        → Refine materials
```

**Start here:** [Lesson Planning System](../LESSON-PLANNING-SYSTEM.md)

---

## 📋 Phase 1 Materials Checklist

All materials for Phase 1 (Elixir Core) are complete:

- ✅ **Workbook:** [phase-01-workbook.md](../workbooks/phase-01-workbook.md)
  - 7 learning checkpoints
  - Interactive exercises
  - Self-assessment questions
  - Solutions included

- ✅ **Study Guide:** [phase-01-study-guide.md](../guides/phase-01-study-guide.md)
  - 10-day schedule
  - Reading assignments
  - Daily checkpoints
  - Completion checklist

- ✅ **Lesson Plan:** [phase-01-lesson-plan.md](../lessons/phase-01-lesson-plan.md)
  - Teaching methodology
  - Assessment rubric
  - Common pitfalls
  - Instructor notes

- ✅ **Reading Notes:** [phase-01-core.md](../reading/phase-01-core.md)
  - Book summaries
  - Key concepts
  - Code snippets
  - Drills

- ✅ **Curriculum Map:** [curriculum-map.md](../curriculum-map.md)
  - Phase dependencies
  - Learning tracks
  - Skill progression

---

## 🎓 Learning Paths

### Path 1: Complete Beginner
**Duration:** 120-180 days (all phases)

```
Roadmap → Curriculum Map → Phase 1 Study Guide → Phase 1 Workbook
  ↓                           ↓                      ↓
Phase 2... → Phase 15      Daily Reading          Daily Exercises
```

**Materials:** All 4 types for each phase

### Path 2: Fast Track (Experienced)
**Duration:** 60-80 days (selected phases)

```
Curriculum Map (choose path) → Skip to Phase 3 → Focus on advanced
```

**Materials:** Lesson plans + workbooks (skip study guides)

### Path 3: Web-First
**Duration:** 50-70 days (web-focused phases)

```
P0 → P1 → P3 → P5 → P6 → P10 → P12
```

**Materials:** Study guides + workbooks

### Path 4: Systems Engineering
**Duration:** 90-120 days (systems-focused phases)

```
P0 → P1 → P2 → P3 → P4 → P8 → P9 → P10 → P13
```

**Materials:** All 4 types for depth

---

## 📖 How Materials Work Together

```
                    ROADMAP.MD (Source of Truth)
                            |
                            ↓
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
   READING NOTES      CURRICULUM MAP     LESSON PLANNING
   (Theory)           (Big Picture)       SYSTEM DOCS
        ↓                                       ↓
        └───────────────────┬───────────────────┘
                            ↓
                ┌───────────┼───────────┐
                ↓           ↓           ↓
           WORKBOOK    STUDY GUIDE   LESSON PLAN
           (Practice)  (Schedule)    (Teaching)
                ↓           ↓           ↓
                └───────────┼───────────┘
                            ↓
                    STUDENT LEARNING
                            ↓
                    APPS BUILT + TESTS PASS
                            ↓
                     ADVANCE TO NEXT PHASE
```

---

## 🔄 Maintenance

### Updating Materials

When roadmap changes:
1. Update `docs/roadmap.md` (source of truth)
2. Update `docs/reading/phase-*.md` (theory)
3. Regenerate workbook if drills change
4. Update study guide if readings change
5. Regenerate lesson plan (auto from roadmap)
6. Update curriculum map if dependencies change

### Version Control

All materials should include:
```markdown
**Version:** 1.0
**Generated:** 2025-11-05
**Based on:** docs/roadmap.md v1.2
```

### Feedback Loop

```
Students complete → Collect feedback → Update materials → Version bump
                                            ↓
                                    Test with next cohort
```

---

## 📊 Material Status

| Phase | Workbook | Study Guide | Lesson Plan | Reading Notes |
|-------|----------|-------------|-------------|---------------|
| 0 | ⏳ Planned | ⏳ Planned | ⏳ Planned | ✅ Complete |
| 1 | ✅ Complete | ✅ Complete | ✅ Complete | ✅ Complete |
| 2 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 3 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 4 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 5 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 6 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 7 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 8 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 9 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 10 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 11 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 12 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 13 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 14 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |
| 15 | 📋 Template | 📋 Template | 📋 Template | ✅ Complete |

**Legend:**
- ✅ Complete and tested
- 📋 Template available, can be generated
- ⏳ Planned for future

---

## 🎯 Next Steps

### To Complete Phase 1

1. **Read:** [Phase 1 Study Guide](../guides/phase-01-study-guide.md)
2. **Practice:** [Phase 1 Workbook](../workbooks/phase-01-workbook.md)
3. **Build:** `apps/labs_csv_stats` and `apps/pulse_core`
4. **Verify:** `make ci` passes
5. **Advance:** Move to Phase 2

### To Create Phase 2 Materials

1. **Read:** [Lesson Planning System](../LESSON-PLANNING-SYSTEM.md)
2. **Use:** Templates from Phase 1
3. **Generate:** Workbook, study guide, lesson plan for Phase 2
4. **Test:** Pilot with students
5. **Iterate:** Based on feedback

### To Contribute

1. **Read:** `CONTRIBUTING.md`
2. **Choose:** Material to improve
3. **Update:** Following templates
4. **Submit:** PR with changes
5. **Discuss:** In issue or PR comments

---

## 📞 Support

**Questions about materials?**
- Read [Lesson Planning System](../LESSON-PLANNING-SYSTEM.md)
- Check templates section
- Review examples

**Questions about content?**
- Read phase-specific lesson plan
- Check reading notes
- Review workbook solutions

**Want to contribute?**
- Open issue on GitHub
- Submit PR with updates
- Share feedback after use

---

## 📚 All Documentation

### Primary
- [Lesson Planning System](../LESSON-PLANNING-SYSTEM.md) - How everything works
- [Curriculum Map](../curriculum-map.md) - Visual overview
- [Roadmap](../roadmap.md) - Source of truth

### Phase 1 (Complete)
- [Study Guide](../guides/phase-01-study-guide.md) - 10-day schedule
- [Workbook](../workbooks/phase-01-workbook.md) - Interactive exercises
- [Lesson Plan](../lessons/phase-01-lesson-plan.md) - Teaching materials
- [Reading Notes](../reading/phase-01-core.md) - Theory

### Other Reading Notes (17 phases)
- Phase 0: [phase-00-tooling.md](../reading/phase-00-tooling.md)
- Phase 2: [phase-02-mailboxes.md](../reading/phase-02-mailboxes.md)
- Phase 3: [phase-03-genserver.md](../reading/phase-03-genserver.md)
- [... and 12 more](../reading/)

---

**Created:** 2025-11-05
**Version:** 1.0
**Maintainer:** System

Ready to start learning? → [Phase 1 Study Guide](../guides/phase-01-study-guide.md)
