<p align="center"><img src="https://user-images.githubusercontent.com/39482679/203600977-327824cb-26a9-4802-821d-004363922f5b.png" alt="gitpod.tmux"></p>

Tmux plugin for Gitpod. Provides theme, resource meters, indicators, keybindings and menus.

Can be used locally as well for the `ui:theme` module, other [modules](#modules) will be disabled outside of Gitpod.

# Installation

You do not need to install it if you are using [dotsh](https://github.com/axonasif/dotsh). However, if you want to use the theme locally, you may put it on your `.tmux.conf` for installing with TPM.

### With [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

```tmux
set -g @plugin 'axonasif/gitpod.tmux'
```

Hit `prefix + I` to fetch the plugin and source it. You should now be able to
use the plugin.

### Without TPM (Tmux Plugin Manager)

This plugin is built with [bashbox](https://github.com/bashbox/bashbox), so we get a self-contained compiled single script.

Run the following command(s) in your terminal.

```bash
curl -L "https://raw.githubusercontent.com/axonasif/gitpod.tmux/main/gitpod.tmux" --output ~/gitpod.tmux
chmod +x ~/gitpod.tmux
! grep -q 'gitpod.tmux' ~/.tmux.conf 2>/dev/null && echo "run-shell ~/gitpod.tmux" >> ~/.tmux.conf
```

Then you can reload TMUX environment to use it without restarting the session:
```bash
tmux source-file ~/.tmux.conf
```

# Modules

The following modules are available:

- `indicator:dotfiles_progress`
- `meter:cpu`
- `meter:disk`
- `meter:memory`
- `misc:keybindings`
- `ui:theme`
- `menu:general`

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

# Development and contributing

[![Hack in Gitpod!](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#github.com/axonasif/gitpod.tmux)
