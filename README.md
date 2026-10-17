# briefWatcher

A launchd agent that turns Muse prospect briefs (`~/Projects/freelance/<prospect>/brief.md`)
into interactive Claude Code `/pitch-site` sessions in Ghostty.

Docs: https://10elizabethbell.github.io/briefWatcher/

- `brief-watcher.sh`: the watcher. Install with
  `ln -s "$PWD/brief-watcher.sh" ~/.local/bin/brief-watcher.sh`
- `com.ellie.brief-watcher.plist`: the launchd agent. Copy it to `~/Library/LaunchAgents/`, then
  `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.ellie.brief-watcher.plist`
