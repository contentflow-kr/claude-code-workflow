# Example: Session Flow

A typical workflow using `/session-start` and `/session-end`.

---

## 1. Start of Session

```
You: /session-start
```

Claude reads `work_logs/chatlog.md`, `remind.md`, and `error-rules.md`, then outputs:

```
## Session Context Restored

### Previous Session Summary
- Last session: 2026-03-03 - Add user authentication
- Key work done: Implemented JWT middleware, added login endpoint

### Unfinished Tasks (2)
- [ ] Add refresh token rotation
- [ ] Write auth integration tests

### Project Rules (remind.md)
- Always use environment variables for secrets
- Run tests before committing

### Error Prevention Rules
- RUL-001: Always check token expiration before database queries (from ERR-001)
```

## 2. During Work

You work normally. Claude follows the rules from `remind.md` and avoids mistakes listed in `error-rules.md`.

## 3. End of Session

```
You: /session-end
```

Claude automatically:

1. **Updates chatlog.md** with session summary
2. **Logs errors** (if any occurred) to `error_logs.md` + derives rules to `error-rules.md`
3. **Appends to global dashboard** (if configured)
4. **Creates worklog** file: `2026_03_04_refresh_token_worklog.md`
5. **Asks about Git commit**:

```
Commit session changes to Git?
  [x] Commit all (Recommended)
  [ ] Selective commit
  [ ] Skip
```

6. **Commits** with auto-generated message:
```
Session 5: Add refresh token rotation

- Implemented refresh token rotation logic
- Added token expiration checks
- Fixed race condition in concurrent refresh

Co-Authored-By: Claude <noreply@anthropic.com>
```

7. **Reports completion** with next session suggestions.

---

## Key Benefit

Next time you start a new session (even after `/clear`), `/session-start` restores full context from `chatlog.md`. No information is lost.
