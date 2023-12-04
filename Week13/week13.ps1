# Storyline: A script to parse threat intel (creating iptables and Windows firewall ruleset)


# Array of websites containing threat intell
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules', 'https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

# loop through the URLs for the rules list
foreach ($u in $drop_urls){

    # Extract the filename
    $temp = $u.split("/")

    # The last element in the array plucked off is the filename
    $file_name = $temp[4]

    if (Test-Path $file_name){
        
        continue

    } else {
        # Download the rules list
        Invoke-WebRequest -Uri $u -OutFile $file_name
    }
    

}

# Array containing the filename
$input_paths = @('.\compromised-ips.txt', 'emerging-botcc.rules')

# Extract IP Addresses using Regex
$regx =  '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP Addresses to a temporary IP list
Select-String -Path $input_paths -Pattern $regx | `
ForEach-Object { $_.Matches } | `
ForEach-Object { $_.Value } | Sort-Object | Get-Unique | `
Out-File -FilePath "ips-bad.tmp"

# iptables syntax
(Get-Content -Path ".\ips-bad.tmp") | % `
{ $_ -replace "^", "iptables -A INPUT -s " -replace "$", " -j DROP" } | `
Out-File -FilePath "iptables.bash"

# Windows Firewall
(Get-Content -Path ".\ips-bad.tmp") | % `
{ $_ -replace "^", "netsh advfirewall firewall add rule name='BLOCK BAD IPS' dir=in action=block remoteip="} | `
Out-File -FilePath "windows-firewall.ps1"
