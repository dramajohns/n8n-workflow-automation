# MCP Server Configuration for Windows

This guide walks you through configuring the n8n-mcp MCP server on Windows to enable Claude Code to interact with your self-hosted n8n instance.

## Prerequisites

Before you begin:
- ✅ Node.js 18+ installed (for NPX method) OR Docker Desktop (for Docker method)
- ✅ Self-hosted n8n instance running and accessible
- ✅ Claude Desktop installed on your system
- ✅ n8n API key (obtain from n8n Settings → API)

## Step 1: Obtain n8n API Key

1. Open your n8n instance in a browser (e.g., `http://localhost:5678`)
2. Navigate to **Settings** → **API**
3. Click **Create API Key**
4. Give it a name (e.g., "Claude MCP Server")
5. **Copy the API key** - you'll need it in Step 3

**Important**: Store this API key securely - you won't be able to see it again.

## Step 2: Locate Claude Desktop Configuration File

The Claude Desktop configuration file is located at:

```
%APPDATA%\Claude\claude_desktop_config.json
```

**Full path** (replace `YourUsername` with your Windows username):
```
C:\Users\YourUsername\AppData\Roaming\Claude\claude_desktop_config.json
```

### How to Access

**Method 1: Using Windows Explorer**
1. Press `Win + R` to open Run dialog
2. Type: `%APPDATA%\Claude`
3. Press Enter
4. Look for `claude_desktop_config.json`

**Method 2: Using Command**
1. Open Command Prompt or PowerShell
2. Run: `notepad "%APPDATA%\Claude\claude_desktop_config.json"`

## Step 3: Configure n8n-mcp Server

### Installation Method 1: NPX (Recommended for Learning)

This method uses NPX to run n8n-mcp without manual installation. Simplest setup for getting started.

**Edit `claude_desktop_config.json`** and add:

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "http://localhost:5678",
        "N8N_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

**Replace placeholders**:
- `your-api-key-here` → Your actual n8n API key from Step 1
- `http://localhost:5678` → Your n8n instance URL (if different)

### Installation Method 2: Docker

This method uses Docker to run n8n-mcp in a container. More reproducible and isolated.

**Prerequisites**:
- Docker Desktop installed and running

**Edit `claude_desktop_config.json`** and add:

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm", "--init",
        "-e", "MCP_MODE=stdio",
        "-e", "LOG_LEVEL=error",
        "-e", "DISABLE_CONSOLE_OUTPUT=true",
        "-e", "N8N_API_URL=http://host.docker.internal:5678",
        "-e", "N8N_API_KEY=your-api-key-here",
        "ghcr.io/czlonkowski/n8n-mcp:latest"
      ]
    }
  }
}
```

**Replace placeholders**:
- `your-api-key-here` → Your actual n8n API key
- **Note**: Use `host.docker.internal` instead of `localhost` when running in Docker to access host machine

## Step 4: Understand Environment Variables

### Required Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `MCP_MODE` | `stdio` | Required for Claude Desktop communication |
| `N8N_API_URL` | Your n8n URL | Connection to your n8n instance |
| `N8N_API_KEY` | Your API key | Authentication for n8n API |

### Optional Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `LOG_LEVEL` | `error` | Suppress debug output (cleaner console) |
| `DISABLE_CONSOLE_OUTPUT` | `true` | Prevent protocol interference |
| `N8N_MCP_TELEMETRY_DISABLED` | `true` | Disable anonymous telemetry |

## Step 5: Save and Restart Claude Desktop

1. **Save** the `claude_desktop_config.json` file
2. **Completely quit** Claude Desktop:
   - Right-click Claude Desktop in system tray
   - Select "Quit" or "Exit"
   - Or use Task Manager to ensure it's fully closed
3. **Restart** Claude Desktop

**Important**: Claude Desktop must be fully restarted (not just minimized) for changes to take effect.

## Step 6: Verify Installation

After restarting Claude Desktop, test the MCP connection:

### Test 1: List Available Tools
In Claude Desktop, type:
```
List all available n8n MCP tools
```

You should see a response listing tools like:
- `n8n_list_workflows`
- `n8n_create_workflow`
- `n8n_get_workflow`
- `search_nodes`
- `get_template`
- etc.

### Test 2: List Workflows
```
List all n8n workflows
```

You should see your existing n8n workflows listed, or an empty list if you have none.

### Test 3: Search Nodes
```
Search for HTTP Request node in n8n
```

You should get information about the HTTP Request node.

## Troubleshooting

### Issue: "MCP tools not available"

**Possible causes**:
1. Claude Desktop not fully restarted
2. JSON syntax error in config file
3. n8n instance not running
4. Incorrect API key

**Solutions**:
1. Fully quit and restart Claude Desktop
2. Validate JSON syntax using [jsonlint.com](https://jsonlint.com)
3. Verify n8n is running: open `http://localhost:5678` in browser
4. Generate a new API key and update config

### Issue: "Connection refused" or "Cannot connect to n8n"

**Possible causes**:
1. n8n instance not running
2. Wrong URL in `N8N_API_URL`
3. Firewall blocking connection

**Solutions**:
1. Start your n8n instance
2. Verify URL is correct (check port number)
3. Check Windows Firewall settings

### Issue: "Unauthorized" or "Invalid API key"

**Possible causes**:
1. API key incorrect or expired
2. API key has wrong permissions

**Solutions**:
1. Generate a new API key in n8n Settings → API
2. Copy the entire key (no spaces or line breaks)
3. Update config and restart Claude Desktop

### Issue: NPX hanging or slow

**Possible causes**:
1. First run downloads n8n-mcp package
2. Network issues

**Solutions**:
1. Wait for initial download to complete (1-2 minutes)
2. Pre-install: `npm install -g n8n-mcp`
3. Switch to Docker method if persistent

### Issue: Docker "image not found"

**Possible causes**:
1. Docker Desktop not running
2. Image not pulled

**Solutions**:
1. Start Docker Desktop and wait for it to fully initialize
2. Pull image manually: `docker pull ghcr.io/czlonkowski/n8n-mcp:latest`

## Advanced Configuration

### Using Environment File

For easier management, create a `.env` file (already templated in `config/.env.example`):

```bash
N8N_API_URL=http://localhost:5678
N8N_API_KEY=your_api_key_here
```

Then reference in PowerShell scripts or Docker Compose files.

### Production Configuration

For production self-hosted n8n, add:

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "https://your-domain.com",
        "N8N_API_KEY": "your-api-key-here",
        "WEBHOOK_SECURITY_MODE": "strict",
        "N8N_MCP_TELEMETRY_DISABLED": "true"
      }
    }
  }
}
```

**Changes for production**:
- Use `https://` for API URL
- Set `WEBHOOK_SECURITY_MODE` to `strict`
- Use proper domain name instead of localhost

## Next Steps

✅ MCP server configured and working

**Now continue to**:
1. [Install n8n Skills](SKILLS_INSTALLATION.md) - Add 7 specialized skills for n8n
2. [Complete Windows Setup](WINDOWS_SETUP.md) - Finish full project setup

## Reference

- **n8n-mcp GitHub**: https://github.com/czlonkowski/n8n-mcp
- **Example Config**: `config/claude-config-example.json`
- **Environment Variables**: `config/n8n-env-vars.md`

---

Last updated: February 2026
