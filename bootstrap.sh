#!/usr/bin/env bash
# ~/.dotfiles/bootstrap.sh
# Multi-OS dotfiles bootstrap using GNU Stow

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
fatal() { error "$*"; exit 1; }

# Detect OS and environment
detect_os() {
    local os=""

    case "$(uname -s)" in
        Darwin)
            os="macos"
            ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                os="wsl"
            elif [ -f /etc/arch-release ]; then
                os="arch"
            else
                os="linux"
            fi
            ;;
        *)
            fatal "Unsupported OS: $(uname -s)"
            ;;
    esac

    echo "$os"
}

# Check prerequisites
check_prerequisites() {
    if ! command -v stow &>/dev/null; then
        fatal "GNU Stow is not installed. Install it first:\n  macOS: brew install stow\n  Arch: sudo pacman -S stow\n  Debian/Ubuntu: sudo apt install stow"
    fi

    if ! command -v git &>/dev/null; then
        fatal "Git is not installed"
    fi
}

# Get packages to stow based on OS
get_packages() {
    local os="$1"
    local packages=()

    # Common packages (always stow these)
    packages+=(
        "common-zsh"
        "common-git"
        "common-tmux"
        "common-nvim"
        "common-bin"
    )

    # Platform-specific packages
    case "$os" in
        macos)
            packages+=("platform-macos")
            ;;
        wsl)
            packages+=("platform-wsl")
            ;;
        arch)
            packages+=("platform-arch")
            # Add Hyprland if installed (works during provisioning, not just in session)
            if command -v hyprctl &>/dev/null || [ -f /usr/bin/Hyprland ]; then
                packages+=("arch-hyprland")
            fi
            ;;
    esac

    echo "${packages[@]}"
}

# Stow packages with conflict detection
stow_packages() {
    local dotfiles_dir="$1"
    shift
    local packages=("$@")
    local failed=()

    for package in "${packages[@]}"; do
        if [ ! -d "$dotfiles_dir/$package" ]; then
            warn "Package '$package' does not exist, skipping"
            continue
        fi

        info "Stowing $package..."

        # Explicit stow invocation with source directory
        if stow -d "$dotfiles_dir" -t "$HOME" -v "$package" 2>&1; then
            success "Stowed $package"
        else
            error "Failed to stow $package"
            failed+=("$package")
        fi
    done

    if [ ${#failed[@]} -gt 0 ]; then
        error "Failed packages: ${failed[*]}"
        return 1
    fi

    return 0
}

# Unstow packages (for cleanup)
unstow_packages() {
    local dotfiles_dir="$1"
    shift
    local packages=("$@")

    for package in "${packages[@]}"; do
        if [ -d "$dotfiles_dir/$package" ]; then
            info "Unstowing $package..."
            stow -d "$dotfiles_dir" -t "$HOME" -D -v "$package" 2>/dev/null || true
        fi
    done
}

# Main bootstrap function
main() {
    local dotfiles_dir="${HOME}/.dotfiles"
    local dry_run=false
    local unstow=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -u|--unstow)
                unstow=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -d, --dry-run    Show what would be done"
                echo "  -u, --unstow     Remove stowed dotfiles"
                echo "  -h, --help       Show this help"
                exit 0
                ;;
            *)
                fatal "Unknown option: $1"
                ;;
        esac
    done

    info "Dotfiles Bootstrap"
    info "=================="

    # Detect OS
    local os
    os=$(detect_os)
    success "Detected: $os"

    # Check prerequisites
    check_prerequisites

    # Get packages for this OS
    local packages
    read -ra packages <<< "$(get_packages "$os")"
    info "Packages to stow: ${packages[*]}"

    if [ "$unstow" = true ]; then
        info "Unstowing packages..."
        unstow_packages "$dotfiles_dir" "${packages[@]}"
        success "Unstow complete"
        exit 0
    fi

    if [ "$dry_run" = true ]; then
        info "Dry run mode - no changes will be made"
        for package in "${packages[@]}"; do
            if [ -d "$dotfiles_dir/$package" ]; then
                echo "Would stow: $package"
                stow -d "$dotfiles_dir" -t "$HOME" -n -v "$package" 2>&1 | head -20
            fi
        done
        exit 0
    fi

    # Stow packages
    if stow_packages "$dotfiles_dir" "${packages[@]}"; then
        success "Bootstrap complete!"
        echo ""
        info "Next steps:"
        echo "  1. Restart your shell: exec zsh"
        echo "  2. Run zgenom reset to regenerate plugins"
        echo "  3. Verify tools: command -v task claude bd git nvim"
    else
        fatal "Bootstrap failed - some packages could not be stowed"
    fi
}

main "$@"
