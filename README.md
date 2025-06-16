 Android Pentesting Tools Installer

What This Is

This script sets up a full toolkit for Android app pentesting, all in one go. It’s built for Debian-based systems like Kali, Ubuntu, or Parrot OS and handles everything—from installing packages and pulling tools from GitHub to setting up your system path and creating easy-to-use launch commands.

Think of it as your one-stop setup for both static and dynamic analysis. No more hunting down and installing tools one by one.

What You’ll Need First

Before you run the script, make sure you’ve got:

1. **A Debian-based OS** – Kali, Ubuntu, or anything similar will work.
2. **Sudo access** – The script installs stuff system-wide, so you'll need elevated privileges.
3. **Internet access** – Downloads a bunch of tools and dependencies from online sources.

What Gets Installed

The script grabs and sets up the following tools, grouped by what they help with:

Recon and Static Analysis
- Quark-Engine – Flags malicious behavior in APKs using a scoring system.

Dynamic Analysis and Debugging
- Frida Tools – Inject and inspect app behavior at runtime.
- Objection – Frida-based tool for exploring mobile apps, no root required.

Reverse Engineering
- JADX – Turns `.dex` files into readable Java code.
- APKTool – Decodes APK resources and lets you rebuild them.
- Ghidra – NSA-built reverse engineering suite with all the bells and whistles.
- Bytecode Viewer – GUI for viewing and editing Java bytecode.

Payloads and APK Modding
- APK Editor Studio – Edit and explore APK files through a clean UI.
- Evil-Droid – Builds APKs with embedded payloads for testing.

Core Tools and Dependencies
It also installs a bunch of backend stuff you’ll need to keep everything running smoothly:
- adb
- git
- docker.io
- curl
- pipx
- Python 3.11
- Java Runtime (JRE)

How to Use It
Save the Script**  
   Copy the script into a file and name it:  
   ```
   android-tools-installer.sh
   ```

2. **Make It Executable**  
   Open your terminal, go to the folder where the script lives, and run:  
   ```bash
   chmod +x android-tools-installer.sh
   ```

Then just run it and let the automation take care of the rest.
