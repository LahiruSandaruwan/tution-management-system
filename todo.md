Here's a ready-to-use prompt for Claude Code:

---

```
Analyze my Tuition Management System with 5 applications: admin-web, backend, rfid-gate-system, student-app, and teacher-app.

**Phase 1 - Discovery:**
1. Scan all 5 project directories and understand the architecture
2. Read any README, TODO, CHANGELOG, or documentation files
3. Check for TODO/FIXME/HACK comments in the codebase
4. Identify incomplete features (empty functions, placeholder code, unimplemented routes/endpoints)
5. Look for console.log/print statements left for debugging
6. Check for commented-out code blocks

**Phase 2 - Issue Detection:**
1. Find potential bugs (null checks, error handling gaps, security issues)
2. Check API endpoint consistency between backend and frontend apps
3. Verify database schema completeness
4. Identify missing validations
5. Check authentication/authorization gaps

**Phase 3 - Report:**
Create a detailed markdown report with:
- Project structure overview
- List of pending features per application (prioritized)
- List of bugs/issues found (with severity: critical/high/medium/low)
- Suggested implementation phases with time estimates

**Phase 4 - Implementation:**
After showing me the report, wait for my approval. Then implement fixes phase by phase, starting with critical issues first. After each phase, summarize what was done and ask before proceeding to the next phase.

Start with Phase 1 now.
```

---

Save this as a `.md` file in your project root if you want to reuse it. Just paste it directly into Claude Code and it'll start analyzing your system systematically.