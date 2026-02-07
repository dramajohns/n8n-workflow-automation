# Self-Hosted n8n Architecture Guide

Comprehensive guide for self-hosted n8n setup, from development to production.

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│                  n8n Instance                │
│  ┌────────────┐  ┌──────────────┐          │
│  │  Web UI    │  │  Webhook     │          │
│  │  (Port     │  │  Endpoints   │          │
│  │   5678)    │  │              │          │
│  └────────────┘  └──────────────┘          │
│         │                │                   │
│         ├────────────────┤                   │
│         ▼                ▼                   │
│  ┌──────────────────────────────┐          │
│  │     n8n Core Engine          │          │
│  │   (Workflow Execution)       │          │
│  └──────────────────────────────┘          │
│         │                │                   │
│         ▼                ▼                   │
│  ┌────────────┐  ┌──────────────┐          │
│  │  Database  │  │  Queue       │          │
│  │  (SQLite/  │  │  (Redis -    │          │
│  │  Postgres) │  │  Optional)   │          │
│  └────────────┘  └──────────────┘          │
└─────────────────────────────────────────────┘
```

## Development Setup (Local Machine)

### Prerequisites
- **OS**: Windows 10/11, macOS, or Linux
- **Node.js**: v18.x or v20.x (LTS recommended)
- **RAM**: 2 GB minimum
- **Storage**: 10 GB

### Installation Methods

#### Method 1: NPM (Recommended for Development)

```bash
# Install globally
npm install -g n8n

# Run
n8n start

# Access at http://localhost:5678
```

#### Method 2: Docker (Recommended for Consistency)

```bash
# Pull image
docker pull n8nio/n8n

# Run with SQLite
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# Access at http://localhost:5678
```

#### Method 3: Docker Compose (Best for Development)

Create `docker-compose.yml`:

```yaml
version: "3.8"

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n-dev
    ports:
      - "5678:5678"
    environment:
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=development
      - GENERIC_TIMEZONE=Europe/Berlin
      - TZ=Europe/Berlin
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

Run:
```bash
docker-compose up -d
```

### Development Configuration

Create `.env` file:

```bash
# Basic
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_HOST=localhost

# Database (SQLite for dev)
DB_TYPE=sqlite
DB_SQLITE_DATABASE=database.sqlite

# Timezone
GENERIC_TIMEZONE=Europe/Berlin
TZ=Europe/Berlin

# Development
NODE_ENV=development
N8N_LOG_LEVEL=debug
EXECUTIONS_DATA_SAVE_ON_ERROR=all
EXECUTIONS_DATA_SAVE_ON_SUCCESS=all

# Disable telemetry (optional)
N8N_DIAGNOSTICS_ENABLED=false
```

## Production Setup

### Minimum Requirements

- **CPU**: 2 vCPUs (4+ recommended)
- **RAM**: 2 GB (4-8 GB recommended)
- **Storage**: 50 GB SSD
- **Database**: PostgreSQL (required for production)
- **Reverse Proxy**: Nginx or Caddy (for HTTPS)
- **Monitoring**: Prometheus + Grafana

### Recommended Requirements (High Availability)

- **CPU**: 8+ vCPUs
- **RAM**: 16+ GB
- **Storage**: 100+ GB NVMe SSD
- **Database**: Managed PostgreSQL (AWS RDS, Azure Database)
- **Cache**: Redis (for queue mode)
- **Workers**: Multiple worker instances
- **Load Balancer**: For distributing traffic

### Production Architecture

```
Internet
   │
   ▼
┌──────────────┐
│ Load Balancer│
│ (Optional)   │
└──────┬───────┘
       │
   ┌───┴────┐
   ▼        ▼
┌─────┐  ┌─────┐
│ n8n │  │ n8n │  (Web instances)
│ Web │  │ Web │
└──┬──┘  └──┬──┘
   │        │
   └────┬───┘
        │
   ┌────▼────┐
   │  Redis  │  (Queue)
   └────┬────┘
        │
   ┌────┴─────┐
   ▼          ▼
┌──────┐  ┌──────┐
│ n8n  │  │ n8n  │  (Worker instances)
│Worker│  │Worker│
└──┬───┘  └──┬───┘
   │         │
   └────┬────┘
        │
   ┌────▼──────┐
   │ PostgreSQL│  (Database)
   └───────────┘
```

### PostgreSQL Setup

#### Install PostgreSQL

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

**Windows**:
Download from https://www.postgresql.org/download/windows/

#### Create Database and User

```sql
-- Connect to PostgreSQL
psql -U postgres

-- Create database
CREATE DATABASE n8n;

-- Create user
CREATE USER n8n_user WITH PASSWORD 'secure_password_here';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n_user;

-- Exit
\q
```

### Production Docker Compose

Create `docker-compose.production.yml`:

