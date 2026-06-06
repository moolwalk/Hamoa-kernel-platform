#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# ANSI color support
COLOR_RESET="\e[0m"
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_BLUE="\e[34m"

REPO_ROOT="."
DEST_DIR="./extracted"
BRANCH=""

function color_echo() {
  local color="$1"
  shift
  printf "%b%s%b\n" "$color" "$*" "$COLOR_RESET"
}

function info() {
  color_echo "$COLOR_BLUE" "INFO: $*"
}

function success() {
  color_echo "$COLOR_GREEN" "$*"
}

function warn() {
  color_echo "$COLOR_YELLOW" "WARNING: $*"
}

function usage() {
  cat <<EOF
Usage: $0 [-r repo-root] [-d dest-parent-dir] [-b branch] <project-path>

Extract a standalone git repository from a repo-managed checkout.

Arguments:
  project-path         Repo project path relative to the repository root,
                       for example: kernel_platform/common or kernel_platform/build/kernel

Options:
  -r repo-root         Path to the repo checkout root (default: current directory)
  -d dest-parent-dir   Parent directory for the extracted repo (default: ./extracted)
  -b branch            Checkout a specific branch after cloning
  -h, --help           Show this help message
EOF
}

function error() {
  color_echo "$COLOR_RED" "ERROR: $*" >&2
  exit 1
}

while getopts ":r:d:b:h" opt; do
  case "$opt" in
    r) REPO_ROOT="$OPTARG" ;;
    d) DEST_DIR="$OPTARG" ;;
    b) BRANCH="$OPTARG" ;;
    h) usage; exit 0 ;;
    :) error "Option -$OPTARG requires an argument." ;;
    \?) error "Unknown option: -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

PROJECT_PATH="$1"
PROJECT_PATH="${PROJECT_PATH%.git}"

REPO_ROOT="$(realpath "$REPO_ROOT")"
BARE_REPO="$REPO_ROOT/.repo/projects/$PROJECT_PATH.git"

if [[ ! -d "$BARE_REPO" ]]; then
  error "Could not find bare repo at: $BARE_REPO"
fi

mkdir -p "$DEST_DIR"
OUTPUT_DIR="$DEST_DIR/$(basename "$PROJECT_PATH")"

if [[ -e "$OUTPUT_DIR" ]]; then
  error "Destination already exists: $OUTPUT_DIR"
fi

info "Extracting project from $BARE_REPO to $OUTPUT_DIR"

git clone --no-local "$BARE_REPO" "$OUTPUT_DIR"

if [[ -n "$BRANCH" ]]; then
  git -C "$OUTPUT_DIR" checkout "$BRANCH"
fi

success "Extraction complete: $OUTPUT_DIR"
info "Run: cd $OUTPUT_DIR"
