#!/bin/zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USERDIR="$SCRIPT_DIR/userdir"
SYSDIR="$SCRIPT_DIR/sysdir"
PKGDIR="$SCRIPT_DIR/pkgs"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create directories if they don't exist
mkdir -p "$PKGDIR"

# Backup user dotfiles
if [[ -d "$USERDIR" ]] && [[ -n "$(find "$USERDIR" -type f 2>/dev/null)" ]]; then
    log_info "Backing up user dotfiles from ~/ to $USERDIR"
    
    cd "$USERDIR"
    find . -type f -print0 | while IFS= read -r -d '' file; do
        # Remove leading ./
        clean_file="${file#./}"
        source_file="$HOME/$clean_file"

        if [[ -f "$source_file" ]]; then
	    log_info "Backing up $source_file"
            # Use rsync with progress and preserve attributes
            rsync -a --progress "$source_file" "$file"
        else
            log_warn "Source file $source_file not found, skipping..."
        fi
    done
else
    log_warn "No user files to backup (userdir empty or doesn't exist)"
fi

# Backup system files
if [[ -d "$SYSDIR" ]] && [[ -n "$(find "$SYSDIR" -type f 2>/dev/null)" ]]; then
    log_info "Backing up system files from / to $SYSDIR"
    
    cd "$SYSDIR"
    find . -type f -print0 | while IFS= read -r -d '' file; do
        clean_file="${file#./}"
        source_file="/$clean_file"
        
        if [[ -f "$source_file" ]]; then
	    log_info "Backing up $source_file"
            # Use sudo with rsync for system files
            sudo rsync -a --progress "$source_file" "$file"
            # Fix ownership back to current user
            sudo chown "$USER:$(id -gn)" "$file"
        else
            log_warn "Source file $source_file not found, skipping..."
        fi
    done
else
    log_warn "No system files to backup (sysdir empty or doesn't exist)"
fi

# Backup package lists
log_info "Updating package lists..."
if pacman -Qenq > "$PKGDIR/native.tmp"; then
    mv "$PKGDIR/native.tmp" "$PKGDIR/native"
    log_info "Native packages: $(wc -l < "$PKGDIR/native") packages"
else
    log_error "Failed to get native packages"
fi

if pacman -Qemq > "$PKGDIR/foreign.tmp"; then
    mv "$PKGDIR/foreign.tmp" "$PKGDIR/foreign"
    log_info "Foreign packages: $(wc -l < "$PKGDIR/foreign") packages"
else
    log_error "Failed to get foreign packages"
fi

# Optional: Show summary if git is available
if command -v git >/dev/null 2>&1 && [[ -d "$SCRIPT_DIR/.git" ]]; then
    cd "$SCRIPT_DIR"
    if [[ -n "$(git status --porcelain)" ]]; then
        log_info "Files changed:"
        git status --porcelain
    else
        log_info "No changes detected"
    fi
fi

log_info "Backup completed successfully!"
