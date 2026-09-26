# Fake Claude Code data for the demo GIF. It is sourced by demo.tape, so it
# can change HOME, PATH and PS1 of the recording shell.
# Nothing outside /tmp/ccleaner-demo is touched.

repo_dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/..
demo_home=/tmp/ccleaner-demo
claude_dir="$demo_home/.claude"

rm -rf "$demo_home"
mkdir -p "$claude_dir/sessions" "$demo_home/bin"

# new_session <project> <session id> <title> <transcript size> <modified>
new_session() {
	local project_dir="$claude_dir/projects/$1" id="$2"

	mkdir -p "$project_dir/memory" "$claude_dir/file-history/$id" "$claude_dir/session-env/$id"
	{
		echo "{\"type\":\"ai-title\",\"aiTitle\":\"$3\",\"sessionId\":\"$id\"}"
		head -c "$4" /dev/zero | tr '\0' 'x'
	} > "$project_dir/$id.jsonl"
	head -c 24K /dev/zero > "$claude_dir/file-history/$id/3f9a1c07b2e4d8a6@v1"
	touch -d "$5" "$project_dir/$id.jsonl"
}

new_session -home-demo-webapp  4b6f2c1e-8a3d-4e7b-9c05-1d2e3f4a5b6c "Add login form validation"      1300K "2 hours ago"
new_session -home-demo-webapp  9e8d7c6b-5a4f-4e3d-8c2b-1a0f9e8d7c6b "Fix flaky checkout tests"       640K  "3 days ago"
new_session -home-demo-webapp  2a3b4c5d-6e7f-4a8b-9c0d-1e2f3a4b5c6d "Refactor the API client"        2100K "12 days ago"
new_session -home-demo-dotfiles 7c1d2e3f-4a5b-4c6d-8e7f-9a0b1c2d3e4f "Configure Neovim LSP"          480K  "5 days ago"
new_session -home-demo-scripts 5f6e7d8c-9b0a-4c1d-8e2f-3a4b5c6d7e8f "Write a backup script with rsync" 350K "20 days ago"

# The newest session is running right now
echo '{"sessionId":"4b6f2c1e-8a3d-4e7b-9c05-1d2e3f4a5b6c"}' > "$claude_dir/sessions/4242.json"

ln -s "$(realpath "$repo_dir/ccleaner.sh")" "$demo_home/bin/ccleaner"

export HOME="$demo_home"
export PATH="$demo_home/bin:$PATH"
export PS1='\[\e[1;34m\]~\[\e[0m\] \[\e[1;32m\]$\[\e[0m\] '
unset CLAUDE_CONFIG_DIR
cd "$HOME" || return
