---
name: build-project
description: 'Build the target ASP.NET web project with the exact proven MSBuild command against the configured web csproj. Use when you need a reproducible web build without building the full solution, especially before run-project or testing-and-proof.'
argument-hint: 'Optional: release-build'
user-invocable: true
---

# Build Project

## When to Use
- Build only the web project in this repository.
- Reproduce the exact MSBuild command already proven to work in this workspace.
- Avoid unrelated solution-level failures when the immediate goal is to prepare the website for startup or browser verification.
- Prepare fresh binaries before running `run-project` or `testing-and-proof`.

## Fixed Constraints
- Web project path comes from `.agents/skill-scripts.psd1` key `BUILD_PROJECT_PATH`.
- MSBuild executable path comes from `.agents/skill-scripts.psd1` key `BUILD_MSBUILD_PATH`.
- This skill targets MSBuild-based .NET Framework projects.
- Optional frontend packaging is controlled by `.agents/skill-scripts.psd1`.
- If `BUILD_FRONTEND_DIR_PATH` is configured, run the frontend packaging workflow from that directory after MSBuild succeeds.
- If `BUILD_NODE_VERSION` is configured, validate with `node -v` before running frontend commands because NVM for Windows may warn that it should be run from a terminal when invoked inside scripts.
- If frontend packaging is not configured, skip Node and frontend command checks entirely.
- Build configuration: `Release`
- Build platform: `AnyCPU`
- Shell assumption: Windows PowerShell on Windows
- Do not replace this workflow with `dotnet build` or full solution build.

## Exact Workflow
1. Confirm `.agents/skill-scripts.psd1` exists and `BUILD_PROJECT_PATH` points to the target `.csproj` relative to the workspace root.
2. Run [build-web.ps1](./scripts/build-web.ps1) from the workspace root.
3. Let MSBuild restore NuGet packages and then build the configured web project.
4. If `BUILD_FRONTEND_DIR_PATH` is configured, change into that directory after MSBuild succeeds.
5. If `BUILD_NODE_VERSION` is configured, run a Node version check and confirm the active Node version matches it.
6. If frontend packaging is configured, run the configured install command to restore frontend dependencies.
7. If frontend packaging is configured, run the configured build command to package frontend assets.
8. Confirm the full workflow exits with code `0`.
9. Report warnings separately from errors instead of treating warnings as build failure.

## Decision Rules
- If solution-level build errors are mentioned elsewhere, ignore them unless the build-project script fails.
- If `.agents/skill-scripts.psd1` is missing, or `BUILD_PROJECT_PATH` or `BUILD_MSBUILD_PATH` is empty, stop and report the configuration problem before attempting the build.
- If the configured MSBuild executable path is missing on the machine, stop and report the missing dependency instead of swapping to another build tool.
- If frontend packaging is configured and `BUILD_NODE_VERSION` is set, stop when the active `node -v` result does not match that configured version.
- If frontend packaging is configured and the configured install or build command fails, treat the overall build-project workflow as failed even when MSBuild succeeded.
- If frontend packaging is not configured, a successful MSBuild result is sufficient for this skill.
- If the user asks for another configuration or platform, clarify first because the proven workflow is `Release` plus `AnyCPU` only.
- Run the build command as a standalone terminal step. Do not combine it with stash apply, startup, cleanup, or other state-changing commands in the same multi-line shell block or with `&&`.

## Required Config
Create `.agents/skill-scripts.psd1` in the workspace root with this shape:

```powershell
@{
	BUILD_PROJECT_PATH = 'path/to/web-project.csproj'
	BUILD_MSBUILD_PATH = 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/MSBuild.exe'
	BUILD_FRONTEND_DIR_PATH = 'path/to/frontend-or-web-project-dir/'
	BUILD_NODE_VERSION = 'v10.15.3'
	BUILD_FRONTEND_INSTALL_COMMAND = @('yarn', 'install')
	BUILD_FRONTEND_BUILD_COMMAND = @('yarn', 'dev-build')
}
```

Only `BUILD_PROJECT_PATH` and `BUILD_MSBUILD_PATH` are required. Omit the frontend keys when the project has no Node-based asset packaging step.
When `BUILD_FRONTEND_DIR_PATH` is used, prefer a trailing `/` so the value is visually clear as a directory path.

## Exact Commands
Run this command exactly from the workspace root when reproducing the successful build workflow.

```powershell
powershell -ExecutionPolicy Bypass -File .agents/skills/build-project/scripts/build-web.ps1
```

## Completion Checks
- The build command exits with code `0`.
- NuGet package restore completed without restore errors.
- The configured web project build completed with no MSBuild errors.
- If `BUILD_NODE_VERSION` is configured, the active `node -v` result matched it.
- If frontend packaging is configured, the configured install and build commands completed successfully.
- The result is ready for `run-project` to launch the site.

## Notes
- The skill becomes easier to copy into another repository because `.agents/skill-scripts.psd1` carries the project-specific paths and optional frontend settings.
- The MSBuild executable path is still machine-specific, but it now lives in the same env file so the skill can move between repositories without editing the script.
- Use `testing-and-proof` when the user needs browser evidence after the build, not just a successful compile.