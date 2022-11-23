use meters;
use theme;
use indicators;
# use menus;

# Colors
declare \
  WHITE='white' \
  WHITE_BACKGROUND='#ece7e5' \
  ORNAGE='#ffae33' \
  DARK_GRAY='#282a36' \
  ORANGE_LIGHT="#ffb45b" \
  DARK_BLUE='#12100c' \
  BLACK='#12100c' \
  LIGHT_GRAY='#565451' \
  RED='red' \
  YELLOW='yellow' \
  GREEN='green' \
  DARK_PURPLE='purple'

function ui::loop_constructor() {

  declare namespace="$1";
  declare str="$2";
  declare func;
  shift && shift;

  for func in "${@}"; do {
    ui::pushfn_to_stack_str "$str" "${namespace}::$func";
  } done

  declare -n str="$str";

  eval "function loop() { $str }";
}

function ui::pushfn_to_stack_str() {
  declare -n stack_str="$1";
  declare fn="$2";
  stack_str="${stack_str:-}${fn} ; "
}

function ui::status-bar_common {
  printf '\n'; # init quick draw

  tmux \
    set-option -g status-left-length 100\; \
    set-option -g status-right-length 100
}
