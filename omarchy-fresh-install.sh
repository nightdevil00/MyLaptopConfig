#!/bin/bash

# This script is a comprehensive installer for Hyprland configuration and other tools.

# Exit on error
set -e

# Get the directory of the script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# --- Embedded Scripts ---

run_sudo_setup() {
    echo "--- Running Sudo Setup ---"
    # This script configures passwordless sudo for pacman for the current user.

    # The user to be configured
    USER_TO_CONFIGURE="$USER"
    SUDOERS_FILE="/etc/sudoers.d/$USER_TO_CONFIGURE-pacman"

    # Check if the configuration file already exists
    if [ -e "$SUDOERS_FILE" ]; then
        echo "Configuration already exists for '$USER_TO_CONFIGURE' in $SUDOERS_FILE."
        # Optional: Display the existing configuration
        echo "Current content:"
        cat "$SUDOERS_FILE"
        return
    fi

    # The rule to be added
    SUDO_RULE="$USER_TO_CONFIGURE ALL=(ALL) NOPASSWD: /usr/bin/pacman"

    # Create the sudoers file for the user
    echo "Creating sudoers file for '$USER_TO_CONFIGURE'..."
    sudo sh -c "echo '$SUDO_RULE' > '$SUDOERS_FILE'"

    # Set the correct permissions for the sudoers file
    sudo chmod 440 "$SUDOERS_FILE"

    # Validate the sudoers file syntax
    echo "Validating sudoers file..."
    if sudo visudo -c; then
        echo "Sudoers file updated successfully for '$USER_TO_CONFIGURE'."
    else
        echo "Error: Sudoers file has syntax issues. Removing the created file..."
        sudo rm "$SUDOERS_FILE"
        echo "Removal complete. Please check the script and try again."
        exit 1
    fi

    echo "Passwordless sudo for pacman has been configured for '$USER_TO_CONFIGURE'."
}

run_gaming_dependencies() {
    echo "--- Installing Gaming Dependencies ---"
    # This script installs the gaming dependencies listed in list.txt

    # Read the packages from list.txt into an array
    mapfile -t packages < "$SCRIPT_DIR/list.txt"

    # Install the packages using yay
    yay -S --needed --noconfirm "${packages[@]}"
}

run_remove_transparency() {
    echo "--- Removing Transparency ---"
    # This script removes transparency settings from your Hyprland configuration.

    # Note: This script is based on the file structure and content as of 2025-09-30.
    # If the configuration files change, this script may need to be updated.

    # Theme file
    THEME_FILE="$HOME/.config/omarchy/current/theme/hyprland.conf"
    if [ -f "$THEME_FILE" ]; then
        sed -i 's/col.active_border = rgba(ADADADee) rgba(CECECEee) 45deg/col.active_border = rgb(ADADAD) rgb(CECECE) 45deg/' "$THEME_FILE"
        sed -i 's/col.inactive_border = rgba(00000088)/col.inactive_border = rgb(000000)/' "$THEME_FILE"
    fi

    # Windows file
    WINDOWS_FILE="$HOME/.local/share/omarchy/default/hypr/windows.conf"
    if [ -f "$WINDOWS_FILE" ]; then
        sed -i 's/windowrule = opacity 0.97 0.9, class:.*/windowrule = opacity 1.0 1.0, class:.*/' "$WINDOWS_FILE"
    fi

    # Look and feel file
    LOOKNFEEL_FILE="$HOME/.local/share/omarchy/default/hypr/looknfeel.conf"
    if [ -f "$LOOKNFEEL_FILE" ]; then
        sed -i 's/col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg/col.active_border = rgb(33ccff) rgb(00ff99) 45deg/' "$LOOKNFEEL_FILE"
        sed -i 's/col.inactive_border = rgba(595959aa)/col.inactive_border = rgb(595959)/' "$LOOKNFEEL_FILE"
        sed -i 's/color = rgba(1a1a1aee)/color = rgb(1a1a1a)/' "$LOOKNFEEL_FILE"
        sed -i 's/enabled = true/enabled = false/' "$LOOKNFEEL_FILE"
    fi

    # Browser apps file
    BROWSER_FILE="$HOME/.local/share/omarchy/default/hypr/apps/browser.conf"
    if [ -f "$BROWSER_FILE" ]; then
        sed -i 's/windowrule = opacity 1 0.97, tag:chromium-based-browser/windowrule = opacity 1 1, tag:chromium-based-browser/' "$BROWSER_FILE"
        sed -i 's/windowrule = opacity 1 0.97, tag:firefox-based-browser/windowrule = opacity 1 1, tag:firefox-based-browser/' "$BROWSER_FILE"
    fi

    echo "Transparency removal script finished."
}

