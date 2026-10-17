#!/bin/bash
# Picks up Muse briefs: for each ~/Projects/freelance/<prospect>/BRIEF.md not yet
# claimed, opens a Ghostty tab in that folder running an interactive
# `claude "/pitch-site ..."` session. Run by launchd (com.ellie.brief-watcher).
set -u

ROOT="$HOME/Projects/freelance"
CLAIM=".claude-claimed"   # marker: this brief has been handed to Claude
SETTLE=60                 # seconds a brief must sit unchanged (Muse may still be writing)
LOCK="${TMPDIR:-/tmp}/brief-watcher.lock"
PROMPT="/pitch-site Muse dropped BRIEF.md in this folder. Build the pitch site from it."

log() { echo "$(date '+%F %T') $*"; }

# One run at a time (WatchPaths and StartInterval can fire together).
mkdir "$LOCK" 2>/dev/null || { log "another run holds $LOCK; skipping"; exit 0; }
trap 'rmdir "$LOCK"' EXIT

open_tab() {
  /usr/bin/osascript - "$1" "$2" <<'APPLESCRIPT'
on run argv
  tell application "Ghostty"
    set cfg to new surface configuration
    set initial working directory of cfg to item 1 of argv
    set initial input of cfg to item 2 of argv & linefeed
    if (count of windows) > 0 then
      new tab in front window with configuration cfg
    else
      new window with configuration cfg
    end if
  end tell
end run
APPLESCRIPT
}

now=$(date +%s)
shopt -s nullglob nocaseglob   # Muse may write brief.md or BRIEF.md
for brief in "$ROOT"/*/brief.md; do
  dir=$(dirname "$brief")
  name=$(basename "$dir")
  [ -e "$dir/$CLAIM" ] && continue
  age=$(( now - $(stat -f %m "$brief") ))
  if [ "$age" -lt "$SETTLE" ]; then
    log "$name: brief changed ${age}s ago; waiting"
    continue
  fi

  if open_tab "$dir" "claude \"$PROMPT\"" >/dev/null; then
    date '+%F %T' > "$dir/$CLAIM"
    log "$name: launched Claude in Ghostty"
    /usr/bin/osascript -e "display notification \"Claude is building the pitch site\" with title \"Brief picked up: $name\""
  else
    log "$name: failed to open Ghostty tab"
  fi
done
