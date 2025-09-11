# Archon VPS Deployment with Tailscale Serve

This guide covers deploying Archon on a VPS with Tailscale Serve for secure HTTPS access without opening any ports to the internet.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Your VPS Server                          │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   Frontend   │  │    API      │  │    MCP      │       │
│  │  :3737       │  │  :8181      │  │  :8051      │       │
│  │   UI         │  │  Server     │  │  Server     │       │
│  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                             │
│  ┌─────────────┐                                           │
│  │  Supabase   │  ← Database + Kong Gateway                 │
│  │  :8000      │                                           │
│  └─────────────┘                                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Tailscale Serve (localhost proxy)
                          │
                 ┌─────────────────┐
                 │   *.ts.net      │ ← HTTPS + Auto-certificates
                 │                 │
                 │  /  → UI        │
                 │  /api → API     │  
                 │  /mcp → MCP     │
                 │  /supabase → DB │
                 └─────────────────┘
```

## 🚀 Quick Start

### 1. VPS Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker and Docker Compose
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh --hostname=archon-vps
```

### 2. Deploy Archon

```bash
# Clone and setup
git clone <your-archon-repo>
cd Archon
cp .env.example .env

# Configure environment variables
nano .env
```

**Required .env variables:**
```bash
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-long-service-role-key
POSTGRES_PASSWORD=your-db-password
POSTGRES_DB=archon
JWT_SECRET=your-jwt-secret
JWT_EXPIRY=3600

# API Keys
OPENAI_API_KEY=your-openai-api-key

# Service Ports (keep defaults unless needed)
ARCHON_SERVER_PORT=8181
ARCHON_MCP_PORT=8051
ARCHON_FRONTEND_PORT=3737
```

### 3. Start Services

```bash
# Start all services
docker compose up --build -d

# Check status
docker compose ps
docker compose logs -f archon-server
```

### 4. Configure Tailscale Serve

```bash
# Run the automated setup script
./tailscale-setup.sh
```

**Manual setup:**
```bash
# Stop any existing serves
sudo tailscale serve stop

# Configure all services
sudo tailscale serve --set-path /=http://localhost:3737        # Main UI
sudo tailscale serve --set-path /api=http://localhost:8181      # API Server  
sudo tailscale serve --set-path /mcp=http://localhost:8051      # MCP Server
sudo tailscale serve --set-path /supabase=http://localhost:8000  # Supabase
```

## 🔗 Access URLs

Once configured, access your services at:

- **Archon Dashboard**: `https://archon-vps.mytailnet.ts.net/`
- **API Documentation**: `https://archon-vps.mytailnet.ts.net/api/docs`
- **MCP Endpoint**: `https://archon-vps.mytailnet.ts.net/mcp`
- **Supabase Studio**: `https://archon-vps.mytailnet.ts.net/supabase`

## 🔧 Client Configuration

### Claude Code MCP Setup

Update `~/.config/claude-code/config.json`:
```json
{
  "mcpServers": {
    "archon": {
      "url": "https://archon-vps.mytailnet.ts.net/mcp"
    }
  }
}
```

### Local Development Environment

For local frontend development that connects to your VPS:

```bash
# .env.local for development
VITE_SUPABASE_URL=https://archon-vps.mytailnet.ts.net/supabase
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_API_URL=https://archon-vps.mytailnet.ts.net/api
```

## 🛠️ Management Commands

### Service Management

```bash
# View all service logs
docker compose logs -f

# Specific service logs
docker compose logs -f archon-server
docker compose logs -f archon-mcp
docker compose logs -f archon-frontend

# Restart services
docker compose restart archon-server

# Update and rebuild
git pull
docker compose up --build -d
```

### Tailscale Management

```bash
# Check Tailscale status
tailscale status

# View current serve configuration
sudo tailscale serve status

# Stop serving (for maintenance)
sudo tailscale serve stop

# Restart serving
./tailscale-setup.sh
```

