# Windows Setup Guide for n8n Workflow Automation

Complete setup guide for this n8n workflow automation project on Windows 10/11.

## Prerequisites Checklist

Before starting, ensure you have:

### Required
- ✅ **Windows 10/11** (64-bit)
- ✅ **Self-hosted n8n instance** running and accessible
- ✅ **Claude Desktop** installed
- ✅ **Git** for version control
- ✅ **Node.js 18+** (for NPX method) OR **Docker Desktop** (for Docker method)
- ✅ **n8n API key** (from n8n Settings → API)

### Recommended
- ✅ **PowerShell 5.1+** (included with Windows 10/11)
- ✅ **Code editor** (VS Code, Notepad++, or similar)
- ✅ **Git Bash** (optional, for better terminal experience)

## Setup Overview

This setup process takes approximately **90 minutes** across 4 phases:

1. **Foundation** (30 min) - Project structure and Git
2. **MCP Server** (30 min) - Configure n8n-mcp server
3. **Skills** (15 min) - Install n8n skills
4. **Validation** (15 min) - Test and verify

## Phase 1: Foundation (30 minutes)

### Step 1: Verify n8n Instance

1. Open browser and navigate to your n8n instance:
   ```
   http://localhost:5678
   ```
   (Or your actual n8n URL if different)

2. Verify n8n is accessible and you can log in

