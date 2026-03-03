# Example: Error Learning System

How the ERR-### / RUL-### system prevents repeated mistakes.

---

## Scenario: Database Connection Error

### Session 3: Error Occurs

While working, Claude tries to query the database without checking if the connection pool is initialized. The query fails.

**error_logs.md gets updated:**

| ID | Date | Error Summary | Resolution | Rule |
|----|------|---------------|------------|------|
| ERR-001 | 2026-03-01 | DB query failed - connection pool not initialized | Added pool initialization check before queries | RUL-001 |

**error-rules.md gets updated:**

| ID | Rule | Caused By |
|----|------|-----------|
| RUL-001 | Always verify connection pool is initialized before database queries | ERR-001 |

### Session 4: Rule Prevents Repeat

At session start, `/session-start` loads `error-rules.md` and outputs:

```
### Error Prevention Rules
- RUL-001: Always verify connection pool is initialized before database queries
```

Now Claude automatically checks the connection pool before any database operation.

---

## Cross-Project Learning

If you enable the global dashboard (`~/work_logs/`):

**Project A** encounters an API rate limit error → creates RUL-005.

**Project B** starts a new session → `/session-start` loads `~/work_logs/error-rules.md` → Claude sees RUL-005 and avoids the same mistake in a completely different project.

```
~/work_logs/error-rules.md (global, shared)

| ID | Rule | Caused By |
|----|------|-----------|
| RUL-001 | Always verify connection pool before DB queries | ERR-001 |
| RUL-002 | Check file encoding before parsing CSV | ERR-003 |
| RUL-005 | Add exponential backoff for external API calls | ERR-007 |
```

---

## Why This Matters

| Without error-rules | With error-rules |
|---------------------|-----------------|
| Claude makes the same mistake in session 5 that it made in session 2 | Claude remembers and avoids it |
| Each `/clear` resets all knowledge | Rules persist across sessions |
| Errors in Project A don't help Project B | Global rules shared across all projects |
