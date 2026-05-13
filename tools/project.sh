#!/bin/sh
# 用法：
#   ./set_project.sh NEW_VALUE
# 會在當前目錄的 Makefile 裡，
# 只在「前五行」找到的第一個 PROJECT=XXX 把等號後面換成 NEW_VALUE
# （XXX 可能為空）

if [ $# -lt 1 ]; then
    echo "Usage: $0 NEW_VALUE" >&2
    exit 1
fi

NEW_VALUE=$1
FILE=Makefile

if [ ! -f "$FILE" ]; then
    echo "Makefile not found in current directory" >&2
    exit 1
fi

# 把 & 轉義，避免在 awk 的替換字串裡被當成特殊字元
ESCAPED_NEW_VALUE=$(printf '%s\n' "$NEW_VALUE" | sed 's/&/\\&/g')

TMP="${FILE}.$$"

awk -v newval="$ESCAPED_NEW_VALUE" '
NR <= 5 && !done {
    if (sub(/PROJECT=[^[:space:]]*/, "PROJECT=" newval)) {
        done = 1
    }
}
{ print }
' "$FILE" > "$TMP" || {
    echo "awk failed" >&2
    rm -f "$TMP"
    exit 1
}

mv "$TMP" "$FILE"
