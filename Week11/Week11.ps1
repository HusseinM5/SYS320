# Storyline: Incident Response Toolkit (This is a simple script that looks for important things during an IR case)


# Read user input
$UserPath = Read-Host -Prompt "[*] Enter the location to save results"

# Get running processes and path
function RunningProcesses {

    Write-Host "[+] Get running processes"
    Get-Process | Select-Object ProcessName, Path
}

# Registered services and their executables
function Services {
    Write-Host "[+] List Registered services and their executables"
    Get-WmiObject Win32_Service | Select-Object DisplayName, PathName
}

# Get TcpSockets Connection
function TcpSockets {
    Write-Host "[+] Get TcpSockets Connection"
    Get-NetTCPConnection
}

# Get User Accounts information
function UserAccounts {
    Write-Host "[+] Get User Accounts information"
    Get-WmiObject Win32_UserAccount
}

# Get Netowrk Adapter configuration
function NetworkAdapterConfig {
    Write-Host "[+] Get Netowrk Adapter configuration"
    Get-WmiObject Win32_NetworkAdapterConfiguration
}

# Get the last 10 entries of a created process
# This can help with finding any malicious processes 
function ProcessCreation {
    Write-Host "[+] Get the last 10 entries of a created process"
    Get-EventLog -LogName Security -InstanceId 4688 -Newest 10
}

# List deleted files for the current user
# I think this is important to check the Recycle Bin because many threat actors forget to delete their traces
function RecycleBin {
    Write-Host "[+] Get deleted files for the current user"
    $CurrentUserSID = Get-WmiObject Win32_UserAccount | Where-Object { $_.Name -eq $Env:UserName } | Select-Object -ExpandProperty SID
    Get-ChildItem "C:\`$Recycle.Bin\$CurrentUserSID" -Force
}

# Check if Fodhelper was used to bypass UAC
# This trick is still being used by threat actors to bypass UAC
function Fodhelper {
    
    Write-Host "[+] Check if Fodhelper was used to bypass UAC"

    $registryPath = 'HKCU:\Software\Classes\ms-settings\Shell\Open\command'

    if (Test-Path -Path $registryPath) {
        Write-Host "[+] The registry path exists: $registryPath"
    
        # Display the content of the registry key
        $registryValue = Get-ItemProperty -Path $registryPath
        $registryValue
        } 
    
    else {
    Write-Host "[-] The registry path does not exist: $registryPath"
    }
}

# List Prefetch files
# This is helpful as we can learn what was the last executable that got executed, and when did that happen
function PrefetchFiles {

    Write-Host "[+] Get Prefetch file"
    $prefetchPath = "$env:SystemRoot\Prefetch"

    if (Test-Path -Path $prefetchPath) {
        $prefetchFiles = Get-ChildItem -Path $prefetchPath -File

    if ($prefetchFiles.Count -gt 0) {
        Write-Host "[+] Prefetch files exist in $prefetchPath."
        $prefetchFiles | Select-Object Name, LastWriteTime
    } else {
        Write-Host "[-] No prefetch files found in $prefetchPath."
        }
    } 
    else {
    Write-Host "[-] The prefetch directory does not exist: $prefetchPath."
    }

}

# Calling all the functions
RunningProcesses | Export-Csv -Path "$UserPath\processes.csv" -NoTypeInformation
Services | Export-Csv -Path "$UserPath\services.csv" -NoTypeInformation
TcpSockets | Export-Csv -Path "$UserPath\TcpSockets.csv" -NoTypeInformation
UserAccounts | Export-Csv -Path "$UserPath\UserAccountsInfo.csv" -NoTypeInformation
NetworkAdapterConfig | Export-Csv -Path "$UserPath\NetworkAdapterConfig.csv" -NoTypeInformation
ProcessCreation | Export-Csv -Path "$UserPath\ProcessCreation.csv" -NoTypeInformation
RecycleBin | Export-Csv -Path "$UserPath\RecycleBin.csv" -NoTypeInformation
Fodhelper | Export-Csv -Path "$UserPath\Fodhelper.csv" -NoTypeInformation
PrefetchFiles | Export-Csv -Path "$UserPath\Prefetch.csv" -NoTypeInformation


# Create file hashes
Write-Host "[+] Creating file hashes"
Get-ChildItem -Path $UserPath -Filter *.csv | ForEach-Object {
    $hash = Get-FileHash -Path $_.FullName -Algorithm SHA1
    "$($hash.Hash)  $($hash.Path)" | Out-File -Append -FilePath "$UserPath\checksums.txt"
}

# Create the ZIP file
Write-Host "[+] Creating the ZIP file"
Compress-Archive -Path $UserPath -DestinationPath "$UserPath\Results.zip" -Force

# Create checksum for the ZIP file
Write-Host "[+] Creating checksum for the ZIP file"
$zipChecksum = Get-FileHash -Path "$UserPath\Results.zip" -Algorithm SHA1
"$($zipChecksum.Hash)  Results.zip" | Out-File -FilePath "$UserPath\zipChecksum.txt"