```yaml
version: "3.8"

services:
  postgres:
    image: postgres:15
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n_user
      - POSTGRES_PASSWORD=secure_password_here
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n_user -d n8n"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: n8n-redis
    restart: unless-stopped
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  n8n-web:
    image: n8nio/n8n:latest
    container_name: n8n-web
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=secure_password_here
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - N8N_HOST=your-domain.com
      - WEBHOOK_URL=https://your-domain.com
      - NODE_ENV=production
      - EXECUTIONS_MODE=queue
      - QUEUE_BULL_REDIS_HOST=redis
      - QUEUE_BULL_REDIS_PORT=6379
      - N8N_ENCRYPTION_KEY=your_long_random_string_here
      - GENERIC_TIMEZONE=Europe/Berlin
      - TZ=Europe/Berlin
      - N8N_LOG_LEVEL=info
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=168
      - N8N_METRICS=true
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3

  n8n-worker:
    image: n8nio/n8n:latest
    container_name: n8n-worker
    restart: unless-stopped
    command: worker
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=secure_password_here
      - EXECUTIONS_MODE=queue
      - QUEUE_BULL_REDIS_HOST=redis
      - QUEUE_BULL_REDIS_PORT=6379
      - N8N_ENCRYPTION_KEY=your_long_random_string_here
      - GENERIC_TIMEZONE=Europe/Berlin
      - TZ=Europe/Berlin
      - N8N_LOG_LEVEL=info
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

volumes:
  postgres_data:
  redis_data:
  n8n_data:
```

Deploy:
```bash
docker-compose -f docker-compose.production.yml up -d
```

### Nginx Reverse Proxy (HTTPS)

Install Nginx and Certbot:
```bash
sudo apt install nginx certbot python3-certbot-nginx
```

Create Nginx config (`/etc/nginx/sites-available/n8n`):

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support
        proxy_read_timeout 86400;
    }
}
```

Enable site and get SSL:
```bash
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo certbot --nginx -d your-domain.com
sudo nginx -t
sudo systemctl reload nginx
```

## Security Best Practices

### Authentication

Enable basic authentication:
```bash
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=secure_password_here
```

### Encryption

Generate encryption key:
```bash
node -e "console.log(require('crypto').randomBytes(24).toString('hex'))"
```

Add to environment:
```bash
N8N_ENCRYPTION_KEY=your_generated_key_here
```

**Important**: Keep this key consistent. Changing it makes encrypted data unreadable.

### Network Security

- Use firewall (UFW, iptables)
- Allow only necessary ports (80, 443, 22)
- Use VPN for database access
- Implement rate limiting
- Use strong passwords

### API Security

- Rotate API keys regularly
- Use separate keys for different purposes
- Monitor API usage
- Implement IP whitelisting (if possible)

## Monitoring & Maintenance

### Enable Metrics

```bash
N8N_METRICS=true
N8N_METRICS_PORT=8081
```

Access Prometheus metrics at: `http://localhost:8081/metrics`

### Prometheus Configuration

`prometheus.yml`:
```yaml
scrape_configs:
  - job_name: 'n8n'
    static_configs:
      - targets: ['localhost:8081']
```

### Backup Strategy

#### Database Backups

**PostgreSQL**:
```bash
# Daily backup script
pg_dump -U n8n_user -d n8n > /backups/n8n_$(date +%Y%m%d).sql

# Restore
psql -U n8n_user -d n8n < /backups/n8n_20260207.sql
```

#### Workflow Backups

Use project scripts:
```powershell
# Automated daily backups
.\scripts\backup-workflows.ps1

# Schedule in Task Scheduler (Windows)
# Or cron (Linux):
0 2 * * * /path/to/scripts/backup-workflows.ps1
```

### Log Management

**View logs**:
```bash
# Docker
docker logs n8n-web -f

# NPM install
journalctl -u n8n -f
```

**Configure log rotation** (`/etc/logrotate.d/n8n`):
```
/var/log/n8n/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 n8n n8n
}
```

## Scaling Strategies

### Vertical Scaling (Single Server)

Increase resources:
- More CPU cores
- More RAM
- Faster storage (SSD → NVMe)
- Optimize database queries
- Enable caching

### Horizontal Scaling (Multiple Servers)

**Queue Mode** (recommended):
1. Multiple web instances (UI + webhooks)
2. Multiple worker instances (execution)
3. Redis for job queue
4. Load balancer for distribution

**Benefits**:
- Better resource utilization
- Higher availability
- Easier maintenance (rolling updates)

## Troubleshooting

### Common Issues

#### High Memory Usage
- Enable execution data pruning
- Limit concurrent executions
- Increase worker memory limit

#### Slow Execution
- Check database performance
- Optimize workflows (batch operations)
- Add more workers
- Upgrade hardware

#### Database Connection Errors
- Check PostgreSQL is running
- Verify credentials
- Check connection limits
- Review firewall rules

#### Webhook Timeouts
- Increase timeout limits
- Use async webhooks
- Optimize workflow execution time

## Resources

- **Official Docs**: https://docs.n8n.io/hosting/
- **Community Forum**: https://community.n8n.io/
- **Docker Hub**: https://hub.docker.com/r/n8nio/n8n
- **GitHub**: https://github.com/n8n-io/n8n

---

Last updated: February 2026
