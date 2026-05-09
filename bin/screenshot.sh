#!/bin/bash

#!/bin/bash
set -euo pipefail

FILE="${1:-screenshot_urls.txt}"                                                                        
BASE="$(basename "$FILE")"                                                                              
BASE="${BASE%.*}"                                                                                       
OUTPUT_DIR="screenshots/${BASE}"                                                                        


mkdir -p "$OUTPUT_DIR"                                                                                  
gowitness file \
 --file "$FILE" \
 --threads 1 \
 --delay 5 \
 --disable-db \
 --resolution-x 720 \
 --resolution-y 450 \
 --screenshot-path "$OUTPUT_DIR"  > "$OUTPUT_DIR/index.html"

for I in "$OUTPUT_DIR"/*; do                                                                            
 [ -f "$I" ] || continue                                                                               
 NAME="$(basename "$I")"                                                                               
 [ "$NAME" = "index.html" ] && continue                                                                
 printf '%s<br/>\n<img src="%s"><br>\n<hr/>\n' "$NAME" "$NAME" >> "$OUTPUT_DIR/index.html"             
done                                                                                 
