#!/usr/bin/env python3
"""Skill checks, free and quick: host-table flags vs each CLI's --help (CLIs not installed are skipped), skill links,
orphan files, agents and bin/ scripts, executable scripts run only from bin/ or their own skill, skill and agent word
budgets, pointers to another skill's rules, Markdown templates vs markdownlint (no npx: skipped), skills writing .ai/
running lint-md.sh, and proposed-improvement statuses."""
import itertools, json, os, re, shutil, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors = []
# Word budgets: descriptions sit in every session's context, except user-only skills' (disable-model-invocation), which
# the total skips; bodies load on each call. Raise only with the user's OK.
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


def check_runs(f, run, ran):
    """A script must exist and be executable, and live in bin/ or the caller's own skill folder, so no skill depends on
    another skill's files."""
    rel, own = f.relative_to(ROOT), f.relative_to(ROOT).parts[:2]
    for s in (s for s in run if s.suffix != ".md"):
        r = s.resolve()
        ran.add(r)
        if not s.exists():
            errors.append(f"{rel}: runs missing {os.path.relpath(s, ROOT)}")
        elif not os.access(s, os.X_OK):
            errors.append(f"{rel}: runs {os.path.relpath(s, ROOT)}, which isn't executable")
        elif (p := r.relative_to(ROOT).parts)[0] == "skills" and p[:2] != own:
            errors.append(f"{rel}: runs {os.path.relpath(s, ROOT)}, another skill's script: move it to bin/")


def check_skills():
    """Progressive disclosure only works if every pointer resolves and every sibling file is pointed at."""
    root, linked, descs, ran = ROOT, set(), 0, set()
    for f in sorted([*root.glob("skills/*/*.md"), *root.glob("agents/*.md")]):
        t, rel = f.read_text(), f.relative_to(root)
        targets = [f.parent / l for l in re.findall(r"\]\(([^)\s#]+)\)", t) if not re.match(r"[a-z]+:|<", l)]
        run = [f.parent / l for l in re.findall(r"(?:\$\{CLAUDE_SKILL_DIR\}|<this skill's base directory>)/([\w./-]+\w)", t)]
        run += [root / l for l in re.findall(r"\$\{CLAUDE_PLUGIN_ROOT\}/([\w./-]+\w)", t)]
        targets += run
        check_runs(f, run, ran)
        for target in targets:
            if not target.exists() and not (target in run and target.suffix != ".md"):
                errors.append(f"{rel}: links to missing {os.path.relpath(target, root)}")
            linked.add(target.resolve())
        if m := re.search(r"(?:as|per) the `[\w-]+` skill \w+", t):
            errors.append(f"{rel}: '{m.group(0)}' points at a skill that may not be loaded: invoke that skill, or inline the rule")
        fm = re.match(r"---\n(.*?)\n---\n", t, re.S)
        if fm:
            n = len((re.search(r"^description: (.*)$", fm.group(1), re.M) or [""])[0].split()) - 1
            if not re.search(r"^disable-model-invocation: true$", fm.group(1), re.M):
                descs += n
            if n > DESC_MAX:
                errors.append(f"{rel}: description is {n} words (budget {DESC_MAX})")
        if (n := len(t[fm.end():].split()) if fm else len(t.split())) > (cap := BODY_MAX if fm else SIBLING_MAX):
            errors.append(f"{rel}: {n} words (budget {cap})")
    if descs > DESCS_MAX:
        errors.append(f"skills: descriptions in Claude's context total {descs} words (budget {DESCS_MAX})")
    for f in sorted(p for p in [*root.glob("skills/*/*"), *root.glob("bin/*")] if p.is_file() and p.suffix != ".md"):
        check_runs(f, [f.parent / l for l in re.findall(r'\$\(dirname "\$0"\)/([\w./-]+\w)', f.read_text())], ran)
    for f in sorted(root.glob("bin/*")):
        if f.resolve() not in ran:
            errors.append(f"{f.relative_to(root)}: no skill or script runs it")
    linked |= ran
    for f in sorted(p for p in root.glob("skills/*/*") if p.is_file()):
        if f.name != "SKILL.md" and f.resolve() not in linked:
            errors.append(f"{f.relative_to(root)}: no skill file links to it, so it never loads")
    skill_text = "".join(f.read_text() for f in root.glob("skills/*/*.md"))
    plugin = json.loads((root / ".claude-plugin/plugin.json").read_text())["name"]
    for a in sorted(root.glob("agents/*.md")):
        if f"{plugin}:{a.stem}" not in skill_text:
            errors.append(f"{a.relative_to(root)}: no skill names {plugin}:{a.stem}, so it never runs")


