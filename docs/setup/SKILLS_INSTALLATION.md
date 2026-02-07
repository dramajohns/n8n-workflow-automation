# n8n Skills Installation Guide

This guide explains how to install the 7 specialized n8n skills that enhance Claude Code's ability to build workflows.

## Prerequisites

✅ **MCP server (n8n-mcp) must be installed and working first**
- If not done yet, complete [MCP_CONFIGURATION.md](MCP_CONFIGURATION.md) first
- Verify MCP server works: "List n8n workflows" in Claude Desktop

✅ **Claude Code or Claude Desktop access**
- Skills work with both Claude Desktop and Claude Code CLI

## What are n8n Skills?

Skills are specialized capabilities that auto-activate based on your questions. The n8n skills package includes 7 skills that provide:

1. **n8n Expression Syntax** - Correct `{{}}` patterns and variable access
2. **n8n MCP Tools Expert** - Effective use of MCP server tools (HIGHEST PRIORITY)
3. **n8n Workflow Patterns** - 5 proven architectural approaches
4. **n8n Validation Expert** - Interpret and resolve validation errors
5. **n8n Node Configuration** - Operation-aware node setup
6. **n8n Code JavaScript** - JavaScript in Code nodes
7. **n8n Code Python** - Python with limitations awareness

These skills work together with the MCP server to provide comprehensive n8n workflow building assistance.

## Installation Method 1: Plugin Command (Recommended)

The easiest way to install all 7 skills at once.

### Step 1: Install via Plugin Command

In Claude Desktop or Claude Code, run:

```
/plugin install czlonkowski/n8n-skills
```

This will:
- Download the n8n-skills package from GitHub
- Install all 7 skills automatically
- Place them in your skills directory

### Step 2: Verify Installation

After installation completes, ask Claude:

```
What n8n skills are available?
```

You should see confirmation of all 7 skills installed.

### Step 3: Test Skill Activation

Try these queries to test each skill:

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

## Installation Method 2: Manual Installation

For more control or if the plugin command doesn't work.

### Step 1: Clone the Repository

Open Git Bash or PowerShell and run:

```bash
cd ~/Downloads
git clone https://github.com/czlonkowski/n8n-skills.git
cd n8n-skills
```

### Step 2: Copy Skills to Project Directory

**For this project** (recommended):

```powershell
# From n8n-skills repository root
Copy-Item -Recurse -Path .\skills\* -Destination "c:\Users\fedib\projects\learning\automation\.claude\skills\"
```

**For global installation** (available in all projects):

```powershell
# Copy to global Claude skills directory
Copy-Item -Recurse -Path .\skills\* -Destination "$env:USERPROFILE\.claude\skills\"
```

### Step 3: Verify Directory Structure

Check that skills are in the correct location:

**Project-specific** (this project only):
```
c:\Users\fedib\projects\learning\automation\.claude\skills\
├── n8n-expression-syntax\
│   ├── skill.md
│   └── metadata.json
├── n8n-mcp-tools-expert\
│   ├── skill.md
│   └── metadata.json
├── n8n-workflow-patterns\
│   ├── skill.md
│   └── metadata.json
├── n8n-validation-expert\
│   ├── skill.md
│   └── metadata.json
├── n8n-node-configuration\
│   ├── skill.md
│   └── metadata.json
├── n8n-code-javascript\
│   ├── skill.md
│   └── metadata.json
└── n8n-code-python\
    ├── skill.md
    └── metadata.json
```

### Step 4: Restart Claude

For skills to be recognized:
1. Fully quit Claude Desktop
2. Restart Claude Desktop
3. Skills will auto-activate based on context

## Skill Details

### 1. n8n Expression Syntax

**Auto-activates when you ask**:
- "How do I write expressions?"
- "Access data from previous node"
- "Format dates in n8n"

**Provides**:
- Correct `{{ }}` syntax patterns
- Variable access methods (`$json`, `$node`, etc.)
- Built-in functions and methods
- Common expression examples

**Example query**:
```
How do I access the email field from a previous HTTP Request node?
```

### 2. n8n MCP Tools Expert (Highest Priority)

**Auto-activates when you ask**:
- "Find me a Slack node"
- "Search for templates"
- "Create a workflow"

**Provides**:
- Best practices for using MCP tools
- When to use each tool
- How to structure queries
- Search optimization

**Example query**:
```
Search for email automation templates
```

### 3. n8n Workflow Patterns

**Auto-activates when you ask**:
- "Build a webhook workflow"
- "Create an API integration"
- "Schedule a task"

**Provides**:
- 5 proven workflow architectural patterns
- When to use each pattern
- Best practices for each type
- Example implementations

**The 5 patterns**:
1. Webhook Processing
2. HTTP API Integration
3. Database Operations
4. AI Workflows
5. Scheduled Tasks

