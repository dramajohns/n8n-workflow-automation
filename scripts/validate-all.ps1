# Validate all workflow JSON files in workflows directory
# Usage: .\validate-all.ps1
#        .\validate-all.ps1 -Path "workflows\dev"

param(
    [Parameter(Mandatory=$false)]
    [string]$Path = "workflows"
)

# Convert to absolute path if relative
if (-not [System.IO.Path]::IsPathRooted($Path)) {
    $projectRoot = Split-Path $PSScriptRoot -Parent
    $Path = Join-Path $projectRoot $Path
}

# Verify directory exists
if (-not (Test-Path $Path)) {
    Write-Error "Directory not found: $Path"
    exit 1
}

Write-Host "Validating workflow files in: $Path"
Write-Host ("=" * 70)

# Find all JSON files
$jsonFiles = Get-ChildItem -Path $Path -Filter *.json -Recurse

if ($jsonFiles.Count -eq 0) {
    Write-Warning "No JSON files found in: $Path"
    exit 0
}

Write-Host "Found $($jsonFiles.Count) JSON file(s) to validate`n"

# Track validation results
$results = @{
    Total = 0
    Valid = 0
    Invalid = 0
    Warnings = 0
}

# Validate each file
foreach ($file in $jsonFiles) {
    $results.Total++
    $relativePath = $file.FullName.Replace($Path, "").TrimStart('\')

    Write-Host "[$($results.Total)/$($jsonFiles.Count)] Validating: $relativePath"

    try {
        # Read and parse JSON
        $content = Get-Content $file.FullName -Raw
        $workflow = $content | ConvertFrom-Json

        # Basic structure validation
        $errors = @()
        $warnings = @()

        # Check required properties
        if (-not $workflow.name) {
            $errors += "Missing required property: 'name'"
        }

        if (-not $workflow.nodes) {
            $errors += "Missing required property: 'nodes'"
        } elseif ($workflow.nodes.Count -eq 0) {
            $warnings += "Workflow has no nodes"
        }

        if (-not $workflow.connections) {
            $warnings += "Missing 'connections' property (workflow may be disconnected)"
        }

        # Validate nodes structure
        if ($workflow.nodes) {
            for ($i = 0; $i -lt $workflow.nodes.Count; $i++) {
                $node = $workflow.nodes[$i]

                if (-not $node.name) {
                    $errors += "Node $i: Missing 'name' property"
                }

                if (-not $node.type) {
                    $errors += "Node $i ($($node.name)): Missing 'type' property"
                }

                if (-not $node.position) {
                    $warnings += "Node $i ($($node.name)): Missing 'position' property"
                }

                if (-not $node.parameters) {
                    $warnings += "Node $i ($($node.name)): Missing 'parameters' property"
                }
            }
        }

        # Report results
        if ($errors.Count -eq 0) {
            $results.Valid++
            Write-Host "  ✓ Valid workflow" -ForegroundColor Green
            Write-Host "    Name: $($workflow.name)"
            Write-Host "    Nodes: $($workflow.nodes.Count)"

            if ($warnings.Count -gt 0) {
                $results.Warnings++
                Write-Host "  ⚠ Warnings:" -ForegroundColor Yellow
                foreach ($warning in $warnings) {
                    Write-Host "    - $warning" -ForegroundColor Yellow
                }
            }
        } else {
            $results.Invalid++
            Write-Host "  ✗ Invalid workflow" -ForegroundColor Red
            foreach ($error in $errors) {
                Write-Host "    - $error" -ForegroundColor Red
            }

            if ($warnings.Count -gt 0) {
                Write-Host "  ⚠ Warnings:" -ForegroundColor Yellow
                foreach ($warning in $warnings) {
                    Write-Host "    - $warning" -ForegroundColor Yellow
                }
            }
        }

    } catch {
        $results.Invalid++
        Write-Host "  ✗ Failed to parse JSON" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
}

# Print summary
Write-Host ("=" * 70)
Write-Host "Validation Summary"
Write-Host ("=" * 70)
Write-Host "Total files:    $($results.Total)"
Write-Host "Valid:          $($results.Valid)" -ForegroundColor Green
Write-Host "Invalid:        $($results.Invalid)" -ForegroundColor $(if ($results.Invalid -gt 0) { "Red" } else { "Green" })
Write-Host "With warnings:  $($results.Warnings)" -ForegroundColor $(if ($results.Warnings -gt 0) { "Yellow" } else { "Green" })
Write-Host ("=" * 70)

# Exit with appropriate code
if ($results.Invalid -gt 0) {
    Write-Host "`nValidation FAILED: Some files have errors" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nValidation PASSED: All files are valid" -ForegroundColor Green
    exit 0
}
