NAME="tmux-gitpod"
CODENAME="tmux-gitpod"
AUTHORS=("AXON <axonasif@gmail.com>")
VERSION="1.0"
DEPENDENCIES=(
	std
	https://github.com/bashbox/libtmux::2863b38
)
REPOSITORY=""
BASHBOX_COMPAT="0.4.0~"

bashbox::build::after() {
	cp "$_target_workfile" "$_arg_path/$CODENAME";
	chmod +x "$_arg_path/$CODENAME";
}
