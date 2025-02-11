# Check and install OpenSSH Server
Write-Host "Checking for OpenSSH Server installation..." -ForegroundColor Green
$sshServer = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

if ($sshServer.State -eq "NotPresent") {
    Write-Host "OpenSSH Server not installed. Installing now..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Write-Host "OpenSSH Server installed successfully." -ForegroundColor Green
} else {
    Write-Host "OpenSSH Server is already installed." -ForegroundColor Green
}

# Ensure the OpenSSH Service is running and set to start automatically
Write-Host "Configuring OpenSSH Server service..." -ForegroundColor Green
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd
Write-Host "OpenSSH Server service is running and set to start automatically." -ForegroundColor Green

# Enable autologin with enhanced security
Write-Host "Preparing to enable autologin..." -ForegroundColor Green

# Registry path for Winlogon settings
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Check if autologin is already enabled
$currentAutologin = Get-ItemProperty -Path $regPath -Name "AutoAdminLogon" -ErrorAction SilentlyContinue

if ($currentAutologin -and $currentAutologin.AutoAdminLogon -eq "1") {
    Write-Host "Autologin is already enabled. Updating credentials..." -ForegroundColor Yellow
} else {
    Write-Host "Autologin is not enabled. Configuring now..." -ForegroundColor Green
}

# Prompt user for credentials
$username = Read-Host "Enter the username for autologin"
$password = Read-Host "Enter the password for autologin" -AsSecureString

# Convert secure password to plaintext
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
)

try {
    # Set registry keys for autologin
    Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
    Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value $username
    Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $plainPassword

    Write-Host "Autologin has been successfully enabled for user: $username" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to configure autologin." -ForegroundColor Red
} finally {
    # Cleanup sensitive data from memory
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    )
    $plainPassword = $null
    $password = $null
}

Write-Host "Script execution completed." -ForegroundColor Green
