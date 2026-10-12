#!/usr/bin/env python3
"""Free checks before any paid eval run: YAML, case and grader keys, free grader types, regex graders vs samples,
and, with --run-fixtures, each scaffold script in a clean temp dir (check.py passes it only after its review gate).

samples.yaml, next to case.yaml: <grader name>: {pass: [text, ...], fail: [text, ...]}; a trace sample is a Bash command or {tool, input}.
"""
import json, os, subprocess, sys, tempfile
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


def yaml(p):
    if not p.exists():
        return {}
    r = subprocess.run(["npx", "-y", "js-yaml@4.1.0", str(p)], capture_output=True, text=True)
    if r.returncode:
        errors.append(f"{p.relative_to(EVALS)}: {(r.stderr.strip().splitlines() or ['unparseable'])[0]}")
        return {}
    return json.loads(r.stdout)


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


for case in sorted(EVALS.glob("*/*/case.yaml")):
    c, samples, cid = yaml(case), yaml(case.parent / "samples.yaml"), f"{case.parent.parent.name}/{case.parent.name}"
    for section, allowed in KEYS.items():
        if unknown := set((c.get(section) or {}) if section else c) - allowed:
            errors.append(f"{cid}: unknown {section or 'top-level'} keys {sorted(unknown)}")
    graders = c.get("graders") or []
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
for e in errors:
    print(f"✗ {e}", flush=True)
code = subprocess.run(["node", "-e", JS], input=json.dumps(checks), text=True).returncode
sys.exit(1 if errors or code else 0)
