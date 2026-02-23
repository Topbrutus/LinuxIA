#!/bin/bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
DRY_RUN=false
KEEP_DAYS=30
KEEP_COUNT=0
SNAPSHOT_DIR="/opt/linuxia/data/shareA/archives/configsnap"

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Manage retention policy for LinuxIA config snapshots.
By default, operates in DRY RUN mode (no deletions).

OPTIONS:
    --dry-run           Show what would be deleted (default)
    --execute           Actually delete files (REQUIRES CONFIRMATION)
    --keep-days N       Keep snapshots newer than N days (default: 30)
    --keep-count N      Keep at least N most recent snapshots (default: 0)
    --snapshot-dir PATH Override snapshot directory (default: $SNAPSHOT_DIR)
    -h, --help          Show this help message

EXAMPLES:
    # Dry run: show what would be deleted (30+ days old)
    $SCRIPT_NAME --dry-run --keep-days 30

    # Keep last 60 days
    $SCRIPT_NAME --dry-run --keep-days 60

    # Keep at least 10 most recent snapshots, regardless of age
    $SCRIPT_NAME --dry-run --keep-count 10

    # Execute deletion (REQUIRES CONFIRMATION)
    $SCRIPT_NAME --execute --keep-days 30

SAFETY:
    - Defaults to DRY RUN mode
    - Requires explicit --execute flag
    - Prompts for confirmation before deletion
    - Provides detailed list of files to be deleted
    - Verifies snapshot directory exists and is readable

EXIT CODES:
    0 - Success (or dry run completed)
    1 - Error (missing directory, invalid arguments, etc.)
    2 - User aborted execution

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --execute)
            DRY_RUN=false
            shift
            ;;
        --keep-days)
            KEEP_DAYS="$2"
            shift 2
            ;;
        --keep-count)
            KEEP_COUNT="$2"
            shift 2
            ;;
        --snapshot-dir)
            SNAPSHOT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            printf "Error: Unknown option: %s\n" "$1" >&2
            usage
            ;;
    esac
done

# Validate arguments
if ! [[ "$KEEP_DAYS" =~ ^[0-9]+$ ]]; then
    printf "Error: --keep-days must be a positive integer\n" >&2
    exit 1
fi

if ! [[ "$KEEP_COUNT" =~ ^[0-9]+$ ]]; then
    printf "Error: --keep-count must be a positive integer\n" >&2
    exit 1
fi

# Verify snapshot directory exists
if [[ ! -d "$SNAPSHOT_DIR" ]]; then
    printf "Error: Snapshot directory does not exist: %s\n" "$SNAPSHOT_DIR" >&2
    exit 1
fi

if [[ ! -r "$SNAPSHOT_DIR" ]]; then
    printf "Error: Snapshot directory not readable: %s\n" "$SNAPSHOT_DIR" >&2
    exit 1
fi

# Find all snapshot files
mapfile -t ALL_SNAPSHOTS < <(find "$SNAPSHOT_DIR" -type f -name "linuxia-configsnap_*.tar.zst" | sort -r)

TOTAL_COUNT=${#ALL_SNAPSHOTS[@]}
if [[ $TOTAL_COUNT -eq 0 ]]; then
    printf "No snapshots found in %s\n" "$SNAPSHOT_DIR"
    exit 0
fi

printf "=== Snapshot Retention Analysis ===\n"
printf "Directory: %s\n" "$SNAPSHOT_DIR"
printf "Total snapshots found: %d\n" "$TOTAL_COUNT"
printf "Keep days: %d\n" "$KEEP_DAYS"
printf "Keep count (minimum): %d\n" "$KEEP_COUNT"
printf "\n"

# Find candidates for deletion (older than KEEP_DAYS)
mapfile -t DELETE_CANDIDATES < <(find "$SNAPSHOT_DIR" -type f -name "linuxia-configsnap_*.tar.zst" -mtime +"$KEEP_DAYS" | sort)

DELETE_COUNT=${#DELETE_CANDIDATES[@]}

# Apply keep-count logic: protect N most recent files
if [[ $KEEP_COUNT -gt 0 ]]; then
    # Get N most recent files to protect
    mapfile -t PROTECTED_FILES < <(printf '%s\n' "${ALL_SNAPSHOTS[@]}" | head -n "$KEEP_COUNT")
    
    # Filter DELETE_CANDIDATES to exclude protected files
    FILTERED_DELETE=()
    for candidate in "${DELETE_CANDIDATES[@]}"; do
        is_protected=false
        for protected in "${PROTECTED_FILES[@]}"; do
            if [[ "$candidate" == "$protected" ]]; then
                is_protected=true
                break
            fi
        done
        if [[ "$is_protected" == false ]]; then
            FILTERED_DELETE+=("$candidate")
        fi
    done
    DELETE_CANDIDATES=("${FILTERED_DELETE[@]}")
    DELETE_COUNT=${#DELETE_CANDIDATES[@]}
fi

if [[ $DELETE_COUNT -eq 0 ]]; then
    printf "No snapshots eligible for deletion.\n"
    printf "All %d snapshots are within retention policy.\n" "$TOTAL_COUNT"
    exit 0
fi

printf "Snapshots eligible for deletion: %d\n" "$DELETE_COUNT"
printf "\n"

# List files to be deleted with details
printf "=== Files to be deleted ===\n"
TOTAL_SIZE=0
for file in "${DELETE_CANDIDATES[@]}"; do
    if [[ -f "$file" ]]; then
        SIZE=$(stat -c %s "$file" 2>/dev/null || echo 0)
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
        SIZE_MB=$((SIZE / 1024 / 1024))
        MTIME=$(stat -c %y "$file" | cut -d' ' -f1)
        printf "%-70s  %10s MB  %s\n" "$(basename "$file")" "$SIZE_MB" "$MTIME"
    fi
done

TOTAL_SIZE_MB=$((TOTAL_SIZE / 1024 / 1024))
printf "\nTotal space to be freed: %d MB\n" "$TOTAL_SIZE_MB"
printf "\n"

# Dry run or execute
if [[ "$DRY_RUN" == true ]]; then
    printf "=== DRY RUN MODE ===\n"
    printf "No files deleted. Use --execute to perform actual deletion.\n"
    exit 0
fi

# Execute mode: require confirmation
printf "=== EXECUTE MODE ===\n"
printf "WARNING: This will PERMANENTLY delete %d snapshot files (%d MB).\n" "$DELETE_COUNT" "$TOTAL_SIZE_MB"
printf "\n"
printf "Type 'DELETE' (all caps) to confirm: "
read -r CONFIRMATION

if [[ "$CONFIRMATION" != "DELETE" ]]; then
    printf "Aborted. No files deleted.\n"
    exit 2
fi

printf "\nDeleting %d files...\n" "$DELETE_COUNT"

DELETED_COUNT=0
FAILED_COUNT=0

for file in "${DELETE_CANDIDATES[@]}"; do
    if rm -f "$file" 2>/dev/null; then
        ((DELETED_COUNT++))
        printf "Deleted: %s\n" "$(basename "$file")"
    else
        ((FAILED_COUNT++))
        printf "Failed to delete: %s\n" "$file" >&2
    fi
done

printf "\n=== Deletion Summary ===\n"
printf "Successfully deleted: %d files\n" "$DELETED_COUNT"
printf "Failed deletions: %d files\n" "$FAILED_COUNT"
printf "Freed space: ~%d MB\n" "$TOTAL_SIZE_MB"

if [[ $FAILED_COUNT -gt 0 ]]; then
    exit 1
fi

exit 0
