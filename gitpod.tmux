#!/usr/bin/env bash
main@bashbox%gitpod.tmux () 
{ 
    if test "${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}" -lt 43; then
        { 
            printf '[!!!] \033[1;31m%s\033[0m[%s]: %s\n' ERROR 1 "At least bash 4.3 is required to run this." "Please upgrade bash or use the correct interpreter." "If you're on MacOS, you can install latest bash using brew or nix." 1>&2;
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
        function ___errmsg () 
        { 
            printf '[!!!] \033[1;31m%s\033[0m[%s]: %s\n' ERROR "$_retcode" "$@" 1>&2
        };
        if [[ ! "$_exception_line" == \(*\) ]]; then
            { 
                ___errmsg "${_source##*/}[${BASH_LINENO[0]}]: ${BB_ERR_MSG:-"$_exception_line"}";
                if test -v BB_ERR_MSG; then
                    { 
                        printf "STACK TRACE: (TOKEN: %s)\n" "$_exception_line" 1>&2;
                        local -i _frame=0;
                        local _treestack='|-';
                        local _line _caller _source;
                        while read -r _line _caller _source < <(caller "$_frame"); do
                            { 
                                printf '%s >> %s\n' "$_treestack ${_caller}" "${_source##*/}:${_line}" 1>&2;
                                _frame+=1;
                                _treestack+='-'
                            };
                        done
                    };
                fi
            };
        else
            { 
                ___errmsg "${_source##*/}[${BASH_LINENO[0]}]: SUBSHELL EXITED WITH NON-ZERO STATUS"
            };
        fi;
        return "$_retcode"
    };
    \command unalias -a || true;
    set -eEuT -o pipefail;
    shopt -sq inherit_errexit expand_aliases nullglob;
    trap 'exit' USR1;
    trap 'BB_ERR_MSG="UNCAUGHT EXCEPTION" log::error "$BASH_COMMAND" || process::self::exit' ERR;
    ___self="$0";
    ___self_PID="$$";
    ___self_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)";
    ___MAIN_FUNCNAME='main@bashbox%gitpod.tmux';
    ___self_NAME="gitpod.tmux";
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
        print_buffer+=("#[bg=${RED},fg=${WHITE},bold] CPU: ${cpu_perc}%")
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
        if !is::gitpod; then
            { 
                return 0
            };
        fi;
        declare workspace_url workspace_class_display_name workspace_class_description workspace_inactivity_timeout open_ports_data open_ports_count;
        IFS='
