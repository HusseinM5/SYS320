#Storyline: Script that list running/stopped/all services based on user choice


while ($true) {
    # Read user input
    $inputOption = Read-Host "Select one of the following options to view system services 'all', 'stopped', 'running', or 'quit'"

    # Switch statment based on user choice
    switch ($inputOption) {
        'all' {
            # Dispaly all services
            Get-Service | Select-Object DisplayName, Status | Format-Table
        }
        'stopped' {
            # Display Stopped services
            Get-Service | Select-Object DisplayName, Status | Where-Object {$_.Status -eq 'Stopped'} | Format-Table
        }
        'running' {
            # Display Running services
            Get-Service | Select-Object DisplayName, Status | Where-Object {$_.Status -eq 'Running'} | Format-Table
        }
        'quit' {
            # quits the script
            Write-Host
            Write-Host "[+] Quitting the script"
            exit
        }
        default {
            # Invalid option message for unknown value
            write-Host
            Write-Host "[-] Invalid option. Please select 'all', 'stopped', 'running', or 'quit' to exit the script."
        }
    }
}
