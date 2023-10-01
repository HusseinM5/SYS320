#!/bin/bash
 
# Storyline: Script to perform local security checks based on CIS Benchmark
 
function checks() {
        if [[ $2 != $3 ]]
        then
 
                echo -e "\e[31mThe $1 is not compliant. The current policy should be set to: $2, but the current value is: $3.\nHere is the Remediation:\n\n$4 \n\e[0m"
 
        else
 
                echo -e "\e[32mThe $1 is compliant. Current Value $3. \n\e[0m"
 
        fi
}
 
 
# Ensure IP forwarding is disabled
checks "IP Forwarding" "0" "$(sysctl -n net.ipv4.ip_forward)" "Set net.ipv4.ip_forward to 0 in /etc/sysctl.conf"
 
# Ensure ICMP redirects are not accepted
checks "ICMP Redirects" "0" "$(sysctl -n net.ipv4.conf.all.accept_redirects)" "Set net.ipv4.conf.all.accept_redirects to 0 in /etc/sysctl.conf"
 
# Ensure permissions on /etc/crontab are configured
checks "Permissions on /etc/crontab" "600" "$(stat -c %a /etc/crontab)" "chmod 600 /etc/crontab"
 
# Ensure permissions on /etc/cron.hourly are configured
checks "Permissions on /etc/cron.hourly" "700" "$(stat -c %a /etc/cron.hourly)" "chmod 700 /etc/cron.hourly"
 
# Ensure permissions on /etc/cron.daily are configured
checks "Permissions on /etc/cron.daily" "700" "$(stat -c %a /etc/cron.daily)" "chmod 700 /etc/cron.daily"
 
# Ensure permissions on /etc/cron.weekly are configured
checks "Permissions on /etc/cron.weekly" "700" "$(stat -c %a /etc/cron.weekly)" "chmod 700 /etc/cron.weekly"
 
# Ensure permissions on /etc/cron.monthly are configured
checks "Permissions on /etc/cron.monthly" "700" "$(stat -c %a /etc/cron.monthly)" "chmod 700 /etc/cron.monthly"
 
# Ensure permissions on /etc/passwd are configured
checks "Permissions on /etc/passwd" "644" "$(stat -c %a /etc/passwd)" "chmod 644 /etc/passwd"
 
# Ensure permissions on /etc/shadow are configured
checks "Permissions on /etc/shadow" "640" "$(stat -c %a /etc/shadow)" "chmod 640 /etc/shadow"
 
# Ensure permissions on /etc/group are configured
checks "Permissions on /etc/group" "644" "$(stat -c %a /etc/group)" "chmod 644 /etc/group"
 
# Ensure permissions on /etc/gshadow are configured
checks "Permissions on /etc/gshadow" "640" "$(stat -c %a /etc/gshadow)" "chmod 640 /etc/gshadow"
 
# Ensure permissions on /etc/passwd- are configured
checks "Permissions on /etc/passwd-" "644" "$(stat -c %a /etc/passwd-)" "chmod 644 /etc/passwd-"
 
# Ensure permissions on /etc/shadow- are configured
checks "Permissions on /etc/shadow-" "640" "$(stat -c %a /etc/shadow-)" "chown 640 /etc/shadow-"
 
# Ensure permissions on /etc/group- are configured
checks "Permissions on /etc/group-" "644" "$(stat -c %a /etc/group-)" "chmod 644 /etc/group-"
 
# Ensure permissions on /etc/gshadow- are configured
checks "Permissions on /etc/gshadow-" "640" "$(stat -c %a /etc/gshadow-)" "chmod 640 /etc/gshadow-"
 
# Ensure no legacy "+" entries exist in /etc/passwd
checks "Legacy '+' entries in /etc/passwd" "" "$(grep '^+:' /etc/passwd)" "Edit /etc/passwd and remove any lines starting with '+'"
 
# Ensure no legacy "+" entries exist in /etc/shadow
checks "Legacy '+' entries in /etc/shadow" "" "$(sudo grep '^+:' /etc/shadow)" "Edit /etc/shadow and remove any lines starting with '+'"
 
# Ensure no legacy "+" entries exist in /etc/group
checks "Legacy '+' entries in /etc/group" "" "$(grep '^+:' /etc/group)" "Edit /etc/group and remove any lines starting with '+'"
 
# Ensure root is the only UID 0 account
checks "UID 0 accounts in /etc/passwd" "root" "$(awk -F: '($3 == 0) {print $1}' /etc/passwd)" "Remove any accounts with a UID set to 0, except the root account"