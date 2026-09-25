#!/usr/bin/env bash

#Colors (only when the output is a terminal, so they don't end up in files)
if [[ -t 1 ]]; then
	bold=$'\e[1m'
	dim=$'\e[2m'
	red=$'\e[31m'
	green=$'\e[32m'
	yellow=$'\e[33m'
	cyan=$'\e[36m'
	reset=$'\e[0m'
fi

#Print an error message in red to stderr
error() {
	echo "${red}${bold}ERROR:${reset} $1" >&2
}

#Print how to use the script
usage() {
	echo "${bold}Usage:${reset} $(basename "$0") [--dry-run] [--help]"
	echo
	echo "  --dry-run   Show what would be deleted without deleting anything"
	echo "  -h, --help  Show this help"
}

#Parse the arguments
dry_run=false

for arg in "$@"; do
	case "$arg" in
		--dry-run)
			dry_run=true
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			error "Unknown option: $arg"
			echo >&2
			usage >&2
			exit 1
			;;
	esac
done

#Starting point
echo
echo "${cyan}${bold}  Claude Code session cleaner${reset}"
echo "${dim}  Delete Claude Code sessions and all their data${reset}"
echo

#Check the binary claude path
claude_path_bin=$(command -v claude)

if [[ -z $claude_path_bin ]]; then
	error "Claude Code is not installed on this system"
	exit 1
fi

#Check is there is $CLAUDE_CONFIG_DIR declared as a env variable
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

if [[ ! -d "$claude_dir/projects" ]]; then
	error "$claude_dir/projects does not exist"
	exit 1
fi

echo "  ${dim}Claude binary:${reset}    $claude_path_bin"
echo "  ${dim}Claude directory:${reset} $claude_dir"

if [[ $dry_run == true ]]; then
	echo
	echo "  ${yellow}${bold}DRY-RUN:${reset} ${yellow}nothing will be deleted${reset}"
fi

#List the project directories inside $claude_dir/projects
mapfile -t dirs < <(find "$claude_dir/projects" -mindepth 1 -maxdepth 1 -type d | sort)

