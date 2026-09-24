#!/usr/bin/env bash

#Vars declaration
claude_path_bin=$(which claude)

#Starting point
echo  -e "\nPRINTAR ALGUN MENSAJE CHULO EN ALGUN COLOR CHULO DE INFORMACION/BIENVENIDA...\n\n"

#Check the binary claude path
if [[ -e $claude_path_bin ]]; then
	echo $claude_path_bin
else 
	echo "ERROR: There are not claude isntalled in the system"
fi

#Check if there are any .claude directory in $HOME
find $HOME --name .claude 


exit


