#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DB_FILE="$SCRIPT_DIR/wol_entries"

usage() {
    code=${1:-1}
    echo "Usage:"
    echo "  $0                     # send WOL to default (unnamed) MAC"
    echo "  $0 <name>              # send WOL to named MAC entry"
    echo "  $0 list                # list all stored MAC entries"
    echo "  $0 set <MAC>           # set default (unnamed) MAC entry"
    echo "  $0 set -n <name> <MAC> # set named MAC entry (create/update)"
    echo "  $0 unset -n <name>     # remove named MAC entry"
    echo "  $0 -h|--help"
    exit "$code"
}

is_valid_mac() {
    echo "$1" | grep -Eiq '^[0-9a-f]{2}(:[0-9a-f]{2}){5}$'
}

is_valid_name() {
    # simple/safe name
    echo "$1" | grep -Eq '^[A-Za-z0-9_.-]+$'
}

init_db() {
    if [ ! -f "$DB_FILE" ]; then
        cat > "$DB_FILE" <<'EOF'
# default entry (unnamed)
|
EOF
        chmod 600 "$DB_FILE" || true
    fi
}

normalize_db() {
    # Keep only:
    #   |MAC        (default)
    #   name|MAC    (named)
    # Keep last default entry if multiple
    tmp="$DB_FILE.tmp.$$"

    awk '
    BEGIN { OFS="|" }
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
        line=$0
        sub(/^[[:space:]]+/, "", line)
        sub(/[[:space:]]+$/, "", line)

        p = index(line, "|")
        if (p == 0) next

        name = substr(line, 1, p-1)
        mac  = substr(line, p+1)

        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", mac)

        if (mac != "" && mac !~ /^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}$/) next

        if (name == "") {
            default_mac = toupper(mac)
            have_default = 1
            next
        }

        if (name !~ /^[A-Za-z0-9_.-]+$/) next

        named[name] = toupper(mac)
        order[++n] = name
    }
    END {
        if (have_default) {
            print "", default_mac
        } else {
            print "", ""
        }

        seen_count=0
        for (i=1; i<=n; i++) {
            nm = order[i]
            if (!(nm in printed)) {
                printed[nm]=1
                names[++seen_count]=nm
            }
        }
        for (i=1; i<=seen_count; i++) {
            nm=names[i]
            if (named[nm] != "") print nm, named[nm]
        }
    }
    ' "$DB_FILE" > "$tmp"

    mv "$tmp" "$DB_FILE"
    chmod 600 "$DB_FILE" || true
}

get_default_mac() {
    awk -F'|' '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    $1=="" { mac=$2 }
    END { gsub(/^[[:space:]]+|[[:space:]]+$/, "", mac); print mac }
    ' "$DB_FILE"
}

get_named_mac() {
    target="$1"
    awk -F'|' -v target="$target" '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
        name=$1; mac=$2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", mac)
        if (name==target) found=mac
    }
    END {
        if (found!="") print found
    }
    ' "$DB_FILE"
}

set_default_mac() {
    mac="$1"
    tmp="$DB_FILE.tmp.$$"
    awk -F'|' -v newmac="$mac" '
    BEGIN { done=0 }
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
        name=$1; m=$2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", m)
        if (name=="") {
            if (!done) {
                print "|" toupper(newmac)
                done=1
            }
            next
        }
        if (name != "" && m != "") print name "|" toupper(m)
    }
    END {
        if (!done) print "|" toupper(newmac)
    }
    ' "$DB_FILE" > "$tmp"
    mv "$tmp" "$DB_FILE"
}

set_named_mac() {
    name="$1"
    mac="$2"
    tmp="$DB_FILE.tmp.$$"
    awk -F'|' -v tname="$name" -v tmac="$mac" '
    BEGIN { done=0 }
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
        name=$1; m=$2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", m)

        if (name=="") {
            print "|" toupper(m)
            next
        }

        if (name==tname) {
            print tname "|" toupper(tmac)
            done=1
        } else if (name != "" && m != "") {
            print name "|" toupper(m)
        }
    }
    END {
        if (!done) print tname "|" toupper(tmac)
    }
    ' "$DB_FILE" > "$tmp"
    mv "$tmp" "$DB_FILE"
}

