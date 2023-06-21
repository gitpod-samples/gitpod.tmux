function misc::ports_notify() {
    local forwarded_ports=();

    function read_ports() {
        while sleep 2; do
            while read -r line; do
                IFS='|' read -r _ port_num port_status port_protocol port_url port_name _ <<<"$line"

                if [[ "$port_num" =~ [0-9]+ ]] && ! [[ "${forwarded_ports[*]}" =~ (^| )${port_num}($| ) ]]; then {
                    forwarded_ports+=("$port_num");
                    echo "$port_num"
                    tmux display-message "Port${port_num}is open: $port_url";
                } fi
            done < <(gp ports list --no-color)
        done
    }

    read_ports
}
