#Storyline: Exploring process, services, and WMI Objects

# Export services and process to CSV file
$CPATH = "C:\Users\IEUser\Desktop"
Get-Process | Select-Object ProcessName | Export-Csv -Path "$CPATH\processes.csv" -NoTypeInformation
Get-Service | Select-Object ServiceName | Export-Csv -Path "$CPATH\services.csv" -NoTypeInformation
Write-Host "[+] CSV files saved to $CPATH"

# Start and stop calculator process
Write-Host "[+] Starting calc"
Start-Process calc
sleep 2
Write-Host "[+] Stopping calc"
Stop-Process -Name calculator

# Extract DHCPServer, IPAddress, DNSServer using WMI Objects
Write-Host "[+] Netowrk Information:"
Get-WmiObject Win32_NetworkAdapterConfiguration | Select-Object ServiceName, DHCPServer, IPAddress, DNSServerSearchOrder
