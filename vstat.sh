#!/bin/bash

# This Linux program aims to present the user with a number of useful metrics or information about their system

EnvOption1(){
	# Function to print some commonly used environment variables
	echo ""
	echo "You are logged in as: $USER. You are using the shell: $SHELL."
	echo "The current working directory is: $PWD."
	echo "You are using the $DESKTOP_SESSION desktop environment"
	echo ""
}

EnvOption2(){
	# Function to call the environment variables for the current terminal session, and to print these to the user on demand
	read -p "Please enter what environment variable you want (e.g.: HOME, PATH, PWD) : " env_var
	
	if [[ -z "${!env_var}" ]]; then # A loop to check whether the environment variable exists and print it, if it does
		echo "The environment variable '$env_var' either does not exist or is currently empty."
	else 
		echo "The value of '$env_var' is: ${!env_var}"
	fi
	read -p "Press Enter to return to the main menu"
}

HardwarePrint(){
	# Function to print important hardware metrics or information about their system
	uptime=$(cut -d ' ' -f1 /proc/uptime | cut -d '.' -f1) 
	
	# Convert the uptime value from seconds, into  days and left over hours, minutes. 86400 = 60*60*24.
	local uptimeDay=$((uptime / 86400))
	local uptimeHour=$(((uptime % 86400) / 3600))
	local uptimeMin=$(((uptime % 3600) / 60))
	echo ""
	printf "Your device has been up for $uptimeDay days, $uptimeHour hours, and $uptimeMin minutes"
	echo ""
	
	cpuName=$(grep -m 1 'model name' /proc/cpuinfo)
	cpuCoreCount=$(grep -c ^'processor' /proc/cpuinfo)
	

	echo ""
	printf "$cpuName $cpuCoreCount"
	printf "%-20s %-20s\n" "Item" "Description"
	echo "---------------------------------------"
	echo ""
}

UsersGroups(){
	# Function to call the /etc/passwd and /etc/groups files, which is present on most Linux operating systems. This function assumes that ALL service accounts have a UID threshold of below 1000
	echo ""
	printf "%-20s %-20s %-20s %-20s\n" "Username" "Groups" "Home directory" "Account type"
	echo "---------------------------------------------------------------------------------"
	while IFS=":" read -r username _ uid gid _ home shell; do
		if [[ $uid -lt 1000 || "$shell" == "/usr/sbin/nologin" || "$shell" == "/bin/false" ]]; then 
			account_type="Service Account"
		else
			account_type="User Account"
		fi

		# Retrieve group information
		groups=$(id -Gn "$username" 2>/dev/null | tr ' ' ',')

		# Print output and user details
		printf "%-20s %-20s %-20s %-20s\n" "$username" "$groups" "$home" "$account_type"	
	done < /etc/passwd
	echo ""
}

MenuOption1(){
	# Function to define when the user selects Option 1 in the main menu. This option handles and prints the user's envrionment variables
	read -p "Select 1 to print commonly used values. Select 2 to find and print values: " option1
		# Call functions based on user input
		case $option1 in
			1) EnvOption1 ;;
			2) EnvOption2 ;;
			*) echo "Invalid choice, try again" ;;
		esac
	read -p "Press Enter to return to the main menu"
}

MenuOption2(){
	# Function to define when user selects Option 2 in main menu
	read -p "Select 1 to list the hardware being used on this device, or print interesting hardware metrics: "
		case $REPLY in
			1) HardwarePrint ;;
			*) echo "Invaild choice, try again" ;;
		esac
	read -p "Press Enter to return to the main menu"
}

MenuOption3(){
	echo "You chose option 3"
	read -p "Press Enter to return to the main menu"
}

MenuOption4(){
	UsersGroups
	read -p "Press Enter to return to the main menu"
}

echo ""
echo "Welcome to vstat. You are logged in as $USER"

while true; do
# Display menu and read input
echo ""
echo "------ Main Menu ------"
echo "1. Environment variables"
echo "2. Hardware stats"
echo "3. Software stats"
echo "4. Users and groups"
echo "5. Exit"
echo ""

read -p "Enter your choice: " choice
	# Call functions based on user input
	case $choice in 
		1) MenuOption1 ;;
		2) MenuOption2 ;;
		3) MenuOption3 ;;
		4) MenuOption4 ;;
		5) break ;;
		*) echo "Invalid choice, try again" ;;
	esac

done
