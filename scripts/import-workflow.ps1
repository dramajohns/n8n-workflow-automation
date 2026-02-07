# Import workflow from JSON file to n8n instance
# Usage: .\import-workflow.ps1 -FilePath "workflows\dev\my-workflow.json"
#        .\import-workflow.ps1 -FilePath "workflows\dev\my-workflow.json" -Activate

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,

    [Parameter(Mandatory=$false)]
    [switch]$Activate,

    [string]$ApiUrl = $env:N8N_API_URL,
    [string]$ApiKey = $env:N8N_API_KEY
)

# Verify file exists
if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
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
    # Read and parse workflow JSON
    Write-Host "Reading workflow file: $FilePath"
    $workflowJson = Get-Content $FilePath -Raw | ConvertFrom-Json

    # Validate basic structure
    if (-not $workflowJson.nodes) {
        Write-Error "Invalid workflow file: Missing 'nodes' property"
        exit 1
    }

    Write-Host "Workflow name: $($workflowJson.name)"
    Write-Host "Nodes count: $($workflowJson.nodes.Count)"

    # Prepare workflow for import (remove id and createdAt/updatedAt if present)
    $importWorkflow = $workflowJson | Select-Object -Property * -ExcludeProperty id, createdAt, updatedAt

    # Set activation status
    if ($Activate) {
        $importWorkflow.active = $true
        Write-Host "Workflow will be activated after import"
    } else {
        $importWorkflow.active = $false
        Write-Host "Workflow will be imported as inactive"
    }

    # Set up API headers
    $headers = @{
        "X-N8N-API-KEY" = $ApiKey
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }

    # Import workflow to n8n
    Write-Host "`nImporting workflow to n8n instance: $ApiUrl"
    $body = $importWorkflow | ConvertTo-Json -Depth 100
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/workflows" -Headers $headers -Method Post -Body $body

    Write-Host "`nWorkflow imported successfully!"
    Write-Host "Name: $($response.name)"
    Write-Host "New ID: $($response.id)"
    Write-Host "Active: $($response.active)"
    Write-Host "Nodes: $($response.nodes.Count)"

    Write-Host "`nYou can now access this workflow in n8n at:"
    Write-Host "$ApiUrl/workflow/$($response.id)"

} catch {
    Write-Error "Import failed: $_"
    Write-Error "Error details: $($_.Exception.Message)"

    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Error "API Response: $responseBody"
    }

    exit 1
}
