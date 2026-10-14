#!/usr/bin/env python3
"""Run skill evals and compare case scores with the accepted baseline (evals/scores.json, per model).

Usage: check.py <model> [skill[,skill…]|changed|since-release|all] [eval args]   e.g. --case <name> --runs 1, -j 4;
         ▲ ▼ = per case; a ▼ is re-run before it counts; exit 1 on any ▼. changed: skills, agents and cases touched since main;
         since-release: since the last v* tag (none → all). evals/lib or an agent touched → the skills whose fixtures source it or that name it;
         other eval tooling (not check.py, free_checks.py) → all
       check.py <model> [target] --with-without   also run each case without the plugin; print Δ and the graders that differ; store nothing
       check.py --free            free checks only (see free_checks.py); every paid run runs them first and stops on a ✗
       check.py --accept          store the last run's scores as the baseline
Add --reviewed (last) once the user has reviewed the diff from main. --runs above 3 needs --user-asked: only when the user asked.
"""
import atexit, json, os, re, shutil, signal, subprocess, sys, tempfile
from collections import Counter
from pathlib import Path

EVALS = Path(__file__).resolve().parent
SCORES, LAST, FLAKES = EVALS / "scores.json", EVALS / ".last.json", EVALS / "flakes.json"
CONFIRM_RUNS = MAX_RUNS = 3
TMP = Path("/tmp").resolve()  # where `claude plugin eval` puts its e-* scaffold dirs, whatever TMPDIR says


def last_reply(trace):
    text = ""
    for line in Path(trace).read_text().splitlines() if trace and Path(trace).exists() else []:
        try:
            m = json.loads(line)
        except ValueError:
            continue
        m = m.get("message", m) if isinstance(m, dict) else {}
        if isinstance(m, dict) and m.get("role") == "assistant":
            c = m.get("content")
            t = c if isinstance(c, str) else "".join(b.get("text", "") for b in c or [] if isinstance(b, dict))
            text = t or text
    return re.sub(r"\s+", " ", text).strip()


def load(p):
    return json.loads(p.read_text()) if p.exists() else {}


def delta(case):
    """Mean with-minus-without pass rate per grader, leaving out graders that require a skill to fire (`*-fired`, not
    `*-not-fired`): without the plugin they always fail, so they'd make every case look like it pins something."""
    rates = []
    for arm in ("with", "without"):
        passes = {}
        for r in case["arms"].get(arm) or []:
            for g in r["graders"]:
                if not re.search(r"(?<!-not)-fired$", g["name"]):
                    passes.setdefault(g["name"], []).append(g["passed"])
        rates.append({n: sum(v) / len(v) for n, v in passes.items()})
    w, wo = rates
    if not w or not wo:
        return None, ""
    differ = ", ".join(f"{n} {w[n]:.2f}/{wo.get(n, 0):.2f}" for n in w if w[n] != wo.get(n, 0))
    return sum(w[n] - wo.get(n, 0) for n in w) / len(w), differ


if sys.argv[1:] == ["--accept"]:
    last, scores = load(LAST), {k: v for k, v in load(SCORES).items() if isinstance(v, dict)}
    if "scores" not in last:
        sys.exit("nothing new to accept")
    scores[last["model"]] = {**scores.get(last["model"], {}), **last["scores"]}
    SCORES.write_text(json.dumps(scores, indent=2, sort_keys=True) + "\n")
    LAST.unlink()
    print(f"accepted {len(last['scores'])} {last['model']} case scores")
    sys.exit()

free = sys.argv[1:2] == ["--free"]
model, target, extra = (None, "all", sys.argv[2:]) if free else (sys.argv[1], (sys.argv[2:3] or ["all"])[0], sys.argv[3:])
git = lambda *a: subprocess.run(["git", *a], cwd=EVALS.parent, capture_output=True, text=True)


