#!/usr/bin/env bash

#Vars declaration
claude_path_bin=$(which claude)
script_dir=$(dirname "$(realpath "$0")")
claude_dirs_file="$script_dir/claude_directories"
PS3="Which directory do you want to clean? "

#Starting point
echo  -e "\nPRINTAR ALGUN MENSAJE CHULO EN ALGUN COLOR CHULO DE INFORMACION/BIENVENIDA...\n\n"

#Check the binary claude path
if [[ -e $claude_path_bin ]]; then
	echo -e "$claude_path_bin\n"
else 
	echo "ERROR: There are not claude isntalled in the system"
	exit
fi

#Check if there are any .claude directory in $HOME
find / -name .claude > "$claude_dirs_file" 2>/dev/null

if [[ -s claude_directories ]]; then 
	echo -e "There are this .claude directories in the system:"
	
	# Print .claude directories path
	mapfile -t dirs < "$claude_dirs_file"
	select dir in "${dirs[@]}"; do
   		echo -e "You chose: $dir"
    		break
	done

	# Remove session of claude session selected
	
	
	

else 
	echo -e "There are no .claude directories in you system"
fi

exit


