# dev

Personal dev-environment notes, dotfiles and proxy rules.

| Path | What's in it |
| --- | --- |
| [`setup/linux.md`](setup/linux.md) | Bootstrapping a fresh Linux box: SSH key, zsh + oh-my-zsh + p10k, Rust/Node/Python, Neovim + LunarVim, tmux, locale fix |
| [`dotfiles/aliases.sh`](dotfiles/aliases.sh) | Shell and tmux aliases, sourced from `~/.zshrc` |
| [`dotfiles/git-aliases.gitconfig`](dotfiles/git-aliases.gitconfig) | Git aliases, pulled in with `git config --global include.path` |
| [`rule/`](rule/) | Proxy routing rule sets (one file per service/region), plus `surge/` configs. Referenced by raw URL from proxy clients, so paths here must not change. |
| [`guides/weread-epub/`](guides/weread-epub/) | Making self-imported EPUBs show footnote popups and a correct TOC in WeRead (微信读书) |

New topics go under `guides/<topic>/` with a `README.md`; keep any images next to it.
