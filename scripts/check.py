#!/usr/bin/env python3
"""Skill checks, free and quick: host-table flags vs each CLI's --help (CLIs not installed are skipped), skill links,
orphan files and agents, executable skill scripts, skill and agent word budgets, pointers to another skill's rules, and
proposed-improvement statuses."""
import itertools, json, os, re, shutil, subprocess, sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors = []
# Word budgets: descriptions sit in every session's context; bodies load on each call. Raise only with the user's OK.
DESC_MAX, DESCS_MAX, BODY_MAX, SIBLING_MAX = 55, 520, 750, 300


def check_cli_flags():
    """Skills run remote commands only from their host tables, so a flag the CLI dropped or renamed fails for real."""
    cmds = [(f, c.split("\\|")[0]) for f in sorted(ROOT.glob("skills/*/*.md"))
            for c in re.findall(r"`((?:gh|glab|acli) [^`]+)`", f.read_text())]

    def sub(cmd):  # the subcommand: words up to the first flag or placeholder; `api` takes a path, not subcommands
        words = list(itertools.takewhile(lambda t: re.fullmatch(r"[a-z][\w-]*", t), cmd.split()))
        return tuple(words[:2] if words[1:2] == ["api"] else words)

    def help_text(s):
        r = subprocess.run([*s, "--help"], capture_output=True, text=True, timeout=30)
        return r.stdout + r.stderr

    subs = sorted({sub(c) for _, c in cmds if shutil.which(c.split()[0])})
    with ThreadPoolExecutor(8) as ex:
        helps = dict(zip(subs, ex.map(help_text, subs)))
    for f, c in cmds:
        if (s := sub(c)) in helps:
            for flag in sorted(set(re.findall(r"(?<![\w-])--[a-z][\w-]*", c))):
                if not re.search(rf"(?<![\w-]){re.escape(flag)}(?![\w-])", helps[s]):
                    errors.append(f"{f.relative_to(ROOT)}: `{' '.join(s)} --help` lists no {flag}")
    for tool in sorted({c.split()[0] for _, c in cmds} - {s[0] for s in subs}):
        print(f"· {tool} not installed: its host tables go unchecked", flush=True)


def check_skills():
    """Progressive disclosure only works if every pointer resolves and every sibling file is pointed at."""
    root, linked, descs = ROOT, set(), 0
    for f in sorted([*root.glob("skills/*/*.md"), *root.glob("agents/*.md")]):
        t, rel = f.read_text(), f.relative_to(root)
        targets = [f.parent / l for l in re.findall(r"\]\(([^)\s#]+)\)", t) if not re.match(r"[a-z]+:|<", l)]
        run = [f.parent / l for l in re.findall(r"\$\{CLAUDE_SKILL_DIR\}/([\w./-]+\w)", t)]
        targets += run
        for s in run:
            if s.suffix != ".md" and s.exists() and not os.access(s, os.X_OK):
                errors.append(f"{rel}: runs {os.path.relpath(s, root)}, which isn't executable")
        for target in targets:
            if not target.exists():
                errors.append(f"{rel}: links to missing {os.path.relpath(target, root)}")
            linked.add(target.resolve())
        if m := re.search(r"(?:as|per) the `[\w-]+` skill \w+", t):
            errors.append(f"{rel}: '{m.group(0)}' points at a skill that may not be loaded: inline the rule or link its file")
        fm = re.match(r"---\n(.*?)\n---\n", t, re.S)
        if fm:
            n = len((re.search(r"^description: (.*)$", fm.group(1), re.M) or [""])[0].split()) - 1
            descs += n
            if n > DESC_MAX:
                errors.append(f"{rel}: description is {n} words (budget {DESC_MAX})")
        if (n := len(t[fm.end():].split()) if fm else len(t.split())) > (cap := BODY_MAX if fm else SIBLING_MAX):
            errors.append(f"{rel}: {n} words (budget {cap})")
    if descs > DESCS_MAX:
        errors.append(f"skills: descriptions total {descs} words (budget {DESCS_MAX})")
    for f in sorted(p for p in root.glob("skills/*/*") if p.is_file()):
        if f.name != "SKILL.md" and f.resolve() not in linked:
            errors.append(f"{f.relative_to(root)}: no skill file links to it, so it never loads")
    skill_text = "".join(f.read_text() for f in root.glob("skills/*/*.md"))
    plugin = json.loads((root / ".claude-plugin/plugin.json").read_text())["name"]
    for a in sorted(root.glob("agents/*.md")):
        if f"{plugin}:{a.stem}" not in skill_text:
            errors.append(f"{a.relative_to(root)}: no skill names {plugin}:{a.stem}, so it never runs")


def check_proposals():
    """A rejected idea must never come back built, and Done must be true, or the record stops meaning anything."""
    f, statuses = ROOT / "docs/proposed-improvements.md", ("Proposed", "Planned", "Done", "Skipped for now", "Rejected")
    plugin = json.loads((ROOT / ".claude-plugin/plugin.json").read_text())["name"]
    for line in f.read_text().splitlines() if f.exists() else []:
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if not line.startswith("|") or len(cells) < 2 or cells[1] == "Status" or re.fullmatch(r":?-+:?", cells[1]):
            continue
        idea, status = cells[:2]
        if status not in statuses:
            errors.append(f"docs/proposed-improvements.md: {idea}: status '{status}' isn't one of {', '.join(statuses)}")
        elif m := re.match(rf"`{plugin}:([\w-]+)`", idea):  # a skill or agent idea; a feature idea names none first
            built = (ROOT / "skills" / m[1] / "SKILL.md").exists() or (ROOT / "agents" / f"{m[1]}.md").exists()
            if status == "Done" and not built:
                errors.append(f"docs/proposed-improvements.md: {idea} is Done, but there's no skill or agent {m[0]}")
            if status == "Rejected" and built:
                errors.append(f"docs/proposed-improvements.md: {idea} is Rejected, but {m[0]} exists")


check_cli_flags()
check_skills()
check_proposals()
for e in errors:
    print(f"✗ {e}", flush=True)
print(f"{len(errors)} problem(s)" if errors else "✓ all skill checks pass")
sys.exit(1 if errors else 0)
