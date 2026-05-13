#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "Usage: $0 <urls_file>"
    exit 1
fi

BASE="$(basename "$FILE")"
BASE="${BASE%.*}"

OUTPUT_DIR="screenshots/$BASE"
mkdir -p "$OUTPUT_DIR"

echo "[*] Taking screenshots from: $FILE"
echo "[*] Output directory: $OUTPUT_DIR"

gowitness file \
    --file "$FILE" \
    --threads 5 \
    --delay 1 \
    --disable-db \
    --resolution-x 1280 \
    --resolution-y 720 \
    --screenshot-path "$OUTPUT_DIR" \
    > "$OUTPUT_DIR/gowitness.log" 2>&1 || true

INDEX="$OUTPUT_DIR/index.html"

cat > "$INDEX" <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Screenshots - $BASE</title>
<style>
body { font-family: Arial, sans-serif; background: #111; color: #eee; }
.card { margin: 20px; padding: 15px; background: #222; border-radius: 8px; }
img { max-width: 100%; border: 1px solid #444; }
.name { margin-bottom: 10px; font-weight: bold; }
</style>
</head>
<body>
<h1>Screenshots - $BASE</h1>
EOF

find "$OUTPUT_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | sort | while read -r IMG; do
    NAME="$(basename "$IMG")"
    cat >> "$INDEX" <<EOF
<div class="card">
<div class="name">$NAME</div>
<img src="$NAME">
</div>
EOF
done

cat >> "$INDEX" <<EOF
</body>
</html>
EOF

echo "[+] Done."
echo "[+] Open: $INDEX"
