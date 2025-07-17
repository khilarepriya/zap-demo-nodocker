#!/bin/bash

ZAP_PATH="/opt/zaproxy"
TARGET="http://localhost:5010"
REPORT="zap_report.html"

echo "⚙️ Starting ZAP scan on $TARGET"

$ZAP_PATH/zap.sh -cmd -quickurl $TARGET -quickout $REPORT -quickprogress -silent

ZAP_EXIT=$?
echo "✅ ZAP scan exited with code: $ZAP_EXIT"

if [[ $ZAP_EXIT -ne 0 ]]; then
  echo "❌ ZAP scan failed to run"
  exit 1
fi

if [[ ! -f $REPORT ]]; then
  echo "⚠️ Report not found"
  exit 1
fi

if [[ ! -s $REPORT ]]; then
  echo "⚠️ Report is empty"
  exit 1
fi

echo "✅ ZAP scan completed. Report is available at $REPORT"