run_nautilus_scripts() {
    echo "--- Installing Nautilus Scripts ---"
    # Installer for Nautilus custom scripts
    # Works on Arch Linux (and derivatives)

    NAUTILUS_SCRIPT_DIR="$HOME/.local/share/nautilus/scripts"
    CREATE_FILE="$NAUTILUS_SCRIPT_DIR/Create File"
    OPEN_TERM="$NAUTILUS_SCRIPT_DIR/Open Terminal Here"

    echo "[*] Installing Nautilus custom scripts..."

    # Ensure zenity is installed (needed for Create File)
    if ! command -v zenity &>/dev/null; then
        echo "[*] Installing zenity..."
        sudo pacman -S --noconfirm zenity || {
            echo "[!] Failed to install zenity. Exiting."
            exit 1
        }
    fi

    # Create scripts directory if missing
    mkdir -p "$NAUTILUS_SCRIPT_DIR"

    # -------------------------------
    # Script 1: Create File
    # -------------------------------
    cat > "$CREATE_FILE" <<-'EOF'
#!/bin/bash

# Get the current directory Nautilus was opened in
current_dir="$(pwd)"

# Prompt the user for filename (with extension)
filename=$(zenity --entry --title="Create File" --text="Enter file name (with extension):")

# Exit if nothing entered
[ -z "$filename" ] && exit 0

# If file already exists, ask confirmation
if [ -e "$current_dir/$filename" ]; then
    zenity --question --title="File Exists" --text="File '$filename' already exists. Overwrite?"
    if [ $? -ne 0 ]; then
        exit 0
    fi
fi

# Create the file
touch "$current_dir/$filename"

# Success message
zenity --info --title="File Created" --text="File '$filename' created in:\n$current_dir"
EOF

    chmod +x "$CREATE_FILE"
    echo "[✓] Installed: Create File script"


    # -------------------------------
    # Script 2: Open Terminal Here
    # -------------------------------
    cat > "$OPEN_TERM" <<-'EOF'
#!/bin/bash
# Open Terminal Here script

TERMINAL="${TERMINAL:-""}"

if [ -n "$TERMINAL" ]; then
    exec "$TERMINAL"
elif command -v xdg-terminal-exec >/dev/null 2>&1; then
    exec xdg-terminal-exec
elif command -v alacritty >/dev/null 2>&1; then
    exec alacritty
elif command -v konsole >/dev/null 2>&1; then
    exec konsole
else
    exec gnome-terminal
fi
EOF

    chmod +x "$OPEN_TERM"
    echo "[✓] Installed: Open Terminal Here script"


    echo
    echo "[✓] Installation complete!"
    echo "   → Right-click inside Nautilus → Scripts → Create File"
    echo "   → Right-click inside Nautilus → Scripts → Open Terminal Here"
}


run_copy_dotconfig_files() {
    echo "--- Copying .config files ---"

    # Destination directory
    DEST_DIR="$HOME/.config"
    mkdir -p "$DEST_DIR"

    # Source directory for waybar and spotify-flags
    SOURCE_CONFIG_DIR="$SCRIPT_DIR/.config"

    # Copy waybar directory
    if [ -d "$SOURCE_CONFIG_DIR/waybar" ]; then
        echo "Copying waybar configuration..."
        cp -r "$SOURCE_CONFIG_DIR/waybar" "$DEST_DIR/"
    else
        echo "waybar configuration not found in $SOURCE_CONFIG_DIR, skipping."
    fi

    # Copy spotify-flags.conf
    if [ -f "$SOURCE_CONFIG_DIR/spotify-flags.conf" ]; then
        echo "Copying spotify-flags.conf..."
        cp "$SOURCE_CONFIG_DIR/spotify-flags.conf" "$DEST_DIR/"
    else
        echo "spotify-flags.conf not found in $SOURCE_CONFIG_DIR, skipping."
    fi

    echo ".config files copied."
}

