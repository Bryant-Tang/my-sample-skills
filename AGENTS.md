# Workspace Instructions

Prefer invoking the most specific workspace skill when the task clearly matches an existing reusable workflow, instead of improvising an ad-hoc process.

Use the `memory` skill when current work may depend on previously stored repository context not already present in chat, or when new durable project facts should be remembered. Within that workflow, use any appropriate MCP memory entity for the context at hand.

When the current task may depend on previously stored project knowledge and that context is not already present in the chat, use the `memory` skill to proactively read from MCP memory before proceeding. Prefer targeted reads with `mcp_memory-server_open_nodes` or `mcp_memory-server_search_nodes` against the most relevant entity for the task.

When you decide that project-specific information should be remembered later, or when the user asks you to remember something, use the `memory` skill to store it in MCP memory instead of leaving it only in the chat. Choose any appropriate entity for the note. If the needed entity does not exist yet, create it first with `mcp_memory-server_create_entities`, then continue with `mcp_memory-server_add_observations`.

Only store durable project facts, confirmed decisions, proven commands, environment constraints, and repository-specific user preferences. Do not store secrets, credentials, personal data, speculative notes, temporary errors, or large raw logs.

After saving a user-requested memory through the `memory` skill, briefly tell the user what was stored.

Use the `start-dev` skill when a new bug fix or feature starts and the repo needs a dedicated `bugfix/` or `feature/` branch plus an initial `specs/.../goal.md` created through user discussion.

Use the `write-plan` skill when a requirement already has `goal.md` and now needs `plan.md`, `test-plan.md`, and decomposed `test-n.md` files, with `n` replaced by the actual verification task number.

Use the `implement-task` skill when a requirement already has `plan.md` and implementation should proceed task-by-task through subagents, with each task reviewed against its AC and recorded in `task-n-review.md` before moving on, with `n` replaced by the actual task number.

Use the `csharp-comment` skill when a task adds or changes C# classes or members and those symbols or related implementation logic need comments, including XML documentation comments plus single-line or multi-line explanations, that a new engineer can understand without current requirement context.

Use the `build-project` skill for reproducible ASP.NET MVC web builds of `Enterprise.TrainingSystemBackstage`, especially before startup verification or browser proof.

Use the `run-project` skill when the task is to start or restart IIS Express on port `30067` after the web project is built. If fresh binaries may be needed first, run `build-project` before `run-project`.

Use the `testing-and-proof` skill when a requirement already has `test-plan.md` and the user wants ordered verification, screenshots, browser proof, or non-browser evidence recorded back into the corresponding `test-n.md` files, with `n` replaced by the actual verification task number.

Use the `db-management` skill when the task requires inspecting project databases, checking schema or data, or producing SQL scripts under the repository's environment-split `sql files` folders.

Use the `markitdown` skill when the task requires converting a local document into Markdown through the workspace MarkItDown MCP tool, especially when the source file must be staged under `.markitdown/workdir` and referenced with a `file:///workdir/...` URI.

When running terminal commands for this repository, execute state-changing steps one command at a time. Do not send multi-line shell blocks and do not chain state-changing commands with `&&`. Run each stash, build, startup, shutdown, cleanup, or other side-effect command separately, inspect the result, and only then continue to the next step.

When writing `.sh` files for this repository, use `echo` for user-visible text output instead of `printf`.

When writing `.sh` files for this repository, do not start user-visible output text with the lowercase letter `h`, because this repository has observed a `run_in_terminal` rendering bug where such output may not be captured.

If multiple skills apply, choose the one closest to the user's requested outcome and then chain the dependent skills in the documented order. For new development work, the usual sequence is `start-dev` -> `write-plan` -> `implement-task` -> `testing-and-proof`.

Do not switch to different ports, tools, or database delivery conventions when an existing skill already defines the repository standard unless the user explicitly asks for that deviation.