unset_named_mac() {
    target="$1"
    tmp="$DB_FILE.tmp.$$"

    awk -F'|' -v target="$target" '
    BEGIN { removed=0 }
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
        name=$1; mac=$2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", mac)

        if (name=="") {
            print "|" toupper(mac)
            next
        }

        if (name==target) {
            removed=1
            next
        }

        if (name != "" && mac != "") print name "|" toupper(mac)
    }
    END {
        if (removed) exit 0
        exit 2
    }
    ' "$DB_FILE" > "$tmp" || rc=$?

    rc=${rc:-0}
    if [ "$rc" -eq 2 ]; then
        rm -f "$tmp"
        return 1
    elif [ "$rc" -ne 0 ]; then
        rm -f "$tmp"
        echo "Failed to unset entry" >&2
        exit 1
    fi

    mv "$tmp" "$DB_FILE"
    return 0
}

list_entries() {
    echo "DB file: $DB_FILE"
    echo "Stored WOL entries:"
    dmac="$(get_default_mac)"
    if [ -n "$dmac" ]; then
        echo "  [default] $dmac"
    else
        echo "  [default] (not set)"
    fi

    awk -F'|' '
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    {
        name=$1; mac=$2
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", mac)
        if (name!="") print "  [" name "] " toupper(mac)
    }
    ' "$DB_FILE"
}

# ---------- main ----------
[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && usage 0

init_db
normalize_db

if [ "${1:-}" = "list" ]; then
    list_entries
    exit 0
fi

if [ "${1:-}" = "set" ]; then
    if [ "${2:-}" = "-n" ]; then
        [ -n "${3:-}" ] && [ -n "${4:-}" ] && [ -z "${5:-}" ] || usage
        name="$3"
        mac="$4"
        is_valid_name "$name" || { echo "Invalid name: $name" >&2; exit 1; }
        is_valid_mac "$mac" || { echo "Invalid MAC format: $mac" >&2; exit 1; }
        set_named_mac "$name" "$mac"
        echo "Named MAC updated: [$name] ${mac}"
        exit 0
    fi

    [ -n "${2:-}" ] && [ -z "${3:-}" ] || usage
    mac="$2"
    is_valid_mac "$mac" || { echo "Invalid MAC format: $mac" >&2; exit 1; }
    set_default_mac "$mac"
    echo "Default MAC updated: ${mac}"
    exit 0
fi

if [ "${1:-}" = "unset" ]; then
    if [ "${2:-}" = "-n" ]; then
        [ -n "${3:-}" ] && [ -z "${4:-}" ] || usage
        name="$3"
        is_valid_name "$name" || { echo "Invalid name: $name" >&2; exit 1; }
        if unset_named_mac "$name"; then
            echo "Named MAC removed: [$name]"
        else
            echo "Name not found: $name" >&2
            exit 1
        fi
        exit 0
    fi
    usage
fi

if ! command -v wakeonlan >/dev/null 2>&1; then
    echo "wakeonlan command not found. Please install it first." >&2
    exit 1
fi

# no args -> default
if [ $# -eq 0 ]; then
    dmac="$(get_default_mac)"
    if [ -z "$dmac" ]; then
        echo "Default MAC is not set. Use: $0 set <MAC>" >&2
        exit 1
    fi
    echo "Sending Wake-on-LAN to [default] $dmac"
    wakeonlan "$dmac"
    exit 0
fi

# one arg -> name only (MAC direct call removed)
if [ $# -eq 1 ]; then
    name="$1"
    mac="$(get_named_mac "$name")"
    if [ -z "$mac" ]; then
        echo "Name not found: $name" >&2
        echo "Use '$0 list' to see available names." >&2
        exit 1
    fi
    echo "Sending Wake-on-LAN to [$name] $mac"
    wakeonlan "$mac"
    exit 0
fi

usage
