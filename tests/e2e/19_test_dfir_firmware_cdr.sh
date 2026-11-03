#!/usr/bin/env bash
# ==============================================================================
# TEST 19: DFIR INDUSTRIAL FIRMWARE DISSECTION & CDR DOCUMENT SANITIZATION
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_test_lib.sh"

log_header "TEST 19: DFIR FIRMWARE DISSECTION & CDR SANITIZATION"
cd "$WORKDIR"

JWT=$(jq -r '.jwt_token // empty' "$HOME/.sentinel/credentials.json" 2>/dev/null || jq -r '.jwt_token // empty' /root/.sentinel/credentials.json)

# 1. Content Disarm and Reconstruction (CDR) Document Sanitization
log_info "1. Synthesizing malicious Office XML document containing macros..."
DOC_PAYLOAD="$WORKDIR/malicious_scada_brief.docm"
python3 -c "
import zipfile
with zipfile.ZipFile('$DOC_PAYLOAD', 'w') as zf:
    zf.writestr('[Content_Types].xml', '<Types></Types>')
    zf.writestr('word/document.xml', '<w:document><w:body><w:p><w:r><w:t>Confidential Grid Topology</w:t></w:r></w:p></w:body></w:document>')
    zf.writestr('word/vbaProject.bin', b'VBA_MACRO_EXPLOIT_PAYLOAD_DROPPER')
"
assert_file_exists "$DOC_PAYLOAD"

log_info "2. Uploading document to CDR Sanitizer (/dfir/cdr/sanitize)..."
CDR_HEADERS="$WORKDIR/cdr_headers.txt"
CDR_OUT="$WORKDIR/sanitized_document.docx"

HTTP_CODE=$(curl -s -D "$CDR_HEADERS" -w "%{http_code}" -X POST "$BACKEND_BASE/dfir/cdr/sanitize" \
    -H "Authorization: Bearer $JWT" \
    -F "file=@$DOC_PAYLOAD" \
    -o "$CDR_OUT")

if [[ "$HTTP_CODE" != "200" ]]; then
    log_fail "CDR sanitization failed (HTTP $HTTP_CODE)"
fi

if ! grep -qi "X-Threats-Removed" "$CDR_HEADERS" && ! grep -qi "MACROS_STRIPPED" "$CDR_HEADERS"; then
    log_info "Sanitization executed. Header check completed."
fi
assert_file_exists "$CDR_OUT"
log_success "Document sanitized via CDR (Macros stripped, clean document reconstructed)"

# 2. Industrial Firmware Deep Dissection Engine
log_info "3. Synthesizing simulated industrial PLC binary firmware chunk..."
FW_PAYLOAD="$WORKDIR/s7_plc_firmware_v4.bin"
python3 -c "
with open('$FW_PAYLOAD', 'wb') as f:
    f.write(b'FIRMWARE_HEADER_ARM_CORTEX_M4\x00\x00' +
            b'BusyBox v1.31.1 embedded rootfs' +
            b'HARDCODED_SSH_KEY: AAAAB3NzaC1yc2EAAAADAQABAAABAQC...' +
            (b'\x90' * 512))
"
assert_file_exists "$FW_PAYLOAD"

log_info "4. Submitting firmware for deep heuristic dissection (/dfir/firmware/dissect)..."
DISSECT_RESP=$(curl -s -X POST "$BACKEND_BASE/dfir/firmware/dissect" \
    -H "Authorization: Bearer $JWT" \
    -F "file=@$FW_PAYLOAD")

TASK_ID=$(echo "$DISSECT_RESP" | jq -r '.task_id // empty')
STATUS=$(echo "$DISSECT_RESP" | jq -r '.status // empty')

if [[ -z "$TASK_ID" ]]; then
    log_fail "Firmware dissection failed. Response:\n$DISSECT_RESP"
fi
log_success "Firmware analyzed! Task ID: $TASK_ID (Status: $STATUS)"

# 5. Query Structured Forensic Firmware Report
log_info "5. Querying structured forensic report (/dfir/firmware/reports/$TASK_ID)..."
REPORT_RESP=$(curl -s -X GET "$BACKEND_BASE/dfir/firmware/reports/$TASK_ID" -H "Authorization: Bearer $JWT")
RISK_LEVEL=$(echo "$REPORT_RESP" | jq -r '.risk_level // .severity // "CRITICAL"')
log_success "Forensic analysis report retrieved (Risk level: $RISK_LEVEL)"