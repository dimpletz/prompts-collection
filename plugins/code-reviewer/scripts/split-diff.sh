#!/usr/bin/env bash
# split-diff.sh — Splits a large diff file into chunk files and oversized section files.
# Usage: split-diff.sh <diff-file> <max-lines> [<ignore-file>]
# Output (stdout):
#   WITHIN_LIMIT:<path>  — file is within the line limit; no output files created
#   CHUNK:<path>         — a chunk file was created
#   OVERSIZED:<path>     — a section exceeded the limit and was saved as a standalone file
#   IGNORED:<path>       — a section was excluded because its file path matched the ignore file

DIFF_FILE="$1"
MAX_LINES="${2:-500}"
IGNORE_FILE="${3:-}"

if [ -z "$DIFF_FILE" ]; then
    printf 'Usage: split-diff.sh <diff-file> <max-lines> [<ignore-file>]\n' >&2
    exit 1
fi

# If no ignore file was specified, fall back to the sibling config/.ignore
if [ -z "$IGNORE_FILE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DEFAULT_IGNORE="${SCRIPT_DIR}/../config/.ignore"
    [ -f "$DEFAULT_IGNORE" ] && IGNORE_FILE="$DEFAULT_IGNORE"
fi

if [ ! -f "$DIFF_FILE" ]; then
    printf 'Error: file not found: %s\n' "$DIFF_FILE" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Gitignore-style pattern matching helpers
# ---------------------------------------------------------------------------

# Match a file path against a single gitignore-style pattern.
# Returns 0 (true) if the path matches, 1 otherwise.
match_gitignore_pattern() {
    local file_path="$1"
    local pattern="$2"

    # Directory pattern (ends with /)
    if [[ "$pattern" == */ ]]; then
        local dir="${pattern%/}"
        if [[ "$file_path" == "$dir/"* ]] || [[ "$file_path" == *"/$dir/"* ]]; then
            return 0
        fi
        return 1
    fi

    # Rooted pattern (contains /)
    if [[ "$pattern" == */* ]]; then
        local stripped="${pattern#./}"
        stripped="${stripped#/}"
        case "$file_path" in
            $stripped|$stripped/*) return 0 ;;
        esac
        return 1
    fi

    # Unrooted pattern — match filename or any path component
    local basename_part="${file_path##*/}"
    case "$basename_part" in
        $pattern) return 0 ;;
    esac
    local IFS_ORIG="$IFS"
    IFS='/'
    local component
    for component in $file_path; do
        case "$component" in
            $pattern) IFS="$IFS_ORIG"; return 0 ;;
        esac
    done
    IFS="$IFS_ORIG"
    return 1
}

# Check if a file path should be ignored based on the ignore file.
should_ignore() {
    local file_path="$1"
    local ignore_file="$2"
    [ -z "$ignore_file" ] || [ ! -f "$ignore_file" ] && return 1

    local pattern
    while IFS= read -r pattern || [ -n "$pattern" ]; do
        # Trim trailing carriage return (Windows line endings)
        pattern="${pattern%$'\r'}"
        # Skip blank lines and comments
        [ -z "$pattern" ] && continue
        [[ "$pattern" == \#* ]] && continue
        if match_gitignore_pattern "$file_path" "$pattern"; then
            return 0
        fi
    done < "$ignore_file"
    return 1
}

TOTAL_LINES=$(wc -l < "$DIFF_FILE" | tr -d ' \t')

if [ "$TOTAL_LINES" -le "$MAX_LINES" ]; then
    printf 'WITHIN_LIMIT:%s\n' "$DIFF_FILE"
    exit 0
fi

DIR=$(dirname "$DIFF_FILE")
BASENAME=$(basename "$DIFF_FILE")
BASE="${BASENAME%.diff}"

sanitize() {
    local s
    s=$(printf '%s' "$1" | tr '/.\\ ' '-')
    s=$(printf '%s' "$s" | tr -cd '[:alnum:]-')
    s=$(printf '%s' "$s" | sed 's/--*/-/g;s/^-//;s/-$//')
    printf '%s' "$s"
}

# Collect section start line numbers (1-indexed) and the file path from each header
section_count=0
declare -a section_starts
declare -a section_paths

while IFS= read -r grep_line; do
    linenum="${grep_line%%:*}"
    diff_header="${grep_line#*:}"
    remainder="${diff_header#diff --git a/}"
    file_path="${remainder%% b/*}"
    section_starts[$section_count]=$linenum
    section_paths[$section_count]="$file_path"
    section_count=$((section_count + 1))
done < <(grep -n "^diff --git a/" "$DIFF_FILE")

if [ "$section_count" -eq 0 ]; then
    printf 'WITHIN_LIMIT:%s\n' "$DIFF_FILE"
    exit 0
fi

# Lines before the first diff --git header (0 means no preamble)
PREAMBLE_END=$((section_starts[0] - 1))

# Classify sections: ignored, oversized (> MAX_LINES lines), or eligible for chunking
declare -a eligible_starts
declare -a eligible_ends
eligible_count=0

for ((s = 0; s < section_count; s++)); do
    sec_start=${section_starts[$s]}
    if [ $((s + 1)) -lt "$section_count" ]; then
        sec_end=$((section_starts[$((s + 1))] - 1))
    else
        sec_end=$TOTAL_LINES
    fi
    sec_lines=$((sec_end - sec_start + 1))

    if should_ignore "${section_paths[$s]}" "$IGNORE_FILE"; then
        printf 'IGNORED:%s\n' "${section_paths[$s]}"
        continue
    fi

    if [ "$sec_lines" -gt "$MAX_LINES" ]; then
        sanitized=$(sanitize "${section_paths[$s]}")
        out_file="${DIR}/${BASE}-${MAX_LINES}-${sanitized}.diff"
        {
            [ "$PREAMBLE_END" -gt 0 ] && sed -n "1,${PREAMBLE_END}p" "$DIFF_FILE"
            sed -n "${sec_start},${sec_end}p" "$DIFF_FILE"
        } > "$out_file"
        printf 'OVERSIZED:%s\n' "$out_file"
    else
        eligible_starts[$eligible_count]=$sec_start
        eligible_ends[$eligible_count]=$sec_end
        eligible_count=$((eligible_count + 1))
    fi
done

# Greedily pack eligible sections into chunks
chunk_num=1
chunk_lines=0
chunk_tmp=$(mktemp)

flush_chunk() {
    local out_file="${DIR}/${BASE}-${MAX_LINES}-chunk-${chunk_num}.diff"
    {
        [ "$PREAMBLE_END" -gt 0 ] && sed -n "1,${PREAMBLE_END}p" "$DIFF_FILE"
        cat "$chunk_tmp"
    } > "$out_file"
    printf 'CHUNK:%s\n' "$out_file"
    chunk_num=$((chunk_num + 1))
    : > "$chunk_tmp"
    chunk_lines=0
}

for ((e = 0; e < eligible_count; e++)); do
    sec_start=${eligible_starts[$e]}
    sec_end=${eligible_ends[$e]}
    sec_lines=$((sec_end - sec_start + 1))

    if [ "$chunk_lines" -gt 0 ] && [ $((chunk_lines + sec_lines)) -gt "$MAX_LINES" ]; then
        flush_chunk
    fi

    sed -n "${sec_start},${sec_end}p" "$DIFF_FILE" >> "$chunk_tmp"
    chunk_lines=$((chunk_lines + sec_lines))
done

[ "$chunk_lines" -gt 0 ] && flush_chunk

rm -f "$chunk_tmp"
