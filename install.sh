#!/usr/bin/env bash

# Installer for Moderne Version Manager (modvm)
# This script sets up modvm to be sourced in your shell profile

MODVM_SOURCE_FILE="$HOME/.moderne/cli/modvm.sh"
MODVM_PROFILE_LINE="source \$HOME/.moderne/cli/modvm.sh"

echo "Installing Moderne Version Manager (modvm)..."

if [ ! -f "$MODVM_SOURCE_FILE" ]; then
    echo "Error: $MODVM_SOURCE_FILE not found!"
    echo "Please ensure modvm.sh is in your ~/.moderne/cli directory"
    exit 1
fi

# Make it executable
chmod +x "$MODVM_SOURCE_FILE"

# Function to add to shell profile
add_to_profile() {
    local profile_file="$1"
    local profile_name="$2"
    
    if [ -f "$profile_file" ]; then
        if ! grep -q "modvm.sh" "$profile_file"; then
            echo "" >> "$profile_file"
            echo "# Moderne Version Manager (modvm)" >> "$profile_file"
            echo "$MODVM_PROFILE_LINE" >> "$profile_file"
            echo "✓ Added modvm to $profile_name"
            return 0
        else
            echo "✓ modvm already configured in $profile_name"
            return 1
        fi
    fi
    return 1
}

# Track if we added to any profiles
added_to_profile=false

# Try to add to shell profiles
if add_to_profile "$HOME/.zshrc" ".zshrc"; then
    added_to_profile=true
fi

if add_to_profile "$HOME/.bashrc" ".bashrc"; then
    added_to_profile=true
fi

if add_to_profile "$HOME/.bash_profile" ".bash_profile"; then
    added_to_profile=true
fi

# If we didn't add to any existing profiles, create .profile
if [ "$added_to_profile" = false ]; then
    echo "" >> "$HOME/.profile"
    echo "# Moderne Version Manager (modvm)" >> "$HOME/.profile"
    echo "$MODVM_PROFILE_LINE" >> "$HOME/.profile"
    echo "✓ Added modvm to .profile"
    added_to_profile=true
fi

echo ""
echo "🎉 modvm installation complete!"
echo ""
echo "To start using modvm, either:"
echo "1. Start a new shell session, or"
echo "2. Source your profile: source ~/.zshrc (or ~/.bashrc)"
echo ""
echo "Then you can use commands like:"
echo "  modvm install 3.21.1"
echo "  modvm use 3.21.1"
echo "  modvm list"
echo ""
echo "The 'mod' command will be immediately available after switching versions!"
