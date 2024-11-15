#!/bin/bash

# Ensure the required tools are installed
if ! command -v wmctrl &>/dev/null || ! command -v xdotool &>/dev/null; then
    echo "Please install 'wmctrl' and 'xdotool' before running this script."
    exit 1
fi

# Open the application (change 'code' to the desired application, e.g., firefox)
APP_COMMAND=${1:-code}

# Switch to workspace 5 (workspace indices are zero-based)
wmctrl -s 4

# Open the application
$APP_COMMAND &

# Wait for the application window to appear
sleep 2

# Get the window ID of the most recently opened window
WINDOW_ID=$(xdotool search --onlyvisible --name "$(basename $APP_COMMAND)")

if [ -z "$WINDOW_ID" ]; then
    echo "Unable to find a window for the application: $APP_COMMAND"
    exit 1
fi

# Move the application window to workspace 5
wmctrl -ir "$WINDOW_ID" -t 4

# Get the screen dimensions
SCREEN_WIDTH=$(xdpyinfo | awk -F '[ x]+' '/dimensions:/ {print $3}')
SCREEN_HEIGHT=$(xdpyinfo | awk -F '[ x]+' '/dimensions:/ {print $4}')

# Calculate the size and position for the top-right corner
WIDTH=$((SCREEN_WIDTH / 2))
HEIGHT=$((SCREEN_HEIGHT / 2))
X=$((SCREEN_WIDTH / 2))
Y=0

# Resize and move the window
wmctrl -ir "$WINDOW_ID" -e 0,"$X","$Y","$WIDTH","$HEIGHT"

echo "Snapped $APP_COMMAND to the top-right corner of the screen in workspace 5."

