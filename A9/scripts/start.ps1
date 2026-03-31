# PowerShell script for Windows setup

# Check if .env file exists, create if it doesn't
if (-Not (Test-Path ".env")) {
    Write-Host "Creating .env file..."
    New-Item -ItemType File -Name ".env" | Out-Null
} else {
    # Load environment variables from .env file
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#=]+)=(.*)$") {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
}

# Add default Oracle connection settings if not present
if (-Not $env:ORACLE_HOST) {
    Add-Content -Path ".env" -Value "`nORACLE_HOST=oracle.scs.ryerson.ca"
    $env:ORACLE_HOST = "oracle.scs.ryerson.ca"
}

if (-Not $env:ORACLE_PORT) {
    Add-Content -Path ".env" -Value "`nORACLE_PORT=1521"
    $env:ORACLE_PORT = "1521"
}

if (-Not $env:ORACLE_SID) {
    Add-Content -Path ".env" -Value "`nORACLE_SID=orcl"
    $env:ORACLE_SID = "orcl"
}

# Check if ORACLE_USERNAME or ORACLE_PASSWORD are undefined
if (-Not $env:ORACLE_USERNAME -or -Not $env:ORACLE_PASSWORD) {
    Write-Host "Oracle database credentials are missing."
    Write-Host ""
    $username = Read-Host "Enter Oracle username"
    $password = Read-Host "Enter Oracle password" -AsSecureString
    $passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    Write-Host ""
    Write-Host ""
    
    Add-Content -Path ".env" -Value "`nORACLE_USERNAME=$username"
    Add-Content -Path ".env" -Value "ORACLE_PASSWORD=$passwordPlain"
    $env:ORACLE_USERNAME = $username
    $env:ORACLE_PASSWORD = $passwordPlain
}

# Set Oracle Client Library Directory
if (-Not $env:ORACLE_CLIENT_LIB_DIR) {
    Add-Content -Path ".env" -Value "`nORACLE_CLIENT_LIB_DIR=$env:TEMP\instantclient"
    $env:ORACLE_CLIENT_LIB_DIR = "$env:TEMP\instantclient"
}

# Install Oracle Instant Client if not present
if (-Not (Test-Path $env:ORACLE_CLIENT_LIB_DIR)) {
    Write-Host "Oracle Instant Client not found."
    Write-Host "Installing Oracle Instant Client Basic Light..."
    
    # Detect architecture (Windows only)
    $arch = $env:PROCESSOR_ARCHITECTURE
    
    # Determine download URL based on architecture
    switch ($arch) {
        "AMD64" {
            $url = "https://download.oracle.com/otn_software/nt/instantclient/2390000/instantclient-basiclite-windows.x64-23.9.0.25.07.zip"
            $archName = "x64"
        }
        "x86" {
            $url = "https://download.oracle.com/otn_software/nt/instantclient/2118000/instantclient-basiclite-nt-21.18.0.0.0dbru.zip"
            $archName = "x86"
        }
        default {
            Write-Host "Unsupported architecture: $arch"
            Write-Host "This script only supports Windows x64 and x86"
            exit 1
        }
    }
    
    Write-Host "Detected: Windows $archName"
    Write-Host "Downloading Instant Client..."
    
    # Create temp directory and save current location
    $originalDir = Get-Location
    $tempDir = "$env:TEMP\oracle_install"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Set-Location $tempDir
    
    # Download the instant client
    $zipFile = "instantclient.zip"
    try {
        Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    } catch {
        Write-Host "Error: Download failed."
        Write-Host "Please install Oracle Instant Client manually and set the env variable ORACLE_CLIENT_LIB_DIR."
        exit 1
    }
    
    # Extract the ZIP file
    try {
        Write-Host "Extracting..."
        Expand-Archive -Path $zipFile -DestinationPath "." -Force
        
        # Find the instantclient folder (it will be named like instantclient_23_9)
        $instantClientFolder = Get-ChildItem -Directory | Where-Object { $_.Name -like "instantclient*" } | Select-Object -First 1
        
        if ($instantClientFolder) {
            # Copy the contents of the instantclient folder to the target directory
            New-Item -ItemType Directory -Path $env:ORACLE_CLIENT_LIB_DIR -Force | Out-Null
            Copy-Item -Path "$($instantClientFolder.FullName)\*" -Destination $env:ORACLE_CLIENT_LIB_DIR -Recurse -Force
        } else {
            Write-Host "Error: Could not find instantclient folder after extraction."
            exit 1
        }
        
    } catch {
        Write-Host "Error: ZIP extraction failed."
        exit 1
    }
    
    # Cleanup
    Set-Location $originalDir
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "Oracle Instant Client installed to: $env:ORACLE_CLIENT_LIB_DIR"
} else {
    Write-Host "Oracle Instant Client already installed at: $env:ORACLE_CLIENT_LIB_DIR"
}

# Check for Python virtual environment
if (-Not (Test-Path "venv")) {
    Write-Host "Creating Python virtual environment..."
    try {
        python -m venv venv
        Write-Host "Virtual environment created!"
        Write-Host ""
    } catch {
        Write-Host "Error: Python not found. Please install Python 3."
        exit 1
    }
}

# Activate virtual environment and install dependencies
Write-Host "Activating virtual environment and installing dependencies..."
& ".\venv\Scripts\Activate.ps1"
python -m pip install --quiet --upgrade pip
python -m pip install --quiet -r requirements.txt

# Cleanup .env file - remove blank lines
if (Test-Path ".env") {
    $content = Get-Content ".env" | Where-Object { $_.Trim() -ne "" }
    $content | Set-Content ".env"
}

Write-Host "Starting the application..."
Write-Host ""
Write-Host "Open your browser to: http://127.0.0.1:5000"
Write-Host ""
python app/app.py