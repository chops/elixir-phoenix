# Hiring Loop

## Overview
Process for evaluating Elixir/OTP engineering candidates.

## Interview Stages

### Stage 1: Initial Screen (30 min)
**Goal**: Assess basic fit and experience

**Questions**
- Walk me through your experience with Elixir/Erlang
- Describe a challenging concurrency problem you've solved
- How do you approach learning new technologies?
- What interests you about this role?

**Evaluation Criteria**
- [ ] Basic Elixir knowledge
- [ ] Problem-solving approach
- [ ] Communication clarity
- [ ] Cultural fit

---

### Stage 2: Technical Phone Screen (60 min)
**Goal**: Evaluate core technical skills

**Format**
- 45 min coding exercise (shared screen)
- 15 min Q&A

**Exercise Options**
1. **GenServer Implementation**: Build a simple rate limiter
2. **Data Processing**: Parse and transform a CSV with Stream
3. **Debugging**: Fix a supervision tree issue

**Evaluation Criteria**
- [ ] Code quality and style
- [ ] OTP understanding
- [ ] Testing approach
- [ ] Debugging skills
- [ ] Communication during coding

**Scorecard**
- Strong pass: Invite to on-site
- Pass: Second technical screen
- Weak: No hire
- Strong no: No hire

---

### Stage 3: Take-Home Assignment (4-6 hours)
**Goal**: Assess real-world problem-solving

**Assignment**: Build a URL shortener service
- GenServer for in-memory storage
- Phoenix API endpoints
- Tests with ExUnit
- README with setup instructions

**Requirements**
- Supervision tree
- Proper error handling
- At least 80% test coverage
- Documentation

**Evaluation Criteria**
- [ ] Code organization
- [ ] OTP patterns
- [ ] Error handling
- [ ] Test coverage
- [ ] Documentation quality
- [ ] Production readiness

---

### Stage 4: On-Site (4 hours)
**Round 1: System Design (60 min)**
- Design a distributed job queue
- Discuss trade-offs
- Handle failure scenarios

**Round 2: Code Review (45 min)**
- Review their take-home assignment
- Discuss design decisions
- Ask about improvements

**Round 3: Pair Programming (60 min)**
- Add a feature to their take-home
- Collaborative coding
- See how they work with others

**Round 4: Team Fit / Leadership (45 min)**
- Past experiences
- Team collaboration
- Handling conflict
- Learning and growth

**Lunch: Cultural Fit (45 min)**
- Informal conversation
- Team dynamics
- Company values

---

### Stage 5: References (async)
**Questions for References**
- How would you describe [candidate]'s technical skills?
- What's their approach to difficult problems?
- How do they work in a team?
- What areas could they improve?
- Would you hire them again?

---

## Scoring Rubric

### Technical Skills (40%)
- Elixir/OTP fundamentals
- Code quality
- Testing
- System design

### Problem Solving (30%)
- Analytical thinking
- Debugging ability
- Trade-off analysis
- Creativity

### Communication (20%)
- Clarity of explanation
- Documentation
- Collaboration
- Teaching ability

### Cultural Fit (10%)
- Values alignment
- Team dynamics
- Growth mindset
- Initiative

## Decision Making
- **Hire**: 3+ strong passes, no strong nos
- **No Hire**: Any strong no OR <2 strong passes
- **Needs More Data**: Mixed signals, consider additional interview

## Post-Interview
- Send decision within 48 hours
- Provide feedback to candidates
- Maintain candidate relationship
- Update hiring metrics
