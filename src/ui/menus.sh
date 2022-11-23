function ui::menus() {
 declare menu="$1";
 declare key="$2";
 tmux bind-key -T prefix "$key" run -b "exec $self_path menus::${menu}";
}

function menus::general {
  declare \
    workspace_url \
    workspace_class_display_name \
    workspace_class_description \
    \
    open_ports_data \
    open_ports_count;

  IFS=$'\n' read -d '' -r \
    workspace_url \
    workspace_class_display_name \
    workspace_class_description \
    < <(gp info -j | jq -r '[.workspace_url, .workspace_class.display_name, .workspace_class.description] | .[]') || true

  open_ports_data="$(gp ports list)" || true;
  open_ports_count="$(tail -n +3 <<<"$open_ports_data" | wc -l)" || true;

 tmux display-menu -T "#[align=centre fg=orange]Gitpod" -x R -y P \
        "" \
        "-#[nodim, fg=green]Workspace class: #[fg=white]${workspace_class_description} (${workspace_class_display_name})" "" "" \
        "-#[nodim, fg=green]Workspace URL: #[fg=white]${workspace_url}" "" "" \
        "-#[nodim, fg=green]Count of ports: #[fg=white]${open_ports_count}" "" "" \
        "" \
        "Stop workspace"   s "run -b 'tmux detach; gp stop'" \
        "Manage ports"     p "display-popup -E -w '70%' 'gp ports list | tail -n +3 | fzf'" \
        "Take a snapshot"  r "display-popup -E 'gp snapshot | fzf'" \
        "" \
        "Quit menu"       q "" 
}
