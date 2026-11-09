# R0 falsifier, storm Ada r1: settles facts about Python that R0's holds rest on.
# It never imports, runs or pastes spool.py. Usage: python3 -I THIS SCRATCH_DIR
import fractions, json, os, sys, time
from pathlib import Path

d = Path(sys.argv[1]) / "falsifier-incoming"
d.mkdir(parents=True, exist_ok=True)
names = [f"{n:020d}-aaaaaaaaaaaa.json" for n in (time.time_ns() - 2, time.time_ns() - 1, time.time_ns())]
for n in names + [names[0] + ".tmp"]:
    (d / n).write_text("{}")
got = sorted(d.glob("*.json"), reverse=True)
print("F1 python", sys.version.split()[0])
print("F2 glob *.json skips .json.tmp:", all(not p.name.endswith(".tmp") for p in got), len(got))
print("F3 sorted(reverse=True) puts newest first:", [p.name for p in got] == names[::-1])
print("F4 range(1,1), range(1,3):", list(range(1, 1)), list(range(1, 3)))
print("F5 os.kill(own pid, 0) returns:", os.kill(os.getpid(), 0))
def submit(tags=[]):
    tags.append("submitted"); return list(tags)
print("F6 mutable default, third call:", submit(), submit(), submit())
print("F7 bytes per extra tag:", len(json.dumps(["submitted"] * 2)) - len(json.dumps(["submitted"])))
for label, raw in (("empty", b""), ("bad utf-8", b"\xff"), ("list", b"[1]")):
    try:
        job = json.loads(raw.decode("utf-8")); print("F8", label, "loads to", type(job).__name__)
    except ValueError as e:
        print("F8", label, "->", type(e).__name__, "is ValueError: True")
try:
    json.loads("[" * 200000)
except Exception as e:
    print("F9 deep nesting ->", type(e).__name__, "ValueError?", isinstance(e, ValueError), "OSError?", isinstance(e, OSError))
print("F10 KeyboardInterrupt caught by except (OSError, ValueError)?", issubclass(KeyboardInterrupt, (OSError, ValueError)))
try:
    json.dumps({"x": [1, float("nan")]}, allow_nan=False)
except ValueError as e:
    print("F11 nested nan refused:", type(e).__name__)
print("F12 Fraction passes type(d) in (int, float)?", type(fractions.Fraction(1, 2)) in (int, float))
print("F13 os.kill(huge pid, 0):", end=" ")
try:
    os.kill(2 ** 70, 0)
except OverflowError as e:
    print(type(e).__name__)
