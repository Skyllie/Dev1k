#!/bin/bash

# Gradle Installation Script for Linux
# This script downloads and installs the latest version of Gradle

set -e  # Exit on error

# Configuration
GRADLE_VERSION="8.11.1"  # Update this to the desired version
INSTALL_DIR="/opt/gradle"
GRADLE_HOME="$INSTALL_DIR/gradle-$GRADLE_VERSION"

echo "==================================="
echo "Gradle Installation Script"
echo "==================================="
echo "Version to install: $GRADLE_VERSION"
echo "Installation directory: $INSTALL_DIR"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed. Please install Java JDK first."
    echo "You can install it with: sudo apt install openjdk-11-jdk (Ubuntu/Debian)"
    echo "or: sudo yum install java-11-openjdk-devel (RHEL/CentOS)"
    exit 1
fi

echo "Java version detected:"
java -version
echo ""

# Create installation directory
echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"

# Download Gradle
echo "Downloading Gradle $GRADLE_VERSION..."
cd /tmp
GRADLE_ZIP="gradle-$GRADLE_VERSION-bin.zip"
wget "https://services.gradle.org/distributions/$GRADLE_ZIP"

# Verify download
if [ ! -f "$GRADLE_ZIP" ]; then
    echo "Error: Download failed"
    exit 1
fi

# Extract Gradle
echo "Extracting Gradle..."
unzip -q "$GRADLE_ZIP"
rm -rf "$GRADLE_HOME"  # Remove if exists
mv "gradle-$GRADLE_VERSION" "$INSTALL_DIR/"

# Clean up
rm "$GRADLE_ZIP"

# Set up environment variables
echo "Setting up environment variables..."
PROFILE_FILE="/etc/profile.d/gradle.sh"

cat > "$PROFILE_FILE" << EOF
export GRADLE_HOME=$GRADLE_HOME
export PATH=\$GRADLE_HOME/bin:\$PATH
EOF

chmod +x "$PROFILE_FILE"

# Make it available in current session
export GRADLE_HOME="$GRADLE_HOME"
export PATH="$GRADLE_HOME/bin:$PATH"

echo ""
echo "==================================="
echo "Installation Complete!"
echo "==================================="
echo "Gradle has been installed to: $GRADLE_HOME"
echo ""
echo "To use Gradle in your current session, run:"
echo "  source $PROFILE_FILE"
echo ""
echo "For new sessions, it will be available automatically."
echo ""
echo "Verifying installation..."
"$GRADLE_HOME/bin/gradle" --version
