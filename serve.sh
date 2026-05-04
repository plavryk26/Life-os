#!/bin/bash

# Cyborg OS — Local Network Server
# Run this script, then open http://<YOUR_MAC_IP>:8080 on your iPhone

PORT=8080

# Get local IP
IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "unknown")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🤖 CYBORG OS — Local Server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Open on iPhone Safari:"
echo "  ➜ http://$IP:$PORT"
echo ""
echo "  (Make sure Mac & iPhone are on"
echo "   the same Wi-Fi network)"
echo ""
echo "  Press Ctrl+C to stop the server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")"

# Try Ruby first (built into macOS)
if command -v ruby &>/dev/null; then
  ruby -run -e httpd . -p $PORT
# Fallback: Python3
elif /usr/bin/python3 -c "" 2>/dev/null; then
  /usr/bin/python3 -m http.server $PORT
else
  echo "ERROR: No server runtime found (Ruby/Python3 unavailable)"
  exit 1
fi
