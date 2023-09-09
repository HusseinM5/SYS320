#!/bin/bash

# Run the "ip addr" command and filter the output to extract only my IP address
# I am using awk to look for the line that starts with "inet" and then I am printing the second field. Lastly I am just filtering out "127.0.0.1"

ip_address=$(ip addr | awk '/inet / {print $2}' | grep -v "127.0.0.1")

# Print the extracted IP address
echo "My IP Address is: $ip_address"
