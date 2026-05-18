#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# HTTP Endpoint Tester
# --------------------------------------------------
#
# Usage:
#   ./endpoint-test.sh <url>
#   ./endpoint-test.sh <url> -o output_dir
#   ./endpoint-test.sh <url> -H "Header: value"
#
# Example:
#   export KEY="xxxx"
#
#   ./endpoint-test.sh https://api.example.com/upload \
#       -H "Ocp-Apim-Subscription-Key: $KEY" \
#       -H "Authorization: Bearer token" \
#       -o tests/upload-test
#
# --------------------------------------------------

URL="${1:-}"
RUN_AUTH=false

if [[ -z "$URL" ]]; then
    echo "Usage: $0 <url> [-o output_dir] [-H 'Header: value']"
    exit 1
fi

shift || true

SAFE_NAME=$(echo "$URL" | sed 's|https\?://||; s|[^a-zA-Z0-9]|_|g')
OUTDIR="endpoint-test-${SAFE_NAME}-$(date +%F_%H%M%S)"
CUSTOM_HEADERS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTDIR="$2"
            shift 2
            ;;
        -H|--header)
            CUSTOM_HEADERS+=("-H" "$2")
            shift 2
            ;;
	--auth)
	    RUN_AUTH=true
	    shift
	    ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

mkdir -p "$OUTDIR"

SUMMARY="$OUTDIR/summary.txt"
: > "$SUMMARY"

METHODS=(
    GET
    POST
    OPTIONS
    HEAD
    PUT
    PATCH
    DELETE
)

HEADER_REGEX="^(HTTP/|allow:|content-type:|content-length:|server:|x-powered-by:|location:|set-cookie:|strict-transport-security:|content-security-policy:|x-frame-options:|x-content-type-options:|referrer-policy:|access-control-allow-origin:|access-control-allow-credentials:|access-control-allow-methods:)"

