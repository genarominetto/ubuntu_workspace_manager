#!/bin/bash

# Ensure the required tools are installed
if ! command -v wmctrl &>/dev/null || ! command -v xdotool &>/dev/null; then
    echo "Please install 'wmctrl' and 'xdotool' before running this script."
    exit 1
fi

# Function to switch workspace, open the app, and snap it to the top-right corner
switch_and_open() {
    local WORKSPACE_INDEX=$1
    local APP_COMMAND=$2

    # Switch to the specified workspace
    wmctrl -s $WORKSPACE_INDEX

    # Open the application
    $APP_COMMAND &
    sleep 1  # Allow time for the application to fully initialize

    # Get the window ID of the most recently opened window
    WINDOW_ID=$(xdotool search --onlyvisible --name "$(basename $APP_COMMAND)" | tail -n 1)

    if [ -z "$WINDOW_ID" ]; then
        echo "Unable to find a window for the application: $APP_COMMAND in workspace $((WORKSPACE_INDEX + 1))"
        return
    fi

    # Focus the window to ensure it is ready for snapping
    xdotool windowactivate "$WINDOW_ID"

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

    echo "Opened and snapped $APP_COMMAND in workspace $((WORKSPACE_INDEX + 1))."
}

# Workspaces to process (zero-indexed: 4 = workspace 5, 5 = workspace 6, 6 = workspace 7)
WORKSPACES=(4 5 6)

# Application to open (defaults to Visual Studio Code if not provided)
APP_COMMAND=${1:-code}

# Loop through the specified workspaces
for WORKSPACE in "${WORKSPACES[@]}"; do
    switch_and_open "$WORKSPACE" "$APP_COMMAND"
done
