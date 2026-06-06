#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# ANSI color support
COLOR_RESET="\e[0m"
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_BLUE="\e[34m"

MANIFEST_URL="${MANIFEST_URL:-https://git.codelinaro.org/clo/la/kernelplatform/manifest}"
MANIFEST_BRANCH="${REPO_BRANCH:-release}"
MANIFEST_NAME="${MANIFEST_NAME:-AU_LINUX_KERNEL.PLATFORM.5.0.R32.00.00.00.205.015.xml}"
REPO_DIR=".repo"

# Environment aliases
MANIFEST_URL="${REPO_URL:-$MANIFEST_URL}"
MANIFEST_NAME="${REPO_MANIFEST:-${AU_TAG_NAME:-$MANIFEST_NAME}}"

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
Usage: $0 [OPTIONS] [sync-dir]

Initialize and sync the Code Linaro repo manifest.

Arguments:
  sync-dir   Optional destination directory for the repo checkout (default: current directory)

Options:
  --depth <number>          Shallow clone with the specified depth (passed to repo tool)
  --manifest-url <url>      Specify the manifest repo URL
  --manifest-name <name>    Specify the manifest file name
  --au-tag-name <name>      Alias for --manifest-name
  -h, --help                Show this help message

Environment variables:
  MANIFEST_URL    Override the manifest repo URL
  REPO_URL        Alias for MANIFEST_URL
  REPO_BRANCH     Override the manifest branch
  MANIFEST_NAME   Override the manifest name
  AU_TAG_NAME     Alias for MANIFEST_NAME
  REPO_MANIFEST   Alias for MANIFEST_NAME
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

DEPTH_OPTION=""
TARGET_DIR="."

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --depth)
      if [[ -z "${2:-}" ]]; then
        error "--depth requires a number argument"
        exit 1
      fi
      DEPTH_OPTION="--depth $2"
      shift 2
      ;;
    --manifest-url)
      if [[ -z "${2:-}" ]]; then
        error "--manifest-url requires a URL argument"
        exit 1
      fi
      MANIFEST_URL="$2"
      shift 2
      ;;
    --manifest-name|--au-tag-name)
      if [[ -z "${2:-}" ]]; then
        error "$1 requires a manifest name argument"
        exit 1
      fi
      MANIFEST_NAME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

if ! command_exists repo; then
  error "'repo' tool is not installed or not on PATH."
  echo "Install it from https://source.android.com/setup/develop#installing-repo and try again."
  exit 1
fi

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

if [[ -d "$REPO_DIR" && -f "$REPO_DIR/manifest.xml" ]]; then
  info "Repo already initialized in '$TARGET_DIR'. Syncing current manifest..."
  repo sync -c --no-tags --no-clone-bundle -j$(nproc) $DEPTH_OPTION
else
  if [[ -d "$REPO_DIR" ]]; then
    warn ".repo exists but manifest is missing; reinitializing repo manifest."
  else
    info "Initializing repo manifest: $MANIFEST_NAME from branch $MANIFEST_BRANCH"
  fi
  repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH" -m "$MANIFEST_NAME" $DEPTH_OPTION
  info "Performing initial repo sync..."
  repo sync -c --no-tags --no-clone-bundle -j$(nproc) $DEPTH_OPTION
fi

success "Code Linaro sync complete in: $(pwd)"