run_test() {
    local NAME="$1"
    shift

    local FILE="$OUTDIR/${NAME}.txt"

    curl -sk -i \
        --max-time 20 \
        "${CUSTOM_HEADERS[@]}" \
        "$@" \
        "$URL" \
        -o "$FILE" || true

    # Ensure raw response file ends with newline
    if [[ -s "$FILE" ]]; then
	tail -c 1 "$FILE" | read -r _ || echo >> "$FILE"
    fi

    local STATUS
    STATUS=$(grep -m1 "^HTTP/" "$FILE" || true)

    local SIZE
    SIZE=$(wc -c < "$FILE" 2>/dev/null || echo "0")

    {
        echo "=================================================="
        echo "TEST   : $NAME"
        echo "URL    : $URL"
        echo "FILE   : $FILE"
        echo

        echo "[Request]"
        printf 'curl -sk -i --max-time 20 '

        for ARG in "${CUSTOM_HEADERS[@]}"; do
            printf '%q ' "$ARG"
        done

        for ARG in "$@"; do
            printf '%q ' "$ARG"
        done

        printf '%q\n' "$URL"
        echo

        echo "[Info]"
        echo "Status : ${STATUS:-N/A}"
        echo "Size   : $SIZE bytes"
        echo

        echo "[Headers]"
        grep -Ei "$HEADER_REGEX" "$FILE" || true
        echo

	BODY=$(awk '
    BEGIN { body=0 }
    body { print }
    /^\r?$/ { body=1 }
' "$FILE")

	if [[ -n "$BODY" ]]; then
	    echo "[Body]"
	    printf '%s' "$BODY" | head -c 1200
	    printf '\n\n'
	fi
	
    } >> "$SUMMARY"
}

echo "[*] Target : $URL"
echo "[*] Output : $OUTDIR"
echo

for METHOD in "${METHODS[@]}"; do
    echo "[*] Testing method: $METHOD"

    run_test "method-${METHOD}" \
        -X "$METHOD"
done

echo "[*] Testing CORS"

run_test "cors-origin" \
    -X OPTIONS \
    -H "Origin: https://evil.example" \
    -H "Access-Control-Request-Method: POST"

echo "[*] Testing Authorization"

run_test "auth-empty-bearer" \
    -H "Authorization: Bearer"

run_test "auth-fake-bearer" \
    -H "Authorization: Bearer fake-token-test"

echo "[*] Testing JSON handling"

run_test "json-valid" \
    -X POST \
    -H "Content-Type: application/json" \
    --data '{"test":"endpoint-test"}'

run_test "json-invalid" \
    -X POST \
    -H "Content-Type: application/json" \
    --data '{"test":'

echo "[*] Testing form handling"

run_test "form-basic" \
    -X POST \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data 'name=test&value=endpoint-test'

echo "[*] Testing filename/path validation"

run_test "path-validation" \
    -X POST \
    -H "Content-Type: application/json" \
    --data '{"filename":"../../test.txt","name":"test.php.jpg"}'

if [[ "$RUN_AUTH" == true ]]; then
    echo "[*] Testing authentication misconfig patterns"

    # --------------------------------------------------
    # JWT Test Samples
    # --------------------------------------------------

    # alg:none unsigned JWT
    JWT_ALG_NONE='eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiIxMjMiLCJhZG1pbiI6dHJ1ZSwiZXhwIjo5OTk5OTk5OTk5fQ.'

    # malformed structure
    JWT_MALFORMED='aaa.bbb.ccc'

    # expired JWT
    JWT_EXPIRED='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjMiLCJleHAiOjEwfQ.invalidsig'

    # wrong issuer
    JWT_WRONG_ISS='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJldmlsLmV4YW1wbGUiLCJzdWIiOiIxMjMiLCJhZG1pbiI6dHJ1ZX0.invalidsig'

    # wrong audience
    JWT_WRONG_AUD='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJldmlsLWFwcCIsInN1YiI6IjEyMyIsImFkbWluIjp0cnVlfQ.invalidsig'

    # huge claims JWT
    JWT_LARGE='eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJhZG1pbiI6dHJ1ZSwicm9sZXMiOlsiYWRtaW4iLCJzdXBlcmFkbWluIl0sInBlcm1pc3Npb25zIjpbInJlYWQiLCJ3cml0ZSIsImRlbGV0ZSJdLCJleHAiOjk5OTk5OTk5OTl9.'

    # lowercase alg
    JWT_LOWERCASE_ALG='eyJhbGciOiJub25lIiwidHlwIjoiand0In0.eyJhZG1pbiI6dHJ1ZX0.'

    # empty signature HS256
    JWT_EMPTY_SIG='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZG1pbiI6dHJ1ZX0.'

    # admin=true unsigned
    JWT_ADMIN='eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJhZG1pbiI6dHJ1ZSwic3ViIjoiMSJ9.'

    run_test "auth-no-auth" \
             -X GET

    run_test "auth-empty-header" \
             -X GET \
             -H "Authorization:"

    run_test "auth-bearer-empty" \
             -X GET \
             -H "Authorization: Bearer"

    run_test "auth-bearer-fake" \
             -X GET \
             -H "Authorization: Bearer fake-token-test"

    run_test "auth-basic-fake" \
             -X GET \
             -H "Authorization: Basic dGVzdDp0ZXN0"

    run_test "auth-null" \
             -X GET \
             -H "Authorization: null"

    run_test "auth-undefined" \
             -X GET \
             -H "Authorization: undefined"

    run_test "auth-malformed-jwt" \
             -X GET \
             -H "Authorization: Bearer aaa.bbb.ccc"

    run_test "auth-jwt-malformed" \
	     -X GET \
	     -H "Authorization: Bearer $JWT_MALFORMED"

    run_test "auth-jwt-alg-none" \
	     -X GET \
	     -H "Authorization: Bearer $JWT_ALG_NONE"

    run_test "auth-jwt-expired" \
	     -X GET \
	     -H "Authorization: Bearer $JWT_EXPIRED"

    run_test "auth-jwt-wrong-iss" \
	     -X GET \
	     -H "Authorization: Bearer $JWT_WRONG_ISS"

    run_test "auth-jwt-wrong-aud" \
	     -X GET \
	     -H "Authorization: Bearer $JWT_WRONG_AUD"

    run_test "auth-jwt-large" \
	     -X GET \
	     -H "Authorization: Bearer $JWT_LARGE"

    run_test "auth-jwt-empty-signature" \
	     -X GET \
	     -H "Authorization: Bearer $JWT_EMPTY_SIG"

    run_test "auth-jwt-admin" \
	     -X GET \
	     -H "Authorization: Bearer $JWT_ADMIN"

    run_test "auth-lowercase-header" \
             -X GET \
             -H "authorization: Bearer fake-token-test"

    run_test "auth-duplicate-header" \
             -X GET \
             -H "Authorization: Bearer fake-token-test" \
             -H "Authorization: Bearer"

    run_test "auth-x-api-key-fake" \
             -X GET \
             -H "X-API-Key: fake-key-test"

    run_test "auth-api-key-fake" \
             -X GET \
             -H "API-Key: fake-key-test"

    run_test "auth-apim-key-fake" \
             -X GET \
             -H "Ocp-Apim-Subscription-Key: fake-key-test"
fi

echo
echo "[+] Done"
echo "[+] Summary : $SUMMARY"
echo
echo "[+] Interesting things to look for:"
echo "    - PUT/DELETE/PATCH returning 200/201/204"
echo "    - Access-Control-Allow-Origin: *"
echo "    - Access-Control-Allow-Credentials: true"
echo "    - Missing Secure/HttpOnly/SameSite cookies"
echo "    - Framework/version disclosure"
echo "    - Stack traces or verbose errors"
echo "    - Different behavior with fake auth"
echo "    - Dangerous methods in Allow header"

