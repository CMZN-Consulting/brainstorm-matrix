# Storm Ada r1, L0's falsifier: facts about CPython that L0's holds turn on.
# It imports, runs and pastes nothing of spool.py; no network; it writes only under argv[1].
import json, os, sys, tempfile

print("python", sys.version.split()[0])
for exc in (json.JSONDecodeError, UnicodeDecodeError, RecursionError, MemoryError):
    print(f"F1 {exc.__name__} is a ValueError: {issubclass(exc, ValueError)}; an OSError: {issubclass(exc, OSError)}")

def nested(d):
    x = []
    for _ in range(d):
        x = [x]
    return x

def fails(fn, d):
    try:
        fn(d)
        return None
    except BaseException as e:
        return type(e).__name__

dumps = lambda d: json.dumps({"payload": nested(d)}, allow_nan=False)
loads = lambda d: json.loads('{"payload": ' + "[" * d + "]" * d + "}")
for d in (100, 1_000, 10_000, 100_000, 1_000_000):
    print(f"F2 depth {d}: dumps -> {fails(dumps, d)}; loads -> {fails(loads, d)}")

def tags_default(tags=[]):
    tags.append("submitted")
    return len(json.dumps(tags))
sizes = [tags_default() for _ in range(1000)]
print(f"F3 shared default after 1, 2, 1000 calls: bytes {sizes[0]}, {sizes[1]}, {sizes[-1]}; per call {(sizes[-1] - sizes[0]) / 999:.1f}")

with tempfile.TemporaryDirectory(dir=sys.argv[1]) as tmp:
    src = os.path.join(tmp, "a.json")
    open(src, "w").close()
    try:
        os.replace(src, os.path.join(tmp, "gone", "a.json"))
    except OSError as e:
        print(f"F4 os.replace into a missing directory: {type(e).__name__}, an OSError: True")
    print(f"F5 os.kill(own pid, 0) raises: {fails(lambda _: os.kill(os.getpid(), 0), 0)}")
