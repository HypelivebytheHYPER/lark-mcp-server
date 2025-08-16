#!/usr/bin/env bash
set -euo pipefail

# Required: APP_ID, APP_SECRET
: "${APP_ID:?APP_ID is required}"

export POQT="${PORT:-8080}"
export LARK_DOMAIN="${LARK_DOMAIN:-https://open.larksuite.com}"
export LARK_MCP_TOOLS="${LARK_MCP_TOOLS:-}"

# Run the Node supervisor that exposes /health and spawns the MCP Server
Ïde server.js
