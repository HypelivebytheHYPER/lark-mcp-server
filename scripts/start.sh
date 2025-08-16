#!/usr/bin/env bash
set -euo pipefail

# Required: APP_ID, APP_SECRET
: "${APP_ID:?APP_ID is required}"
: "${APP_SECRET:?APP_SECRET is required}"

export PORT="${PORT:-8080}"
export LARK_DOMAIN="${LARK_DOMAIN:-https://open.larksuite.com}"
export LARK_MCP_TOOLS="${LARK_MCP_TOOLS:-}"

# Run the Node supervisor that exposes /health and spawns the MCP server
node server.js
