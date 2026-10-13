#!/usr/bin/env python3
"""Free checks before any paid eval run: YAML, case and grader keys, free grader types, regex graders vs samples,
host-table flags vs each CLI's --help (CLIs not installed are skipped), skill links, orphan files, word budgets and
pointers to another skill's rules, and, with --run-fixtures, each scaffold script
in a clean temp dir (check.py passes it only after its review gate).

samples.yaml, next to case.yaml: <grader name>: {pass: [text, ...], fail: [text, ...]}; a trace sample is a Bash command or {tool, input}.
"""
import itertools, json, os, re, shutil, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

EVALS = Path(__file__).resolve().parent
KEYS = {"": {"schema_version", "name", "description", "tags", "plugins", "runs", "expected_outcome", "context", "execution", "graders"},
        "context": {"scaffold_script", "history_file", "add_dirs"},
        "execution": {"prompt", "model", "max_turns", "timeout_seconds", "allowed_tools", "append_system_prompt", "env"}}
GRADERS = {"regex": {"pattern", "flags", "match", "target"}, "tool_used": {"tool", "input_match", "min", "max"},
           "tool_order": {"before", "after"}, "file_exists": {"path", "exists"}}
JS = """const c = JSON.parse(require("fs").readFileSync(0, "utf8")); let bad = 0;
for (const [id, p, f, m, t, want] of c) {
  let n;
  try { n = (t.match(new RegExp(p, f.replace("g", "") + "g")) || []).length; } catch (e) { bad++; console.log(`✗ ${id}: ${e.message}`); continue; }
  if ((m === "not_contains" ? n === 0 : m.startsWith("count:") ? n === +m.slice(6) : n > 0) !== want)
    bad++, console.log(`✗ ${id} should ${want ? "pass" : "fail"}: ${JSON.stringify(t).slice(0, 140)}`);
}
console.log(`${c.length - bad}/${c.length} samples ok`); process.exit(bad ? 1 : 0);"""
errors, checks = [], []
# Word budgets: descriptions sit in every session's context; bodies load on each call. Raise only with the user's OK.
DESC_MAX, DESCS_MAX, BODY_MAX, SIBLING_MAX = 55, 450, 750, 300


def load_yaml(paths):
    """{path: parsed} for each existing file, all in one node process: one npx call per file took ~28 s."""
    r = subprocess.run(["npx", "-y", "-p", "js-yaml@4.1.0", "-c", "command -v js-yaml"], capture_output=True, text=True)
    if r.returncode:
        sys.exit(f"✗ can't fetch js-yaml@4.1.0: {(r.stderr or r.stdout).strip()[-200:]}")
    pkg = Path(os.path.realpath(r.stdout.strip())).parents[1]  # node_modules/.bin/js-yaml → node_modules/js-yaml
    js = """const y = require(process.argv[1]), fs = require("fs"), out = {};
for (const p of process.argv.slice(2)) try { out[p] = [y.load(fs.readFileSync(p, "utf8"))]; } catch (e) { out[p] = e.message.split("\\n")[0]; }
console.log(JSON.stringify(out));"""
    files = [str(p) for p in paths if p.exists()]
    out = json.loads(subprocess.run(["node", "-e", js, str(pkg), *files], capture_output=True, text=True, check=True).stdout)
    errors.extend(f"{Path(p).relative_to(EVALS)}: {v}" for p, v in out.items() if isinstance(v, str))
    return {Path(p): v[0] for p, v in out.items() if isinstance(v, list)}


