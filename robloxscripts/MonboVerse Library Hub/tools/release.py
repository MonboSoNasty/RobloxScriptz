#!/usr/bin/env python3
"""
MonboVerse Library Hub — deterministic, reversible release pipeline.

Usage:
    python tools/release.py [root]

Default root is the "MonboVerse Library Hub" folder containing this tool
(one directory above tools/). Pass an explicit root to process a copy.

Pipeline (never modifies scripts/ or src/; performs NO deletions anywhere):
  * Creates release/ under root (missing directories are created as needed;
    files inside release/ are written/overwritten only).
  * Minifies every .lua under src/ and scripts/:
      - strips -- line comments and --[[...]] / --[=[...]=] block comments,
      - preserves string literals verbatim (quoted, [[...]], [=[...]=]),
      - collapses leading/trailing whitespace per line,
    written to release/<same-relative-path>.
  * Copies non-Lua payload files (metadata/, config/, README.md) as-is.

Deterministic: identical inputs always produce identical release/ output.
Reversible: release/ is a generated artifact — remove it manually to revert,
then re-run this script to regenerate it. Original sources are never touched.

Exit code 0 on success, 1 on failure.
"""

import os
import shutil
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass


def minify_lua(text):
    """Strip Lua comments and collapse whitespace while preserving strings."""
    lines = text.split("\n")
    out = []
    state = "normal"
    level = 0

    for line in lines:
        parts = []
        i = 0
        n = len(line)
        emit_rest_verbatim = False

        while i < n:
            ch = line[i]

            if state == "line_comment":
                break

            if state == "block_comment":
                target = "]" + "=" * level + "]"
                idx = line.find(target, i)
                if idx == -1:
                    break
                i = idx + len(target)
                state = "normal"
                continue

            if state in ("str_single", "str_double"):
                q = state[4:]
                j = i
                closed = False
                while j < n:
                    c = line[j]
                    if c == "\\":
                        j += 2
                        continue
                    if c == q:
                        closed = True
                        j += 1
                        break
                    j += 1
                if closed:
                    parts.append(line[i:j])
                    i = j
                    state = "normal"
                    continue
                parts.append(line[i:])
                emit_rest_verbatim = True
                break

            if state == "long_str":
                target = "]" + "=" * level + "]"
                idx = line.find(target, i)
                if idx == -1:
                    parts.append(line[i:])
                    emit_rest_verbatim = True
                    break
                parts.append(line[i:idx + len(target)])
                i = idx + len(target)
                state = "normal"
                continue

            if ch == "-" and i + 1 < n and line[i + 1] == "-":
                if i + 2 < n and line[i + 2] == "[":
                    j = i + 3
                    lvl = 0
                    while j < n and line[j] == "=":
                        lvl += 1
                        j += 1
                    if j < n and line[j] == "[":
                        target = "]" + "=" * lvl + "]"
                        idx = line.find(target, j + 1)
                        if idx == -1:
                            state = "block_comment"
                            level = lvl
                            break
                        i = idx + len(target)
                        continue
                break

            if ch == "[":
                j = i + 1
                lvl = 0
                while j < n and line[j] == "=":
                    lvl += 1
                    j += 1
                if j < n and line[j] == "[":
                    target = "]" + "=" * lvl + "]"
                    idx = line.find(target, j + 1)
                    if idx == -1:
                        parts.append(line[i:])
                        state = "long_str"
                        level = lvl
                        emit_rest_verbatim = True
                        break
                    parts.append(line[i:idx + len(target)])
                    i = idx + len(target)
                    continue

            if ch == "'" or ch == '"':
                q = ch
                j = i + 1
                closed = False
                while j < n:
                    c = line[j]
                    if c == "\\":
                        j += 2
                        continue
                    if c == q:
                        closed = True
                        j += 1
                        break
                    j += 1
                if closed:
                    parts.append(line[i:j])
                    i = j
                    continue
                parts.append(line[i:])
                state = "str_single" if q == "'" else "str_double"
                emit_rest_verbatim = True
                break

            if ch in " \t":
                if parts and parts[-1] and not parts[-1][-1].isspace():
                    parts.append(" ")
                i += 1
                continue

            parts.append(ch)
            i += 1

        if emit_rest_verbatim:
            out.append(line)
            continue

        if state == "line_comment":
            state = "normal"

        joined = "".join(parts)
        if joined.strip():
            out.append(joined.strip())

    result = "\n".join(out)
    if result and not result.endswith("\n"):
        result += "\n"
    return result


def collect_lua_files(base):
    found = []
    if not os.path.isdir(base):
        return found
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames.sort()
        for fn in sorted(filenames):
            if fn.lower().endswith(".lua"):
                found.append(os.path.join(dirpath, fn))
    return found


def copy_dir(src, dst):
    if not os.path.isdir(src):
        return 0
    count = 0
    for dirpath, dirnames, filenames in os.walk(src):
        dirnames.sort()
        for fn in sorted(filenames):
            full = os.path.join(dirpath, fn)
            rel = os.path.relpath(full, src)
            target = os.path.join(dst, rel)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy2(full, target)
            count += 1
    return count


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    root = os.path.abspath(root)

    if not os.path.isdir(root):
        print("❌ release failed: %s is not a directory" % root)
        return 1

    release_dir = os.path.join(root, "release")
    os.makedirs(release_dir, exist_ok=True)

    written = []

    for base in ("src", "scripts"):
        for path in collect_lua_files(os.path.join(root, base)):
            rel = os.path.relpath(path, root)
            with open(path, "r", encoding="utf-8", errors="replace") as fh:
                source = fh.read()
            minified = minify_lua(source)
            target = os.path.join(release_dir, rel)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            with open(target, "w", encoding="utf-8", newline="\n") as fh:
                fh.write(minified)
            written.append(rel)

    for item in ("metadata", "config"):
        copy_dir(os.path.join(root, item), os.path.join(release_dir, item))
        item_dir = os.path.join(release_dir, item)
        if os.path.isdir(item_dir):
            for dirpath, _, filenames in os.walk(item_dir):
                for fn in sorted(filenames):
                    written.append(os.path.relpath(os.path.join(dirpath, fn), release_dir))

    readme = os.path.join(root, "README.md")
    if os.path.isfile(readme):
        target = os.path.join(release_dir, "README.md")
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copy2(readme, target)
        written.append("README.md")
    else:
        print("note: README.md not found, skipping")

    written = sorted(set(written))
    print("release/: wrote %d file(s) to %s" % (len(written), release_dir))
    for rel in written:
        print("  - %s" % rel)

    print("✅ Release build complete (original sources untouched; no files deleted)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
