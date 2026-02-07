# Export single workflow by ID or name
# Usage: .\export-workflow.ps1 -WorkflowId "workflow-id" -OutputPath "workflows\dev\my-workflow.json"
#        .\export-workflow.ps1 -WorkflowName "My Workflow" -OutputPath "workflows\dev\my-workflow.json"

param(
    [Parameter(Mandatory=$false)]
    [string]$WorkflowId,

    [Parameter(Mandatory=$false)]
    [string]$WorkflowName,

    [Parameter(Mandatory=$true)]
    [string]$OutputPath,

    [string]$ApiUrl = $env:N8N_API_URL,
    [string]$ApiKey = $env:N8N_API_KEY
)

# Verify parameters
if (-not $WorkflowId -and -not $WorkflowName) {
    Write-Error "Please provide either -WorkflowId or -WorkflowName"
    exit 1
}

# Load environment variables from .env file if not set
if (-not $ApiUrl -or -not $ApiKey) {
    $projectRoot = Split-Path $PSScriptRoot -Parent
    $envFile = Join-Path $projectRoot ".env"
    if (Test-Path $envFile) {
        Write-Host "Loading environment variables from .env file..."
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                if ($key -eq "N8N_API_URL" -and -not $ApiUrl) { $ApiUrl = $value }
                if ($key -eq "N8N_API_KEY" -and -not $ApiKey) { $ApiKey = $value }
            }
        }
    }
}

# Verify API credentials
if (-not $ApiUrl) {
    Write-Error "N8N_API_URL not set. Please set it in .env file or environment variable."
    exit 1
}

if (-not $ApiKey) {
    Write-Error "N8N_API_KEY not set. Please set it in .env file or environment variable."
    exit 1
}

try {
    # Set up API headers
    $headers = @{
        "X-N8N-API-KEY" = $ApiKey
        "Accept" = "application/json"
    }

    # If WorkflowName provided, find the workflow ID
    if ($WorkflowName -and -not $WorkflowId) {
        Write-Host "Searching for workflow: $WorkflowName"
        $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/workflows" -Headers $headers -Method Get

        $workflow = $response.data | Where-Object { $_.name -eq $WorkflowName }

        if (-not $workflow) {
            Write-Error "Workflow not found: $WorkflowName"
            Write-Host "`nAvailable workflows:"
            $response.data | ForEach-Object { Write-Host "  - $($_.name) (ID: $($_.id))" }
            exit 1
        }

        $WorkflowId = $workflow.id
        Write-Host "Found workflow ID: $WorkflowId"
    }

    # Fetch workflow details
    Write-Host "Exporting workflow ID: $WorkflowId"
    $workflowDetails = Invoke-RestMethod -Uri "$ApiUrl/api/v1/workflows/$WorkflowId" -Headers $headers -Method Get

    # Ensure output directory exists
    $outputDir = Split-Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        Write-Host "Creating output directory: $outputDir"
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    # Convert to absolute path if relative
    if (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
        $projectRoot = Split-Path $PSScriptRoot -Parent
        $OutputPath = Join-Path $projectRoot $OutputPath
    }

    # Save to file
    $workflowDetails | ConvertTo-Json -Depth 100 | Set-Content -Path $OutputPath -Encoding UTF8

    Write-Host "`nWorkflow exported successfully!"
    Write-Host "Name: $($workflowDetails.name)"
    Write-Host "ID: $($workflowDetails.id)"
    Write-Host "Location: $OutputPath"
    Write-Host "Nodes: $($workflowDetails.nodes.Count)"

} catch {
    Write-Error "Export failed: $_"
    Write-Error "Error details: $($_.Exception.Message)"
    exit 1
}
