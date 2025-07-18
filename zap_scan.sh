#!/bin/bash

ZAP_PATH="/opt/zaproxy"
TARGET="http://localhost:5010"
REPORT="zap_report.html"
ZAP_PORT="8091"

echo "⚙️ Starting ZAP scan on $TARGET using port $ZAP_PORT"

# Ensure zap.sh exists
if [[ ! -x "$ZAP_PATH/zap.sh" ]]; then
  echo "❌ ZAP not found or not executable at $ZAP_PATH"
  exit 1
fi

# Run ZAP scan
"$ZAP_PATH/zap.sh" -cmd -port "$ZAP_PORT" \
  -quickurl "$TARGET" \
  -quickout "$PWD/$REPORT" \
  -quickprogress -silent

ZAP_EXIT=$?
echo "🔚 ZAP exited with code: $ZAP_EXIT"

# Check if ZAP ran successfully
if [[ $ZAP_EXIT -ne 0 ]]; then
  echo "❌ ZAP scan failed"
  exit 1
fi

# Check if report file exists and is not empty
if [[ ! -f $REPORT ]]; then
  echo "⚠️ Report not created"
  exit 1
fi

if [[ ! -s $REPORT ]]; then
  echo "⚠️ Report is empty"
  exit 1
fi

echo "✅ ZAP scan completed. Report saved to $REPORT"

