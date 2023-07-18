#!/usr/bin/env bash

# Install latest static tmux
sudo curl -L https://github.com/axonasif/build-static-tmux/releases/latest/download/tmux.linux-amd64.stripped -o /usr/bin/tmux
sudo chmod +x /usr/bin/tmux

# Auto start tmux on SSH or xtermjs
cat >>"$HOME/.bashrc" <<'EOF'
if test ! -v TMUX && (test -v SSH_CONNECTION || test "$PPID" == "$(pgrep -f '/ide/xterm/bin/node /ide/xterm/index.cjs' | head -n1)"); then {
  if ! tmux has-session 2>/dev/null; then {
    tmux new-session -n "editor" -ds "gitpod"
  } fi
    exec tmux attach
} fi
EOF

curl -L "https://raw.githubusercontent.com/axonasif/gitpod.tmux/main/gitpod.tmux" --output ~/gitpod.tmux
chmod +x ~/gitpod.tmux
! grep -q 'gitpod.tmux' ~/.tmux.conf 2>/dev/null && echo "run-shell -b 'exec ~/gitpod.tmux'" >>~/.tmux.conf
