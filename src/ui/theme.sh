function ui::theme {

  true
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
