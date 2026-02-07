# Workflow Development Guide

Best practices for developing n8n workflows in this project.

## Development Workflow

### 1. Start with Templates

Always begin with a template from `workflows/templates/`:

**Starter Templates** (`starters/`):
- `webhook-example.json` - Basic webhook workflow

**Pattern Templates** (`patterns/`):
- `01-webhook-processing.json` - External triggers → Process → Respond
- `02-http-api-integration.json` - Fetch data → Transform → Store/Send
- `03-database-operations.json` - Query → Process → Update
- `04-ai-workflows.json` - Input → AI processing → Output handling
- `05-scheduled-tasks.json` - Cron trigger → Batch process → Report

### 2. Development Environment Workflow

```
workflows/
├── dev/
│   ├── experiments/     ← Start here (safe playground)
│   └── testing/         ← Move here when ready for testing
├── production/          ← Move here when stable and validated
│   ├── automation/
│   ├── integrations/
│   └── ai-workflows/
└── templates/           ← Reference these for patterns
```

**Development process**:
1. **Experiment** - Copy template to `dev/experiments/`, modify freely
2. **Test** - When working, move to `dev/testing/`, test thoroughly
3. **Deploy** - When validated, move to appropriate `production/` subfolder
4. **Activate** - Activate workflow in n8n for production use

### 3. Naming Conventions

**Workflow Names**:
```
[Category] - [Purpose] - [Version]

Examples:
- "Integration - Slack Notifications - v1"
- "Automation - Daily Report - v2"
- "AI - Content Generator - v1"
```

**File Names**:
```
[id]_[descriptive-name].json

Examples:
- "5_slack-notifications.json"
- "12_daily-report-generator.json"
- "8_ai-content-generator.json"
```

### 4. Version Control Workflow

See [VERSION_CONTROL.md](VERSION_CONTROL.md) for detailed Git workflow.

**Quick summary**:
```bash
# 1. Export workflow from n8n
.\scripts\export-workflow.ps1 -WorkflowName "My Workflow" -OutputPath "workflows\dev\testing\my-workflow.json"

# 2. Test and validate
.\scripts\validate-all.ps1 -Path "workflows\dev\testing"

# 3. Commit to Git
git add workflows\dev\testing\my-workflow.json
git commit -m "Add: My Workflow v1"

# 4. Move to production when ready
Move-Item workflows\dev\testing\my-workflow.json workflows\production\automation\
git add -A
git commit -m "Deploy: My Workflow v1 to production"
```

## Workflow Building Process

Follow the process outlined in [CLAUDE.md](../../CLAUDE.md):

### Phase 1: Understand Requirements
- Clarify workflow purpose and triggers
- Identify required integrations
- Determine error handling needs
- Document expected inputs and outputs

### Phase 2: Research
```
# Search for similar templates
Ask Claude: "Search n8n templates for [your use case]"

# Find required nodes
Ask Claude: "Search for [integration] node in n8n"

# Get node configuration details
Ask Claude: "How do I configure [node name] for [operation]?"
```

### Phase 3: Build Incrementally
1. Start with trigger node
2. Add nodes one at a time
3. Test each node individually
4. Validate after each addition
5. Add error handling

### Phase 4: Validate
```bash
# Validate workflow JSON structure
.\scripts\validate-all.ps1 -Path "workflows\dev\experiments"

# Use n8n-mcp validation
Ask Claude: "Validate my workflow [workflow-name]"
```

### Phase 5: Test
```
# Test in n8n
Ask Claude: "Test workflow [workflow-name] with test data"

# Verify outputs
Ask Claude: "Get execution details for [execution-id]"
```

### Phase 6: Document
Add workflow documentation:
- Purpose and use case
- Required credentials
- Configuration steps
- Expected inputs and outputs
- Error handling behavior

## Best Practices

### Node Organization

**Positioning**:
- Flow left to right
- Use vertical spacing for branches
- Keep related nodes together
- Align nodes in columns

**Naming**:
- Use descriptive node names
- Follow convention: "[Action] [Resource]"
- Examples: "Fetch User Data", "Send Slack Message", "Transform Results"

**Notes**:
- Add notes to complex nodes
- Explain non-obvious logic
- Document expected data structures

### Error Handling

**Always include**:
1. Error trigger node for critical workflows
2. Try/catch in Code nodes
3. Validation before external API calls
4. Fallback values for optional data

