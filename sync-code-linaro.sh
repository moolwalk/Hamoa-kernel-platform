#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# ANSI color support
COLOR_RESET="\e[0m"
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_BLUE="\e[34m"

MANIFEST_URL="https://git.codelinaro.org/clo/la/kernelplatform/manifest"
MANIFEST_BRANCH="release"
MANIFEST_NAME="AU_LINUX_KERNEL.PLATFORM.5.0.R32.00.00.00.205.015.xml"
REPO_DIR=".repo"

function color_echo() {
  local color="$1"
  shift
  printf "%b%s%b\n" "$color" "$*" "$COLOR_RESET"
}

function info() {
  color_echo "$COLOR_BLUE" "INFO: $*"
}

function warn() {
  color_echo "$COLOR_YELLOW" "WARNING: $*"
}

function success() {
  color_echo "$COLOR_GREEN" "$*"
}

function error() {
  color_echo "$COLOR_RED" "ERROR: $*"
}

function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

function usage() {
  cat <<EOF
Usage: $0 [sync-dir]

Initialize and sync the Code Linaro repo manifest.

Arguments:
  sync-dir   Optional destination directory for the repo checkout (default: current directory)

Environment variables:
  REPO_URL        Override the manifest repo URL
  REPO_BRANCH     Override the manifest branch
  REPO_MANIFEST   Override the manifest name
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

TARGET_DIR="${1:-.}"

if ! command_exists repo; then
  error "'repo' tool is not installed or not on PATH."
  echo "Install it from https://source.android.com/setup/develop#installing-repo and try again."
  exit 1
fi

MANIFEST_URL="${REPO_URL:-$MANIFEST_URL}"
MANIFEST_BRANCH="${REPO_BRANCH:-$MANIFEST_BRANCH}"
MANIFEST_NAME="${REPO_MANIFEST:-$MANIFEST_NAME}"

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

if [[ -d "$REPO_DIR" && -f "$REPO_DIR/manifest.xml" ]]; then
  info "Repo already initialized in '$TARGET_DIR'. Syncing current manifest..."
  repo sync -c --no-tags --no-clone-bundle -j$(nproc)
else
  if [[ -d "$REPO_DIR" ]]; then
    warn ".repo exists but manifest is missing; reinitializing repo manifest."
  else
    info "Initializing repo manifest: $MANIFEST_NAME from branch $MANIFEST_BRANCH"
  fi
  repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH" -m "$MANIFEST_NAME"
  info "Performing initial repo sync..."
  repo sync -c --no-tags --no-clone-bundle -j$(nproc)
fi

success "Code Linaro sync complete in: $(pwd)"
