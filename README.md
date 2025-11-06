# Hyprland Configuration and Tool Installer

This script is a comprehensive installer for Hyprland configuration and other useful tools to serve as a reinstall script of my tools and required pkgs for Omarchy

## Features

*   **Hyprland Configuration:** Sets up my own Hyprland environment by copying configuration files, fonts, and scripts after a Omarchy reinstall.
*   **Passwordless Sudo:** Configures passwordless sudo for `user` to streamline package management.
*   **Gaming Dependencies:** Installs a list of gaming-related dependencies using `yay`.
*   **Transparency Control:** Provides an option to remove transparency from the Hyprland configuration for a more opaque look.
*   **Nautilus Scripts:** Adds custom scripts to the Nautilus file manager for "Create File" and "Open Terminal Here" functionality.

## Usage

1.  **Clone the repository or download the files.**
2.  **Run the installer:**

    ```bash
    ./omarchy-fresh-install.sh
    ```

3.  **Follow the on-screen prompts:** The script will guide you through the setup process, allowing you to choose which tasks to perform.

## Prerequisites

*   **Arch Linux (or a derivative):** The script is designed for Arch-based distributions.
*   **`yay`:** The "Install Gaming Dependencies" feature requires `yay`, an AUR helper.

## File Structure

*   `omarchy-fresh-install.sh`: The main installer script.
*   `list.txt`: A list of packages to be installed for gaming.
*   `bindings.conf`, `hyprlock.conf`, `input.conf`, `looknfeel.conf`, `monitors.conf`, `steam.conf`: Hyprland configuration files.
*   `Fonts/`: Contains fonts for the Hyprland setup.
*   `Scripts/`: Contains scripts used by the Hyland configuration.
