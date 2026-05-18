#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="tests"
mkdir -p "$TEST_DIR"

cat > "$TEST_DIR/json_empty_body.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data ''
)
EOF

cat > "$TEST_DIR/json_empty_object.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '{}'
)
EOF

cat > "$TEST_DIR/json_array.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '[]'
)
EOF

cat > "$TEST_DIR/json_null_values.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '{"id":null,"name":null,"email":null}'
)
EOF

cat > "$TEST_DIR/json_wrong_content_type.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: text/plain"
  --data '{"test":"endpoint-test"}'
)
EOF

cat > "$TEST_DIR/json_deep_nested.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '{"a":{"b":{"c":{"d":{"e":{"f":"test"}}}}}}'
)
EOF

cat > "$TEST_DIR/json_large_body.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data "$(python3 -c 'print("{\"data\":\"" + "A"*10000 + "\"}")')"
)
EOF

cat > "$TEST_DIR/accept_html.et" <<'EOF'
ARGS=(
  -X GET
  -H "Accept: text/html"
)
EOF

cat > "$TEST_DIR/accept_xml.et" <<'EOF'
ARGS=(
  -X GET
  -H "Accept: application/xml"
)
EOF

cat > "$TEST_DIR/content_type_text_plain.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: text/plain"
  --data 'hello'
)
EOF

cat > "$TEST_DIR/content_type_xml.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/xml"
  --data '<test>hello</test>'
)
EOF

cat > "$TEST_DIR/x_forwarded_for_localhost.et" <<'EOF'
ARGS=(
  -X GET
  -H "X-Forwarded-For: 127.0.0.1"
  -H "X-Real-IP: 127.0.0.1"
)
EOF

cat > "$TEST_DIR/x_original_url.et" <<'EOF'
ARGS=(
  -X GET
  -H "X-Original-URL: /admin"
)
EOF

cat > "$TEST_DIR/x_rewrite_url.et" <<'EOF'
ARGS=(
  -X GET
  -H "X-Rewrite-URL: /admin"
)
EOF

cat > "$TEST_DIR/host_header_fake.et" <<'EOF'
ARGS=(
  -X GET
  -H "Host: evil.example"
)
EOF

cat > "$TEST_DIR/query_debug_true.et" <<'EOF'
ARGS=(
  -X GET
  --get
  --data-urlencode "debug=true"
)
EOF

cat > "$TEST_DIR/query_admin_true.et" <<'EOF'
ARGS=(
  -X GET
  --get
  --data-urlencode "admin=true"
)
EOF

cat > "$TEST_DIR/query_redirect_external.et" <<'EOF'
ARGS=(
  -X GET
  --get
  --data-urlencode "redirect=https://example.com"
)
EOF

cat > "$TEST_DIR/query_callback.et" <<'EOF'
ARGS=(
  -X GET
  --get
  --data-urlencode "callback=test"
)
EOF

cat > "$TEST_DIR/xss_basic.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '{"name":"<script>alert(1)</script>"}'
)
EOF

cat > "$TEST_DIR/ssti_basic.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '{"name":"{{7*7}}"}'
)
EOF

cat > "$TEST_DIR/sql_like.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data "{\"id\":\"1' OR '1'='1\"}"
)
EOF

echo "[+] Created extra templates in: $TEST_DIR"
find "$TEST_DIR" -type f -name "*.et" | sort
