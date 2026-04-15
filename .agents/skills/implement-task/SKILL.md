---
name: implement-task
description: 'Implement plan.md tasks in order by delegating both coding and AC review to subagents. Use when plan.md already exists and each task should loop implement -> review -> rewrite task-n-review.md until COMPLETE, where n must be replaced with the actual task number, without running final test-plan verification.'
argument-hint: 'Optional: path/to/plan.md'
user-invocable: true
---

# Implement Task

## When to Use
- A requirement already has `plan.md`.
- The next step is to execute implementation tasks in order.
- Each task must be reviewed against its AC before moving on.
- Final verification from `test-plan.md` should not run yet.

## Outcome
- One target `plan.md` is identified.
- Each implementation task is executed in order through subagents.
- Each task has a `task-n-review.md` report written or overwritten by a review subagent, and `n` must be replaced with the actual task number.
- The loop stops only when the current task review says `COMPLETE`.

## Core Rules
- First determine which `plan.md` to use. If more than one candidate fits, ask the user instead of guessing.
- Do not implement the task directly in the parent agent. Use `runSubagent` for each implementation attempt.
- Do not review the task directly in the parent agent. Use `runSubagent` for each review attempt.
- One implementation task per implementation subagent invocation.
- One implementation task per review subagent invocation.
- If the review report is not `COMPLETE`, run another implementation subagent for that same task, then another review subagent, and overwrite the same report file.
- Do not run the final `test-plan.md` verification in this skill.

## Review Report Location Rule
- If the spec folder already contains `task-n-review.md` files at its root, keep that convention, but replace `n` with the actual task number when creating or overwriting the file.
- Otherwise default to `reviews/task-n-review.md` inside the same spec folder, with `n` replaced by the actual task number.

## Procedure
1. Identify the target `plan.md`. If ambiguous, ask the user.
2. Read `plan.md` and the sibling `goal.md`.
3. Determine the ordered implementation tasks and the AC for each one.
4. For the current task, invoke an implementation subagent with the task scope, files, AC, and an explicit instruction not to touch later tasks.
5. After the implementation attempt completes, invoke a review subagent with the same task scope and AC. The review subagent must write or overwrite the task report from the [task review template](./assets/task-review.template.md), and must replace every `task-n` placeholder with the actual task number in both file path and visible document title.
6. If the report verdict is `COMPLETE`, move to the next task.
7. If the report verdict is not `COMPLETE`, feed the blocking findings back into a new implementation subagent for the same task, then rerun the review subagent and overwrite the same report.
8. Repeat until the current task report says `COMPLETE`, then continue.
9. Stop after the planned implementation tasks are complete. Do not execute `test-plan.md` here.

## Decision Rules
- If a task is too large for a single chat session, stop and revise `plan.md` first instead of silently doing a mega-task.
- Review must judge the task only against the current AC and current scope, not against future tasks.
- Preserve existing user changes outside the current implementation scope.
- If a previous review file already exists but the code changed afterward, overwrite it with a fresh review instead of appending stale conclusions.

## Completion Checks
- Every completed task has a current `task-n-review.md` report with `n` replaced by the actual task number in the file path and visible title.
- Every current report verdict is `COMPLETE`.
- No final verification tasks were executed in this skill.

## Template
- [task review template](./assets/task-review.template.md)