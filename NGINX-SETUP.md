# Nginx + Tailscale Setup Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Your VPS Server                          │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   Frontend   │  │    API      │  │    MCP      │       │
│  │  :3737       │  │  :8181      │  │  :8051      │       │
│  └─────────────┘  └─────────────┘  └─────────────┘       │
│           │                 │                 │           │
│           └─────────────────┼─────────────────┘           │
│                             │                             │
│                    ┌─────────────┐                       │
│                    │   Nginx     │  ← Reverse Proxy       │
│                    │   :8080      │                       │
│                    └─────────────┘                       │
│                             │                             │
│                    ┌─────────────┐                       │
│                    │  Tailscale   │  ← HTTPS Proxy         │
│                    │   Serve      │                       │
│                    └─────────────┘                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS via *.ts.net
                          │
                 ┌─────────────────┐
                 │  https://...   │
                 │     /          │ → Frontend
                 │     /api       │ → API
                 │     /mcp       │ → MCP  
                 │     /supabase  │ → Supabase
                 └─────────────────┘
```

## Setup Instructions

### 1. Restart Docker Services

```bash
# Stop current services
docker compose down

# Start with new Nginx proxy
docker compose up --build -d

# Check all services are running
docker compose ps
```

### 2. Configure Tailscale Serve

```bash
# Run the updated setup script
./tailscale-setup.sh
```

### 3. Test the Setup

```bash
# Test Nginx proxy locally
curl -I http://localhost:8080/
curl -I http://localhost:8080/api/health
curl -I http://localhost:8080/health

# Test via Tailscale
curl -I https://archon-docker.tail56561c.ts.net/
curl -I https://archon-docker.tail56561c.ts.net/api/health
```

## Service URLs

Once configured, all services are available via:

- **Archon UI**: `https://archon-docker.tail56561c.ts.net/`
- **API Docs**: `https://archon-docker.tail56561c.ts.net/api/docs`
- **MCP Endpoint**: `https://archon-docker.tail56561c.ts.net/mcp`
- **Supabase Studio**: `https://archon-docker.tail56561c.ts.net/supabase`

## Claude Code Configuration

```json
{
  "mcpServers": {
    "archon": {
      "url": "https://archon-docker.tail56561c.ts.net/mcp"
    }
  }
}
```

## Troubleshooting

### Services Not Starting

```bash
# Check Nginx logs
docker compose logs nginx-proxy

# Check if services are reachable from Nginx
docker compose exec nginx-proxy curl archon-frontend:3737
docker compose exec nginx-proxy curl archon-server:8181/health
docker compose exec nginx-proxy curl archon-mcp:8051
```

### Tailscale Issues

```bash
# Reset Tailscale serve
sudo tailscale serve stop
./tailscale-setup.sh

# Check Tailscale status
tailscale status
```

### Path Routing Issues

```bash
# Test individual routes
curl http://localhost:8080/api/health
curl http://localhost:8080/mcp
curl http://localhost:8080/supabase/rest/v1/
```

## Benefits

✅ **Single HTTPS endpoint** - All services under one domain
✅ **Proper path routing** - Nginx handles all routing internally  
✅ **Zero open ports** - Only localhost:8080 exposed to Tailscale
✅ **WebSocket/SSE support** - Proper proxy configuration for real-time features
✅ **Easy maintenance** - Single point of configuration