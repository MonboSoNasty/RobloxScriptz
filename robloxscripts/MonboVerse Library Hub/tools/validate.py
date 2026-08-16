#!/usr/bin/env python3
"""
MonboVerse Library Hub — Lua/Luau sanity validator + project validator.

Usage:
    python tools/validate.py [root]

Default root is the "MonboVerse Library Hub" folder containing this tool
(one directory above tools/). Pass an explicit root to validate a copy.

Checks:
  * Every .lua file under scripts/ and src/: a lightweight Luau syntax sanity
    pass — comments (--... and --[[...]]) and strings (quoted, [[...]], [=[...]=])
    are ignored, then block keywords (function/if/then/do/for/while/repeat vs
    end/until) and brackets ( ) { } [ ] must be balanced.
  * metadata/*.json and config/library.json: valid JSON, `version` fields match
    MAJOR.MINOR.PATCH, `placeIds` is a list of integers (empty allowed), and
    every game's `script` / `metadata` relative paths exist on disk.

Exit code 0 when everything passes, 1 otherwise.
"""

import json
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")

BLOCK_OPENERS = {"function", "if", "for", "while", "repeat", "do"}
BRACKET_PAIRS = {"(": ")", "{": "}", "[": "]"}


def is_ident_char(ch):
    return ch.isalnum() or ch == "_"


def display_name(kind):
    return kind[:-5] if kind.endswith("-loop") else kind


def read_word(text, i):
    j = i
    while j < len(text) and is_ident_char(text[j]):
        j += 1
    return text[i:j], j


def check_lua(path):
    """Lightweight Luau sanity check. Returns None on success, or (line, reason)."""
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()

    line = 1
    i = 0
    n = len(text)
    blocks = []
    brackets = []

    while i < n:
        ch = text[i]

        if ch == "\n":
            line += 1
            i += 1
            continue

        if ch == "-" and i + 1 < n and text[i + 1] == "-":
            if i + 2 < n and text[i + 2] == "[":
                j = i + 3
                level = 0
                while j < n and text[j] == "=":
                    level += 1
                    j += 1
                if j < n and text[j] == "[":
                    target = "]" + "=" * level + "]"
                    end = text.find(target, j + 1)
                    if end == -1:
                        raise ValueError("unclosed block comment (missing %r)" % target, line)
                    line += text.count("\n", i, end + len(target))
                    i = end + len(target)
                    continue
            nl = text.find("\n", i)
            i = n if nl == -1 else nl
            continue

        if ch == "[":
            j = i + 1
            level = 0
            while j < n and text[j] == "=":
                level += 1
                j += 1
            if j < n and text[j] == "[":
                target = "]" + "=" * level + "]"
                end = text.find(target, j + 1)
                if end == -1:
                    raise ValueError("unclosed long string (missing %r)" % target, line)
                line += text.count("\n", i, end + len(target))
                i = end + len(target)
                continue

        if ch == "'" or ch == '"':
            quote = ch
            j = i + 1
            closed = False
            while j < n:
                c = text[j]
                if c == "\\":
                    j += 1
                    if j >= n:
                        break
                    if text[j] == "\n":
                        line += 1
                    j += 1
                    continue
                if c == "\n":
                    line += 1
                    j += 1
                    continue
                if c == quote:
                    closed = True
                    j += 1
                    break
                j += 1
            if not closed:
                raise ValueError("unclosed string literal", line)
            i = j
            continue

        if ch.isalpha() or ch == "_":
            word, j = read_word(text, i)
            before_ok = (i == 0) or not is_ident_char(text[i - 1])
            after_ok = (j >= n) or not is_ident_char(text[j])
            if before_ok and after_ok:
                if word in BLOCK_OPENERS:
                    if word == "do":
                        if blocks and blocks[-1][0] in ("for", "while"):
                            opener, open_line = blocks[-1]
                            blocks[-1] = (opener + "-loop", open_line)
                        else:
                            blocks.append((word, line))
                    else:
                        blocks.append((word, line))
                elif word == "end":
                    if not blocks:
                        raise ValueError("unexpected 'end'", line)
                    blocks.pop()
                elif word == "until":
                    if not blocks:
                        raise ValueError("unexpected 'until'", line)
                    opener, open_line = blocks[-1]
                    if opener != "repeat":
                        raise ValueError("'until' without matching 'repeat' (top of stack is '%s' from line %d)" % (display_name(opener), open_line), line)
                    blocks.pop()
            i = j
            continue

        if ch in BRACKET_PAIRS:
            brackets.append((ch, line))
            i += 1
            continue
        if ch in BRACKET_PAIRS.values():
            if not brackets:
                raise ValueError("unbalanced '%s'" % ch, line)
            open_ch, open_line = brackets[-1]
            if BRACKET_PAIRS[open_ch] != ch:
                raise ValueError("mismatched '%s' (expected '%s' from line %d)" % (ch, BRACKET_PAIRS[open_ch], open_line), line)
            brackets.pop()
            i += 1
            continue

        i += 1

    if brackets:
        open_ch, open_line = brackets[-1]
        raise ValueError("unbalanced '%s' (missing '%s' from line %d)" % (open_ch, BRACKET_PAIRS[open_ch], open_line), open_line)
    if blocks:
        opener, open_line = blocks[-1]
        raise ValueError("unclosed block '%s' opened at line %d (missing 'end')" % (display_name(opener), open_line), open_line)
    return None


