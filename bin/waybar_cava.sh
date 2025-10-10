#!/bin/bash
#
# waybar_cava.sh
# Visualizes CAVA output for Waybar modules (left/right halves)
# Usage:
#   waybar_cava.sh --left
#   waybar_cava.sh --right

# Prevent multiple instances
PID_FILE="/tmp/waybar_cava_$1.pid"
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    exit 0
fi
echo $$ > "$PID_FILE"

# Characters for bar levels
# use: ascii_max_range = 8 if starting with empty space
# bar_chars=" |▎▍▌▋▊▉█"
# bar_chars=" ▔▕▖▗▘▙▚▛▜▝▞▟"
bar_chars=" ▁▂▃▄▅▆▇█"

# Build a sed dictionary to replace numbers with bars
dict="s/;//g;"
for i in $(seq 0 $(( ${#bar_chars} - 1 ))); do
    dict="${dict}s/$i/${bar_chars:$i:1}/g;"
done

# Temporary CAVA config file
config_file="/tmp/waybar_cava_config_$1"

# Generate minimal CAVA config
cat <<EOF > "$config_file"
[general]
bars = 20
autosens = 1
framerate = 60
minimum_bar_height = 0

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 8
orientation = bottom
channels = stereo
stereo = split

[smoothing]
integral = 40
monstercat = 1
waves = 0
gravity = 120
EOF

# Determine side (default to left)
SIDE="left"
if [[ "$1" == "--right" ]]; then
    SIDE="right"
elif [[ "$1" == "--left" ]]; then
    SIDE="left"
fi

# Open FIFOs in the background to prevent blocking
# cat < /tmp/minicava_left_fifo  < /dev/null &
# cat < /tmp/minicava_right_fifo < /dev/null &

# Start CAVA and process output
cava -p "$config_file" | while read -r line; do
    # Replace digits with bar characters
    bars=$(echo "$line" | sed "$dict")

    # Split bars into left/right halves
    total=${#bars}
    half=$(( total / 2 ))

    if [[ "$SIDE" == "left" ]]; then
        part="${bars:0:half}"
        # fifo="/tmp/minicava_left_fifo"
    else
        part="${bars:half}"
        # fifo="/tmp/minicava_right_fifo"
    fi

    # Also write to FIFO (non-blocking)
    # if [ -p "$fifo" ]; then
    #     printf "%s\n" "$part" > "$fifo" &
    # fi

    # Output for Waybar
    echo "$part"
done

# Clean up PID and config file on exit
rm -f "$PID_FILE" "$config_file"