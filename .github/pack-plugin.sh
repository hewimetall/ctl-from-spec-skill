#!/bin/sh
# Pack this repository as a Claude Code plugin.
# Source stays a skill at the repo root. The artifact is the plugin layout.
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$root"

test -f SKILL.md
name=$(awk '
  /^---$/ { c++; next }
  c==1 && /^name:/ {
    sub(/^name:[[:space:]]*/, "")
    gsub(/["'\'' ]/, "")
    print
    exit
  }
' SKILL.md)
desc=$(awk '
  /^---$/ { c++; next }
  c==1 && /^description:/ {
    sub(/^description:[[:space:]]*/, "")
    print
    exit
  }
' SKILL.md)

test -n "$name"
test -n "$desc"
echo "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'

# Relative markdown links must resolve inside this repo.
python3 - "$root" << 'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
missing = []
for path in root.rglob("*.md"):
    if ".git" in path.parts or "dist" in path.parts:
        continue
    text = path.read_text(encoding="utf-8")
    for target in re.findall(r"\[[^\]]*\]\(([^)]+)\)", text):
        if target.startswith(("http://", "https://", "mailto:")):
            continue
        target = target.split("#", 1)[0].strip()
        if not target:
            continue
        dest = (path.parent / target).resolve()
        if not dest.is_file():
            missing.append(f"{path.relative_to(root)} -> {target}")
if missing:
    sys.stderr.write("missing link targets:\n" + "\n".join(missing) + "\n")
    sys.exit(1)
PY

stage="$root/dist/$name"
rm -rf "$stage"
mkdir -p "$stage/.claude-plugin" "$stage/skills/$name/references"
cp SKILL.md README.md "$stage/skills/$name/"
cp references/*.md "$stage/skills/$name/references/"

python3 - "$stage/.claude-plugin/plugin.json" "$name" "$desc" << 'PY'
import json, sys
path, name, desc = sys.argv[1:]
json.dump(
    {
        "name": name,
        "version": "0.1.0",
        "description": desc,
    },
    open(path, "w", encoding="utf-8"),
    indent=2,
)
open(path, "a", encoding="utf-8").write("\n")
PY

tar -C "$root/dist" -czf "$root/dist/$name-plugin.tar.gz" "$name"
echo "packed dist/$name-plugin.tar.gz"