**Example Code node with error handling**:
```javascript
try {
  const data = $json.body;

  if (!data || !data.email) {
    throw new Error('Missing required field: email');
  }

  return [{
    json: {
      email: data.email.toLowerCase(),
      status: 'success'
    }
  }];
} catch (error) {
  return [{
    json: {
      error: error.message,
      status: 'failed'
    }
  }];
}
```

### Expression Syntax

**Best practices**:
- Use `{{ }}` only in node parameters, NOT in Code nodes
- Access data: `{{ $json.fieldName }}`
- Reference previous node: `{{ $('Node Name').item.json.field }}`
- Use Code nodes for complex logic

**Common patterns**:
```javascript
// Access webhook body
{{ $json.body }}

// Access specific field
{{ $json.body.email }}

// Conditional logic
{{ $json.status === 'active' ? 'yes' : 'no' }}

// Current timestamp
{{ $now.toISO() }}

// Date formatting
{{ $today.format('yyyy-MM-dd') }}

// Access all items from previous node
{{ $('Previous Node').all() }}
```

### Credentials Management

**Never commit credentials**:
- Use n8n credential system
- Reference credentials by name in workflows
- Don't hardcode API keys or passwords
- `.gitignore` excludes credential files

**Example**:
```json
{
  "credentials": {
    "httpHeaderAuth": {
      "id": "1",
      "name": "My API Credentials"
    }
  }
}
```

## Testing Strategies

### Unit Testing
Test individual nodes:
1. Disable all nodes except one
2. Provide test input data
3. Verify output
4. Re-enable and continue

### Integration Testing
Test complete workflow:
1. Use `dev/testing/` environment
2. Test with realistic data
3. Verify all branches (success/error paths)
4. Check error handling

### Production Testing
Before activating in production:
1. Run workflow manually several times
2. Test edge cases (empty data, missing fields, etc.)
3. Verify credential access
4. Check webhook endpoints (if applicable)
5. Monitor first few executions closely

## Common Patterns

### Pattern 1: Webhook → Process → Respond
```
Webhook → Code (validate) → Code (transform) → Respond to Webhook
```
Use for: APIs, form submissions, external integrations

### Pattern 2: Schedule → Fetch → Transform → Store
```
Schedule → HTTP Request → Code (transform) → Database/API
```
Use for: Data syncing, reporting, batch processing

### Pattern 3: Trigger → Branch → Merge
```
Trigger → IF → [Branch A] → Merge
             └→ [Branch B] → Merge
```
Use for: Conditional logic, multi-path workflows

### Pattern 4: Trigger → Loop → Process
```
Trigger → Split In Batches → Process Item → Merge
```
Use for: Batch processing, iterating over arrays

### Pattern 5: Error Handling
```
Trigger → Try (main flow) → Success path
                           → Error Trigger → Error handler
```
Use for: Critical workflows requiring error monitoring

## Optimization Tips

### Performance
- Batch operations when possible
- Use pagination for large datasets
- Minimize API calls
- Cache frequently accessed data
- Use queue mode for heavy workloads

### Maintainability
- Keep workflows focused (single responsibility)
- Extract reusable logic to sub-workflows
- Document complex expressions
- Use consistent naming conventions
- Version control all changes

### Reliability
- Implement retry logic for external APIs
- Add timeout limits
- Validate input data
- Handle empty/null values gracefully
- Monitor execution history

## Troubleshooting

### Workflow not triggering
- Check trigger node configuration
- Verify webhook URLs (if applicable)
- Check workflow is active
- Review execution history for errors

### Node execution failing
- Check node configuration
- Verify credentials
- Test with minimal data
- Review error messages in execution log

### Expression errors
- Verify syntax: `{{ }}` in parameters only
- Check field names (case-sensitive)
- Test expressions in browser console
- Use Code nodes for complex logic

### Data not passing between nodes
- Check connections
- Verify output format: `[{ json: {...} }]`
- Use "Execute Previous Nodes" to debug
- Check for empty arrays

## Resources

- **CLAUDE.md** - Complete workflow building reference
- **Templates** - `workflows/templates/` for examples
- **Scripts** - `scripts/` for automation tools
- **Expression Syntax** - Ask Claude: "How do I write n8n expressions?"
- **Node Configuration** - Ask Claude: "How do I configure [node] for [operation]?"

---

Last updated: February 2026
