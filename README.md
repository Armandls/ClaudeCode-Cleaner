# ClaudeCode Cleaner

An interactive Bash script to delete [Claude Code](https://code.claude.com) sessions,
together with all the data Claude Code keeps for each one.

Claude Code already removes sessions older than `cleanupPeriodDays` (30 days by
default). This script is for deleting a specific session **now**, chosen by hand.

![Choosing a project and a session, reviewing its files and deleting it](demo/demo.gif)

The demo uses fake data. To record it again: `vhs demo/demo.tape`
(needs [VHS](https://github.com/charmbracelet/vhs)).

## Requirements

- Bash 4 or newer
- Claude Code installed (`claude` in your `PATH`)
- GNU coreutils (`date -r`, `du`, `find`)

## Installation

```bash
git clone https://github.com/Armandls/ClaudeCode-Cleaner.git
cd ClaudeCode-Cleaner
chmod +x ccleaner.sh
```

## Usage

```bash
./ccleaner.sh            # choose a session and delete it
./ccleaner.sh --dry-run  # show what would be deleted, delete nothing
./ccleaner.sh --help     # show the help
```

1. Choose a project. Only projects that still have sessions are listed.
2. Choose a session. Each one shows its last modified date, size, short ID and
   title. Sessions that are running right now are marked `(active)`.
3. Review the list of paths that belong to that session and their total size.
4. Confirm with `y`. Any other answer, or `Ctrl+D`, deletes nothing.

After each action you go back to the sessions menu. Use `Back` to return to the
projects menu and `Quit` to exit.

## What gets deleted

All paths are relative to the Claude directory. Only the ones that exist are
deleted.

| Path | Contents |
|---|---|
| `projects/<project>/<id>.jsonl` | Conversation transcript |
| `projects/<project>/<id>/` | Subagent transcripts, large tool outputs, session title |
| `projects/<project>/<id>.jsonl.superseded-*`, `<id>.orphaned-*.jsonl` | Older copies of the transcript |
| `file-history/<id>/` | File snapshots used for checkpoint restore |
| `session-env/<id>/` | Session environment metadata |
| `debug/<id>*`, `image-cache/<id>/`, `uploads/<id>/`, `tasks/<id>/` | Only present if you used those features |

### Last session of a project

When you delete the last session of a project, the whole project directory
(`projects/<project>/`) is deleted too, including its `memory/` and any other
file inside it. The list shown before the confirmation warns you about it.

While a project still has other sessions, its `memory/` is never touched: it is
shared by all of them.

## What is never touched

- `history.jsonl`: the global prompt history
- `sessions/`, `.credentials.json`, `jobs/`, `daemon/` and any other Claude Code state
- Files that are not named after a session (`paste-cache/`, `shell-snapshots/`,
  `plans/`, `backups/`). Claude Code's own cleanup takes care of them.

## Safety checks

Before deleting anything, the script checks that:

- the session ID is a valid UUID;
- the session is not running right now (it is not listed in `sessions/*.json`);
- every path is inside the Claude directory, contains the session ID and is not
  a `memory` directory;
- the whole project directory is only deleted when it is the last session, and
  only if it is exactly `projects/<project>`.

The script checks again that the session is not running right before deleting it.

## Custom Claude directory

The script uses `$CLAUDE_CONFIG_DIR` if it is set, and `~/.claude` otherwise.
This also makes it easy to try the script on a copy of your data:

```bash
mkdir -p /tmp/claude-test
cp -r ~/.claude/{projects,file-history,session-env,sessions} /tmp/claude-test/
CLAUDE_CONFIG_DIR=/tmp/claude-test ./ccleaner.sh
```

## License

[MIT](LICENSE)
