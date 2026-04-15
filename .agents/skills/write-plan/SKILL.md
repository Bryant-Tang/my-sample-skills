---
name: write-plan
description: 'Write plan.md, test-plan.md, and decomposed test-n.md files from an approved goal.md. Use when a requirement already has goal.md and now needs single-session implementation tasks, AC including code formatting and indentation requirements, and final verification tasks with evidence rules. Replace the n in every test-n file name with the actual task number.'
argument-hint: 'Optional: path/to/goal.md'
user-invocable: true
---

# Write Plan

## When to Use
- A requirement already has `goal.md`.
- The next step is to create `plan.md`.
- Final verification needs to be split into `test-plan.md` plus multiple `test-n.md` files.
- The work needs explicit AC and evidence rules before implementation starts.

## Outcome
- One target `goal.md` is identified.
- One `plan.md` is created beside it.
- One `test-plan.md` is created beside it.
- One `test-n.md` file is created for each verification task listed in `test-plan.md`, and `n` must be replaced with the actual task number.

## Placeholder Rule
- Replace every `test-n` placeholder with the actual verification task number in file names and visible document text.

## Core Rules
- First determine which `goal.md` to use. If more than one candidate fits, ask the user instead of guessing.
- `plan.md` tasks must stay small enough that one implementation task can finish in a single chat session.
- Every implementation task must have explicit AC.
- Every implementation task AC must include a code formatting and indentation requirement so the finished code matches the repository's existing style and has no obvious formatting drift.
- Every verification task must stay small enough that one verification task can finish in a single chat session.
- Every verification task must define evidence.
- Browser-verifiable tasks must use actual system screenshots embedded directly in `test-n.md` with Markdown image syntax.
- Screenshot evidence must show the real system page only. Do not use annotated, synthetic, or manually edited images.
- Non-browser tasks must use file plus line links as evidence.

## Verification Mode Rules
- Default to browser-backed verification when the requirement affects a user-facing flow that can be reproduced locally through build, debug, and browser interaction.
- Use non-browser verification when the requirement is backend-only, static-audit oriented, environment-limited, or otherwise cannot be safely and reliably proven through the browser.
- Mixed mode is allowed. A single `test-plan.md` may contain both browser tasks and non-browser tasks.

## Procedure
1. Identify the target `goal.md`. If the branch name and specs path clearly point to one file, use it. Otherwise ask the user.
2. Read `goal.md` and extract the requirement scope, constraints, impact, and expected validation style.
3. Create `plan.md` from the [plan template](./assets/plan.template.md).
4. Split the implementation into ordered tasks. Keep each task narrow enough for a single chat session.
5. For each implementation task, write goal, scope, AC, and completion criteria.
6. In every implementation task AC section, include an explicit acceptance criterion that code formatting and indentation must be checked and must match the repository's existing style.
7. Create `test-plan.md` from the [test-plan template](./assets/test-plan.template.md).
8. Split final verification into ordered `test-n.md` tasks, replacing `n` with the actual verification task number. Do not collapse everything into one large final verification document.
9. Create one `test-n.md` file per verification task from the [test-n template](./assets/test-n.template.md), and replace `n` with the actual verification task number.
10. If any verification task needs browser screenshots, ensure the spec folder is ready to hold screenshot files under `screenshots/` when `testing-and-proof` runs.
11. Surface any ambiguous assumptions that still need user confirmation.

## Decision Rules
- If nearby spec folders already show an accepted browser-backed verification style for the same repository workflow, reuse that style instead of inventing a new one.
- If nearby spec folders already show an accepted non-browser evidence style for the same repository workflow, reuse that style when browser proof is not a realistic or meaningful success signal.
- Keep implementation tasks and verification tasks aligned, but do not force a one-to-one mapping when the final proof needs a different grouping.
- If a verification task would require too many manual steps, split it further into additional `test-n.md` files, replacing `n` with the actual verification task number in each file.

## Completion Checks
- `plan.md` exists and all implementation tasks have AC.
- Every implementation task AC explicitly requires code formatting and indentation to be checked and aligned with existing repository style.
- `test-plan.md` exists and lists the verification tasks in order.
- All referenced `test-n.md` files exist, with `n` replaced by the actual verification task number.
- Each `test-n.md` defines evidence that matches its verification mode.

## Templates
- [plan template](./assets/plan.template.md)
- [test-plan template](./assets/test-plan.template.md)
- [test-n template](./assets/test-n.template.md)