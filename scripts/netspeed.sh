#!/usr/bin/env sh

netspeed_data="$(tmux show-option -gqv '@netspeed_data')"
tmux set -g @netspeed-max-download 0
MAX_DOWNLOAD_TEXT=""
#tmux display-message "My plugin option: $option_value"

interface=eno1

set_option()
{
	if [ $OPTION -eq "download" ]; then
	    icon="󰅢 "
	else
	    icon=""
	fi
	
    VALUE=" $OPTION$icon$(printf '%7.2f' $1) $(printf '%-4s' $2)**"
    BRIEF_VALUE="$(printf '%.2f' $1) $2"
    set_max $1
    tmux set -g @netspeed-$OPTION "$VALUE $MAX_TEXT"
}

set_max()
{

    max="$(tmux show-option -gqv @netspeed-max-$OPTION)"
    if awk -v bps="$BPS" -v max="$max" 'BEGIN { exit !(bps > max) }'; then
        tmux set -g @netspeed-max-$OPTION $BPS
        MAX_TEXT="(max $BRIEF_VALUE)"
    fi
}

calculate()
{
    FECHA_INI=$(date +%s%N)
    RX1=$(cat /sys/class/net/$interface/statistics/$RXTX)
    sleep 1
    FECHA_FIN=$(date +%s%N)
    RX2=$(cat /sys/class/net/$interface/statistics/$RXTX)
	SEC=$(awk -v fecha_fin="$FECHA_FIN" -v fecha_ini="$FECHA_INI" 'BEGIN { printf "%.3f\n", (fecha_fin - fecha_ini) / 1000000000 }')
	#echo "INI: $FECHA_INI END: $FECHA_FIN TIME: $SEC"
	BPS=$(awk -v rx2="$RX2" -v rx1="$RX1" -v sec="$SEC" 'BEGIN { printf "%7.2f\n", (rx2 - rx1) / sec * 8 }')

	if awk -v bps="$BPS" 'BEGIN { exit !(bps > 1000) }'; then
	    KBPS=$(awk -v bps="$BPS" 'BEGIN { printf "%7.2f\n", bps / 1000 }')
	else
	    value=$(echo "$BPS bps")
	    set_option $value
	    return
	fi

	if awk -v kbps="$KBPS" 'BEGIN { exit !(kbps > 1000) }'; then
	    MBPS=$(awk -v kbps="$KBPS" 'BEGIN { printf "%7.2f\n", kbps / 1000 }')
	else
	    value=$(echo "$KBPS Kbps")
	    set_option $value
	    return
	fi

	if awk -v mbps="$MBPS" 'BEGIN { exit !(mbps > 1000) }'; then
	    value=$(echo $(awk -v mbps="$MBPS" 'BEGIN { printf "%7.2f Gbps\n", mbps / 1000 }'))
	else
	    value=$(echo $MBPS "Mbps")
	fi

    set_option $value
}

main() 
{
    #if [[ $string == *'download'* ]]; then
    OPTION="download"
    RXTX="rx_bytes"
    calculate
    OPTION="upload"
    RXTX="tx_bytes"
    calculate
    tmux set -g @netspeed-DATE "$(date)"
}

main