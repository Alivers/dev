# Agent guidelines

## Git

Push straight to `main`; no feature branches or PRs. Before pushing, `git pull --rebase origin main` and make sure the working tree has nothing unrelated in it.

## Layout

- `rule/`: don't move or rename anything here. Proxy clients load these files by path.
- `setup/`: one Markdown file per machine type.
- `dotfiles/`: files meant to be downloaded or sourced as-is. Keep them valid for their format; no Markdown.
- `guides/<topic>/README.md`: one directory per topic, images next to the README.
- `README.md` at the root only describes what each directory is for. Don't list individual guides or put instructions in it.

Remove content once it's obsolete instead of marking it as old.

This repo is public. Never commit keys, certificates, passphrases or tokens (e.g. a Surge `[MITM]` CA).
