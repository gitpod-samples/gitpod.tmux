#!/usr/bin/env bash
main@bashbox%gitpod.tmux () 
{ 
    if test "${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}" -lt 43; then
        { 
            printf 'error: %s\n' 'At least bash 4.3 is required to run this, please upgrade bash or use the correct interpreter' 1>&2;
            exit 1
        };
    fi;
    function process::self::exit () 
    { 
        local _r=$?;
        ( kill -USR1 "$___self_PID" 2> /dev/null || : ) & exit $_r
    };
    function process::self::forcekill () 
    { 
        kill -9 "$___self_PID" 2> /dev/null
    };
    function log::error () 
    { 
        local _retcode="${2:-$?}";
        local _exception_line="$1";
        local _source="${BB_ERR_SOURCE:-"${BASH_SOURCE[-1]}"}";
        if [[ ! "$_exception_line" == \(*\) ]]; then
            { 
                printf '[!!!] \033[1;31m%s\033[0m[%s]: %s\n' error "$_retcode" "${_source##*/}[${BASH_LINENO[0]}]: ${BB_ERR_MSG:-"$_exception_line"}" 1>&2;
                if test -v BB_ERR_MSG; then
                    { 
                        echo -e "STACK TRACE: (TOKEN: $_exception_line)" 1>&2;
                        local -i _frame=0;
                        local _treestack='|--';
                        local _line _caller _source;
                        while read -r _line _caller _source < <(caller "$_frame"); do
                            { 
                                printf '%s >> %s\n' "$_treestack ${_caller}" "${_source##*/}:${_line}" 1>&2;
                                _frame+=1;
                                _treestack+='--'
                            };
                        done
                    };
                fi
            };
        else
            { 
                printf '[!!!] \033[1;31m%s\033[0m[%s]: %s\n' error "$_retcode" "${_source##*/}[${BASH_LINENO[0]}]: SUBSHELL EXITED WITH NON-ZERO STATUS" 1>&2
            };
        fi;
        return "$_retcode"
    };
    \command unalias -a || exit;
    set -eEuT -o pipefail;
    shopt -sq inherit_errexit expand_aliases nullglob;
    trap 'exit' USR1;
    trap 'BB_ERR_MSG="UNCAUGHT EXCEPTION" log::error "$BASH_COMMAND" || process::self::exit' ERR;
    ___self="$0";
    ___self_PID="$$";
    ___self_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)";
    ___MAIN_FUNCNAME='main@bashbox%gitpod.tmux';
    ___self_NAME="gitpod.tmu";
    ___self_CODENAME="gitpod.tmux";
    ___self_AUTHORS=("AXON <axonasif@gmail.com>");
    ___self_VERSION="1.0";
    ___self_DEPENDENCIES=(std https://github.com/bashbox/libtmux::2863b38);
    ___self_REPOSITORY="";
    ___self_BASHBOX_COMPAT="0.4.0~";
    function bashbox::build::after () 
    { 
        declare target_path="$_arg_path/${CODENAME}";
        cp "$_target_workfile" "$target_path";
        chmod +x "$target_path"
    };
    function ui::meters () 
    { 
        ui::status-bar_common;
        declare func_stack;
        declare -a input_meters=("$@");
        declare tmp_dir && tmp_dir="$(get_temp::dir)";
        if [[ "${*}" =~ cpu|memory ]]; then
            { 
                ui::pushfn_to_stack_str func_stack meters::cpu_mem_common;
                json_cli="$(
      if res=$(command -v jq); then {
        : "$res";
      } elif res="$(command -v yq)"; then {
        : "$res";
      } else {
        log::error "None of jq or yq was found" 1 || exit;
      } fi
      printf '%s\n' "jq";
    )"
            };
        fi;
        ui::loop_constructor meters func_stack "${input_meters[@]}";
        i=1;
        while true; do
            { 
                print_buffer=();
                loop;
                printf '%s \n' "${print_buffer[*]}";
                ((i=i+1));
                sleep 3
            };
        done
    };
    function meters::cpu_mem_common () 
    { 
        IFS='
' read -d '' -r mem_used mem_max cpu_used cpu_max < <(gp top -j | $json_cli -rM ".resources | [.memory.used, .memory.limit, .cpu.used, .cpu.limit] | .[]") || true
    };
    function meters::cpu () 
    { 
        cpu_perc="$(( (cpu_used * 100) / cpu_max ))";
        print_buffer+=("#[bg=${RED},fg=#282a36,bold] CPU: ${cpu_perc}%")
    };
    function meters::memory () 
    { 
        read -r hmem_used hmem_max < <(numfmt -z --to=iec --format="%8.2f" "$mem_used" "$mem_max") || true;
        print_buffer+=("#[bg=#8be9fd,fg=#282a36,bold] MEM: ${hmem_used%?}/${hmem_max}")
    };
    function meters::disk () 
    { 
        if [ "${i:0-1}" == 1 ]; then
            read -r dsize dused < <(df -h --output=size,used /workspace | tail -n1) || true;
        fi;
        print_buffer+=("#[bg=green,fg=#282a36,bold] DISK: ${dused}/${dsize}")
    };
    function ui::theme () 
    { 
        true;
        tmux::chain-cmds <<CMD

  # Human-friendly window and pane indexing
  set-option -g base-index 1
  set-window-option -g pane-base-index 1

  # window style
  ##############
  set-window-option -g window-status-bell-style bold
  set-window-option -g window-status-activity-style underscore
  set-window-option -g window-status-format '#[fg=${WHITE}]#[bg=${DARK_GRAY}]#[fg=${RED},bold][#I]#[fg=${WHITE},nobold]#W'
  set-window-option -g window-status-current-format '#[fg=${BLACK},bg=${ORNAGE},bold] #W '

  # status-bar style
  ##################
  set-option -g status-style "bg=${DARK_GRAY},fg=${WHITE}"

  ## length
  set-option -g status-left-length 100
  set-option -g status-right-length 100

  ## left panel
  set-option -g status-left "#[bg=${BLACK},fg=${WHITE}]#{?client_prefix,#[bg=${YELLOW}],} #S "

  ## right panel (reset it)
  set-option -g status-right ""

  ## refresh interval
  set-option -g status-interval 3

  ## window tab(s) position
  set-option -g status-justify left

  ## window tab sep
  set-window-option -g window-status-separator '#[fg=${GREEN},bold]|'

  ## disable visual-activity notifcation
  set-option -g visual-activity off

  ## enable renumbering of windows
  set-option -g renumber-windows on

  # pane-border style
  ###################
  set-option -g pane-active-border-style "fg=${DARK_PURPLE}"
  set-option -g pane-border-style "fg=${LIGHT_GRAY}"

  # message style
  set-option -g message-style "bg=${LIGHT_GRAY},fg=${WHITE}"

  
CMD

    }
    function ui::indicators () 
    { 
        ui::status-bar_common;
        indicators_dotfiles_progress "$@"
    };
    function indicators_dotfiles_progress () 
    { 
        while pgrep -f "$HOME/.dotfiles/install.sh" > /dev/null; do
            for s in / - \\ \|;
            do
                sleep 1;
                printf '%s \n' "#[bg=#ff5555,fg=#282a36,bold] $s Dotfiles";
            done;
        done;
        current_status="$(tmux display -p '#{status-right}')";
        tmux set -g status-right "$(printf '%s\n' "$current_status" | sed "s|#(exec $self_path ${FUNCNAME[1]} ${*})||g")"
    };
    function ui::menus () 
    { 
        declare menu="$1";
        declare key="$2";
        tmux bind-key -T prefix "$key" run -b "exec $self_path menus::${menu}"
    };
    function menus::general () 
    { 
        declare workspace_url workspace_class_display_name workspace_class_description open_ports_data open_ports_count;
        IFS='
' read -d '' -r workspace_url workspace_class_display_name workspace_class_description < <(gp info -j | jq -r '[.workspace_url, .workspace_class.display_name, .workspace_class.description] | .[]') || true;
        open_ports_data="$(gp ports list)" || true;
        open_ports_count="$(tail -n +3 <<<"$open_ports_data" | wc -l)" || true;
        tmux display-menu -T "#[align=centre fg=orange]Gitpod" -x R -y P "" "-#[nodim, fg=green]Workspace class: #[fg=white]${workspace_class_description} (${workspace_class_display_name})" "" "" "-#[nodim, fg=green]Workspace URL: #[fg=white]${workspace_url}" "" "" "-#[nodim, fg=green]Count of ports: #[fg=white]${open_ports_count}" "" "" "" "Stop workspace" s "run -b 'tmux detach; gp stop'" "Manage ports" p "display-popup -E -w '70%' 'gp ports list | tail -n +3 | fzf'" "Take a snapshot" r "display-popup -E 'gp snapshot | fzf'" "" "Quit menu" q ""
    };
    declare WHITE='white' WHITE_BACKGROUND='#ece7e5' ORNAGE='#ffae33' DARK_GRAY='#282a36' ORANGE_LIGHT="#ffb45b" DARK_BLUE='#12100c' BLACK='#12100c' LIGHT_GRAY='#565451' RED='red' YELLOW='yellow' GREEN='green' DARK_PURPLE='purple';
    function ui::loop_constructor () 
    { 
        declare namespace="$1";
        declare str="$2";
        declare func;
        shift && shift;
        for func in "${@}";
        do
            { 
                ui::pushfn_to_stack_str "$str" "${namespace}::$func"
            };
        done;
        declare -n str="$str";
        eval "function loop() { $str }"
    };
    function ui::pushfn_to_stack_str () 
    { 
        declare -n stack_str="$1";
        declare fn="$2";
        stack_str="${stack_str:-}${fn} ; "
    };
    function ui::status-bar_common () 
    { 
        printf '\n';
        tmux set-option -g status-left-length 100\; set-option -g status-right-length 100
    };
    function misc::keybinds () 
    { 
        true;
        tmux::chain-cmds <<CMD
  ## Switch windows with Alt/option+num
  $(for w in {0..9}; do printf '%s\n' "bind-key -n M-$w select-window -t $w"; done)
  ## For xterm.js (macbook)
  $(w=1; for k in ¡ ™ £ ¢ ∞ § ¶ • ª º; do printf '%s\n' "bind-key -n $k select-window -t $w" && w=$((w+1)); done)
CMD

    }
    function tmux::show-option () 
    { 
        local opt="$1";
        local opt_val;
        if opt_val="$(tmux start-server\; show-option -gv "$opt" 2>/dev/null)" && test -n "${opt_val:-}"; then
            { 
                printf '%s\n' "$opt_val"
            };
        else
            if test -v DEFAULT_VALUE; then
                { 
                    printf '%s\n' "$DEFAULT_VALUE"
                };
            else
                { 
                    return 1
                };
            fi;
        fi
    };
    function tmux::chain-cmds () 
    { 
        declare -a cmds;
        declare cmd stdin;
        IFS= read -t0.01 -u0 -r -d '' stdin || :;
        while read -r cmd; do
            { 
                if ! [[ "$cmd" =~ ^\# ]] && test -n "${cmd:-}"; then
                    { 
                        eval "cmds+=(${cmd} ';')"
                    };
                fi
            };
        done <<< "$stdin";
        tmux "${cmds[@]}"
    };
    function sleep () 
    { 
        [[ -n "${_snore_fd:-}" ]] || { 
            exec {_snore_fd}<> <(:)
        } 2> /dev/null || { 
            local fifo;
            fifo=$(mktemp -u);
            mkfifo -m 700 "$fifo";
            exec {_snore_fd}<> "$fifo";
            rm "$fifo"
        };
        IFS='' read ${1:+-t "$1"} -u $_snore_fd || :
    };
    function get_temp::file () 
    { 
        if test -w /tmp; then
            { 
                printf '/tmp/%s\n' ".$$_$((RANDOM * RANDOM))"
            };
        else
            if res="$(mktemp -u)"; then
                { 
                    printf '%s\n' "$res" && unset res
                };
            else
                { 
                    return 1
                };
            fi;
        fi
    };
    function get_temp::dir () 
    { 
        if test -w /tmp; then
            { 
                printf '%s\n' '/tmp'
            };
        else
            if res="$(mktemp -u)"; then
                { 
                    printf '%s\n' "${res%/*}" && unset res
                };
            else
                { 
                    return 1
                };
            fi;
        fi
    };
    function is::gitpod () 
    { 
        test -e /usr/bin/gp && test -v GITPOD_REPO_ROOT
    };
    function main () 
    { 
        declare self_path="$___self_DIR/${___self##*/}";
        if test -n "${*:-}"; then
            { 
                unset -f get::gitpod-modules;
                "$@"
            };
        else
            { 
                declare plugin_options;
                declare -a meters indicators;
                if plugin_options="$(tmux::show-option "@gitpod-modules")"; then
                    { 
                        for mod in $plugin_options;
                        do
                            { 
                                case "$mod" in 
                                    "ui:theme")
                                        ui::theme
                                    ;;
                                    "meter:cpu")
                                        meters+=(cpu)
                                    ;;
                                    "meter:memory")
                                        meters+=(memory)
                                    ;;
                                    "meter:disk")
                                        meters+=(disk)
                                    ;;
                                    "indicator:dotfiles_progress")
                                        indicators+=(dotfiles_progress)
                                    ;;
                                    "misc:keybinds")
                                        misc::keybinds
                                    ;;
                                    "menu:general")
                                        ui::menus general g
                                    ;;
                                esac
                            };
                        done
                    };
                else
                    { 
                        ui::theme;
                        meters+=(cpu memory disk);
                        indicators+=(dotfiles_progress);
                        misc::keybinds;
                        ui::menus general g
                    };
                fi;
                if is::gitpod; then
                    { 
                        declare func;
                        for func in ui::meters ui::indicators;
                        do
                            { 
                                declare -n ref="${func##*:}";
                                if test -n "${ref:-}"; then
                                    { 
                                        tmux set-option -ga status-right "#(exec $self_path $func ${ref[*]})"
                                    };
                                fi
                            };
                        done
                    };
                fi
            };
        fi
    };
    main "$@";
    wait;
    exit
}
"main@bashbox%gitpod.tmux" "$@";
