use ui;
use misc;
use libtmux::common;
use std::native::sleep;
use std::process::get_temp;

function is::gitpod() {
      # Check for existent of this gitpod-specific file and the ENV var.
      test -e /usr/bin/gp && test -v GITPOD_REPO_ROOT;
}

function main() {
  exec 2>>/tmp/tmux-gitpod

  # Main loop
  if test -n "${*:-}"; then {
    unset -f get::gitpod-modules;
    "$@";
  } else {

    declare plugin_options;
    declare -a meters indicators;

    if plugin_options="$(tmux::show-option "@gitpod-modules")"; then {

      for mod in $plugin_options; do {

        case "$mod" in
          "ui:theme")
            ui::theme;
            ;;
          "meter:cpu")
            meters+=(cpu);
            ;;
          "meter:memory")
            meters+=(memory);
            ;;
          "meter:disk")
            meters+=(disk);
            ;;
          "indicator:dotfiles_progress")
            indicators+=(dotfiles_progress);
            ;;
          "misc::keybinds")
            misc::keybinds;
            ;;
        esac

      } done

    } else {
      ui::theme;
      meters+=(cpu memory disk);
      indicators+=(dotfiles_progress);
      misc::keybinds;
    } fi

    if is::gitpod; then {
      declare func;

      for func in ui::meters ui::indicators; do {
        declare -n ref="${func##*:}";

        if test -n "${ref:-}"; then {
          tmux set-option -ga status-right "#(exec $0 $func ${ref[*]})";
        } fi

      } done

    } fi

  } fi

}

