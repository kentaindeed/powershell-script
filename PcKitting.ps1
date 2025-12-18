# Function to uninstall HP Security applications
function Remove-HPSecurityApps {
    Write-Host "Starting uninstallation of HP Security applications..." -ForegroundColor Yellow
    
    # List of target applications
    $apps = @(
        "HP Wolf Security",
        "HP Wolf Security - Console",
        "HP Security Update Service"
    )

    foreach ($app in $apps) {
        Write-Host "Checking for $app..." -ForegroundColor Cyan
        # Check if the package exists
        $package = Get-Package -Name $app -ErrorAction SilentlyContinue
        
        if ($package) {
            Write-Host "Found $app. Uninstalling..." -ForegroundColor Yellow
            try {
                # Execute uninstallation
                $package | Uninstall-Package -Force
                Write-Host "Successfully uninstalled $app." -ForegroundColor Green
            } catch {
                Write-Host "Failed to uninstall $app. It might require a manual restart." -ForegroundColor Red
            }
        } else {
            Write-Host "$app is not installed or already removed." -ForegroundColor Gray
        }
    }

    Write-Host "Process complete. Please restart your PC." -ForegroundColor White -BackgroundColor Blue
}

# Host name 変更
# Function to rename the computer
function Rename-PC {
    $currentName = $env:COMPUTERNAME
    Write-Host "Current Hostname: $currentName" -ForegroundColor Cyan
    $newName = Read-Host "Enter the new Hostname (Leave blank to cancel)"
    
    if (-not [string]::IsNullOrWhiteSpace($newName)) {
        try {
            Rename-Computer -NewName $newName -ErrorAction Stop
            Write-Host "Success: Hostname set to '$newName'." -ForegroundColor Green
            Write-Host "A restart is required to apply the changes." -ForegroundColor Yellow
        } catch {
            Write-Host "Error: Failed to change hostname. Please check permissions or naming rules." -ForegroundColor Red
        }
    } else {
        Write-Host "Operation cancelled." -ForegroundColor Gray
    }
}

# Main function
# Main Menu function
function main {
    Clear-Host
    Write-Host "=== PC Kitting Tool ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Uninstall HP Security Applications" -ForegroundColor Cyan
    Write-Host "2. Rename Hostname (Computer Name)" -ForegroundColor Cyan
    Write-Host "0. Exit" -ForegroundColor Red
    Write-Host ""
    
    do {
        $choice = Read-Host "Select an option (0-2)"
        
        switch ($choice) {
            "1" {
                Remove-HPSecurityApps
                Write-Host "`nTask completed. Press any key to return to menu..."
                $null = [System.Console]::ReadKey($true)
                main; return
            }
            "2" {
                Rename-PC
                Write-Host "`nTask completed. Press any key to return to menu..."
                $null = [System.Console]::ReadKey($true)
                main; return
            }
            "0" {
                Write-Host "Exiting..." -ForegroundColor Green
                return
            }
            default {
                Write-Host "Invalid choice. Please enter 0, 1, or 2." -ForegroundColor Red
            }
        }
    } while ($true)
}

# Run the script
main