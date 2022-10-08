use libtmux;
use gitpod_tasks;
use ui;

function main() {
	export TMUX_SESSION_NAME="main";

	# Ensure a session is created
	tmux::create_session;

	for mod in $(DEFAULT_VALUE='' tmux::get_option "$tmux_option_name"); do {
		case "$mod" in
			"tasks")
			;;
			
		esac
	} done
}

