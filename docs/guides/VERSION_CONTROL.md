# Version Control for n8n Workflows

Git workflow and best practices for managing n8n workflows with version control.

## Why Version Control for Workflows?

Version control provides:
- **History** - Track all changes over time
- **Rollback** - Revert to previous versions if needed
- **Collaboration** - Work with others safely
- **Backup** - Cloud-based backup of all workflows
- **Documentation** - Commit messages document changes

## Project Git Structure

```
.git/                    # Git repository
.gitignore               # Excludes secrets and backups
workflows/               # All workflow JSON files (tracked)
├── dev/
│   ├── experiments/     # Tracked, but experimental
│   └── testing/         # Tracked, pre-production
└── production/          # Tracked, production workflows
backups/                 # NOT tracked (local only)
.env                     # NOT tracked (secrets)
```

## Workflow Lifecycle

### 1. Create New Workflow

```bash
# Create workflow in n8n UI first
# Then export it

.\scripts\export-workflow.ps1 -WorkflowName "My New Workflow" -OutputPath "workflows\dev\experiments\my-new-workflow.json"

# Add to Git
git add workflows\dev\experiments\my-new-workflow.json
git commit -m "Add: My New Workflow (experimental)"
```

### 2. Iterate and Test

```bash
# After making changes in n8n, re-export
.\scripts\export-workflow.ps1 -WorkflowName "My New Workflow" -OutputPath "workflows\dev\experiments\my-new-workflow.json"

# Review changes
git diff workflows\dev\experiments\my-new-workflow.json

# Commit if satisfied
git add workflows\dev\experiments\my-new-workflow.json
git commit -m "Update: Added error handling to My New Workflow"
```

### 3. Move to Testing

```bash
# Move workflow file
Move-Item workflows\dev\experiments\my-new-workflow.json workflows\dev\testing\

# Commit the move
git add -A
git commit -m "Move: My New Workflow to testing phase"
```

### 4. Deploy to Production

```bash
# Move to appropriate production folder
Move-Item workflows\dev\testing\my-new-workflow.json workflows\production\automation\

# Commit deployment
git add -A
git commit -m "Deploy: My New Workflow v1 to production"

# Tag the release
git tag -a v1.0-my-new-workflow -m "Release My New Workflow v1.0"
```

## Commit Message Conventions

Use semantic commit messages for clarity:

### Format
```
<type>: <description>

[optional body]
[optional footer]
```

### Types

- **Add** - New workflow created
- **Update** - Modify existing workflow
- **Fix** - Bug fix in workflow
- **Deploy** - Move workflow to production
- **Remove** - Delete workflow
- **Refactor** - Restructure without changing behavior
- **Docs** - Documentation changes
- **Test** - Add or update tests

### Examples

```bash
# New workflow
git commit -m "Add: Slack notification workflow for errors"

# Update workflow
git commit -m "Update: Added retry logic to API integration workflow"

# Fix bug
git commit -m "Fix: Corrected email validation in webhook processor"

# Deploy
git commit -m "Deploy: Daily report generator v2 to production"

# With detailed body
git commit -m "Update: Improved error handling in payment processor

- Added try/catch blocks in all Code nodes
- Implemented fallback for failed API calls
- Added error notification via Slack
- Tested with various edge cases"

# Remove workflow
git commit -m "Remove: Deprecated user sync workflow (replaced by v2)"
```

## Branching Strategy

### Simple (Recommended for Learning)

**Single branch (`main`)** with organized folders:
```
main
└── workflows/
    ├── dev/          # Development (may be broken)
    ├── testing/      # Testing (should work)
    └── production/   # Production (stable)
```

**Workflow**:
1. Commit directly to `main`
2. Use folder structure for lifecycle management
3. Tags for production releases

### Advanced (For Team Collaboration)

**Multiple branches**:
```
main                  # Production-ready workflows
├── develop           # Integration branch
│   ├── feature/X     # New workflow features
│   └── fix/Y         # Bug fixes
```

**Workflow**:
1. Create feature branch: `git checkout -b feature/slack-integration`
2. Develop workflow, commit changes
3. Merge to `develop`: `git checkout develop && git merge feature/slack-integration`
4. Test in `develop`
5. Merge to `main` when ready: `git checkout main && git merge develop`
6. Tag release: `git tag -a v1.2.0 -m "Release v1.2.0"`

## Best Practices

### DO

✅ **Commit frequently** - Small, logical commits
✅ **Use descriptive messages** - Explain what and why
✅ **Review diffs before committing** - `git diff` to verify changes
✅ **Export after every significant change** - Keep Git in sync with n8n
✅ **Tag production releases** - Easy rollback reference
✅ **Document breaking changes** - In commit message body
✅ **Keep workflows organized** - Use folder structure

### DON'T

❌ **Commit credentials** - Use `.gitignore`, already configured
❌ **Commit large backups** - Backups are in `.gitignore`
❌ **Use generic messages** - "Update workflow" is not helpful
❌ **Mix unrelated changes** - One workflow per commit (when possible)
❌ **Force push to main** - Dangerous, can lose history
❌ **Forget to export** - n8n changes must be exported to sync

