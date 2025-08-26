#!/usr/bin/env bash

# Moderne Version Manager (modvm)
# A version manager for Moderne CLI similar to nvm
# 
# To use modvm, source this file in your shell:
# source ~/bin/modvm.sh
# 
# Or add this line to your .bashrc/.zshrc:
# source ~/bin/modvm.sh

MODVM_DIR="${HOME}/bin/moderne-cli"
MAVEN_CENTRAL_BASE="https://repo1.maven.org/maven2/io/moderne/moderne-cli"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
modvm_print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

modvm_print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

modvm_print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

modvm_print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
modvm_show_help() {
    cat << EOF
Moderne Version Manager (modvm)

Usage:
  modvm install <version>    Install a specific version of Moderne CLI
  modvm use <version>        Switch to a specific version of Moderne CLI
  modvm list                 List all installed versions
  modvm list-remote          List available versions from Maven Central
  modvm current              Show currently active version
  modvm uninstall <version>  Remove a specific version
  modvm help                 Show this help message

Examples:
  modvm install 3.21.1      Install Moderne CLI version 3.21.1
  modvm use 3.21.1          Switch to version 3.21.1
  modvm list                 Show all installed versions
  modvm current              Show current version

Note: After installation or switching versions, the 'mod' alias will be updated
immediately in the current shell.
EOF
}

# Function to create modvm directory if it doesn't exist
modvm_ensure_dir() {
    if [ ! -d "$MODVM_DIR" ]; then
        modvm_print_info "Creating Moderne CLI directory at $MODVM_DIR"
        mkdir -p "$MODVM_DIR"
    fi
}

# Function to check if a version is installed
modvm_is_version_installed() {
    local version="$1"
    [ -f "$MODVM_DIR/moderne-cli-$version.jar" ]
}

# Function to get the current version
modvm_get_current_version() {
    if command -v mod >/dev/null 2>&1; then
        local alias_cmd=$(type mod 2>/dev/null | grep -o 'moderne-cli-[0-9]\+\.[0-9]\+\.[0-9]\+\.jar')
        if [ -n "$alias_cmd" ]; then
            echo "$alias_cmd" | sed 's/moderne-cli-\(.*\)\.jar/\1/'
        fi
    fi
}

# Function to set the mod alias in the current shell
modvm_set_alias() {
    local version="$1"
    local jar_path="$MODVM_DIR/moderne-cli-$version.jar"
    
    if [ ! -f "$jar_path" ]; then
        modvm_print_error "Version $version is not installed"
        return 1
    fi
    
    # Remove existing mod alias/function if it exists
    unalias mod 2>/dev/null || true
    unset -f mod 2>/dev/null || true
    
    # Set the alias in the current shell
    alias mod="java -jar $jar_path"
    
    modvm_print_success "Now using Moderne CLI version $version"
    modvm_print_info "The 'mod' command is now available in this shell"
}

# Function to install a version
modvm_install() {
    local version="$1"
    
    if [ -z "$version" ]; then
        modvm_print_error "Please specify a version to install"
        return 1
    fi
    
    if modvm_is_version_installed "$version"; then
        modvm_print_warning "Version $version is already installed"
        modvm_set_alias "$version"
        return 0
    fi
    
    modvm_ensure_dir
    
    local jar_url="$MAVEN_CENTRAL_BASE/$version/moderne-cli-$version.jar"
    local jar_path="$MODVM_DIR/moderne-cli-$version.jar"
    
    modvm_print_info "Downloading Moderne CLI version $version..."
    modvm_print_info "URL: $jar_url"
    
    # Download the JAR file
    if curl -L -f -o "$jar_path" "$jar_url"; then
        modvm_print_success "Successfully installed Moderne CLI version $version"
        modvm_print_info "JAR saved to: $jar_path"
        
        # Automatically switch to the newly installed version
        modvm_set_alias "$version"
    else
        modvm_print_error "Failed to download Moderne CLI version $version"
        modvm_print_error "Please check if the version exists at: $jar_url"
        # Clean up partial download
        [ -f "$jar_path" ] && rm "$jar_path"
        return 1
    fi
}

# Function to use a specific version
modvm_use() {
    local version="$1"
    
    if [ -z "$version" ]; then
        modvm_print_error "Please specify a version to use"
        return 1
    fi
    
    if ! modvm_is_version_installed "$version"; then
        modvm_print_error "Version $version is not installed"
        modvm_print_info "Use 'modvm install $version' to install it first"
        return 1
    fi
    
    modvm_set_alias "$version"
}

