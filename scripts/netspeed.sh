#!/usr/bin/env sh

option_value="$(tmux show-option -gqv '@netspeed-option')"
#tmux display-message "My plugin option: $option_value"
#!/usr/bin/env bash

interface=eno1

set_option()
{
    tmux set -g @netspeed $1
}

loop() 
{
    while true; do
        SEC=1
        FECHA_INI=$(date +%s%N)
        RX1=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        sleep 1
        FECHA_FIN=$(date +%s%N)
        SEC=$(awk -v fecha_fin="$FECHA_FIN" -v fecha_ini="$FECHA_INI" 'BEGIN { printf "%.3f\n", (fecha_fin - fecha_ini) / 1000000000 }')
        #echo "INI: $FECHA_INI END: $FECHA_FIN TIME: $SEC"
        RX2=$(cat /sys/class/net/$interface/statistics/rx_bytes)
        BPS=$(awk -v rx2="$RX2" -v rx1="$RX1" -v sec="$SEC" 'BEGIN { printf "%.2f\n", (rx2 - rx1) / sec * 8 }')
        
        if awk -v bps="$BPS" 'BEGIN { exit !(bps > 1000) }'; then
            KBPS=$(awk -v bps="$BPS" 'BEGIN { printf "%.2f\n", bps / 1000 }')
        else
            value=$(echo "$BPS bps")
            set_option $value
            continue
        fi

        if awk -v kbps="$KBPS" 'BEGIN { exit !(kbps > 1000) }'; then
            MBPS=$(awk -v kbps="$KBPS" 'BEGIN { printf "%.2f\n", kbps / 1000 }')
        else
            value=$(echo "$KBPS Kbps")
            set_option $value
            continue
        fi

        if awk -v mbps="$MBPS" 'BEGIN { exit !(mbps > 1000) }'; then
            value=$(echo $(awk -v mbps="$MBPS" 'BEGIN { printf "%.2f Gbps\n", mbps / 1000 }'))
        else
            value=$(echo $MBPS "Mbps")
        fi

        set_option $value
    done
}

main() 
{
    loop
}

main