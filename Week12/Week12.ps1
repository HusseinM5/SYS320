#Storyline: Script to connect and run remote commands through SSH


# Login to a remote SSH server
$login = New-SSHSession -ComputerName '192.168.67.158' -Credential (Get-Credential)
$SessionID = $login.SessionId

while ($True) {

    # Prompt to run commands
    $cmd = read-host -prompt "[+] Enter a command"

    # Check if the user wants to exit
    if ($cmd -eq "exit"){
        Write-Host
        Write-Host "[!] Closing SSH session"
        Write-Host

        # Remove the used SSH session
        Remove-SSHSession $SessionID
        exit
    }
    
    Write-Host ""

    # Run the command on remote SSH server
    (Invoke-SSHCommand -index $SessionID $cmd).Output
    Write-Host ""

}
