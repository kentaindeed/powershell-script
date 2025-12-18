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

# 3. Function to install Google Chrome
function Install-Chrome {
    Write-Host "Checking for Google Chrome..." -ForegroundColor Cyan
    if (Get-Command chrome -ErrorAction SilentlyContinue) {
        Write-Host "Google Chrome is already installed." -ForegroundColor Gray
    } else {
        Write-Host "Installing Google Chrome via winget..." -ForegroundColor Yellow
        try {
            # --silent: no UI, --accept-package-agreements: auto-accept terms
            winget install --id Google.Chrome --silent --accept-package-agreements --accept-source-agreements
            Write-Host "Success: Google Chrome installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Error: Failed to install Google Chrome." -ForegroundColor Red
        }
    }
}

# 4. Function to Sync Time and Set TimeZone
function Set-TimeAndZone {
    Write-Host "Setting Time Zone to Tokyo Standard Time..." -ForegroundColor Yellow
    try {
        # Set Time Zone
        Set-TimeZone -Id "Tokyo Standard Time"
        
        # Start and Sync Windows Time Service
        Write-Host "Synchronizing time with time.windows.com..." -ForegroundColor Cyan
        Set-Service -Name W32Time -StartupType Automatic
        Start-Service -Name W32Time -ErrorAction SilentlyContinue
        w32tm /resync /force
        
        Write-Host "Success: Time synchronized and Zone set to Tokyo." -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to sync time. Please check internet connection." -ForegroundColor Red
    }
}

# Main Menu
function main {
    Clear-Host
    Write-Host "=== PC Kitting Tool ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Uninstall HP Security Applications" -ForegroundColor Cyan
    Write-Host "2. Rename Hostname (Computer Name)" -ForegroundColor Cyan
    Write-Host "3. Install Google Chrome" -ForegroundColor Cyan
    Write-Host "4. Set Time Zone & Sync Time (Tokyo)" -ForegroundColor Cyan
    Write-Host "0. Exit" -ForegroundColor Red
    Write-Host ""
    
    do {
        $choice = Read-Host "Select an option (0-4)"
        switch ($choice) {
            "1" { Remove-HPSecurityApps; break }
            "2" { Rename-PC; break }
            "3" { Install-Chrome; break }
            "4" { Set-TimeAndZone; break }
            "0" { Write-Host "Exiting..."; return }
            default { Write-Host "Invalid choice." -ForegroundColor Red }
        }
        Write-Host "`nTask completed. Press any key to return to menu..."
        $null = [System.Console]::ReadKey($true)
        main; return
    } while ($true)
}

main