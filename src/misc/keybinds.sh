function misc::keybinds() {
  true;
  tmux::chain-cmds <<CMD
  ## Switch windows with Alt/option+num
  $(for w in {0..9}; do printf '%s\n' "bind-key -n M-$w select-window -t $w"; done)
  ## For xterm.js (macbook)
  $(w=1; for k in ¡ ™ £ ¢ ∞ § ¶ • ª º; do printf '%s\n' "bind-key -n $k select-window -t $w" && w=$((w+1)); done)
CMD
}
