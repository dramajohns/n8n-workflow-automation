# n8n Workflow Automation Project

Personal learning and development project for n8n workflow automation using CLAUDE.

## Quick Start

1. **Configure MCP Server**: Follow [docs/setup/MCP_CONFIGURATION.md](docs/setup/MCP_CONFIGURATION.md)
2. **Install n8n Skills**: Follow [docs/setup/SKILLS_INSTALLATION.md](docs/setup/SKILLS_INSTALLATION.md)
3. **Complete Setup**: Follow [docs/setup/WINDOWS_SETUP.md](docs/setup/WINDOWS_SETUP.md)

## Project Structure

- **workflows/** - All workflow JSON files organized by environment
  - **dev/** - Development and testing workflows
    - **experiments/** - Learning and experimentation
    - **testing/** - Test workflows before production
  - **production/** - Stable, production-ready workflows
    - **automation/** - General automation tasks
    - **integrations/** - Third-party integrations
    - **ai-workflows/** - AI-powered workflows
  - **templates/** - Reusable workflow templates
    - **starters/** - Basic starter templates
    - **patterns/** - Implementation of 5 core workflow patterns
- **docs/** - Complete documentation and guides
  - **setup/** - Setup and configuration guides
  - **guides/** - Usage and development guides
  - **architecture/** - Architecture documentation
- **scripts/** - PowerShell automation scripts
- **config/** - Configuration examples and references
- **backups/** - Automated workflow backups (excluded from git)

## Environment

- **Platform**: Windows 10/11
- **n8n Instance**: Self-hosted (localhost:5678)
- **MCP Server**: n8n-mcp (czlonkowski/n8n-mcp)
- **Skills**: n8n-skills (czlonkowski/n8n-skills)

## Setup Order

### Phase 1: Foundation (30 minutes)
1. Review project structure (you're here!)
2. Read configuration templates in `config/`
3. Understand documentation structure

### Phase 2: MCP Server Setup (30 minutes)
4. Obtain n8n API key from self-hosted instance (Settings → API)
5. Edit `%APPDATA%\Claude\claude_desktop_config.json`
6. Add n8n-mcp configuration with API credentials
7. Restart Claude Desktop
8. Test: "List n8n workflows" in Claude Desktop

### Phase 3: Skills Installation (15 minutes)
9. Run: `/plugin install czlonkowski/n8n-skills`
10. Verify all 7 skills installed
11. Test skill auto-activation

### Phase 4: Validation (15 minutes)
12. Export a test workflow from n8n
13. Save to `workflows/dev/experiments/`
14. Run `scripts/backup-workflows.ps1`
15. Commit to Git

**Total estimated time: 90 minutes**

## Available Scripts

All scripts are located in the `scripts/` directory:

- **backup-workflows.ps1** - Backup all workflows to timestamped directory
- **export-workflow.ps1** - Export single workflow by ID
- **import-workflow.ps1** - Import workflow from JSON file
- **validate-all.ps1** - Validate all workflow JSON files

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - Workflow building guidance, MCP tools reference, expression syntax, patterns
- **[docs/setup/WINDOWS_SETUP.md](docs/setup/WINDOWS_SETUP.md)** - Complete Windows setup guide
- **[docs/setup/MCP_CONFIGURATION.md](docs/setup/MCP_CONFIGURATION.md)** - MCP server configuration
- **[docs/setup/SKILLS_INSTALLATION.md](docs/setup/SKILLS_INSTALLATION.md)** - Skills installation guide
- **[docs/guides/WORKFLOW_DEVELOPMENT.md](docs/guides/WORKFLOW_DEVELOPMENT.md)** - Development workflow best practices
- **[docs/guides/VERSION_CONTROL.md](docs/guides/VERSION_CONTROL.md)** - Git workflow for n8n projects
- **[docs/architecture/SELF_HOSTED_SETUP.md](docs/architecture/SELF_HOSTED_SETUP.md)** - Production n8n architecture

## Learning Path

1. **Start with Templates**: Explore `workflows/templates/starters/` for basic examples
2. **Study Patterns**: Review `workflows/templates/patterns/` for the 5 core workflow patterns
3. **Experiment Safely**: Use `workflows/dev/experiments/` for learning
4. **Build and Test**: Create workflows in `workflows/dev/testing/`
5. **Deploy to Production**: Move stable workflows to `workflows/production/`

## Version Control

Workflows are stored as JSON files in the `workflows/` directory structure:
- Use `scripts/export-workflow.ps1` to export from n8n
- Commit workflow JSON files to version control
- Use `scripts/backup-workflows.ps1` for automated backups
- See `docs/guides/VERSION_CONTROL.md` for detailed Git workflow

## Safety & Security

- **Never commit credentials**: `.env`, API keys, or credential files
- **Backups are local only**: `backups/` directory is excluded from Git
- **Use .env.example**: Configuration templates don't contain secrets
- **Dev vs Production**: Clear separation prevents accidental production changes

## Getting Help

- **Workflow building**: See [CLAUDE.md](CLAUDE.md) for comprehensive guidance
- **MCP tools**: Type "List available n8n MCP tools" in Claude
- **Skills**: Ask "What n8n skills are available?"
- **Troubleshooting**: Check docs in `docs/setup/` for platform-specific issues

---

Built with Claude Code for learning n8n workflow automation.
