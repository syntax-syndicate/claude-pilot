#!/usr/bin/env bash
# claude-pilot Installer
# One-line installation/update script for Claude Code preset
#
# Usage:
#   Install:   curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash
#   Update:    curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash -s -- update
#   Version:   curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash -s -- version

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Remote repository URLs
REPO_BASE="https://raw.githubusercontent.com/changoo89/claude-pilot/main"
REPO_RAW="${REPO_BASE}"

# Installation mode (install/update/version)
MODE="${1:-install}"

# Target directory (default: current directory)
TARGET_DIR="$(pwd)"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Print banner
print_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
       _                 _                  _ _       _
   ___| | __ _ _   _  __| | ___       _ __ (_) | ___ | |_
  / __| |/ _` | | | |/ _` |/ _ \_____| '_ \| | |/ _ \| __|
 | (__| | (_| | |_| | (_| |  __/_____| |_) | | | (_) | |_
  \___|_|\__,_|\__,_|\__,_|\___|     | .__/|_|_|\___/ \__|
                                     |_|
                         Your Claude Code Copilot
EOF
    echo -e "${NC}"
    echo -e "${GREEN}claude-pilot v${VERSION}${NC}"
    echo ""
}

# Function to print error and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to print info
info() {
    echo -e "${BLUE}i${NC} $1"
}

# Function to print success
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Check if curl is available
check_curl() {
    if ! command -v curl &> /dev/null; then
        error_exit "curl is required but not installed. Please install curl first."
    fi
}

# =============================================================================
# FILE OWNERSHIP DEFINITION
# =============================================================================

# Files managed by claude-pilot (overwritten on update)
# Format: "source_path:dest_path"
declare -a MANAGED_FILES=(
    # Commands (0x and 9x prefix only - claude-pilot core)
    ".claude/commands/00_plan.md:.claude/commands/00_plan.md"
    ".claude/commands/01_confirm.md:.claude/commands/01_confirm.md"
    ".claude/commands/02_execute.md:.claude/commands/02_execute.md"
    ".claude/commands/03_close.md:.claude/commands/03_close.md"
    ".claude/commands/90_review.md:.claude/commands/90_review.md"
    ".claude/commands/91_document.md:.claude/commands/91_document.md"
    # Guides
    ".claude/guides/context-engineering.md:.claude/guides/context-engineering.md"
    ".claude/guides/ralph-loop-tdd.md:.claude/guides/ralph-loop-tdd.md"
    # Templates
    ".claude/templates/PRP.md.template:.claude/templates/PRP.md.template"
    ".claude/templates/CONTEXT.md.template:.claude/templates/CONTEXT.md.template"
    ".claude/templates/SKILL.md.template:.claude/templates/SKILL.md.template"
    # Hooks
    ".claude/scripts/hooks/typecheck.sh:.claude/scripts/hooks/typecheck.sh"
    ".claude/scripts/hooks/lint.sh:.claude/scripts/hooks/lint.sh"
    ".claude/scripts/hooks/check-todos.sh:.claude/scripts/hooks/check-todos.sh"
    ".claude/scripts/hooks/branch-guard.sh:.claude/scripts/hooks/branch-guard.sh"
    # Version file
    ".claude/.pilot-version:.claude/.pilot-version"
)

# User-owned files (never overwritten)
declare -a USER_FILES=(
    "CLAUDE.md"
    "AGENTS.md"
    ".pilot"
    ".claude/settings.json"
    ".claude/local"
)

# =============================================================================
# REMOTE DOWNLOAD FUNCTIONS
# =============================================================================

# Download a single file from remote repository
download_file() {
    local src_path="$1"
    local dest_path="$2"
    local dest_full="${TARGET_DIR}/${dest_path}"

    # Create directory if needed
    local dest_dir="$(dirname "${dest_full}")"
    mkdir -p "${dest_dir}"

    # Download file
    local url="${REPO_RAW}/${src_path}"
    if curl -fsSL "${url}" -o "${dest_full}" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Download all managed files
download_managed_files() {
    info "Downloading claude-pilot managed files..."

    local success_count=0
    local fail_count=0

    for entry in "${MANAGED_FILES[@]}"; do
        local src_path="${entry%%:*}"
        local dest_path="${entry#*:}"

        if download_file "${src_path}" "${dest_path}"; then
            success_count=$((success_count + 1))
        else
            fail_count=$((fail_count + 1))
            warning "Failed to download: ${src_path}"
        fi
    done

    info "Downloaded: ${success_count} files"
    if [[ ${fail_count} -gt 0 ]]; then
        warning "Failed: ${fail_count} files"
    fi

    return ${fail_count}
}

# =============================================================================
# LOCAL INSTALLATION FUNCTIONS
# =============================================================================

# Install from local template directory
install_from_local() {
    local template_dir="$1"

    info "Installing from local template: ${template_dir}"

    # Copy managed files
    for entry in "${MANAGED_FILES[@]}"; do
        local src_path="${entry%%:*}"
        local dest_path="${entry#*:}"
        local src_full="${template_dir}/${src_path}"
        local dest_full="${TARGET_DIR}/${dest_path}"

        if [[ -f "${src_full}" ]]; then
            mkdir -p "$(dirname "${dest_full}")"
            cp "${src_full}" "${dest_full}"
        fi
    done

    success "Copied managed files from local template"
}

# =============================================================================
# VERSION FUNCTIONS
# =============================================================================

# Get current installed version
get_current_version() {
    if [[ -f "${TARGET_DIR}/.claude/.pilot-version" ]]; then
        cat "${TARGET_DIR}/.claude/.pilot-version"
    else
        echo "none"
    fi
}

# Save version to file
save_version() {
    echo "${VERSION}" > "${TARGET_DIR}/.claude/.pilot-version"
}

# Show version information
show_version() {
    local current_version=$(get_current_version)
    echo "claude-pilot version information:"
    echo "  Latest:  ${VERSION}"
    echo "  Current: ${current_version}"

    if [[ "${current_version}" == "${VERSION}" ]]; then
        echo ""
        success "You are running the latest version!"
        exit 0
    fi
}

# =============================================================================
# MODE HANDLERS
# =============================================================================

# Handle install mode
do_install() {
    print_banner

    # Detect if running from cloned repo or via curl
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ -f "${SCRIPT_DIR}/.claude/settings.json" ]]; then
        # Running from cloned repo
        install_from_local "${SCRIPT_DIR}"
    else
        # Running via curl - download from remote
        info "Installing from remote repository..."
        if ! download_managed_files; then
            error_exit "Failed to download some files. Please check your internet connection."
        fi
    fi

    # Create .pilot directory structure
    info "Creating .pilot directory structure..."
    mkdir -p "${TARGET_DIR}/.pilot/plan/pending"
    mkdir -p "${TARGET_DIR}/.pilot/plan/in_progress"
    mkdir -p "${TARGET_DIR}/.pilot/plan/done"
    mkdir -p "${TARGET_DIR}/.pilot/plan/active"
    success ".pilot directory created"

    # Save version
    save_version
    success "Version ${VERSION} installed"

    # Summary
    echo ""
    echo -e "${GREEN}======================================================${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "${GREEN}======================================================${NC}"
    echo ""
    info "Summary:"
    echo "  Version: ${VERSION}"
    echo "  Target: ${TARGET_DIR}"
    echo ""
    info "Next Steps:"
    echo "  1. Review CLAUDE.md and customize for your project"
    echo "  2. Test: /00_plan 'test feature'"
    echo "  3. Start building with /02_execute"
    echo ""
    success "Happy coding with claude-pilot!"
    echo ""
}