## Handling Credentials

**Never commit credentials!**

Workflows reference credentials by name, not actual values:
```json
{
  "credentials": {
    "slackApi": {
      "id": "1",
      "name": "Slack API Key"
    }
  }
}
```

This is safe to commit. Actual credential values stay in n8n database.

### If you accidentally commit credentials:

```bash
# Remove file from Git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (DANGER: only if working alone)
git push origin --force --all

# Better: Rotate the credentials immediately
```

## Working with Remotes

### Initial Setup

```bash
# Initialize Git (if not done)
git init

# Add remote (GitHub, GitLab, etc.)
git remote add origin https://github.com/yourusername/automation.git

# Push to remote
git branch -M main
git push -u origin main
```

### Daily Workflow

```bash
# Pull latest changes (if collaborating)
git pull origin main

# Export modified workflows
.\scripts\export-workflow.ps1 -WorkflowName "Modified Workflow" -OutputPath "workflows\..."

# Review changes
git status
git diff

# Stage and commit
git add workflows\
git commit -m "Update: Description of changes"

# Push to remote
git push origin main
```

## Rollback and Recovery

### Rollback to Previous Version

```bash
# View commit history
git log --oneline

# Rollback specific file to previous commit
git checkout <commit-hash> -- workflows\production\automation\my-workflow.json

# Import the old version back to n8n
.\scripts\import-workflow.ps1 -FilePath "workflows\production\automation\my-workflow.json"

# Commit the rollback
git add workflows\production\automation\my-workflow.json
git commit -m "Rollback: Revert my-workflow to version <commit-hash>"
```

### Recover Deleted Workflow

```bash
# Find when it was deleted
git log --all --full-history -- workflows\production\automation\deleted-workflow.json

# Restore from specific commit (before deletion)
git checkout <commit-hash>~1 -- workflows\production\automation\deleted-workflow.json

# Import back to n8n
.\scripts\import-workflow.ps1 -FilePath "workflows\production\automation\deleted-workflow.json"

# Commit recovery
git add workflows\production\automation\deleted-workflow.json
git commit -m "Recover: Restore deleted-workflow from backup"
```

## Tagging Strategy

### Semantic Versioning

Use tags for production releases:
```
v<major>.<minor>.<patch>-<workflow-name>

Examples:
v1.0.0-slack-integration
v1.1.0-slack-integration (new feature)
v1.1.1-slack-integration (bug fix)
v2.0.0-slack-integration (breaking change)
```

### Creating Tags

```bash
# Annotated tag (recommended)
git tag -a v1.0.0-workflow-name -m "Release v1.0.0: Description of release"

# Push tag to remote
git push origin v1.0.0-workflow-name

# Push all tags
git push origin --tags

# List tags
git tag -l

# Checkout specific tag
git checkout v1.0.0-workflow-name
```

## Automation Scripts Integration

### Export and Commit Workflow

```powershell
# Custom script: export-and-commit.ps1
param([string]$WorkflowName, [string]$OutputPath, [string]$Message)

# Export
.\scripts\export-workflow.ps1 -WorkflowName $WorkflowName -OutputPath $OutputPath

# Validate
.\scripts\validate-all.ps1 -Path (Split-Path $OutputPath -Parent)

# Commit
git add $OutputPath
git commit -m $Message
```

Usage:
```powershell
.\export-and-commit.ps1 -WorkflowName "My Workflow" -OutputPath "workflows\dev\testing\my-workflow.json" -Message "Update: Added new feature"
```

### Backup Before Changes

```powershell
# Always backup before major changes
.\scripts\backup-workflows.ps1

# Make changes in n8n

# Export and commit
.\scripts\export-workflow.ps1 -WorkflowName "Modified Workflow" -OutputPath "workflows\..."
git add -A
git commit -m "Update: Description"
```

## Conflict Resolution

If you get merge conflicts (rare for solo development):

```bash
# Pull changes
git pull origin main

# If conflict occurs
# Edit conflicting file manually
notepad workflows\production\automation\conflicted-workflow.json

# Look for conflict markers
# <<<<<<< HEAD
# ... your changes ...
# =======
# ... incoming changes ...
# >>>>>>> branch-name

# Resolve manually, keep desired version

# Mark as resolved
git add workflows\production\automation\conflicted-workflow.json
git commit -m "Merge: Resolved conflict in conflicted-workflow"
```

## .gitignore Essentials

Already configured in `.gitignore`:

```gitignore
# Secrets (NEVER commit)
.env
*.env
!.env.example

# Backups (local only)
backups/*
!backups/.gitkeep

# Credentials
*-credentials.json

# Local settings
.claude/settings.local.json
```

## Verification Checklist

Before committing:

✅ Exported latest version from n8n
✅ Validated JSON structure (`validate-all.ps1`)
✅ Reviewed changes (`git diff`)
✅ No credentials in files
✅ Descriptive commit message
✅ Workflow tested and working

## Resources

- **Git Documentation**: https://git-scm.com/doc
- **Semantic Versioning**: https://semver.org/
- **Conventional Commits**: https://www.conventionalcommits.org/

---

Last updated: February 2026
