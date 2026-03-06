# Claude Code Guidelines

## Git Workflow

Before creating a new feature branch and pushing, always run these pre-flight checks:

1. `git fetch origin main` — ensure remote is up to date
2. `git status` — confirm working tree is clean, no uncommitted changes
3. `git log --oneline main --not origin/main` — confirm no unpushed commits on main
4. Check for stale feature branches and clean them up if needed

Only proceed with creating a new branch and pushing after all checks pass.
