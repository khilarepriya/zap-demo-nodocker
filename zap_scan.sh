#!/bin/bash
# zap_scan.sh

ZAP_PATH="/opt/zaproxy"  # ✅ Correct path
TARGET="http://localhost:5010"
REPORT="zap_report.html"

echo "⚙️ Starting ZAP scan on $TARGET"

$ZAP_PATH/zap.sh -cmd -port 8091 -quickurl $TARGET -quickout $REPORT -quickprogress -silent

echo "✅ ZAP scan completed"