3. Obtain API key:
   - Go to **Settings** → **API**
   - Click **Create API Key**
   - Name it "Claude MCP Server"
   - **Copy the key** and save it temporarily (you'll need it soon)

### Step 2: Verify Project Structure

The project structure should already be created. Verify it exists:

```powershell
# Navigate to project directory
cd "c:\Users\fedib\projects\learning\automation"

# List directories
ls
```

You should see:
```
.claude/
backups/
config/
docs/
scripts/
workflows/
CLAUDE.md
README.md
.gitignore
```

### Step 3: Configure Environment Variables

1. Copy the environment template:
   ```powershell
   Copy-Item config\.env.example .env
   ```

2. Edit `.env` file (use Notepad or your preferred editor):
   ```powershell
   notepad .env
   ```

3. Update with your values:
   ```bash
   N8N_API_URL=http://localhost:5678
   N8N_API_KEY=your_actual_api_key_here
   ```

4. Save and close

**Important**: The `.env` file is in `.gitignore` and won't be committed to version control.

### Step 4: Initialize Git Repository

If not already a Git repository:

```powershell
# Initialize Git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial project structure for n8n workflow automation"
```

Verify Git is initialized:
```powershell
git status
```

## Phase 2: MCP Server Setup (30 minutes)

### Step 5: Configure n8n-mcp Server

Follow the detailed guide: **[MCP_CONFIGURATION.md](MCP_CONFIGURATION.md)**

**Quick summary**:
1. Locate Claude Desktop config: `%APPDATA%\Claude\claude_desktop_config.json`
2. Add n8n-mcp server configuration
3. Use your API key from Step 1
4. Save and restart Claude Desktop

**Installation methods**:
- **NPX** (Recommended for learning) - Simple, no infrastructure
- **Docker** - More reproducible, requires Docker Desktop

### Step 6: Verify MCP Server

After restarting Claude Desktop, test the connection:

1. Open Claude Desktop
2. Type: `List all n8n workflows`
3. You should see your workflows listed (or empty list if none exist)

**If this doesn't work**, see [MCP_CONFIGURATION.md - Troubleshooting](MCP_CONFIGURATION.md#troubleshooting)

## Phase 3: Skills Installation (15 minutes)

### Step 7: Install n8n Skills

Follow the detailed guide: **[SKILLS_INSTALLATION.md](SKILLS_INSTALLATION.md)**

**Quick summary**:
1. In Claude Desktop, run: `/plugin install czlonkowski/n8n-skills`
2. Wait for installation to complete
3. Verify all 7 skills installed

**OR** manual installation:
1. Clone: `git clone https://github.com/czlonkowski/n8n-skills.git`
2. Copy skills to `.claude/skills/` directory
3. Restart Claude Desktop

### Step 8: Test Skills Activation

Try these queries in Claude Desktop:

```
How do I write n8n expressions?
```
→ Should activate **n8n Expression Syntax** skill

```
Search for a Slack node
```
→ Should activate **n8n MCP Tools Expert** skill

```
Build a webhook workflow
```
→ Should activate **n8n Workflow Patterns** skill

## Phase 4: Validation (15 minutes)

### Step 9: Test Workflow Export

1. In Claude Desktop or Claude Code, ask:
   ```
   Export one of my n8n workflows to a JSON file
   ```

2. Save the exported workflow to:
   ```
   workflows/dev/experiments/test-workflow.json
   ```

3. Verify the file exists and contains valid JSON

### Step 10: Run Backup Script

**Note**: The backup script needs to be functional first (implemented in next section).

For now, verify the script exists:
```powershell
ls scripts\backup-workflows.ps1
```

### Step 11: Commit to Git

After testing, commit your first workflow (if exported):

```powershell
git add workflows/dev/experiments/*.json
git commit -m "Add test workflow for validation"
```

## Windows-Specific Considerations

### PowerShell Execution Policy

If you encounter "script execution disabled" errors:

```powershell
# Check current policy
Get-ExecutionPolicy

# Set to RemoteSigned (recommended)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Path Separators

Windows uses backslashes (`\`) for paths:
- ✅ Correct: `c:\Users\fedib\projects\learning\automation`
- ❌ Wrong: `c:/Users/fedib/projects/learning/automation` (Git Bash only)

PowerShell accepts both, but stick with backslashes for consistency.

### File Permissions

n8n workflows are JSON files and don't require special permissions. If you encounter access issues:

```powershell
# Check file permissions
Get-Acl workflows\dev\experiments\test-workflow.json
```

### Long Path Support

If you encounter "path too long" errors:

1. Enable long path support in Windows 10/11:
   - Open Registry Editor (`regedit`)
   - Navigate to: `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem`
   - Set `LongPathsEnabled` to `1`
   - Restart computer

OR keep paths shorter by organizing workflows efficiently.

## Backup Automation (Optional)

### Setup Windows Task Scheduler

To automatically backup workflows daily:

1. Open **Task Scheduler** (`taskschd.msc`)
2. Click **Create Basic Task**
3. Name: "n8n Workflow Backup"
4. Trigger: **Daily** at preferred time
5. Action: **Start a program**
6. Program: `powershell.exe`
7. Arguments:
   ```
   -ExecutionPolicy Bypass -File "c:\Users\fedib\projects\learning\automation\scripts\backup-workflows.ps1"
   ```
8. Finish and test

## Troubleshooting

### Issue: "Cannot find n8n instance"

**Solutions**:
1. Verify n8n is running: `http://localhost:5678`
2. Check `N8N_API_URL` in `.env` and MCP config
3. Ensure port 5678 is not blocked by firewall

### Issue: "API key invalid"

**Solutions**:
1. Generate new API key in n8n Settings → API
2. Update both `.env` and Claude Desktop config
3. Restart Claude Desktop

### Issue: "Skills not activating"

**Solutions**:
1. Verify skills are in `.claude/skills/` directory
2. Each skill folder must have `skill.md` and `metadata.json`
3. Fully quit and restart Claude Desktop

### Issue: PowerShell scripts won't run

**Solutions**:
1. Check execution policy: `Get-ExecutionPolicy`
2. Set to RemoteSigned: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
3. Unblock scripts: `Unblock-File scripts\*.ps1`

### Issue: Git not recognizing repository

**Solutions**:
1. Ensure you ran `git init` in project root
2. Verify `.git` folder exists
3. Check Git is installed: `git --version`

## Verification Checklist

After completing all steps, verify:

✅ Project structure exists (all directories created)
✅ Git repository initialized (`.git/` folder exists)
✅ Environment variables configured (`.env` file with API key)
✅ MCP server working (can list workflows in Claude Desktop)
✅ Skills installed (7 skills in `.claude/skills/`)
✅ Skills activating (test queries work)
✅ Can export workflows (saved to `workflows/dev/`)
✅ Backup script exists (`scripts/backup-workflows.ps1`)

## Next Steps

✅ Complete Windows setup finished!

**Now you can**:
1. **Start Learning**: Explore [workflows/templates/](../../workflows/templates/) for examples
2. **Build Workflows**: Follow [CLAUDE.md](../../CLAUDE.md) for workflow building guidance
3. **Develop**: Use [docs/guides/WORKFLOW_DEVELOPMENT.md](../guides/WORKFLOW_DEVELOPMENT.md)
4. **Reference**: Check [docs/guides/VERSION_CONTROL.md](../guides/VERSION_CONTROL.md) for Git workflow

## Quick Reference

### Important Paths

| Item | Windows Path |
|------|--------------|
| Project Root | `c:\Users\fedib\projects\learning\automation` |
| Claude Config | `%APPDATA%\Claude\claude_desktop_config.json` |
| Environment File | `.env` (in project root) |
| Skills Directory | `.claude\skills\` |
| Workflows | `workflows\` |
| Scripts | `scripts\` |

### Common Commands

```powershell
# Navigate to project
cd "c:\Users\fedib\projects\learning\automation"

# View environment variables
cat .env

# Edit Claude config
notepad "%APPDATA%\Claude\claude_desktop_config.json"

# List workflows
ls workflows\dev\experiments

# Run backup script
.\scripts\backup-workflows.ps1

# Git status
git status

# Commit changes
git add .
git commit -m "Your message"
```

## Support & Resources

- **Project README**: [README.md](../../README.md)
- **Workflow Building**: [CLAUDE.md](../../CLAUDE.md)
- **MCP Configuration**: [MCP_CONFIGURATION.md](MCP_CONFIGURATION.md)
- **Skills Installation**: [SKILLS_INSTALLATION.md](SKILLS_INSTALLATION.md)
- **Environment Variables**: [config/n8n-env-vars.md](../../config/n8n-env-vars.md)

---

Last updated: February 2026
