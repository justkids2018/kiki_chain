# Agent Entry

## Source Of Truth

Project-level agent behavior must follow shared platform governance.
Read these files first:

1. `.ai/system-platform/README.md`
2. `.ai/common-prompt/baseline/README.md`
3. `.github/copilot-instructions.md`

## Project-Specific Notes

Keep project-specific operational details in project docs (for example `docs/project-ops.md`),
not in this entry file.

For `kiki_web` architecture generation, use project-owned docs in `docs/architecture/` as the baseline.
For `kiki_web` implementation rules, follow `docs/architecture/kiki_web_flutter_simplified_ddd_architecture.md` and `docs/architecture/kiki_web_flutter_simplified_ddd_implementation_guide.md`.

## Execution Rule

- Prefer skill-first routing.
- Respect baseline boundaries and quality gates.
- For high-risk changes, require explicit review and rollback plan.
