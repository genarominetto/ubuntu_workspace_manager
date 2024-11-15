#!/usr/bin/env python3

import subprocess
import json
import time
import sys
import os

class WorkspaceManager:
    def __init__(self):
        """Initialization: Read layouts and workspaces from JSON files"""
        # Read layouts from 'layouts.json'
        with open('layouts.json', 'r') as f:
            self.layouts = json.load(f)

        # Read workspaces from 'workspaces.json'
        with open('workspaces.json', 'r') as f:
            self.workspaces = json.load(f)

    def check_dependencies(self):
        """Check for required system dependencies: wmctrl and xdotool"""
        # Check if 'wmctrl' is installed
        if not self.is_command_available('wmctrl'):
            print("Please install 'wmctrl' before running this script.")
            sys.exit(1)

        # Check if 'xdotool' is installed
        if not self.is_command_available('xdotool'):
            print("Please install 'xdotool' before running this script.")
            sys.exit(1)

    def is_command_available(self, command):
        """Helper method to check if a command is available on the system"""
        return subprocess.call(['which', command], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0

    def switch_workspace(self, workspace_index):
        """Switch to the specified workspace"""
        subprocess.call(['wmctrl', '-s', str(workspace_index)])

    def open_application(self, app_command):
        """Open the application and return its window ID"""
        # Start the application
        subprocess.Popen(app_command, shell=True)
        time.sleep(1)  # Allow time for the application to initialize

        # Get the window ID of the most recently opened window matching the command
        window_id = self.get_window_id(app_command)
        if not window_id:
            print(f"Unable to find a window for the application: {app_command}")
            return None
        return window_id

    def get_window_id(self, app_command):
        """Get the window ID of the application based on the command"""
        # Use xdotool to search for windows with the application name
        try:
            output = subprocess.check_output(
                ['xdotool', 'search', '--onlyvisible', '--name', os.path.basename(app_command)],
                universal_newlines=True
            )
            window_ids = output.strip().split('\n')
            if window_ids:
                return window_ids[-1]  # Return the last window ID
        except subprocess.CalledProcessError:
            return None
        return None

    def move_and_resize_window(self, window_id, layout_name):
        """Move and resize the window according to the specified layout"""
        # Focus the window
        subprocess.call(['xdotool', 'windowactivate', window_id])

        # Get the layout dimensions
        layout = self.layouts.get(layout_name)
        if not layout:
            print(f"Layout '{layout_name}' not found.")
            return

        x = layout['x']
        y = layout['y']
        width = layout['width']
        height = layout['height']

        # Move and resize the window using wmctrl
        subprocess.call(['wmctrl', '-ir', window_id, '-e', f'0,{x},{y},{width},{height}'])

        print(f"Moved and resized window {window_id} to layout '{layout_name}'.")

    def run(self):
        """Main method to process workspaces and applications"""
        # Iterate over the workspaces
        for workspace_index, apps in self.workspaces.items():
            # Switch to the workspace
            self.switch_workspace(int(workspace_index))

            # Process each application in the workspace
            for app in apps:
                app_command = app['command']
                layout_name = app['layout']

                # Open the application and get its window ID
                window_id = self.open_application(app_command)
                if window_id:
                    # Move and resize the window according to the layout
                    self.move_and_resize_window(window_id, layout_name)

if __name__ == "__main__":
    manager = WorkspaceManager()
    manager.check_dependencies()
    manager.run()