def is_int_list(value):
    return isinstance(value, list) and all(isinstance(v, int) and not isinstance(v, bool) for v in value)


def check_game_paths(root, rel_json, game):
    errs = []
    for key in ("script", "metadata"):
        p = game.get(key)
        if not isinstance(p, str) or not p:
            errs.append("%s: game %r missing %r field" % (rel_json, game.get("id"), key))
            continue
        full = os.path.normpath(os.path.join(root, p))
        if not os.path.isfile(full):
            errs.append("%s: game %r %s path %r not found on disk" % (rel_json, game.get("id"), key, p))
    return errs


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    root = os.path.abspath(root)

    if not os.path.isdir(root):
        print("❌ Build failed")
        print("%s: not a directory" % root)
        print("❌ 1 error(s)")
        return 1

    errors = []

    lua_files = []
    for sub in ("scripts", "src"):
        base = os.path.join(root, sub)
        if not os.path.isdir(base):
            print("note: skipping missing directory %s/" % sub)
            continue
        for dirpath, dirnames, filenames in os.walk(base):
            dirnames.sort()
            for fn in sorted(filenames):
                if fn.lower().endswith(".lua"):
                    lua_files.append(os.path.join(dirpath, fn))

    for path in lua_files:
        rel = os.path.relpath(path, root)
        try:
            problem = check_lua(path)
        except ValueError as exc:
            problem = exc.args
        if problem is None:
            print("✅ %s" % rel)
        else:
            reason, ln = problem
            errors.append((rel, ln, reason))
            print("❌ Build failed")
            print("%s: line %s" % (rel, ln))
            print(reason)

    json_files = []
    meta_dir = os.path.join(root, "metadata")
    if os.path.isdir(meta_dir):
        for fn in sorted(os.listdir(meta_dir)):
            if fn.lower().endswith(".json"):
                json_files.append(os.path.join(meta_dir, fn))
    lib_json = os.path.join(root, "config", "library.json")
    if os.path.isfile(lib_json):
        json_files.append(lib_json)
    else:
        errors.append((os.path.relpath(lib_json, root), 0, "config/library.json not found"))
        print("❌ Build failed")
        print("%s: line 0" % os.path.relpath(lib_json, root))
        print("config/library.json not found")

    for path in json_files:
        rel = os.path.relpath(path, root)
        file_errors = []
        try:
            with open(path, "r", encoding="utf-8") as fh:
                data = json.load(fh)
        except (OSError, ValueError) as exc:
            file_errors.append("%s: invalid JSON: %s" % (rel, exc))
        else:
            if not isinstance(data, dict):
                file_errors.append("%s: top-level JSON must be an object" % rel)
            else:
                if "version" in data and not SEMVER_RE.match(str(data["version"])):
                    file_errors.append("%s: version %r is not semver (expected MAJOR.MINOR.PATCH)" % (rel, data["version"]))
                if "placeIds" in data and not is_int_list(data["placeIds"]):
                    file_errors.append("%s: placeIds must be a list of integers (empty allowed)" % rel)
                games = data.get("games")
                if games is not None:
                    if not isinstance(games, list):
                        file_errors.append("%s: 'games' must be a list" % rel)
                    else:
                        for game in games:
                            if not isinstance(game, dict):
                                file_errors.append("%s: game entries must be objects" % rel)
                                continue
                            if "version" in game and not SEMVER_RE.match(str(game["version"])):
                                file_errors.append("%s: game %r version %r is not semver" % (rel, game.get("id"), game["version"]))
                            if "placeIds" in game and not is_int_list(game["placeIds"]):
                                file_errors.append("%s: game %r placeIds must be a list of integers" % (rel, game.get("id")))
                            file_errors.extend(check_game_paths(root, rel, game))
        if file_errors:
            errors.append((rel, 0, file_errors[0]))
            print("❌ Build failed")
            print("%s: %s" % (rel, file_errors[0]))
        else:
            print("✅ %s" % rel)

    total = len(errors)
    if total == 0:
        print("✅ All checks passed")
        return 0
    print("❌ %d error(s)" % total)
    return 1


if __name__ == "__main__":
    sys.exit(main())
