#!/bin/bash

# venvswitch Installation Script
# This script helps install venvswitch for Oh My Zsh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    printf "${BLUE}ℹ️  %s${NC}\n" "$1"
}

print_success() {
    printf "${GREEN}✅ %s${NC}\n" "$1"
}

print_warning() {
    printf "${YELLOW}⚠️  %s${NC}\n" "$1"
}

print_error() {
    printf "${RED}❌ %s${NC}\n" "$1"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check if Zsh is installed
    if ! command -v zsh >/dev/null 2>&1; then
        print_error "Zsh is not installed. Please install Zsh first."
        exit 1
    fi

    # Check if Oh My Zsh is installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_error "Oh My Zsh is not installed. Please install Oh My Zsh first:"
        echo "  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
        exit 1
    fi

    # Check if Python is available
    if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
        print_warning "Python is not found. venvswitch requires Python to work."
    fi

    print_success "Prerequisites check passed!"
}

# Install venvswitch
install_venvswitch() {
    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/venvswitch"

    print_info "Installing venvswitch..."

    # Remove existing installation if it exists
    if [[ -d "$plugin_dir" ]]; then
        print_warning "Existing venvswitch installation found. Removing..."
        rm -rf "$plugin_dir"
    fi

    # Create plugin directory
    mkdir -p "$plugin_dir"

    # Copy plugin files
    cp venvswitch.plugin.zsh "$plugin_dir/"
    cp README.md "$plugin_dir/"
    cp LICENSE "$plugin_dir/"

    print_success "venvswitch files installed to $plugin_dir"
}

# Update .zshrc
update_zshrc() {
    local zshrc="$HOME/.zshrc"
    local plugin_entry="venvswitch"

    print_info "Checking .zshrc configuration..."

    # Check if plugins line exists
    if ! grep -q "^plugins=(" "$zshrc"; then
        print_warning "Could not find plugins configuration in .zshrc"
        print_info "Please manually add 'venvswitch' to your plugins list in ~/.zshrc"
        return
    fi

    # Check if venvswitch is already in plugins
    if grep -q "venvswitch" "$zshrc"; then
        print_success "venvswitch is already configured in .zshrc"
        return
    fi

    # Add venvswitch to plugins list
    if sed -i.bak "s/plugins=(/plugins=(venvswitch /" "$zshrc"; then
        print_success "Added venvswitch to plugins list in .zshrc"
        print_info "Backup created: ~/.zshrc.bak"
    else
        print_warning "Could not automatically update .zshrc"
        print_info "Please manually add 'venvswitch' to your plugins list"
    fi
}

# Verify installation
verify_installation() {
    print_info "Verifying installation..."

    local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/venvswitch"

    # Check if files exist
    if [[ ! -f "$plugin_dir/venvswitch.plugin.zsh" ]]; then
        print_error "Plugin file not found!"
        return 1
    fi

    # Check if plugin is in .zshrc
    if ! grep -q "venvswitch" "$HOME/.zshrc"; then
        print_warning "venvswitch not found in .zshrc plugins list"
        return 1
    fi

    print_success "Installation verified!"
}

# Main installation process
main() {
    echo
    print_info "venvswitch Installation Script"
    print_info "=============================="
    echo

    check_prerequisites
    install_venvswitch
    update_zshrc
    verify_installation

    echo
    print_success "Installation completed!"
    echo
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Test the installation: venvswitch_config"
    echo "  3. Create your first environment: mkdir test && cd test && mkvenv"
    echo
    print_info "For more information, see: https://github.com/murapadev/venvswitch"
    echo
}

# Run main function
main "$@"