---
name: run-project
description: 'Start the target ASP.NET web project in detached IIS Express using the URL configured in the web csproj and confirm the port is listening. Use when a repo needs IIS Express startup without terminal blocking after build-project has completed.'
argument-hint: 'Optional: start-only | restart'
user-invocable: true
---

# Run Project

## When to Use
- Start this repository's IIS Express debug target after the web project is already built.
- Start IIS Express in the background without blocking on `Enter 'Q' to stop IIS Express`.
- Reproduce the exact commands that were already proven to work in this workspace.
- Restart a stale IIS Express process on the configured local port.

## Required Dependency
- Use `build-project` first when the latest web binaries may not exist or may be stale.

## Fixed Constraints
- Site root is derived from `.agents/skill-scripts.psd1` key `BUILD_PROJECT_PATH`.
- IIS Express executable path comes from `.agents/skill-scripts.psd1` key `RUN_IIS_EXPRESS_PATH`.
- When `.agents/skill-scripts.psd1` provides `RUN_IIS_APPLICATIONHOST_CONFIG_PATH`, the skill starts IIS Express with that `applicationhost.config` and an auto-detected site from the config.
- Browser URL is derived from the target web csproj `IISUrl` entry referenced by `.agents/skill-scripts.psd1` key `BUILD_PROJECT_PATH`.
- Shell assumption: Windows PowerShell on Windows
- Do not replace these commands with foreground `iisexpress.exe`, another port, or a different startup mechanism.

## Exact Workflow
1. Stop stale IIS Express processes with [stop-iis.ps1](./scripts/stop-iis.ps1).
2. Start IIS Express as a detached background process on the port parsed from the target web csproj `IISUrl` with [start-iis-detached.ps1](./scripts/start-iis-detached.ps1).
3. Confirm the port is listening with [check-iis-listening.ps1](./scripts/check-iis-listening.ps1).
4. Report that the site is ready for browser verification or hand off to `testing-and-proof` if the user asked for proof.

## Decision Rules
- If `taskkill` says no `iisexpress.exe` process exists, continue.
- If `.agents/skill-scripts.psd1` is missing, or `BUILD_PROJECT_PATH` or `RUN_IIS_EXPRESS_PATH` is empty, stop and report the configuration problem before attempting startup.
- If the target `IISUrl` uses `https`, require `RUN_IIS_APPLICATIONHOST_CONFIG_PATH` so IIS Express can start with HTTPS bindings from `applicationhost.config`.
- If the target web csproj does not contain a valid `IISUrl`, stop and report the configuration problem before attempting startup.
- If `RUN_IIS_APPLICATIONHOST_CONFIG_PATH` is set but no matching site can be found in that config, stop and report the mismatch instead of guessing a site.
- If the configured port is occupied by a non-IIS Express process, stop and report the blocker instead of changing the port.
- If IIS Express is started directly in the terminal and blocks or immediately stops, rerun the detached script instead of trying foreground mode again.
- If the user needs browser-level confirmation, do not improvise here; use `testing-and-proof` or explicit browser tools after startup succeeds.
- Execute stop, start, and listening-port verification as separate terminal commands. Do not send them together in one multi-line shell block and do not chain them with `&&`.

## Required Config
Ensure `.agents/skill-scripts.psd1` includes these values:

```powershell
@{
	BUILD_PROJECT_PATH = 'path/to/web-project.csproj'
	RUN_IIS_EXPRESS_PATH = 'C:/Program Files/IIS Express/iisexpress.exe'
	RUN_IIS_APPLICATIONHOST_CONFIG_PATH = '.vs/YourSolution/config/applicationhost.config'
}
```

## Exact Commands
Run these commands exactly from the workspace root when reproducing the successful setup.

```powershell
powershell -ExecutionPolicy Bypass -File .agents/skills/run-project/scripts/stop-iis.ps1
powershell -ExecutionPolicy Bypass -File .agents/skills/run-project/scripts/start-iis-detached.ps1
powershell -ExecutionPolicy Bypass -File .agents/skills/run-project/scripts/check-iis-listening.ps1
```

## Completion Checks
- The listening-port check script shows the port parsed from the target web csproj `IISUrl` in `LISTENING` state.
- IIS Express was started in detached mode instead of blocking the terminal.
- The site is ready for browser verification on the URL parsed from the target web csproj `IISUrl`.

## Notes
- The successful run path starts `iisexpress.exe` directly from PowerShell and backgrounds the process without blocking the terminal.
- If `RUN_IIS_APPLICATIONHOST_CONFIG_PATH` is configured, the script prefers `iisexpress.exe /config:... /site:...` and auto-detects the site from project path, `IISUrl` port, or project folder name.
- If the parsed `IISUrl` uses `https`, the target project still needs an `applicationhost.config` site binding that matches that URL.
- This skill is easier to copy to another repository because `.agents/skill-scripts.psd1` only needs to point at the target web csproj and IIS Express executable, while scheme and port come from that csproj `IISUrl`.