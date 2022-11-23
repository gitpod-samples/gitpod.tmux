function ui::meters() {

  ui::status-bar_common;
  
  # shellcheck disable=SC2034
  declare func_stack;
  declare -a input_meters=("$@");
  declare tmp_dir && tmp_dir="$(get_temp::dir)";

  if [[ "${*}" =~ cpu|memory ]]; then {
    ui::pushfn_to_stack_str func_stack meters::cpu_mem_common;

    # Get avilable json CLI
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

  } fi

  ui::loop_constructor meters func_stack "${input_meters[@]}";

  i=1;
  while true; do {
    print_buffer=();
    loop;
    printf '%s \n' "${print_buffer[*]}";
    ((i=i+1));
    sleep 3;
  } done

}

function meters::cpu_mem_common {

  # Read all properties
  IFS=$'\n' read -d '' -r mem_used mem_max cpu_used cpu_max \
  < <(gp top -j | $json_cli -rM ".resources | [.memory.used, .memory.limit, .cpu.used, .cpu.limit] | .[]") || true;

}

function meters::cpu {

  # CPU percentage
  cpu_perc="$(( (cpu_used * 100) / cpu_max ))";

  # Print out
  print_buffer+=("#[bg=${RED},fg=#282a36,bold] CPU: ${cpu_perc}%");

}

function meters::memory {

  # Human friendly memory numbers
  read -r hmem_used hmem_max < <(numfmt -z --to=iec --format="%8.2f" "$mem_used" "$mem_max") || true;

  # Print out
  print_buffer+=("#[bg=#8be9fd,fg=#282a36,bold] MEM: ${hmem_used%?}/${hmem_max}");

}

function meters::disk {

  # Disk usage
  if [ "${i:0-1}" == 1 ]; then
    read -r dsize dused < <(df -h --output=size,used /workspace | tail -n1) || true;
  fi

  # Print out
  print_buffer+=("#[bg=green,fg=#282a36,bold] DISK: ${dused}/${dsize}");

}