def changed_skills(base):
    """Skills whose skill or eval files differ from base, plus those whose fixtures source a changed evals/lib file
    or whose files name a changed agent;
    None (= all) when other shared eval tooling changed. The runner and free checks don't change what a case does."""
    diff = git("diff", "--name-only", base, "--", "skills", "agents", "evals", ":!evals/scores.json", ":!evals/flakes.json",
               ":!evals/check.py", ":!evals/free_checks.py")
    if diff.returncode:
        sys.exit(f"{target}: no {base} to diff against")
    names = set()
    for f in (diff.stdout + git("ls-files", "-o", "--exclude-standard", "skills", "agents", "evals").stdout).split():
        parts = f.split("/")
        if parts[0] == "agents":
            names |= {s.parent.name for s in EVALS.parent.glob("skills/*/*.md") if Path(f).stem in s.read_text()}
        elif parts[:2] == ["evals", "lib"]:
            names |= {s.parent.name if s.parent.parent == EVALS else s.parent.parent.name
                      for s in EVALS.glob("*/**/*.sh") if "lib/" in s.read_text()} - {"lib"}
        elif parts[0] == "skills" or len(parts) > 2:  # a skill's evals, even a removed skill's
            names.add(parts[1])
        elif parts[0] == "evals":
            return None
    names &= {s.name for s in (EVALS.parent / "skills").iterdir()}  # a removed skill has no cases left to run
    if not names:
        sys.exit(f"{target}: no skill or eval differs from {base}")
    return sorted(names)


tag = git("describe", "--tags", "--abbrev=0", "--match", "v*", "main").stdout.strip() if target == "since-release" else None
tags = (None if free or target == "all" or target == "since-release" and not tag
        else changed_skills(tag or "main") if target in ("changed", "since-release") else target.split(","))
if tags:
    print(f"skills: {', '.join(tags)} (plus every case tagged with one)")
d = git("diff", "--name-only", "main", "--", ".", ":!evals/scores.json")
changed = d.stdout + git("ls-files", "-o", "--exclude-standard").stdout if d.returncode == 0 else "(no main to diff against)\n"
if changed and "--reviewed" not in extra:
    sys.exit(f"Differs from main; scaffold scripts and hooks run unsandboxed as you. Ask the user to review, then add --reviewed:\n{changed}")
runs = [int(a.split("=", 1)[1] if "=" in a else extra[i + 1]) for i, a in enumerate(extra) if a.split("=")[0] == "--runs"]
if any(n > MAX_RUNS for n in runs) and "--user-asked" not in extra:
    sys.exit(f"--runs {max(runs)}: more than {MAX_RUNS} runs a case only when the user asks; then add --user-asked.")
if subprocess.run([sys.executable, str(EVALS / "free_checks.py"), "--run-fixtures"]).returncode:
    sys.exit("Free checks failed: fix them before any paid run.")
if free:
    sys.exit()
ablate = "--with-without" in extra
extra = [a for a in extra if a not in ("--reviewed", "--with-without", "--user-asked")]
if not ablate:  # a with-without run stores nothing, so it keeps the last run's scores for --accept
    LAST.unlink(missing_ok=True)
env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}
env["PATH"] = ".eval-bin:" + env.get("PATH", "")  # fixtures put fake CLIs here (evals/lib/setup.sh)
kept, before = set(), set(TMP.glob("e-*"))
signal.signal(signal.SIGTERM, lambda *_: sys.exit(143))  # so a stopped run still cleans up (atexit)


def evaluate(*args):
    tmp = tempfile.mkdtemp()
    cmd = ["claude", "plugin", "eval", str(EVALS.parent), *(["--tag", *tags] if tags else []),
           "--model", model, "--ablation", "with-without" if ablate else "none", "--threshold", "0", "-j", "8",
           "--trust-plugin", "--no-publish", "--scaffold", "--keep-temp", *args,
           "--output-dir", tmp, "--report", f"{tmp}/r.html", "--json", f"{tmp}/r.json",
           "--allow-tools", "Write", "Edit", "Bash"]
    p = subprocess.run(cmd, env=env, stdin=subprocess.DEVNULL, capture_output=True, text=True)
    result = Path(tmp, "r.json")
    if not result.exists():
        sys.exit(f"eval failed ({p.returncode}):\n{(p.stdout + p.stderr)[-1500:]}")
    for line in (p.stdout + p.stderr).splitlines():
        if line.startswith("✗ ") or "failed to load" in line:
            print(line)
    res = json.loads(result.read_text())
    shutil.rmtree(tmp)
    print(f"{'partial: ' + res['partialReason'] + ' · ' if res.get('partial') else ''}~${res['costUsd']:.2f} · {res['durationSeconds']}s")
    return res


