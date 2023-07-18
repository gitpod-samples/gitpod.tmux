<p align="center"><img src="https://user-images.githubusercontent.com/39482679/203600977-327824cb-26a9-4802-821d-004363922f5b.png" alt="gitpod.tmux"></p>

Tmux plugin for Gitpod, with `.gitpod.yml` tasks integration. Provides theme, resource meters, indicators, keybindings and menus.

Can be used locally as well for the `ui:theme` module, other [modules](#modules) will be disabled outside of Gitpod.

# Installation

You do not need to install it if you are using [dotsh](https://github.com/axonasif/dotsh). But you can always install it in your own way in case you don't want to use `dotsh`.

## Quickstart

If you want to try it out as is:

- Go to <https://gitpod.io/user/preferences> and scroll down.
- Set <https://github.com/gitpod-samples/gitpod.tmux> as **Dotfiles - Repository URL** and click on `Save`.

## Custom setup

If you already have a dotfiles repository that you use on Gitpod, you can copy the contents from [install.sh](./install.sh) and append (while excluding the first shebang line) to your own [installation script](https://www.gitpod.io/docs/configure/user-settings/dotfiles#custom-installation-script).

### (ADVANCED) With [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm), if you're using TPM

Add plugin to the list of TPM plugins in `.tmux.conf`:

```tmux
set -g @plugin 'axonasif/gitpod.tmux'
```

Example `install.sh` for Gitpod dotfiles:

```bash
#!/usr/bin/env bash

# Install latest static tmux
sudo curl -L https://github.com/axonasif/build-static-tmux/releases/latest/download/tmux.linux-amd64.stripped -o /usr/bin/tmux
sudo chmod +x /usr/bin/tmux

# Auto start tmux on SSH or xtermjs
cat >> "$HOME/.bashrc" <<'EOF'
if test ! -v TMUX && (test -v SSH_CONNECTION || test "$PPID" == "$(pgrep -f '/ide/xterm/bin/node /ide/xterm/index.cjs' | head -n1)"); then {
  if ! tmux has-session 2>/dev/null; then {
    tmux new-session -n "editor" -ds "gitpod"
  } fi
  exec tmux attach
} fi
EOF

# Install TPM and non-interactively install the plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
"$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
```

# Modules

The following modules are available:

- `indicator:dotfiles_progress`
- `meter:cpu`
- `meter:disk`
- `meter:memory`
- `misc:keybindings`
- `misc:gitpod_tasks`
- `misc:ports_notify`
- `misc:validate_gitpodyml`
- `menu:general`
- `ui:theme`

By default, all are enabled unless you explicitly specify which ones you want.

For example, if you only want the **CPU meter** and **theme**, you can put the following line in your `.tmux.conf`:

```tmux
set -g @gitpod-modules "meter:cpu ui:theme"
```

As you can see, the modules can be specified this way, separated by space.

## menu:general

To open up the functions menu, press **prefix** + **g**. (e.g. `ctrl+b g`)

## misc:keybindings

This modules basically sets **Alt**(or Option on Mac) + **num** keybinds for switching tmux windows easily. You can disable it if you like.

## misc:gitpod_tasks

For auto creating tmux windows that attach to `.gitpod.yml` task terminals.

## misc:ports_notify

Display message in tmux when a new port is opened.

## misc:validate_gitpodyml

Prompt for running `gp validate` upon `.gitpod.yml` changes.

# Development and contributing

[![Hack in Gitpod!](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#github.com/axonasif/gitpod.tmux)
