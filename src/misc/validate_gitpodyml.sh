function misc::validate_gitpodyml() {
    if is::gitpod; then {
        local run_prompt+=(
            tmux display-menu
            -T "#[align=centre fg=orange]Debug .gitpod.yml"
            -x C -y C
            ""
                "-#[nodim, fg=green]Do you want to validate the workspace configuration?" "" ""
            ""

            "Validate" v "neww -n 'validate' 'gp validate'"
            ""
            "Dismiss" q ""
        )

        function watch() {
            tail -n 0 -F "${GITPOD_REPO_ROOT}/.gitpod.yml" 2>/dev/null | while read -r line; do
                "${run_prompt[@]}";
                break;
            done || true;
            watch;
        }
        watch;
    }; fi
}
