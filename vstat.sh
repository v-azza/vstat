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
	echo ""
	read -p "Please enter what environment variable you want (e.g.: HOME, PATH, PWD) : " env_var
	
	if [[ -z "${!env_var}" ]]; then # A loop to check whether the environment variable exists and print it, if it does
		echo "The environment variable '$env_var' either does not exist or is currently empty."
	else
		echo "The value of '$env_var' is: ${!env_var}"
	fi
	echo ""
}

HardwarePrint(){
	# Function to print important hardware metrics or information about their system
	uptime=$(cut -d ' ' -f1 /proc/uptime | cut -d '.' -f1) 
	
	# Convert the uptime value from seconds, into  days and left over hours, minutes. 86400 = 60*60*24.
	local uptimeDay=$((uptime / 86400))
	local uptimeHour=$(((uptime % 86400) / 3600))
	local uptimeMin=$(((uptime % 3600) / 60))
	echo ""
	printf "This device has been up for $uptimeDay days, $uptimeHour hours, and $uptimeMin minutes"
	echo ""
	
	# Applying hardware stats from various system files into variables. Carry out text manipulation to get it into a readable format
	cpuName=$(grep -m 1 'model name' /proc/cpuinfo | cut -d ':' -f2 | xargs)
	cpuCoreCount=$(awk '/cpu cores/ {cores=$NF} /physical id/ {cpus[$NF]=1} END {print cores * length(cpus)}' /proc/cpuinfo) 
	cpuThreadCount=$(grep -c ^'processor' /proc/cpuinfo)
	ramSizeTotal=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
	ramAvailable=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
	gpu=$(lspci | grep -i 'vga\|3d' | cut -d ':' -f3 | xargs | sed 's/(rev [^)]*)//')
	slashDiskUtil=$(df -h --output=source,size,used,avail,pcent / | tail -n +2 | awk '{print $5}')


	# Base 2 coversions of KB into GB. Using bc floating point arithmetic so I can be more accurate and include 2 decimal places
	ramSizeTotalGB=$(echo "scale=2; $ramSizeTotal/1048576" | bc)
	ramAvailableGB=$(echo "scale=2; $ramAvailable/1048576" | bc)
	
	echo ""
	printf "============== Hardware Information ==============\n"
	printf "CPU Model			: %s\n" "$cpuName"
	printf "CPU Cores			: %s\n" "$cpuCoreCount"
	printf "CPU Threads			: %s\n" "$cpuThreadCount"
	printf "Total RAM Installed (GiB)	: %s\n" "$ramSizeTotalGB"
	printf "Total RAM Available (GiB)	: %s\n" "$ramAvailableGB"
	printf "GPU Model Installed		: %s\n" "$gpu"
	printf "Disk space utilised by / filesystem	: %s\n" "$slashDiskUtil"
	echo ""
}

BatteryPrint(){
	# Function to print battery stats, only when a check to see if upower is present has passed
	echo ""
	if command -v upower &>/dev/null && upower -e | grep -qi 'BAT'; then
		batteryStats=$(upower -i $(upower -e | grep -i BAT))
		echo "$batteryStats"
	else
		echo "Upower command is not present on your system, or no battery detected."
	fi
	echo ""
}

SoftwareOS(){
	# Function to present OS name, Kernel version and software stats
	OSname=$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)
	kernelVersion=$(uname -r)
		

	echo ""
	printf "============== Software & OS Information ==============\n"
	printf "OS Name 			: %s\n" "$OSname"
	printf "Kernel Version			: %s\n" "$kernelVersion"
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

DiskUtilsPrint(){
	# Function to print information about the disk being used, their types and utilisation
	echo ""
	dfOutput=$(df -h)
	echo "$dfOutput"
	echo ""
}

TargetDisk(){
	echo "This is the TargetDisk function"
	read -p "Type the name of the filesystem you wish to investigate: " FILESYSTEM
		# Call the name of the filesystem
		case $FILESYSTEM in
			1) SelectedDiskInfo ;;
			*) echo "Invalid choice, try again" ;;
		esac
	echo ""
}

Network(){
	#Function to print information about the network in use, and any other relevant metrics
	echo "This is the Network function"
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
	read -p "Select 1 to list the hardware being used on this device, or print interesting hardware metrics. Select 2 to print battery statistcs: " REPLY
		case $REPLY in
			1) HardwarePrint ;;
			2) BatteryPrint ;;
			*) echo "Invaild choice, try again" ;;
		esac
	read -p "Press Enter to return to the main menu"
}

MenuOption3(){
	SoftwareOS
	read -p "Press Enter to return to the main menu"
}

MenuOption4(){
	UsersGroups
	read -p "Press Enter to return to the main menu"
}

MenuOption5(){
	#Function to define when user selects Option 5 in main menu
	read -p "Select 1 to print df -h output. Select 2 to print information regarding a specific filesystem: " REPLY
		case $REPLY in
			1) DiskUtilsPrint ;;
			2) TargetDisk ;;
			*) echo "Invalid choice, try again" ;;
		esac
	read -p "Press Enter to return to the main menu"
}

MenuOption6(){
	#Function to define when user selects Option 6 in main menu
	Network
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
echo "5. Disk utilities"
echo "6. Network information"
echo "7. Exit"
echo ""

read -p "Enter your choice: " choice
	# Call functions based on user input
	case $choice in 
		1) MenuOption1 ;;
		2) MenuOption2 ;;
		3) MenuOption3 ;;
		4) MenuOption4 ;;
		5) MenuOption5 ;;
		6) MenuOption6 ;;
		7) break ;;
		*) echo "Invalid choice, try again" ;;
	esac
done
