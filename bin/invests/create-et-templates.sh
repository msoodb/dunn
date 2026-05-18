#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="tests"
mkdir -p "$TEST_DIR"

cat > "$TEST_DIR/method_GET.et" <<'EOF'
ARGS=(
  -X GET
)
EOF

cat > "$TEST_DIR/method_POST.et" <<'EOF'
ARGS=(
  -X POST
)
EOF

cat > "$TEST_DIR/method_OPTIONS.et" <<'EOF'
ARGS=(
  -X OPTIONS
)
EOF

cat > "$TEST_DIR/method_HEAD.et" <<'EOF'
ARGS=(
  -X HEAD
)
EOF

cat > "$TEST_DIR/method_PUT.et" <<'EOF'
ARGS=(
  -X PUT
)
EOF

cat > "$TEST_DIR/method_PATCH.et" <<'EOF'
ARGS=(
  -X PATCH
)
EOF

cat > "$TEST_DIR/method_DELETE.et" <<'EOF'
ARGS=(
  -X DELETE
)
EOF

cat > "$TEST_DIR/cors_origin.et" <<'EOF'
ARGS=(
  -X OPTIONS
  -H "Origin: https://evil.example"
  -H "Access-Control-Request-Method: POST"
)
EOF

cat > "$TEST_DIR/auth_empty_bearer.et" <<'EOF'
ARGS=(
  -H "Authorization: Bearer"
)
EOF

cat > "$TEST_DIR/auth_fake_bearer.et" <<'EOF'
ARGS=(
  -H "Authorization: Bearer fake-token-test"
)
EOF

cat > "$TEST_DIR/json_valid.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '{"test":"endpoint-test"}'
)
EOF

cat > "$TEST_DIR/json_invalid.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '{"test":'
)
EOF

cat > "$TEST_DIR/form_basic.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/x-www-form-urlencoded"
  --data 'name=test&value=endpoint-test'
)
EOF

cat > "$TEST_DIR/path_validation.et" <<'EOF'
ARGS=(
  -X POST
  -H "Content-Type: application/json"
  --data '{"filename":"../../test.txt","name":"test.php.jpg"}'
)
EOF

cat > "$TEST_DIR/auth_no_auth.et" <<'EOF'
ARGS=(
  -X GET
)
EOF

cat > "$TEST_DIR/auth_empty_header.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization:"
)
EOF

cat > "$TEST_DIR/auth_bearer_empty.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer"
)
EOF

cat > "$TEST_DIR/auth_bearer_fake.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer fake-token-test"
)
EOF

cat > "$TEST_DIR/auth_basic_fake.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Basic dGVzdDp0ZXN0"
)
EOF

cat > "$TEST_DIR/auth_null.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: null"
)
EOF

cat > "$TEST_DIR/auth_undefined.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: undefined"
)
EOF

cat > "$TEST_DIR/auth_malformed_jwt.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer aaa.bbb.ccc"
)
EOF

cat > "$TEST_DIR/auth_jwt_alg_none.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiIxMjMiLCJhZG1pbiI6dHJ1ZSwiZXhwIjo5OTk5OTk5OTk5fQ."
)
EOF

cat > "$TEST_DIR/auth_jwt_expired.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjMiLCJleHAiOjEwfQ.invalidsig"
)
EOF

cat > "$TEST_DIR/auth_jwt_wrong_iss.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJldmlsLmV4YW1wbGUiLCJzdWIiOiIxMjMiLCJhZG1pbiI6dHJ1ZX0.invalidsig"
)
EOF

cat > "$TEST_DIR/auth_jwt_wrong_aud.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJldmlsLWFwcCIsInN1YiI6IjEyMyIsImFkbWluIjp0cnVlfQ.invalidsig"
)
EOF

cat > "$TEST_DIR/auth_jwt_large.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJhZG1pbiI6dHJ1ZSwicm9sZXMiOlsiYWRtaW4iLCJzdXBlcmFkbWluIl0sInBlcm1pc3Npb25zIjpbInJlYWQiLCJ3cml0ZSIsImRlbGV0ZSJdLCJleHAiOjk5OTk5OTk5OTl9."
)
EOF

cat > "$TEST_DIR/auth_jwt_empty_signature.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZG1pbiI6dHJ1ZX0."
)
EOF

cat > "$TEST_DIR/auth_jwt_admin.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJhZG1pbiI6dHJ1ZSwic3ViIjoiMSJ9."
)
EOF

cat > "$TEST_DIR/auth_lowercase_header.et" <<'EOF'
ARGS=(
  -X GET
  -H "authorization: Bearer fake-token-test"
)
EOF

cat > "$TEST_DIR/auth_duplicate_header.et" <<'EOF'
ARGS=(
  -X GET
  -H "Authorization: Bearer fake-token-test"
  -H "Authorization: Bearer"
)
EOF

cat > "$TEST_DIR/auth_x_api_key_fake.et" <<'EOF'
ARGS=(
  -X GET
  -H "X-API-Key: fake-key-test"
)
EOF

cat > "$TEST_DIR/auth_api_key_fake.et" <<'EOF'
ARGS=(
  -X GET
  -H "API-Key: fake-key-test"
)
EOF

cat > "$TEST_DIR/auth_apim_key_fake.et" <<'EOF'
ARGS=(
  -X GET
  -H "Ocp-Apim-Subscription-Key: fake-key-test"
)
EOF

echo "[+] Created templates in: $TEST_DIR"
find "$TEST_DIR" -type f -name "*.et" | sort
