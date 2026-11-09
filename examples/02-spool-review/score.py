import argparse
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TOLERANCE = 2
WIDEST = 6
CITE = re.compile(r"([A-Za-z0-9_./~-]*[A-Za-z0-9_-]\.(?:py|md)):(\d+)((?:\s*[-–]\s*\d+)?(?:\s*,\s*\d+(?:\s*[-–]\s*\d+)?)*)")
PART = re.compile(r"(\d+)(?:\s*[-–]\s*(\d+))?")
KEY_ROW = re.compile(r"^\|\s*(D\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*$")


def spans(first, rest):
    out = []
    head = PART.match(first + rest)
    out.append((int(head.group(1)), int(head.group(2) or head.group(1))))
    for m in PART.finditer(rest.split(",", 1)[1] if "," in rest else ""):
        out.append((int(m.group(1)), int(m.group(2) or m.group(1))))
    return [(a, b) if a <= b else (b, a) for a, b in out]


def same_file(cited, keyed):
    c = [p for p in cited.replace("\\", "/").split("/") if p not in ("", ".")]
    k = [p for p in keyed.split("/") if p not in ("", ".")]
    n = min(len(c), len(k))
    return n > 0 and c[-n:] == k[-n:]


def read_key(path):
    defects = []
    for line in path.read_text(encoding="utf-8").splitlines():
        m = KEY_ROW.match(line)
        if not m:
            continue
        sites = []
        for c in CITE.finditer(m.group(3)):
            for a, b in spans(c.group(2), c.group(3)):
                sites.append((c.group(1), a, b))
        defects.append({"id": m.group(1), "kind": m.group(2), "sites": sites, "what": m.group(4)})
    return defects


def citations(path):
    found = []
    killed_section = False
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if line.startswith("#"):
            killed_section = "graveyard" in line.lower()
        cells = [c.strip().lower() for c in line.split("|")] if line.lstrip().startswith("|") else []
        killed_row = any(c.startswith("graveyard") for c in cells)
        for c in CITE.finditer(line):
            for a, b in spans(c.group(2), c.group(3)):
                found.append({
                    "file": c.group(1), "a": a, "b": b,
                    "where": path.name + ":" + str(number),
                    "killed": killed_section or killed_row,
                })
    return found


def hits(defect, cite):
    if cite["b"] - cite["a"] + 1 > WIDEST:
        return False
    for file, a, b in defect["sites"]:
        if same_file(cite["file"], file) and cite["a"] - TOLERANCE <= b and a <= cite["b"] + TOLERANCE:
            return True
    return False


def label(cite):
    span = str(cite["a"]) if cite["a"] == cite["b"] else str(cite["a"]) + "-" + str(cite["b"])
    return cite["file"] + ":" + span + " at " + cite["where"] + (" (graveyard)" if cite["killed"] else "")


def main():
    parser = argparse.ArgumentParser(description="Score a storm's LEDGER.md and SYNTHESIS.md against an answer key of planted defects. A defect is named when a citation of its file lies within two lines of one of its key lines; a citation spanning more than six lines names nothing. A defect named only in a graveyard section or on a graveyard row is reported as named, killed.")
    parser.add_argument("storm", nargs="?", default=str(HERE), help="the storm directory holding LEDGER.md and SYNTHESIS.md (default: this script's directory)")
    parser.add_argument("key", nargs="?", default=str(HERE / "ANSWER-KEY.md"), help="the answer key (default: ANSWER-KEY.md beside this script)")
    args = parser.parse_args()
    storm = Path(args.storm)
    defects = read_key(Path(args.key))
    if not defects:
        print("no defect rows in the key " + args.key)
        return 0
    cites = []
    for name in ("LEDGER.md", "SYNTHESIS.md"):
        p = storm / name
        if p.is_file():
            cites.extend(citations(p))
        else:
            print("not on file: " + str(p))
    target_files = {file for d in defects for file, _, _ in d["sites"]}
    on_target = [c for c in cites if any(same_file(c["file"], f) for f in target_files)]
    print("| Defect | Kind | Verdict | Named at |")
    print("| ------ | ---- | ------- | -------- |")
    named = killed = 0
    used = set()
    for d in defects:
        mine = [c for c in on_target if hits(d, c)]
        used.update(id(c) for c in mine)
        standing = [c for c in mine if not c["killed"]]
        if standing:
            verdict = "named"
            named += 1
        elif mine:
            verdict = "named, killed"
            killed += 1
        else:
            verdict = "missed"
        print("| " + " | ".join([d["id"], d["kind"], verdict, "; ".join(label(c) for c in mine) or "-"]) + " |")
    print("")
    rest = {}
    for c in on_target:
        if id(c) in used:
            continue
        span = Path(c["file"]).name + ":" + (str(c["a"]) if c["a"] == c["b"] else str(c["a"]) + "-" + str(c["b"]))
        wide = c["b"] - c["a"] + 1 > WIDEST
        rest.setdefault(span, []).append(c["where"] + (" (graveyard)" if c["killed"] else "") + (" (wider than " + str(WIDEST) + " lines, names no line)" if wide else ""))
    print("Lines of the target cited that match no planted defect: " + str(len(rest)))
    for span in sorted(rest, key=lambda s: (s.split(":")[0], int(re.split(r"[:-]", s)[1]))):
        print("- " + span + ", cited at " + ", ".join(rest[span]))
    print("")
    print("Named " + str(named) + " of " + str(len(defects)) + "; named only where killed " + str(killed) + "; missed " + str(len(defects) - named - killed) + "; target citations " + str(len(on_target)) + "; cited lines matching no planted defect " + str(len(rest)) + ".")
    return 0


if __name__ == "__main__":
    sys.exit(main())
