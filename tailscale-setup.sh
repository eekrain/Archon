#!/bin/bash

# Tailscale Serve setup script for Archon
# Usage: ./tailscale-setup.sh

set -e

ARCHON_SERVER_PORT=${ARCHON_SERVER_PORT:-8181}
ARCHON_MCP_PORT=${ARCHON_MCP_PORT:-8051}
ARCHON_FRONTEND_PORT=${ARCHON_FRONTEND_PORT:-3737}
SUPABASE_PORT=${SUPABASE_PORT:-8000}

echo "🔧 Setting up Tailscale Serve for Archon..."
echo "Ports:"
echo "  - Frontend: $ARCHON_FRONTEND_PORT"
echo "  - API: $ARCHON_SERVER_PORT" 
echo "  - MCP: $ARCHON_MCP_PORT"
echo "  - Supabase: $SUPABASE_PORT"
echo ""

# Stop existing serves
echo "🛑 Stopping existing serves..."
sudo tailscale serve stop 2>/dev/null || true
sudo tailscale serve https stop 2>/dev/null || true

# Configure serve paths
echo "⚙️  Configuring service paths..."
sudo tailscale serve --set-path /api=http://localhost:$ARCHON_SERVER_PORT
sudo tailscale serve --set-path /mcp=http://localhost:$ARCHON_MCP_PORT  
sudo tailscale serve --set-path /supabase=http://localhost:$SUPABASE_PORT
sudo tailscale serve --set-path /=http://localhost:$ARCHON_FRONTEND_PORT

echo ""
echo "✅ Tailscale Serve configured!"
echo ""
echo "🌐 Access your services:"
echo "  - Archon UI: https://$(hostname).$(tailscale status --json | jq -r '.Self.DNSName | split(".")[1]')/"
echo "  - API: https://$(hostname).$(tailscale status --json | jq -r '.Self.DNSName | split(".")[1]')/api"
echo "  - MCP: https://$(hostname).$(tailscale status --json | jq -r '.Self.DNSName | split(".")[1]')/mcp"
echo "  - Supabase: https://$(hostname).$(tailscale status --json | jq -r '.Self.DNSName | split(".")[1]')/supabase"
echo ""
echo "🔧 MCP Configuration for Claude Code:"
echo "  {"
echo "    \"mcpServers\": {"
echo "      \"archon\": {"
echo "        \"url\": \"https://$(hostname).$(tailscale status --json | jq -r '.Self.DNSName | split(".")[1]')/mcp\""
echo "      }"
echo "    }"
echo "  }"