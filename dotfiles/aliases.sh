# -----------------------
# aliases definition
# -----------------------
alias vim='lvim'
alias vi='lvim'

alias rm='rm'

alias ll='ls -l'
alias la='ll -a'

alias cls='clear'

alias git='LANG=en_GB git'

# tmux
# 1 新建会话
alias tn="tmux new -s "
# 2 分离会话(ctrl+b d)
alias td="tmux detach"
# 3 列出会话(ctrl+b s)
alias tls="tmux ls"
# 4 接入会话
alias tat="tmux attach -t "
# 5 杀死指定会话
alias tk="tmux kill-session -t "
# 6 杀死全部会话
alias tka="tmux kill-server"
# 7 切换会话
alias tsw="tmux switch -t "
# 8 重命名会话(ctrl+b $)
alias trename="tmux rename-session -t "
# 9 窗口上下划分窗格
alias tsv="tmux split-window"
# 10 窗口左右划分窗格
alias tsh="tmux split-window -h"
# 11 光标到上方窗格
alias tmu="tmux select-pane -U"
# 12 光标到下方窗格
alias tmd="tmux select-pane -D"
# 13 光标到上方窗格
alias tml="tmux select-pane -L"
# 14 光标到上方窗格
alias tmr="tmux select-pane -R"
# 15 交换窗格位置(当前窗格上移)
alias tswapu="tmux swap-pane -U"
# 16 交换窗格位置(当前窗格下移)
alias tswapd="tmux swap-pane -D"