if (( ${#dirs[@]} == 0 )); then
	echo
	echo "There are no projects in $claude_dir/projects"
	exit 0
fi

# Keep only the project name (the part after the last /)
names=()
for dir in "${dirs[@]}"; do
	names+=("${dir##*/}")
done

echo
echo "${bold}Projects${reset}"

PS3=$'\n'"${bold}Choose a project:${reset} "
select name in "${names[@]}" "Quit"; do
	if [[ $name == "Quit" ]]; then
		echo "Bye!"
		exit 0
	elif [[ -z $name ]]; then
		echo "${yellow}Invalid option: $REPLY${reset}" >&2
		continue
	fi

	# $REPLY is the number typed, arrays start at 0
	project_dir="${dirs[REPLY - 1]}"
	break
done

# select also ends with Ctrl+D (end of input) without choosing anything
if [[ -z $project_dir ]]; then
	echo
	exit 0
fi

#List the sessions of the chosen project (one .jsonl file per session)
shopt -s nullglob
session_files=("$project_dir"/*.jsonl)

if (( ${#session_files[@]} == 0 )); then
	echo
	echo "There are no sessions in ${bold}$name${reset}"
	exit 0
fi

# Files of the sessions that are running right now
active_files=("$claude_dir"/sessions/*.json)

# Return success (0) if the session ID in $1 is running right now
is_active() {
	(( ${#active_files[@]} > 0 )) && grep -q "\"sessionId\":\"$1\"" "${active_files[@]}"
}

session_ids=()
labels=()
for file in "${session_files[@]}"; do
	# The session ID is the file name without the .jsonl extension
	id="${file##*/}"
	id="${id%.jsonl}"

	modified=$(date -r "$file" '+%Y-%m-%d %H:%M')
	size=$(du -h "$file" | cut -f1)

	title=""
	if [[ -f "$project_dir/$id/custom-title.json" ]]; then
		title=$(grep -o '"customTitle":"[^"]*"' "$project_dir/$id/custom-title.json" | cut -d'"' -f4)
	fi
	if [[ -z $title ]]; then
		title="${dim}(no title)${reset}"
	fi

	if is_active "$id"; then
		title+=" ${green}(active)${reset}"
	fi

	session_ids+=("$id")
	printf -v label '%s  %5s  %s  %s' "$modified" "$size" "${dim}${id:0:8}${reset}" "$title"
	labels+=("$label")
done

echo
echo "${bold}Sessions of $name${reset}"

PS3=$'\n'"${bold}Choose a session:${reset} "
select label in "${labels[@]}" "Quit"; do
	if [[ $label == "Quit" ]]; then
		echo "Bye!"
		exit 0
	elif [[ -z $label ]]; then
		echo "${yellow}Invalid option: $REPLY${reset}" >&2
		continue
	fi

	session_id="${session_ids[REPLY - 1]}"
	break
done

if [[ -z $session_id ]]; then
	echo
	exit 0
fi

#Safety check 1: the session ID must be a real UUID (8-4-4-4-12 hex characters)
uuid_regex='^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'

if [[ ! $session_id =~ $uuid_regex ]]; then
	echo
	error "'$session_id' is not a valid session ID"
	exit 1
fi

#Safety check 2: never delete a session that is running right now
if is_active "$session_id"; then
	echo
	error "Session $session_id is running right now. Close it before deleting it."
	exit 1
fi

#Collect every path that belongs to the chosen session
# The globs (*) only expand to files that exist, thanks to nullglob
candidates=(
	"$project_dir/$session_id.jsonl"
	"$project_dir/$session_id"
	"$project_dir/$session_id".jsonl.superseded-*
	"$project_dir/$session_id".orphaned-*.jsonl
	"$claude_dir/file-history/$session_id"
	"$claude_dir/session-env/$session_id"
	"$claude_dir/debug/$session_id"*
	"$claude_dir/image-cache/$session_id"
	"$claude_dir/uploads/$session_id"
	"$claude_dir/tasks/$session_id"
)

# Keep only the paths that really exist
to_delete=()
for path in "${candidates[@]}"; do
	if [[ -e $path ]]; then
		to_delete+=("$path")
	fi
done

if (( ${#to_delete[@]} == 0 )); then
	echo
	echo "There is nothing to delete for session $session_id"
	exit 0
fi

#Safety check 3: every path must be inside $claude_dir, belong to this session
# and never be a memory directory
for path in "${to_delete[@]}"; do
	if [[ $path != "$claude_dir/"* || $path != *"$session_id"* || $path == */memory* ]]; then
		error "Refusing to delete unexpected path: $path"
		exit 1
	fi
done

echo
echo "${bold}Files of session ${cyan}$session_id${reset}"
echo

for path in "${to_delete[@]}"; do
	size=$(du -sh "$path" | cut -f1)
	# Show the path relative to $claude_dir so it is shorter
	printf '  %6s  %s\n' "$size" "${path#"$claude_dir"/}"
done

total=$(du -shc "${to_delete[@]}" | tail -n 1 | cut -f1)
echo
echo "  ${bold}Total:${reset} $total in ${#to_delete[@]} paths"

#In dry-run mode stop here, before asking anything
if [[ $dry_run == true ]]; then
	echo
	echo "${yellow}DRY-RUN: nothing was deleted${reset}"
	exit 0
fi

#Ask for confirmation (anything but y/Y, or Ctrl+D, means no)
echo
read -rp "${bold}Delete these ${#to_delete[@]} paths? [y/N]${reset} " answer || answer=""

if [[ $answer != [yY] ]]; then
	echo "Nothing was deleted"
	exit 0
fi

#Remove the selected session
# -- marks the end of the options, so no path is read as an option of rm
if rm -rf -- "${to_delete[@]}"; then
	echo
	echo "${green}${bold}Session $session_id deleted${reset} ${dim}($total freed)${reset}"
else
	error "Some paths could not be deleted"
	exit 1
fi

exit 0
