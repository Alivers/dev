# -----------------------
# aliases definition
# -----------------------
alias vim='nvim'
alias vi='nvim'

alias ll='ls -l'
alias la='ll -a'

alias cls='clear'

alias git='LANG=en_GB git'

# tmux
# new session
alias tn="tmux new -s "
# detach (ctrl+b d)
alias td="tmux detach"
# list sessions (ctrl+b s)
alias tls="tmux ls"
# attach to session
alias tat="tmux attach -t "
# kill session
alias tk="tmux kill-session -t "
# kill all sessions
alias tka="tmux kill-server"
# switch session
alias tsw="tmux switch -t "
# rename session (ctrl+b $)
alias trename="tmux rename-session -t "
# split pane top/bottom
alias tsv="tmux split-window"
# split pane left/right
alias tsh="tmux split-window -h"
# focus pane above
alias tmu="tmux select-pane -U"
# focus pane below
alias tmd="tmux select-pane -D"
# focus pane left
alias tml="tmux select-pane -L"
# focus pane right
alias tmr="tmux select-pane -R"
# swap pane up
alias tswapu="tmux swap-pane -U"
# swap pane down
alias tswapd="tmux swap-pane -D"
