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
    workspace_inactivity_timeout \
    \
    open_ports_data \
    open_ports_count;

  IFS=$'\n' read -d '' -r \
    workspace_url \
    workspace_class_display_name \
    workspace_class_description \
    < <(gp info -j | jq -r '[.workspace_url, .workspace_class.display_name, .workspace_class.description] | .[]') || true

  workspace_inactivity_timeout="$(gp timeout show)";

  open_ports_data="$(gp ports list)" || true;
  open_ports_count="$(tail -n +3 <<<"$open_ports_data" | wc -l)" || true;

 tmux display-menu -T "#[align=centre fg=orange]Gitpod" -x R -y P \
        "" \
        "-#[nodim, fg=green]Workspace class: #[fg=white]${workspace_class_description} (${workspace_class_display_name})" "" "" \
        "-#[nodim, fg=green]Workspace URL: #[fg=white]${workspace_url}" "" "" \
        "-#[nodim, fg=green]Inactivity timeout: #[fg=white]${workspace_inactivity_timeout}" "" "" \
        "-#[nodim, fg=green]Count of ports: #[fg=white]${open_ports_count}" "" "" \
        "" \
        "Stop workspace"   s "run -b 'tmux detach; gp stop'" \
        "Manage ports"     p "display-popup -E -w '70%' 'gp ports list | tail -n +3 | fzf'" \
        "Extend timeout"   t "display-popup -E -w '30%' 'gp timeout extend; read'" \
        "Take a snapshot"  r "display-popup -E 'gp snapshot | fzf'" \
        "" \
        "Quit menu"       q "" 
}
