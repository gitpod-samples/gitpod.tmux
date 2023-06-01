function ui::menus() {
 declare menu="$1";
 declare key="$2";
 tmux bind-key -T prefix "$key" run -b "exec $self_path menus::${menu}";
}

function menus::general {

  if !is::gitpod; then {
    return 0;
  } fi

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
        "Validate .gitpod.yml" v "neww -n 'validate' 'if ! test -e $GITPOD_REPO_ROOT/.gitpod.yml; then gp init -i; fi; gp validate'" \
        "Stop workspace"   s "run -b 'tmux detach; gp stop'" \
        "Manage ports"     p "run -b '$self_path submenu::gp_ports'" \
        "Extend timeout"   t "run -b 'tmux display-message -d 2000 \"\$(gp timeout extend)\"" \
        "Take a snapshot"  r "display-popup -E 'gp snapshot; echo; echo Press Enter\return to dismiss ...; read c'" \
        "" \
        "Quit menu"       q "" 
}

function submenu::gp_ports() {
  lines=()
  i=1
  while read -r line; do
      if ! [[ "$line" == "|-"* ]]; then {
          IFS='|' read -r _ port_num port_status port_protocol port_url port_name _ <<<"$line"
          if ! [[ "$port_status" =~ "not served" ]]; then {
              lines+=("$line" "${i}" "run -b '$self_path submenu::manage_gp_ports ${port_num} \"${port_status}\" ${port_protocol} ${port_url} \"${port_name}\"'")
              if [[ "$port_num" =~ [0-9]+ ]]; then i=$((i+1)); fi
          } fi
      } fi
  done < <(gp ports list --no-color)

  run+=(
      tmux display-menu
      -T "#[align=centre fg=orange]Gitpod"
      -x C -y C
      ""
          "-#[nodim, fg=green]${lines[0]}" "" ""
      ""
          "${lines[@]:3}"
      ""
      "#[fg=red]Quit menu" q ""
  )

  "${run[@]}"

}

function submenu::manage_gp_ports() {
  local port_num="$1"
  local port_status="$2"
  local port_protocol="$3"
  local port_url="$4"
  local port_name="$5"
  local symbol ref run

  for symbol in port_status port_name; do {
      declare -n ref="$symbol";
      ref="${ref% }" && ref="${ref# }";
  } done

  run+=(
      tmux display-menu
      -T "#[align=centre fg=orange]Select action"
      -x C -y C
      ""
          "-#[nodim, fg=blue]What do you want to do with port ${port_num}?" "" ""
      ""

      "Open in browser" o "run -b 'gp preview ${port_url} --external'"
  )

  if [[ "$port_status" =~ private ]]; then {
      run+=(
          "Set visibility to Public" v "run -b 'gp ports visibility ${port_num}:public 1>/dev/null'"
      )
  } else {
      run+=(
          "Set visibility to Private" v "run -b 'gp ports visibility ${port_num}:private 1>/dev/null'"
      )
  } fi

  if [[ "$port_protocol" == http ]]; then {
      run+=(
          "Set protocol to HTTPS" p "run -b 'gp ports protocol ${port_num}:https 1>/dev/null'"
      )
  } else {
      run+=(
          "Set protocol to HTTP" p "run -b 'gp ports protocol ${port_num}:http 1>/dev/null'"
      )
  } fi


  run+=(
      ""
      "#[fg=red]Quit menu" q ""
  )

  "${run[@]}"
}

