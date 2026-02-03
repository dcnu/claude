---
name: plan-review
description: Review a plan file and provide feedback before approval
argument-hint: [plan-file.md]
context: fork
agent: general-purpose
allowed-tools: Bash(ls *), Read, Glob, Read(~/.claude/plans/*)
---

# Plan Review

Review a plan file and provide structured feedback before approval.

**Argument:** $ARGUMENTS

## Plan File Discovery

1. **If argument provided:**
   - Check if `~/.claude/plans/$ARGUMENTS` exists (exact match)
   - If not found, search for partial matches: `ls ~/.claude/plans/*$ARGUMENTS*`
   - Use the matching file, or report error if no match or multiple matches

2. **If no argument:**
   - Find most recent plan: `ls -t ~/.claude/plans/*.md | head -1`

## Review Criteria

Evaluate the plan against these dimensions:

### 1. Completeness
- Is the scope clearly defined?
- Are all affected files identified?
- Are edge cases and error scenarios addressed?
- Are dependencies and prerequisites listed?

### 2. Technical Soundness
- Does the architecture follow best practices?
- Are the proposed patterns appropriate for the codebase?
- Is error handling considered?
- Are there potential performance concerns?

### 3. Alignment with Requirements
- Does the plan address all stated requirements?
- Is there scope creep beyond what was asked?
- Are acceptance criteria implicit or explicit?

### 4. Implementation Risk
- What is the complexity level?
- Are there integration risks?
- What testing is needed?
- Are there rollback considerations?

## Output Format

Produce a structured review with this format:

```markdown
# Plan Review: [plan-name]

## Summary
[1-2 sentence overview of what the plan proposes]

## Ratings

| Criterion | Rating | Notes |
|-----------|--------|-------|
| Completeness | ⬤⬤⬤◯◯ | [brief note] |
| Technical Soundness | ⬤⬤⬤⬤◯ | [brief note] |
| Requirements Alignment | ⬤⬤⬤⬤⬤ | [brief note] |
| Implementation Risk | LOW/MEDIUM/HIGH | [brief note] |

## Strengths
- [strength 1]
- [strength 2]

## Concerns
- [concern 1 with suggested mitigation]
- [concern 2 with suggested mitigation]

## Questions for Author
- [clarifying question if any]

## Verdict

**[APPROVE / APPROVE WITH CHANGES / NEEDS REVISION]**

[Brief justification for verdict]
```

## Verdict Definitions

- **APPROVE**: Plan is ready for implementation as-is
- **APPROVE WITH CHANGES**: Minor issues that can be addressed during implementation
- **NEEDS REVISION**: Significant gaps or concerns requiring plan updates before proceeding