# Function to list installed versions
modvm_list() {
    modvm_ensure_dir
    
    modvm_print_info "Installed Moderne CLI versions:"
    local current_version=$(modvm_get_current_version)
    
    if [ ! "$(ls -A $MODVM_DIR/*.jar 2>/dev/null)" ]; then
        modvm_print_warning "No versions installed"
        return 0
    fi
    
    for jar in "$MODVM_DIR"/moderne-cli-*.jar; do
        if [ -f "$jar" ]; then
            local version=$(basename "$jar" | sed 's/moderne-cli-\(.*\)\.jar/\1/')
            if [ "$version" = "$current_version" ]; then
                echo -e "  ${GREEN}* $version${NC} (currently active)"
            else
                echo "    $version"
            fi
        fi
    done
}

# Function to list remote versions from Maven Central
modvm_list_remote() {
    modvm_print_info "Fetching available versions from Maven Central..."
    
    local metadata_url="$MAVEN_CENTRAL_BASE/maven-metadata.xml"
    local temp_file=$(mktemp)
    
    # Download the metadata XML
    if ! curl -s -f -o "$temp_file" "$metadata_url"; then
        modvm_print_error "Failed to fetch version metadata from Maven Central"
        modvm_print_info "You can manually check available versions at:"
        modvm_print_info "https://repo1.maven.org/maven2/io/moderne/moderne-cli/"
        rm -f "$temp_file"
        return 1
    fi
    
    # Parse versions from XML and sort them
    local versions=$(grep -o '<version>[^<]*</version>' "$temp_file" | \
                    sed 's/<version>\(.*\)<\/version>/\1/' | \
                    sort -V)
    
    rm -f "$temp_file"
    
    if [ -z "$versions" ]; then
        modvm_print_error "No versions found in metadata"
        return 1
    fi
    
    modvm_print_success "Available Moderne CLI versions:"
    local current_version=$(modvm_get_current_version)
    local count=0
    
    # Display versions (reverse order to show newest first)
    echo "$versions" | sort -V -r | while read -r version; do
        if [ -n "$version" ]; then
            count=$((count + 1))
            if modvm_is_version_installed "$version"; then
                if [ "$version" = "$current_version" ]; then
                    echo -e "  ${GREEN}* $version${NC} (installed, currently active)"
                else
                    echo -e "  ${BLUE}+ $version${NC} (installed)"
                fi
            else
                echo "    $version"
            fi
            
            # Limit output to prevent overwhelming the user
            if [ $count -ge 20 ]; then
                echo "    ... (and more)"
                break
            fi
        fi
    done
    
    echo ""
    modvm_print_info "Legend: ${GREEN}*${NC} = current version, ${BLUE}+${NC} = installed"
    modvm_print_info "Use 'modvm install <version>' to install a specific version"
}

# Function to show current version
modvm_current() {
    local current_version=$(modvm_get_current_version)
    
    if [ -n "$current_version" ]; then
        modvm_print_success "Currently using Moderne CLI version: $current_version"
    else
        modvm_print_warning "No Moderne CLI version is currently active"
        modvm_print_info "Use 'modvm install <version>' to install and activate a version"
    fi
}

# Function to uninstall a version
modvm_uninstall() {
    local version="$1"
    
    if [ -z "$version" ]; then
        modvm_print_error "Please specify a version to uninstall"
        return 1
    fi
    
    if ! modvm_is_version_installed "$version"; then
        modvm_print_error "Version $version is not installed"
        return 1
    fi
    
    local jar_path="$MODVM_DIR/moderne-cli-$version.jar"
    local current_version=$(modvm_get_current_version)
    
    # Check if trying to uninstall currently active version
    if [ "$version" = "$current_version" ]; then
        modvm_print_warning "Version $version is currently active"
        modvm_print_info "The 'mod' alias will be removed"
        unalias mod 2>/dev/null || true
    fi
    
    rm "$jar_path"
    modvm_print_success "Uninstalled Moderne CLI version $version"
}

# Main modvm function
modvm() {
    case "$1" in
        "install")
            modvm_install "$2"
            ;;
        "use")
            modvm_use "$2"
            ;;
        "list")
            modvm_list
            ;;
        "list-remote")
            modvm_list_remote
            ;;
        "current")
            modvm_current
            ;;
        "uninstall")
            modvm_uninstall "$2"
            ;;
        "help"|"--help"|"-h"|"")
            modvm_show_help
            ;;
        *)
            modvm_print_error "Unknown command: $1"
            echo ""
            modvm_show_help
            return 1
            ;;
    esac
}

# Auto-initialization: try to use the latest installed version if no mod command exists
if ! command -v mod >/dev/null 2>&1; then
    if [ -d "$MODVM_DIR" ] && [ "$(ls -A $MODVM_DIR/*.jar 2>/dev/null)" ]; then
        # Find the latest version and auto-activate it
        latest_jar=$(ls -t "$MODVM_DIR"/moderne-cli-*.jar 2>/dev/null | head -n1)
        if [ -n "$latest_jar" ]; then
            latest_version=$(basename "$latest_jar" | sed 's/moderne-cli-\(.*\)\.jar/\1/')
            alias mod="java -jar $latest_jar"
        fi
    fi
fi