def explain(runs):
    """Each failed grader with its rate and reason, plus the first failing run's reply and kept trace: enough to tell a
    skill bug from a grader that's too strict."""
    failed = [g for r in runs for g in r["graders"] if not g["passed"]]
    for name, n in Counter(g["name"] for g in failed).items():
        why = next(g["explanation"] for g in failed if g["name"] == name)
        print(f"      ✗ {name} {n}/{len(runs)}: {why[:300]}")
    bad = next((r for r in runs if not r["passed"] or r["score"] < 1), None)
    if bad:
        print(f"      reply: {last_reply(bad.get('tracePath'))[:400]}")
        if bad.get("tracePath"):
            kept.add(bad["tracePath"])
            print(f"      trace: {bad['tracePath']}")


def clean_traces():
    """Each e-* dir made since this run started, except those of traces explain() printed. Two check.py runs at once
    aren't supported (they share .last.json), so every new one is this run's."""
    for d in set(TMP.glob("e-*")) - before - {Path(t).parent.parent for t in kept}:
        subprocess.run(["chmod", "-R", "u+rwx", str(d)], capture_output=True)
        shutil.rmtree(d, ignore_errors=True)


atexit.register(clean_traces)


res, old, new, drops = evaluate(*extra), load(SCORES).get(model, {}), {}, 0
for c in res["cases"]:
    runs, s, o = c["arms"]["with"], round(c["aggregates"]["score"], 2), old.get(c["name"])
    errs = {r["error"] for r in runs if r.get("error")}
    if errs:
        drops += 1
        print(f"err {s:.2f}  {c['name']} (run errors; not comparable, not stored)\n      ! {sorted(errs)[0][:160]}")
        continue
    if ablate:
        dl, differ = delta(c)
        print(f"Δ {'n/a' if dl is None else f'{dl:+.2f}'}  with {s:.2f}  {c['name']}{f'  ({differ})' if differ else ''}")
        continue
    if o is not None and s < o:
        keep = [a for i, a in enumerate(extra) if a not in ("--case", "--runs") and extra[i - 1:i] not in (["--case"], ["--runs"])]
        more = [r for x in evaluate(*keep, "--case", c["name"], "--runs", str(CONFIRM_RUNS))["cases"] for r in x["arms"]["with"]]
        if round(sum(r["score"] for r in more) / len(more), 2) >= o:
            flakes = load(FLAKES)
            mine = flakes.setdefault(model, {})
            mine[c["name"]] = n = mine.get(c["name"], 0) + 1
            FLAKES.write_text(json.dumps(flakes, indent=2, sort_keys=True) + "\n")
            print(f"~   {s:.2f} (was {o:.2f})  {c['name']} (flaky: {CONFIRM_RUNS} re-runs held the baseline; not stored;"
                  f" flaked {n}× so far; fix the grader or the skill so it can't flake)")
            explain(runs + more)
            continue
        runs = runs + more
        s = round(sum(r["score"] for r in runs) / len(runs), 2)
    new[c["name"]] = s
    drops += o is not None and s < o
    mark = "new" if o is None else "▲" if s > o else "▼" if s < o else "="
    print(f"{mark:3} {s:.2f}{'' if o is None else f' (was {o:.2f})'}  {c['name']}")
    explain(runs)
if not ablate:
    LAST.write_text(json.dumps({"model": model, "scores": new}))
sys.exit(1 if drops else 0)
