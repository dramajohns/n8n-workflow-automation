# n8n Environment Variables Reference

Complete reference for self-hosted n8n configuration. Use these variables in `.env` file or environment.

## Core Configuration

### Server Settings
- **N8N_PORT** - Port for n8n web interface (default: `5678`)
- **N8N_HOST** - Host for n8n (default: `localhost`, use `0.0.0.0` for external access)
- **N8N_PROTOCOL** - Protocol (default: `http`, use `https` for production)
- **WEBHOOK_URL** - Public URL for webhooks (e.g., `https://your-domain.com`)

### API Configuration
- **N8N_API_URL** - Full URL to n8n instance (e.g., `http://localhost:5678`)
- **N8N_API_KEY** - API key for authentication (generate in n8n Settings → API)

## Database Configuration

### SQLite (Default - Development Only)
```bash
DB_TYPE=sqlite
DB_SQLITE_DATABASE=database.sqlite  # Path to SQLite file
```

### PostgreSQL (Recommended for Production)
```bash
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n_user
DB_POSTGRESDB_PASSWORD=secure_password
DB_POSTGRESDB_SCHEMA=public
```

### MySQL/MariaDB
```bash
DB_TYPE=mysqldb
DB_MYSQLDB_HOST=localhost
DB_MYSQLDB_PORT=3306
DB_MYSQLDB_DATABASE=n8n
DB_MYSQLDB_USER=n8n_user
DB_MYSQLDB_PASSWORD=secure_password
```

## Queue Mode (Production Scaling)

Enables distributed job processing with Redis:

```bash
QUEUE_BULL_REDIS_HOST=localhost
QUEUE_BULL_REDIS_PORT=6379
QUEUE_BULL_REDIS_PASSWORD=
QUEUE_BULL_REDIS_DB=0
QUEUE_BULL_REDIS_TIMEOUT_THRESHOLD=10000
```

**Note**: Requires separate worker processes running `n8n worker`

## Security Configuration

### Basic Authentication
```bash
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=secure_password
```

### JWT Authentication
```bash
N8N_JWT_AUTH_ACTIVE=true
N8N_JWT_AUTH_HEADER=Authorization
N8N_JWT_AUTH_HEADER_VALUE_PREFIX=Bearer
```

### Encryption Key
```bash
N8N_ENCRYPTION_KEY=your_long_random_string_here
```
**Important**: Generate a secure random string and keep it consistent

## Execution Configuration

### Data Retention
```bash
EXECUTIONS_DATA_SAVE_ON_ERROR=all          # all, none
EXECUTIONS_DATA_SAVE_ON_SUCCESS=all        # all, none
EXECUTIONS_DATA_SAVE_ON_PROGRESS=false
EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true
```

### Automatic Pruning
```bash
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=168                # Hours (168 = 1 week)
EXECUTIONS_DATA_PRUNE_MAX_COUNT=10000      # Max executions to keep
```

### Execution Timeout
```bash
EXECUTIONS_TIMEOUT=300                     # Seconds (300 = 5 minutes)
EXECUTIONS_TIMEOUT_MAX=3600                # Max timeout in seconds
```

## Monitoring & Metrics

### Prometheus Metrics
```bash
N8N_METRICS=true
N8N_METRICS_PORT=8081
N8N_METRICS_PREFIX=n8n_
```

Access metrics at: `http://localhost:8081/metrics`

### Logging
```bash
N8N_LOG_LEVEL=info                         # error, warn, info, verbose, debug
N8N_LOG_OUTPUT=console,file
N8N_LOG_FILE_LOCATION=/var/log/n8n/
N8N_LOG_FILE_COUNT_MAX=100
N8N_LOG_FILE_SIZE_MAX=16                   # MB
```

## Timezone Configuration

```bash
GENERIC_TIMEZONE=Europe/Berlin
TZ=Europe/Berlin
```

**Common Timezones**:
- Europe/Berlin
- America/New_York
- America/Los_Angeles
- Asia/Tokyo
- UTC

## Workflow Configuration

### Workflow Execution
```bash
WORKFLOWS_DEFAULT_NAME=My Workflow
N8N_PAYLOAD_SIZE_MAX=16                    # MB
```

### Nodes Configuration
```bash
NODES_EXCLUDE=[n8n-nodes-base.httpRequest]  # JSON array of nodes to exclude
NODES_ERROR_TRIGGER_TYPE=n8n-nodes-base.errorTrigger
```

## External Services

### External Hooks
```bash
EXTERNAL_HOOK_FILES=/path/to/hooks.js
```

### Custom Extensions
```bash
N8N_CUSTOM_EXTENSIONS=/path/to/extensions
```

## Performance Tuning

### Concurrency
```bash
N8N_CONCURRENCY_PRODUCTION_LIMIT=10        # Max concurrent production executions
```

### Memory
```bash
NODE_OPTIONS=--max-old-space-size=4096     # MB (4GB)
```

## Development Settings

### Editor URL
```bash
N8N_EDITOR_BASE_URL=http://localhost:5678
VUE_APP_URL_BASE_API=http://localhost:5678/
```

### Disable Version Check
```bash
N8N_VERSION_NOTIFICATIONS_ENABLED=false
```

### Disable Telemetry
```bash
N8N_DIAGNOSTICS_ENABLED=false
N8N_HIRING_BANNER_ENABLED=false
```

## Environment-Specific Recommendations

### Development (Local)
```bash
DB_TYPE=sqlite
N8N_LOG_LEVEL=debug
EXECUTIONS_DATA_PRUNE=false
N8N_METRICS=false
```

### Production
```bash
DB_TYPE=postgresdb
N8N_LOG_LEVEL=info
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=168
N8N_METRICS=true
QUEUE_BULL_REDIS_HOST=localhost
N8N_ENCRYPTION_KEY=<secure_random_string>
```

## Resource Requirements

### Minimum (Development)
- **CPU**: 2 vCPUs
- **RAM**: 2 GB
- **Storage**: 10 GB

### Recommended (Production)
- **CPU**: 4+ vCPUs
- **RAM**: 4-8 GB
- **Storage**: 50+ GB SSD
- **Database**: Separate PostgreSQL instance
- **Redis**: For queue mode

### High-Scale (Enterprise)
- **CPU**: 8+ vCPUs
- **RAM**: 16+ GB
- **Storage**: 100+ GB NVMe
- **Database**: Managed PostgreSQL (AWS RDS, Azure Database)
- **Redis**: Managed Redis (ElastiCache, Azure Cache)
- **Workers**: Multiple worker instances

## Useful Commands

### Check Current Configuration
```bash
# View all n8n environment variables
env | grep N8N

# Test database connection
n8n user-management:reset
```

### Generate Encryption Key
```bash
# Generate random 32-character string
node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"
```

## References

- [Official n8n Environment Variables](https://docs.n8n.io/hosting/environment-variables/)
- [Self-Hosting Guide](https://docs.n8n.io/hosting/)
- [Performance Tips](https://docs.n8n.io/hosting/scaling/)

---

Last updated: February 2026
