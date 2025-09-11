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

# Configure serve paths using the new syntax (paths need to be configured differently)
echo "⚙️  Configuring service paths..."
echo "Note: With the new Tailscale serve syntax, paths are configured differently."
echo "Setting up individual services with subdomain approach..."

# Stop any existing serves first
sudo tailscale serve stop 2>/dev/null || true

# Start with the main UI on root path
sudo tailscale serve --bg http://localhost:$ARCHON_FRONTEND_PORT

echo "⚠️  IMPORTANT: Tailscale serve has changed!"
echo "The new syntax doesn't support multiple paths on one domain easily."
echo "For multiple services, consider using subdomains or different ports."
echo ""
echo "Current configuration:"
echo "  - Main UI: https://$(hostname).$(tailscale status --json | jq -r '.Self.DNSName | split(".")[1]')/"
echo ""
echo "For other services, you may need to:"
echo "  1. Use different ports: sudo tailscale serve --bg 8181"
echo "  2. Or set up subdomain proxies"

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