run_install_pacman_packages() {
    echo "--- Installing Pacman Packages ---"
    local packages=("nano" "gedit" "kate" "vlc" "vlc-plugins-all" "qbittorrent")
    echo "Installing: ${packages[@]}"
    sudo pacman -S --needed --noconfirm "${packages[@]}"
    echo "Pacman packages installation complete."
}

# --- Main Logic ---

# Define required files and directories for Hyprland config
REQUIRED_CONFIG_FILES=(
    "Fonts"
    "Scripts"
    "bindings.conf"
    "hyprlock.conf"
    "input.conf"
    "looknfeel.conf"
    "monitors.conf"
    "steam.conf"
    "list.txt"
)

MISSING_FILES=()

# Check for missing config files
for file in "${REQUIRED_CONFIG_FILES[@]}"; do
    if [ ! -e "$SCRIPT_DIR/$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

perform_hyprland_setup() {
    local partial_install=$1
    
    echo "--- Setting up Hyprland Configuration ---"

    # 1. Create destination directory
    echo "Creating directory $HOME/.config/hypr/..."
    mkdir -p "$HOME/.config/hypr/"

    # 2. Copy files and directories if they exist
    copy_if_exists() {
        if [ -e "$SCRIPT_DIR/$1" ]; then
            echo "Copying $1..."
            cp -r "$SCRIPT_DIR/$1" "$HOME/.config/hypr/"
        fi
    }

    copy_if_exists "Fonts"
    copy_if_exists "Scripts"
    copy_if_exists "bindings.conf"
    copy_if_exists "hyprlock.conf"
    copy_if_exists "input.conf"
    copy_if_exists "looknfeel.conf"
    copy_if_exists "monitors.conf"
    copy_if_exists "steam.conf"

    # 4. Edit hyprland.conf
    HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
    SOURCE_LINE="source = $HOME/.config/hypr/steam.conf"

    if [ -f "$HYPRLAND_CONFIG" ]; then
        if ! grep -q "$SOURCE_LINE" "$HYPRLAND_CONFIG"; then
            echo "Adding source line to hyprland.conf..."
            echo "$SOURCE_LINE" >> "$HYPRLAND_CONFIG"
        else
            echo "Source line already exists in hyprland.conf."
        fi
    else
        echo "hyprland.conf not found, creating with source line..."
        echo "$SOURCE_LINE" > "$HYPRLAND_CONFIG"
    fi

    echo "Hyprland setup complete!"
}

main() {
    if [ ${#MISSING_FILES[@]} -eq 0 ]; then
        echo "All required configuration files are available."
        read -p "Proceed with Hyprland configuration setup? (y/n): " choice
        case "$choice" in
            y|Y ) perform_hyprland_setup false;; 
            * ) echo "Hyprland setup cancelled.";;
        esac
    else
        echo "The following configuration files are missing:"
        for file in "${MISSING_FILES[@]}"; do
            echo " - $file"
        done
        
        echo
        echo "Choose an option:"
        echo "  1. Perform partial Hyprland setup (copy available files)"
        echo "  2. Skip Hyprland setup"
        read -p "Enter your choice (1-2): " choice

        case "$choice" in
            1 ) perform_hyprland_setup true;; 
            * ) echo "Hyprland setup skipped.";;
        esac
    fi

    echo
    echo "--- Additional Tasks ---"
    echo "You can now choose to run additional setup tasks."
    
    select task in "Configure Sudo" "Install Gaming Dependencies" "Remove Transparency" "Install Nautilus Scripts" "Copy .config files" "Install Pacman Packages" "Exit"; do
        case $task in
            "Configure Sudo" ) run_sudo_setup;; 
            "Install Gaming Dependencies" ) run_gaming_dependencies;; 
            "Remove Transparency" ) run_remove_transparency;; 
            "Install Nautilus Scripts" ) run_nautilus_scripts;; 
            "Copy .config files" ) run_copy_dotconfig_files;;
            "Install Pacman Packages" ) run_install_pacman_packages;;
            "Exit" ) echo "Exiting."; break;; 
            * ) echo "Invalid option.";;
        esac
    done
}

main