' read -d '' -r workspace_url workspace_class_display_name workspace_class_description < <(gp info -j | jq -r '[.workspace_url, .workspace_class.display_name, .workspace_class.description] | .[]') || true;
        workspace_inactivity_timeout="$(gp timeout show)";
        open_ports_data="$(gp ports list)" || true;
        open_ports_count="$(tail -n +3 <<<"$open_ports_data" | wc -l)" || true;
        tmux display-menu -T "#[align=centre fg=orange]Gitpod" -x R -y P "" "-#[nodim, fg=green]Workspace class: #[fg=white]${workspace_class_description} (${workspace_class_display_name})" "" "" "-#[nodim, fg=green]Workspace URL: #[fg=white]${workspace_url}" "" "" "-#[nodim, fg=green]Inactivity timeout: #[fg=white]${workspace_inactivity_timeout}" "" "" "-#[nodim, fg=green]Count of ports: #[fg=white]${open_ports_count}" "" "" "" "Validate .gitpod.yml" v "neww -n 'validate' 'if ! test -e $GITPOD_REPO_ROOT/.gitpod.yml; then gp init -i; fi; gp validate'" "Stop workspace" s "run -b 'tmux detach; gp stop'" "Manage ports" p "run -b '$self_path submenu::gp_ports'" "Extend timeout" t "run -b 'tmux display-message -d 2000 \"\$(gp timeout extend)\"" "Take a snapshot" r "display-popup -E 'gp snapshot; echo; echo Press Enter\return to dismiss ...; read c'" "" "Quit menu" q ""
    };
    function submenu::gp_ports () 
    { 
        lines=();
        i=1;
        while read -r line; do
            if ! [[ "$line" == "|-"* ]]; then
                { 
                    IFS='|' read -r _ port_num port_status port_protocol port_url port_name _ <<< "$line";
                    if ! [[ "$port_status" =~ "not served" ]]; then
                        { 
                            lines+=("$line" "${i}" "run -b '$self_path submenu::manage_gp_ports ${port_num} \"${port_status}\" ${port_protocol} ${port_url} \"${port_name}\"'");
                            if [[ "$port_num" =~ [0-9]+ ]]; then
                                i=$((i+1));
                            fi
                        };
                    fi
                };
            fi;
        done < <(gp ports list --no-color);
        run+=(tmux display-menu -T "#[align=centre fg=orange]Gitpod" -x C -y C "" "-#[nodim, fg=green]${lines[0]}" "" "" "" "${lines[@]:3}" "" "#[fg=red]Quit menu" q "");
        "${run[@]}"
    };
    function submenu::manage_gp_ports () 
    { 
        local port_num="$1";
        local port_status="$2";
        local port_protocol="$3";
        local port_url="$4";
        local port_name="$5";
        local symbol ref run;
        for symbol in port_status port_name;
        do
            { 
                declare -n ref="$symbol";
                ref="${ref#"${ref%%[![:space:]]*}"}";
                ref="${ref%"${ref##*[![:space:]]}"}"
            };
        done;
        run+=(tmux display-menu -T "#[align=centre fg=orange]Select action" -x C -y C "" "-#[nodim, fg=blue]What do you want to do with port ${port_num}?" "" "" "" "Open in browser" o "run -b 'gp preview ${port_url} --external'");
        if [[ "$port_status" =~ private ]]; then
            { 
                run+=("Set visibility to Public" v "run -b 'gp ports visibility ${port_num}:public 1>/dev/null'")
            };
        else
            { 
                run+=("Set visibility to Private" v "run -b 'gp ports visibility ${port_num}:private 1>/dev/null'")
            };
        fi;
        if [[ "$port_protocol" == http ]]; then
            { 
                run+=("Set protocol to HTTPS" p "run -b 'gp ports protocol ${port_num}:https 1>/dev/null'")
            };
        else
            { 
                run+=("Set protocol to HTTP" p "run -b 'gp ports protocol ${port_num}:http 1>/dev/null'")
            };
        fi;
        run+=("" "#[fg=red]Quit menu" q "");
        "${run[@]}"
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
    function misc::gitpod_tasks () 
    { 
        if is::gitpod && test ! -e "$HOME/.dotfiles/dotsh"; then
            { 
                ( until tmux has-session 2> /dev/null; do
                    sleep 1;
                done;
                tmux rename-session "gitpod";
                tmux new-window 'true' || :;
                local first_window editor;
                local window_name="editor";
                if editor="$(command -v nvim || command -v  vim || command -v nano)" && editor="${editor##*/}"; then
                    { 
                        if first_window="$(tmux list-windows -F '#{window_id}' | head -n1)"; then
                            { 
                                tmux rename-window -t :${first_window} "${window_name}"\; send-keys -t :${first_window} "${editor}" Enter
                            };
                        else
                            { 
                                tmux new-window -t "${window_name}" -- bash -c "trap 'exec bash -li' EXIT ERR; '${editor}'"
                            };
                        fi
                    };
                fi;
                local term_id term_name task_state symbol ref;
                while IFS='|' read -r _ term_id term_name task_state _; do
                    { 
                        if [[ "$term_id" =~ [0-9]+ ]]; then
                            { 
                                for symbol in term_id term_name task_state;
                                do
                                    { 
                                        declare -n ref="$symbol";
                                        ref="${ref#"${ref%%[![:space:]]*}"}";
                                        ref="${ref%"${ref##*[![:space:]]}"}"
                                    };
                                done;
                                if test "$task_state" == "running"; then
                                    { 
                                        tmux new-window -d -n "${term_name}" -- gp tasks attach "${term_id}"
                                    };
                                fi;
                                unset symbol ref
                            };
                        fi
                    };
                done < <(gp tasks list --no-color) ) & disown
            };
        fi
    };
    function misc::ports_notify () 
    { 
        local forwarded_ports=();
        function read_ports () 
        { 
            while sleep 2; do
                while read -r line; do
                    IFS='|' read -r _ port_num port_status port_protocol port_url port_name _ <<< "$line";
                    if [[ "$port_num" =~ [0-9]+ ]] && ! [[ "${forwarded_ports[*]}" =~ (^| )${port_num}($| ) ]]; then
                        { 
                            forwarded_ports+=("$port_num");
                            echo "$port_num";
                            tmux display-message -d 5000 "Port${port_num}is open: $port_url"
                        };
                    fi;
                done < <(gp ports list --no-color);
            done
        };
        read_ports
    };
    function misc::validate_gitpodyml () 
    { 
        local run_prompt+=(tmux display-menu -T "#[align=centre fg=orange]Debug .gitpod.yml" -x C -y C "" "-#[nodim, fg=green]Do you want to validate the workspace configuration?" "" "" "" "Validate" v "neww -n 'validate' 'gp validate'" "" "Dismiss" q "");
        function watch () 
        { 
            tail -n 0 -F "${GITPOD_REPO_ROOT}/.gitpod.yml" 2> /dev/null | while read -r line; do
                "${run_prompt[@]}";
                break;
            done || true;
            watch
        };
        watch
    };
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
                                    "misc:gitpod_tasks")
                                        tmux run-shell -b "exec $self_path misc::gitpod_tasks"
                                    ;;
                                    "misc:ports_notify")
                                        tmux run-shell -b "exec $self_path misc::ports_notify"
                                    ;;
                                    "misc:validate_gitpodyml")
                                        tmux run-shell -b "exec $self_path misc::validate_gitpodyml"
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
                        tmux run-shell -b "exec $self_path misc::gitpod_tasks";
                        tmux run-shell -b "exec $self_path misc::ports_notify";
                        tmux run-shell -b "exec $self_path misc::validate_gitpodyml";
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
