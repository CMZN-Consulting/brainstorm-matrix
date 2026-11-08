import json
import math
import os
import time
import uuid
from dataclasses import dataclass, field
from pathlib import Path


class SpoolLocked(RuntimeError):
    pass


class RetryableError(Exception):
    pass


@dataclass
class Result:
    done: list = field(default_factory=list)
    failed: list = field(default_factory=list)
    retried: int = 0


def _alive(pid):
    try:
        os.kill(pid, 0)
    except (ProcessLookupError, OverflowError):
        return False
    except PermissionError:
        return True
    return True


class Spool:
    def __init__(self, root, handler, max_attempts=3, base_delay=0.5, max_delay=8.0, sleep=time.sleep):
        if isinstance(max_attempts, bool) or not isinstance(max_attempts, int) or max_attempts < 1:
            raise ValueError("max_attempts must be an integer of at least 1")
        if not all(type(d) in (int, float) and math.isfinite(d) and d >= 0 for d in (base_delay, max_delay)):
            raise ValueError("delays must be finite numbers, not negative")
        self.root = Path(root).resolve()
        self.handler = handler
        self.max_attempts = max_attempts
        self.base_delay = base_delay
        self.max_delay = max_delay
        self.sleep = sleep
        self.incoming_dir = self.root / "incoming"
        self.done_dir = self.root / "done"
        self.failed_dir = self.root / "failed"
        self.lock_path = self.root / "spool.lock"
        for directory in (self.incoming_dir, self.done_dir, self.failed_dir):
            directory.mkdir(parents=True, exist_ok=True)

    def submit(self, payload, tags=[]):
        tags.append("submitted")
        now = time.time_ns()
        data = json.dumps({"payload": payload, "tags": tags, "created": now / 1e9}, allow_nan=False)
        name = f"{now:020d}-{uuid.uuid4().hex[:12]}.json"
        tmp = self.incoming_dir / (name + ".tmp")
        try:
            with open(tmp, "w", encoding="utf-8") as fh:
                fh.write(data)
            os.replace(tmp, self.incoming_dir / name)
        except BaseException:
            tmp.unlink(missing_ok=True)
            raise
        return name

    def pending(self):
        return sorted(self.incoming_dir.glob("*.json"), reverse=True)

    def _acquire(self):
        mine = self.root / f"spool.lock.{os.getpid()}.{uuid.uuid4().hex[:8]}"
        try:
            mine.write_text(str(os.getpid()), encoding="ascii")
            for _ in range(1000):
                try:
                    os.link(mine, self.lock_path)
                    return
                except FileExistsError:
                    pass
                try:
                    pid = max(int(self.lock_path.read_text(encoding="ascii").strip()), 0)
                except FileNotFoundError:
                    continue
                except ValueError:
                    pid = 0
                if pid and not _alive(pid) and pid == os.getpid():
                    self.lock_path.unlink(missing_ok=True)
                    continue
                raise SpoolLocked(f"{self.lock_path} is held by process {pid}")
            raise SpoolLocked(f"{self.lock_path} could not be taken")
        finally:
            mine.unlink(missing_ok=True)

    def _release(self):
        self.lock_path.unlink(missing_ok=True)

    def _delay(self, attempt):
        return min(self.base_delay * (2 ** min(attempt - 1, 64)), self.max_delay)

    def _load(self, path):
        with open(path, encoding="utf-8") as fh:
            job = json.load(fh)
        if not isinstance(job, dict) or "payload" not in job:
            raise ValueError(f"{path.name} has no payload")
        return job

    def _finish(self, path, target):
        os.replace(path, target / path.name)

    def _process(self, path, result):
        job = self._load(path)
        for attempt in range(1, self.max_attempts):
            try:
                self.handler(job["payload"])
            except RetryableError:
                if attempt < self.max_attempts:
                    result.retried += 1
                    self.sleep(self._delay(attempt))
                continue
            except Exception:
                self._finish(path, self.failed_dir)
                return False
            self._finish(path, self.done_dir)
            return True
        self._finish(path, self.failed_dir)
        return False

    def run(self, limit=None):
        if limit is not None and (isinstance(limit, bool) or not isinstance(limit, int) or limit < 0):
            raise ValueError("limit must be None or an integer of at least 0")
        self._acquire()
        result = Result()
        jobs = self.pending()
        if limit is not None:
            jobs = jobs[:limit]
        for path in jobs:
            try:
                ok = self._process(path, result)
            except (OSError, ValueError):
                continue
            if ok:
                result.done.append(path.name)
            else:
                result.failed.append(path.name)
        self._release()
        return result
