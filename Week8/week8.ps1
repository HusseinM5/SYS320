# Storyline: Review the Security Event Log

# List all the available Windows Event Logs
Get-EventLog -list
Write-Host ""

# Create a few prompts to allow the user to specify the Log to view, the keyword/phrase to search for, and a location to save the file in
$readLog = Read-host -Prompt "[*] Please select a log to review from the list above"
$SearchW = Read-Host -Prompt "[*] Enter what you want to look for in the Logs"
$myDir = Read-Host -Prompt "[*] Enter a Directory to save the csv file in"

# Save the results into a csv file
Get-EventLog -LogName $readLog | where {$_.Message -ilike "*$SearchW*"} |export-csv -NoTypeInformation -Path "$myDir\$readLog.csv"

# Inform the user about the file location
Write-Host ""
Write-Host "[+] The output was saved to $myDir\$readLog.csv"
