function misc::gitpod_tasks() {
    if is::gitpod && test ! -e "$HOME/.dotfiles/dotsh"; then {
        (
            # Await for a session
            until tmux has-session 2>/dev/null; do sleep 1; done;

            # Set session name
            tmux rename-session "gitpod";

            # Refresh window/panel index
            tmux new-window 'true' || :

            # Open an available editor
            local first_window editor
            local window_name="editor"
            if editor="$(command -v nvim || command -v  vim || command -v nano)" && editor="${editor##*/}"; then {
                if first_window="$(tmux list-windows -F '#{window_id}' | head -n1)"; then {
                    tmux rename-window -t :${first_window} "${window_name}"\; send-keys -t :${first_window} "${editor}" Enter;
                } else {
                    tmux new-window -t "${window_name}" -- bash -c "trap 'exec bash -li' EXIT ERR; '${editor}'";
                } fi
            } fi

            # Create tmux windows and attach to Gitpod task terminals
            local term_id term_name task_state symbol ref;
            while IFS='|' read -r _ term_id term_name task_state _; do {
                if [[ "$term_id" =~ [0-9]+ ]]; then {
                    for symbol in term_id term_name task_state; do {
                        declare -n ref="$symbol";
                        ref="${ref#"${ref%%[![:space:]]*}"}"
                        ref="${ref%"${ref##*[![:space:]]}"}"   
                    } done
                    if test "$task_state" == "running"; then {
                        tmux new-window -d -n "${term_name}" -- gp tasks attach "${term_id}"
                    } fi
                    unset symbol ref;
                } fi
            } done < <(gp tasks list --no-color)
        ) & disown
    } fi
}