#!/bin/bash

set -e
set -u
IFS=$'\n\t'

if [[ $EUID -eq 0 ]]; then
    if [ -n "${SUDO_USER-}" ]; then
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        USER_HOME="/root"
    fi
else
    USER_HOME="$HOME"
fi


INSTALL_BASE_DIR="$USER_HOME/Desktop/tools/mobile/mobile_custom_tools"
BUILD_TMP_DIR="$USER_HOME/android-build-tmp"

echo "--- Starting Installation of Android Pentesting Tools ---"
echo "Target User Home: $USER_HOME"
echo "Target Directory: $INSTALL_BASE_DIR"

mkdir -p "$INSTALL_BASE_DIR"
mkdir -p "$BUILD_TMP_DIR"

if [[ $EUID -ne 0 ]]; then
    echo "⚠️  Warning: This script uses 'sudo' to install packages and manage files."
    echo "It will prompt for your password when needed."
fi


run_command() {
    local cmd="$1"
    local msg="$2"
    echo -e "\n=> $msg..."
    if eval "$cmd"; then
        echo "✅ Success."
    else
        echo "❌ Error executing: $cmd"
        exit 1
    fi
}

install_apt_package() {
    local package_name="$1"
    if ! dpkg -l | grep -q "^ii  $package_name "; then
        run_command "sudo apt install -y $package_name" "Installing $package_name"
    else
        echo "✅ $package_name is already installed."
    fi
}

echo "\n--- Section 1: Installing Prerequisites ---"

run_command "sudo apt update" "Updating package lists"
install_apt_package "git"
install_apt_package "python3-pip"
install_apt_package "python3-venv"
install_apt_package "adb"
install_apt_package "docker.io"
install_apt_package "default-jre"
install_apt_package "curl"


echo "=> Ensuring Python 3.11 is installed..."
install_apt_package "python3.11"

if ! command -v pipx &> /dev/null; then
    run_command "sudo pip install pipx" "Installing pipx"
    run_command "sudo -u $SUDO_USER pipx ensurepath" "Adding pipx to PATH"
    export PATH="$PATH:$USER_HOME/.local/bin"
else
    echo "✅ pipx is already installed."
fi


# Updating PATH environment variable for easier access to installed tools
echo "\n--- Section 2: Configuring System PATH ---"
BASHRC="$USER_HOME/.bashrc"
ZSHRC="$USER_HOME/.zshrc"

PATH_EXPORT_LINE='export PATH="$PATH:'"$INSTALL_BASE_DIR"'"'
FOUND_SHELL_RC=false

for rc_file in "$BASHRC" "$ZSHRC"; do
    if [ -f "$rc_file" ]; then
        FOUND_SHELL_RC=true
        if ! grep -qF "$PATH_EXPORT_LINE" "$rc_file"; then
            echo -e "\n# Added by Android Tools Installer" | sudo tee -a "$rc_file" > /dev/null
# Updating PATH environment variable for easier access to installed tools
            echo "$PATH_EXPORT_LINE" | sudo tee -a "$rc_file" > /dev/null
# Updating PATH environment variable for easier access to installed tools
            echo "✅ Added $INSTALL_BASE_DIR to PATH in $rc_file."
            echo "   Please 'source $rc_file' or restart your terminal after the script finishes."
        else
# Updating PATH environment variable for easier access to installed tools
            echo "✅ PATH already configured in $rc_file."
        fi
        break
    fi
done

if ! $FOUND_SHELL_RC; then
    echo "⚠️ Warning: Could not find .bashrc or .zshrc. Please add the following to your shell config manually:"
# Updating PATH environment variable for easier access to installed tools
    echo "$PATH_EXPORT_LINE"
fi

export PATH="$PATH:$INSTALL_BASE_DIR"

echo "\n--- Section 3: Installing Pentesting Tools ---"

echo -e "\n--- Installing Recon & Analysis Tools ---"

# Installing Python tools in isolated environments using pipx
run_command "sudo -u $SUDO_USER pipx install quark-engine" "Installing Quark-Engine with pipx"

echo -e "\n--- Installing Dynamic Analysis Tools ---"

# Installing Python tools in isolated environments using pipx
run_command "sudo -u $SUDO_USER pipx install frida-tools" "Installing Frida Tools with pipx"

# Installing Python tools in isolated environments using pipx
run_command "sudo -u $SUDO_USER pipx install objection" "Installing Objection with pipx"


echo -e "\n--- Installing Reverse Engineering Tools ---"

echo "=> Checking for JADX..."
install_apt_package "jadx"

echo "=> Checking for APKTool..."
install_apt_package "apktool"

