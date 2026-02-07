# Backup all n8n workflows to JSON files
# Usage: .\backup-workflows.ps1

param(
    [string]$BackupDir = "c:\Users\fedib\projects\learning\automation\backups",
    [string]$ApiUrl = $env:N8N_API_URL,
    [string]$ApiKey = $env:N8N_API_KEY
)

# Load environment variables from .env file if not set
if (-not $ApiUrl -or -not $ApiKey) {
    $envFile = Join-Path (Split-Path $PSScriptRoot -Parent) ".env"
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

# Create timestamped backup directory
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupPath = Join-Path $BackupDir $timestamp

try {
    Write-Host "Creating backup directory: $backupPath"
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

    # Set up API headers
    $headers = @{
        "X-N8N-API-KEY" = $ApiKey
        "Accept" = "application/json"
    }

    # Fetch all workflows from n8n API
    Write-Host "Fetching workflows from n8n instance: $ApiUrl"
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/workflows" -Headers $headers -Method Get

    if ($response.data) {
        $workflows = $response.data
        Write-Host "Found $($workflows.Count) workflow(s)"

        # Save each workflow to a JSON file
        foreach ($workflow in $workflows) {
            $workflowId = $workflow.id
            $workflowName = $workflow.name -replace '[\\/:*?"<>|]', '_'  # Sanitize filename
            $filename = "${workflowId}_${workflowName}.json"
            $filePath = Join-Path $backupPath $filename

            Write-Host "  Backing up: $($workflow.name) (ID: $workflowId)"

            # Fetch full workflow details
            $workflowDetails = Invoke-RestMethod -Uri "$ApiUrl/api/v1/workflows/$workflowId" -Headers $headers -Method Get

            # Save to file
            $workflowDetails | ConvertTo-Json -Depth 100 | Set-Content -Path $filePath -Encoding UTF8
        }

        Write-Host "`nBackup completed successfully!"
        Write-Host "Location: $backupPath"
        Write-Host "Total workflows backed up: $($workflows.Count)"

    } else {
        Write-Warning "No workflows found in n8n instance."
        Write-Host "Backup directory created but is empty: $backupPath"
    }

} catch {
    Write-Error "Backup failed: $_"
    Write-Error "Error details: $($_.Exception.Message)"
    exit 1
}
