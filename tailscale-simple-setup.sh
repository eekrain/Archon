#!/bin/bash

# Simplified Tailscale Serve setup for new CLI syntax
# Usage: ./tailscale-simple-setup.sh

set -e

echo "🔧 Setting up Tailscale Serve for Archon (New CLI Syntax)..."
echo ""

# Stop existing serves
echo "🛑 Stopping existing serves..."
sudo tailscale serve stop 2>/dev/null || true

# Main UI on the default domain
echo "🌐 Setting up main UI..."
sudo tailscale serve --bg http://localhost:3737

echo ""
echo "✅ Main UI configured!"
echo ""
echo "🌐 Access your main UI:"
echo "  - Archon UI: https://$(hostname).$(tailscale status --json | jq -r '.Self.DNSName | split(".")[1]')/"
echo ""
echo "⚠️  NOTE: The new Tailscale CLI syntax has limitations for multiple paths."
echo "For other services (API, MCP, Supabase), you have a few options:"
echo ""
echo "1️⃣  Use Funnel for public access (not recommended for all services):"
echo "   sudo tailscale funnel --bg 8181"
echo ""
echo "2️⃣  Set up separate serve instances on different machines/ports"
echo ""
echo "3️⃣  Use a reverse proxy (Nginx/Caddy) internally first"
echo ""
echo "4️⃣  Access services via SSH tunneling:"
echo "   ssh -L 8181:localhost:8181 user@your-vps"
echo ""
echo "For now, the main UI is accessible via Tailscale HTTPS!"
echo "Other services remain available on localhost ports for internal use."