### Backup and Recovery

```bash
# Backup entire setup
docker compose down
tar -czf archon-backup-$(date +%Y%m%d).tar.gz \
  .env \
  docker-compose.yml \
  volumes/

# Restore
tar -xzf archon-backup-YYYYMMDD.tar.gz
docker compose up --build -d
```

## 🔒 Security Configuration

### Tailscale ACLs

Create restrictive access in Tailscale admin console:

```json
{
  "acls": [
    // Everyone can access the main UI
    {"action": "accept", "src": ["group:team"], "dst": ["tag:archon:443"]},
    
    // Only you can access MCP and API endpoints
    {"action": "accept", "src": ["you@yourdomain.com"], "dst": ["tag:archon:443"], "users": ["api", "mcp"]},
    
    // Team members can access Supabase
    {"action": "accept", "src": ["group:team"], "dst": ["tag:archon:443"], "users": ["supabase"]}
  ],
  "tagOwners": {
    "tag:archon": ["you@yourdomain.com"]
  }
}
```

### VPS Firewall

```bash
# Allow only SSH and Tailscale
sudo ufw allow ssh
sudo ufw allow 41641/udp  # Tailscale UDP
sudo ufw enable

# Block all other incoming ports
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

## 📊 Monitoring

### Health Checks

```bash
# Test all endpoints
curl -I https://archon-vps.mytailnet.ts.net/
curl -I https://archon-vps.mytailnet.ts.net/api/health
curl -I https://archon-vps.mytailnet.ts.net/mcp

# Container health
docker compose ps
```

### Resource Monitoring

```bash
# System resources
htop
df -h
docker stats

# Service-specific logs
docker compose logs --tail=100 archon-server | grep ERROR
```

## 🚨 Troubleshooting

### Common Issues

**Services not starting:**
```bash
# Check container logs
docker compose logs archon-server

# Verify environment variables
docker compose exec archon-server env

# Check database connectivity
docker compose exec archon-server curl -I $SUPABASE_URL
```

**Tailscale Serve not working:**
```bash
# Check Tailscale status
tailscale status

# Restart Tailscale
sudo systemctl restart tailscaled

# Reconfigure serve
sudo tailscale serve stop
./tailscale-setup.sh
```

**MCP Connection Issues:**
```bash
# Test MCP endpoint directly
curl -I https://archon-vps.mytailnet.ts.net/mcp

# Check MCP server logs
docker compose logs -f archon-mcp
```

### Recovery Procedures

**Full Reset:**
```bash
# Stop everything
docker compose down -v
sudo tailscale serve stop

# Clean up Docker
docker system prune -f

# Restart services
docker compose up --build -d
./tailscale-setup.sh
```

**Database Issues:**
```bash
# Access database directly
docker compose exec db psql -U supabase_auth_admin -d archon

# Check table status
\dt
SELECT * FROM sources LIMIT 5;
```

## 🔄 Updates and Maintenance

### Regular Updates

```bash
# Update Archon
git pull
docker compose up --build -d

# Update Tailscale
sudo apt update && sudo apt install -y tailscale

# Update Docker
sudo apt update && sudo apt install -y docker.io docker-compose
```

### Maintenance Mode

```bash
# Stop serving (but keep services running)
sudo tailscale serve stop

# Perform maintenance
docker compose exec db pg_dump archon > backup.sql
# ... maintenance tasks ...

# Restart serving
./tailscale-setup.sh
```

## 📈 Performance Optimization

### Resource Allocation

For production use, consider these docker-compose overrides:

```yaml
# docker-compose.override.yml
services:
  archon-server:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
  
  db:
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
```

### Database Optimization

- Enable connection pooling in Supabase
- Monitor query performance with `pg_stat_statements`
- Regular vacuum and analyze operations

---

This setup provides a secure, production-ready Archon deployment with automatic HTTPS, zero open ports, and easy client integration.