def check_markdown():
    """Skills write files from their templates, so a template that fails markdownlint fails in every file made from it;
    a skill writing .ai/ files that never runs lint-md.sh leaves them all unlinted."""
    for d in sorted(ROOT.glob("skills/*/")):
        t = "".join(f.read_text() for f in sorted(d.glob("*.md")))
        if "ai-dir.sh --write" in t and "bin/lint-md.sh" not in t:
            errors.append(f"skills/{d.name}: writes .ai/ files but never runs bin/lint-md.sh")
    if not shutil.which("npx"):
        print("· npx not installed: templates go unlinted", flush=True)
        return
    with tempfile.TemporaryDirectory() as tmp:
        where = {}  # temp file → (skill file, line of its opening fence)
        for f in sorted(ROOT.glob("skills/*/*.md")):
            lines, fence = f.read_text().splitlines(), None
            for i, line in enumerate(lines):
                if not (m := re.fullmatch(r"( *)(`{3,})(.*)", line)):
                    continue
                if fence is None:
                    fence = (i, m[1], m[2], m[3].strip())
                elif m[2].startswith(fence[2]) and not m[3].strip():  # a closer: as many backticks or more, no info
                    start, indent, _, info = fence
                    body = [l[len(indent):] for l in lines[start + 1:i]]
                    if not info and any(re.match(r"#{1,6} ", l) for l in body):  # a bare fence holding headings
                        name = f"{len(where)}.md"
                        where[name] = (f.relative_to(ROOT), start + 1)
                        Path(tmp, name).write_text("\n".join(body) + "\n")
                    fence = None
        # The repo's rules, plus placeholders like <name>, which read as inline HTML.
        cfg = json.loads(re.sub(r"^\s*//.*$", "", (ROOT / ".markdownlint-cli2.jsonc").read_text(), flags=re.M))
        cfg["config"]["MD033"] = False
        Path(tmp, ".markdownlint-cli2.jsonc").write_text(json.dumps(cfg))
        pin = re.search(r"markdownlint-cli2@[\d.]+", (ROOT / "bin/lint-md.sh").read_text())[0]
        r = subprocess.run(["npx", "--yes", pin, *(f":{n}" for n in where)], cwd=tmp, capture_output=True, text=True,
                           timeout=120)
    if r.returncode not in (0, 1):
        errors.append(f"markdownlint couldn't lint the templates: {r.stderr.strip()}")
    for m in re.finditer(r"^(\d+\.md):(\d+)\S* (?:error )?(.*)$", r.stderr, re.M):
        rel, start = where[m[1]]
        errors.append(f"{rel}:{start + int(m[2])}: template fails markdownlint: {m[3]}")


def check_proposals():
    """A rejected idea must never come back built, and a shipped one must leave, or the record stops meaning anything."""
    f, statuses = ROOT / "docs/proposed-improvements.md", ("Proposed", "Planned", "Skipped for now", "Rejected")
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
            if status == "Rejected" and built:
                errors.append(f"docs/proposed-improvements.md: {idea} is Rejected, but {m[0]} exists")
            elif built:
                errors.append(f"docs/proposed-improvements.md: {idea} is {status}, but {m[0]} exists: delete its row")


check_cli_flags()
check_skills()
check_markdown()
check_proposals()
for e in errors:
    print(f"✗ {e}", flush=True)
print(f"{len(errors)} problem(s)" if errors else "✓ all skill checks pass")
sys.exit(1 if errors else 0)