echo "=> Checking for Ghidra..."
GHIDRA_DIR="$INSTALL_BASE_DIR/ghidra"
if [ ! -d "$GHIDRA_DIR" ]; then
    GHIDRA_URL=$(curl -s "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest" | grep "browser_download_url.*zip" | cut -d '"' -f 4 || true)
    if [ -z "$GHIDRA_URL" ]; then
        echo "⚠️ Warning: Could not get URL for Ghidra. Skipping."
    else
        run_command "wget -q --show-progress -O '$BUILD_TMP_DIR/ghidra.zip' '$GHIDRA_URL'" "Downloading latest Ghidra"
        run_command "unzip -q '$BUILD_TMP_DIR/ghidra.zip' -d '$BUILD_TMP_DIR'" "Unzipping Ghidra"
        EXTRACTED_GHIDRA_DIR=$(find "$BUILD_TMP_DIR" -maxdepth 1 -name "ghidra_*" -type d)
# Moving the script or binary to /usr/local/bin for system-wide access
        run_command "mv '$EXTRACTED_GHIDRA_DIR' '$GHIDRA_DIR'" "Moving Ghidra to tools directory"
        rm "$BUILD_TMP_DIR/ghidra.zip"
        sudo tee "$INSTALL_BASE_DIR/ghidra" > /dev/null <<EOF
#!/bin/bash
sh "$GHIDRA_DIR/ghidraRun"
EOF
# Making the script or binary executable
        run_command "sudo chmod +x '$INSTALL_BASE_DIR/ghidra'" "Creating Ghidra launcher"
        echo "✅ Ghidra installed. Run it with the 'ghidra' command."
    fi
else
    echo "✅ Ghidra directory already exists. Skipping."
fi

echo "=> Checking for Bytecode Viewer..."
BCV_JAR="$INSTALL_BASE_DIR/BytecodeViewer.jar"
if [ ! -f "$BCV_JAR" ]; then
    BCV_URL=$(curl -s "https://api.github.com/repos/Konloch/bytecode-viewer/releases/latest" | grep "browser_download_url.*\.jar" | cut -d '"' -f 4 || true)
    if [ -z "$BCV_URL" ]; then
        echo "⚠️ Warning: Could not get URL for Bytecode Viewer. Skipping."
    else
        run_command "wget -q --show-progress -O '$BCV_JAR' '$BCV_URL'" "Downloading latest Bytecode Viewer"
        sudo tee "$INSTALL_BASE_DIR/bytecode-viewer" > /dev/null <<EOF
#!/bin/bash
# Running a Java tool or installing a Java-based component
java -jar "$BCV_JAR"
EOF
# Making the script or binary executable
        run_command "sudo chmod +x '$INSTALL_BASE_DIR/bytecode-viewer'" "Creating Bytecode Viewer launcher"
        echo "✅ Bytecode Viewer installed. Run it with 'bytecode-viewer'."
    fi
else
    echo "✅ Bytecode Viewer already installed. Skipping."
fi


echo -e "\n--- Installing Payload & APK Tools ---"

echo "=> Checking for APK Editor Studio..."
APKEDITOR_APPIMAGE="$INSTALL_BASE_DIR/APKEditorStudio.AppImage"
if [ ! -f "$APKEDITOR_APPIMAGE" ]; then
    APKEDITOR_URL=$(curl -s "https://api.github.com/repos/kefir500/apk-editor-studio/releases/latest" | grep "browser_download_url.*AppImage" | cut -d '"' -f 4 || true)
    if [ -z "$APKEDITOR_URL" ]; then
        echo "⚠️ Warning: Could not get URL for APK Editor Studio. Skipping."
    else
        run_command "wget -q --show-progress -O '$APKEDITOR_APPIMAGE' '$APKEDITOR_URL'" "Downloading latest APK Editor Studio"
# Making the script or binary executable
        run_command "sudo chmod +x '$APKEDITOR_APPIMAGE'" "Making AppImage executable"
        run_command "sudo ln -sf '$APKEDITOR_APPIMAGE' '$INSTALL_BASE_DIR/apk-editor'" "Creating launcher for APK Editor Studio"
        echo "✅ APK Editor Studio installed. Run it with 'apk-editor'."
    fi
else
    echo "✅ APK Editor Studio already installed. Skipping."
fi

if [ ! -d "$INSTALL_BASE_DIR/Evil-Droid" ]; then
# Cloning tool repositories from GitHub
    run_command "git clone https://github.com/M4sc3r4n0/Evil-Droid.git '$INSTALL_BASE_DIR/Evil-Droid'" "Cloning Evil-Droid"
# Changing directory to the tool folder
    echo "✅ Evil-Droid cloned. Run it from its directory: cd $INSTALL_BASE_DIR/Evil-Droid"
else
    echo "✅ Evil-Droid directory already exists. Skipping."
fi


echo -e "\n--- Section 4: Finalizing Installation ---"
run_command "rm -rf '$BUILD_TMP_DIR'" "Cleaning up temporary build files"

echo -e "\n\n🎉 --- Android Pentesting Toolkit Installation Complete! --- 🎉"
echo "Remember to source your shell config ('source ~/.bashrc' or 'source ~/.zshrc') or open a new terminal."