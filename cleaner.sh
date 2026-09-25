#!/usr/bin/env bash

#Starting point
echo  -e "\nPRINTAR ALGUN MENSAJE CHULO EN ALGUN COLOR CHULO DE INFORMACION/BIENVENIDA...\n\n"

#Check the binary claude path
claude_path_bin=$(which claude)

if [[ -e $claude_path_bin ]]; then
	echo -e "$claude_path_bin\n"
else 
	echo "ERROR: There are not claude isntalled in the system" >&2
	exit 1
fi

#Check is there is $CLAUDE_CONFIG_DIR declared as a env variable
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

if [[ ! -d "$claude_dir/projects" ]]; then
	echo "ERROR: $claude_dir/projects does not exist" >&2
	exit 1
fi

echo -e "Claude directory: $claude_dir\n"

#List the project directories inside $claude_dir/projects
mapfile -t dirs < <(find "$claude_dir/projects" -mindepth 1 -maxdepth 1 -type d)

if (( ${#dirs[@]} > 0 )); then
	echo -e "There are this project directories in $claude_dir/projects:"

	PS3="Which directory do you want to clean? "
	select dir in "${dirs[@]}"; do
   		echo -e "You chose: $dir"
    		break
	done

	# Remove session of claude session selected
	
	
	

else
	echo -e "There are no project directories in $claude_dir/projects"
fi

exit 0