# Handle update mode
do_update() {
    print_banner

    local current_version=$(get_current_version)

    if [[ "${current_version}" == "${VERSION}" ]]; then
        success "Already up to date (v${VERSION})"
        exit 0
    fi

    info "Updating from v${current_version} to v${VERSION}..."

    # Backup existing installation
    if [[ -d "${TARGET_DIR}/.claude" ]]; then
        local backup_dir="${TARGET_DIR}/.claude.backup.$(date +%Y%m%d_%H%M%S)"
        warning "Creating backup: ${backup_dir}"
        cp -r "${TARGET_DIR}/.claude" "${backup_dir}"
    fi

    # Download managed files only (user files preserved)
    info "Updating claude-pilot managed files..."
    if ! download_managed_files; then
        error_exit "Failed to download some files. Please check your internet connection."
    fi

    # Save version
    save_version
    success "Updated to version ${VERSION}"

    echo ""
    info "Updated files:"
    echo "  - Commands (00-03, 90-91)"
    echo "  - Guides"
    echo "  - Templates"
    echo "  - Hooks"
    echo ""
    info "Preserved files (your changes):"
    echo "  - CLAUDE.md"
    echo "  - AGENTS.md"
    echo "  - .pilot/"
    echo "  - .claude/settings.json"
    echo "  - Custom commands"
    echo ""
    success "Update complete!"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    check_curl

    case "${MODE}" in
        install)
            do_install
            ;;
        update)
            do_update
            ;;
        version|--version|-v)
            print_banner
            show_version
            ;;
        *)
            error_exit "Unknown mode: ${MODE}
Usage:
  curl ... | bash                    # Install
  curl ... | bash -s -- update       # Update
  curl ... | bash -s -- version      # Show version"
            ;;
    esac
}

main