def check_cli_flags():
    """Skills run remote commands only from their host tables, so a flag the CLI dropped or renamed fails for real."""
    cmds = [(f, c.split("\\|")[0]) for f in sorted(EVALS.parent.glob("skills/*/*.md")) if f.name != "SKILL.md"
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
                    errors.append(f"{f.relative_to(EVALS.parent)}: `{' '.join(s)} --help` lists no {flag}")
    for tool in sorted({c.split()[0] for _, c in cmds} - {s[0] for s in subs}):
        print(f"· {tool} not installed: its host tables go unchecked", flush=True)


def check_skills():
    """Progressive disclosure only works if every pointer resolves and every sibling file is pointed at."""
    root, linked, descs = EVALS.parent, set(), 0
    for f in sorted(root.glob("skills/*/*.md")):
        t, rel = f.read_text(), f.relative_to(root)
        targets = [f.parent / l for l in re.findall(r"\]\(([^)\s#]+)\)", t) if not re.match(r"[a-z]+:|<", l)]
        targets += [f.parent / l for l in re.findall(r"\$\{CLAUDE_SKILL_DIR\}/([\w./-]+\w)", t)]
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
    for f in sorted(root.glob("skills/*/*.md")):
        if f.name != "SKILL.md" and f.resolve() not in linked:
            errors.append(f"{f.relative_to(root)}: no skill file links to it, so it never loads")


def run_fixture(cid, script):
    with tempfile.TemporaryDirectory() as d:
        home, work = Path(d, "home"), Path(d, "work")
        home.mkdir()
        work.mkdir()
        env = {"PATH": os.environ["PATH"], "HOME": str(home), "TMPDIR": d, "TERM": "dumb"}
        try:
            r = subprocess.run(["bash", str(script)], cwd=work, env=env, capture_output=True, text=True, timeout=120)
            if r.returncode:
                errors.append(f"{cid}: {script.name} exits {r.returncode}: {(r.stderr or r.stdout).strip()[-200:]}")
        except subprocess.TimeoutExpired:
            errors.append(f"{cid}: {script.name} runs over 120 s")


cases = sorted(EVALS.glob("*/*/case.yaml"))
docs = load_yaml(p for case in cases for p in (case, case.parent / "samples.yaml"))
for case in cases:
    c, samples = docs.get(case) or {}, docs.get(case.parent / "samples.yaml") or {}
    cid = f"{case.parent.parent.name}/{case.parent.name}"
    for section, allowed in KEYS.items():
        if unknown := set((c.get(section) or {}) if section else c) - allowed:
            errors.append(f"{cid}: unknown {section or 'top-level'} keys {sorted(unknown)}")
    graders = c.get("graders") or []
    tags, skill = set(c.get("tags") or []), case.parent.parent.name
    for t in sorted(tags - {d.name for d in (EVALS.parent / "skills").iterdir()}):
        errors.append(f"{cid}: tag {t!r} isn't a skill")
    for g in graders:  # check.py picks cases by tag: a skill the case runs but doesn't tag misses its runs
        fired = re.search(r"([\w-]+)\"'?$", str(g.get("input_match", ""))) if re.search(r"(?<!-not)-fired$", str(g.get("name"))) else None
        if fired and fired.group(1) not in tags | {skill}:
            errors.append(f"{cid}/{g['name']}: fires {fired.group(1)!r} but tags don't list it")
    if skill not in tags:
        errors.append(f"{cid}: tags don't list its own skill {skill!r}")
    if unknown := set(samples) - {g.get("name") for g in graders}:
        errors.append(f"{cid}: samples for unknown graders {sorted(unknown)}")
    for g in graders:
        gid = f"{cid}/{g.get('name')}"
        if g.get("type") not in GRADERS:
            errors.append(f"{gid}: type {g.get('type')!r} isn't a free grader")
            continue
        if unknown := set(g) - GRADERS[g["type"]] - {"name", "type", "weight", "arm"}:
            errors.append(f"{gid}: unknown keys {sorted(unknown)}")
        if g["type"] != "regex":
            continue
        s = samples.get(g["name"]) or {}
        if not (s.get("pass") and s.get("fail")):
            errors.append(f"{gid}: needs a pass and a fail sample")
        for want in ("pass", "fail"):
            for t in s.get(want) or []:
                if g.get("target") == "trace":
                    t = t if isinstance(t, dict) else {"tool": "Bash", "input": {"command": t}}
                    t = json.dumps({"type": "tool_use", "name": t["tool"], "input": t.get("input", {})})
                checks.append([gid, g["pattern"], g.get("flags", ""), g.get("match", "contains"), t, want == "pass"])
    script = (c.get("context") or {}).get("scaffold_script")
    if script and "--run-fixtures" in sys.argv:
        run_fixture(cid, case.parent / script)
check_cli_flags()
check_skills()
for e in errors:
    print(f"✗ {e}", flush=True)
code = subprocess.run(["node", "-e", JS], input=json.dumps(checks), text=True).returncode
sys.exit(1 if errors or code else 0)