**Example query**:
```
I want to build a workflow that triggers on webhook and sends Slack messages
```

### 4. n8n Validation Expert

**Auto-activates when you ask**:
- "Why is validation failing?"
- "Fix this workflow error"
- "Node configuration error"

**Provides**:
- Error interpretation
- Common validation issues
- How to fix specific errors
- Best practices to avoid errors

**Example query**:
```
I'm getting a validation error: "Missing required parameter 'resource'"
```

### 5. n8n Node Configuration

**Auto-activates when you ask**:
- "Configure HTTP Request node"
- "Setup Slack node"
- "How to use Code node"

**Provides**:
- Operation-specific configuration
- Required vs optional parameters
- Common configurations
- Node-specific best practices

**Example query**:
```
How do I configure the HTTP Request node for a POST request with JSON body?
```

### 6. n8n Code JavaScript

**Auto-activates when you ask**:
- "Write JavaScript in Code node"
- "Access webhook data in JS"
- "Return data from Code node"

**Provides**:
- JavaScript-specific n8n patterns
- How to access input data
- Required return format
- Common JavaScript examples

**Example query**:
```
How do I access webhook body data in a JavaScript Code node?
```

### 7. n8n Code Python

**Auto-activates when you ask**:
- "Use Python in n8n"
- "Python Code node example"
- "Can I use pandas in n8n?"

**Provides**:
- Python-specific n8n patterns
- Limitations (no external libraries)
- Built-in modules available
- Return format requirements

**Example query**:
```
Can I use the requests library in a Python Code node?
```

## How Skills Auto-Activate

Skills automatically detect context from your questions and activate when relevant. You don't need to explicitly invoke them.

**Multi-skill activation**: Some queries may activate multiple skills. For example:

```
Build a webhook workflow that validates data and sends to Slack
```

This might activate:
- **n8n Workflow Patterns** (webhook workflow architecture)
- **n8n MCP Tools Expert** (searching for Slack node)
- **n8n Expression Syntax** (data validation expressions)

## Skill Priority

When multiple skills could apply, they activate in priority order:

1. **n8n MCP Tools Expert** - Highest priority (tool usage)
2. **n8n Validation Expert** - High priority (error fixing)
3. **n8n Workflow Patterns** - Medium-high (workflow building)
4. **n8n Node Configuration** - Medium (specific node setup)
5. **n8n Expression Syntax** - Medium-low (expressions)
6. **n8n Code JavaScript** - Low (JS-specific)
7. **n8n Code Python** - Low (Python-specific)

## Verification Checklist

After installation, verify:

✅ Skills directory exists (`.claude/skills/` with 7 subdirectories)
✅ Each skill has `skill.md` and `metadata.json`
✅ Claude Desktop restarted
✅ Test queries activate appropriate skills
✅ No error messages when querying

## Troubleshooting

### Issue: Skills not activating

**Possible causes**:
1. Skills not in correct directory
2. Missing `metadata.json` files
3. Claude Desktop not restarted

**Solutions**:
1. Verify directory structure matches above
2. Ensure each skill folder has both `skill.md` and `metadata.json`
3. Fully quit and restart Claude Desktop

### Issue: "Skill not found" error

**Possible causes**:
1. Incomplete installation
2. Corrupted files

**Solutions**:
1. Re-run installation (plugin or manual)
2. Delete `.claude/skills/` and reinstall
3. Check file permissions (should be readable)

### Issue: Skills activating incorrectly

**Possible causes**:
1. Ambiguous query
2. Multiple skills applicable

**Solutions**:
1. Be more specific in your questions
2. This is normal - skills complement each other

## Project-Specific vs Global Installation

**Project-Specific** (`.claude/skills/` in this project):
- ✅ Skills only available in this project
- ✅ Easy to version control
- ✅ Can customize per project
- ❌ Not available in other projects

**Global** (`~/.claude/skills/`):
- ✅ Available in all projects
- ✅ One-time installation
- ❌ Can't customize per project
- ❌ Not version controlled

**Recommendation**: Use project-specific installation for learning projects to keep everything organized.

## Next Steps

✅ n8n skills installed and working

**Continue to**:
1. [Complete Windows Setup](WINDOWS_SETUP.md) - Finish project setup
2. [Workflow Development Guide](../guides/WORKFLOW_DEVELOPMENT.md) - Start building workflows
3. [CLAUDE.md](../../CLAUDE.md) - Reference for workflow building

## Reference

- **n8n-skills GitHub**: https://github.com/czlonkowski/n8n-skills
- **Skill Documentation**: Each skill's `skill.md` file
- **MCP Server**: See [MCP_CONFIGURATION.md](MCP_CONFIGURATION.md)

---

Last updated: February 2026
