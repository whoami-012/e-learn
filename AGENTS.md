# AGENTS.md

## General

- This is a production Flutter + Python project.
- Make minimal, targeted changes.
- Preserve the existing architecture and coding style.
- Never refactor unrelated code.

## Verification

By default:
- Do NOT run `flutter run`.
- Do NOT build APK/AAB.
- Do NOT run iOS builds.
- Do NOT execute long-running commands.

Only run:
- `dart format` on modified files.
- `flutter analyze` only if explicitly requested.

Assume the developer will:
- Run the application manually.
- Verify the UI manually.
- Provide any runtime errors if fixes are needed.

## Output

After completing changes:
- Summarize modified files.
- Explain why the change fixes the issue.
- Mention any manual testing steps.

If execution is required, ask for confirmation first.

# Token-Efficient Working Instructions

Optimize every task for minimum context and token usage while preserving correctness.

## Scope
- Work only on the exact task requested.
- Inspect only files directly relevant to the task.
- Do not scan the entire repository unless targeted inspection fails.
- Use targeted search commands such as `rg`, `find`, or symbol search before opening files.
- Do not read generated files, build output, dependencies, lockfiles, logs, coverage files, or large datasets unless required.
- Respect `.gitignore` and avoid `node_modules`, `.git`, `dist`, `build`, `.venv`, `vendor`, and cache directories.

## Implementation
- Make the smallest production-ready change that satisfies the request.
- Do not refactor unrelated code.
- Do not rewrite complete files when a focused patch is sufficient.
- Reuse existing components, utilities, conventions, and dependencies.
- Do not add dependencies unless necessary.
- Do not create extra documentation, examples, tests, or abstractions unless requested or essential.

## Testing
- Run only tests, linting, formatting, and type checks relevant to changed files.
- Do not run the complete test suite unless the change affects shared infrastructure or targeted tests are unavailable.
- Do not repeatedly rerun successful checks.

## Tools and agents
- Do not use web browsing, MCP tools, computer use, images, or external services unless required.
- Do not spawn subagents for small or well-scoped tasks.
- Avoid repeated searches and reopening files already inspected.
- Stop investigating once enough evidence exists to implement safely.

## Communication
- Keep analysis and status updates concise.
- Do not repeat the task, code, logs, or previous findings.
- Do not reproduce entire files in the final response.
- Report only:
  1. What changed
  2. Files changed
  3. Validation performed
  4. Any unresolved issue
- Keep the final response under 150 words unless detailed explanation is requested.

## Ambiguity
- Ask one concise question only when missing information blocks implementation.
- Otherwise, state the safest reasonable assumption and proceed.

## Completion
- Stop as soon as the requested acceptance criteria are satisfied.
- Do not propose or implement unrelated enhancements.