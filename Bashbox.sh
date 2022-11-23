NAME="gitpod.tmux"
CODENAME="gitpod.tmux"
AUTHORS=("AXON <axonasif@gmail.com>")
VERSION="1.0"
DEPENDENCIES=(
	std
	https://github.com/bashbox/libtmux::2863b38
)
REPOSITORY=""
BASHBOX_COMPAT="0.4.0~"

bashbox::build::after() {
  declare target_path="$_arg_path/${CODENAME}";
	cp "$_target_workfile" "$target_path";
	chmod +x "$target_path";
}
