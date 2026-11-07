"""Build a deduplicated translatable-string inventory from the extracted catalog."""
import hashlib
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATALOG = os.path.join(ROOT, "catalog")
WORK = os.path.join(ROOT, "work")
DATA = os.path.join(ROOT, "data")

FILENAME_RE = re.compile(
    r"^[\w./\\-]+\.(exe|dll|txt|csv|xml|json|jpg|jpeg|png|bmp|mat|prt|gcode|nc|dat|py|log|pdf|xls|xlsx)$",
    re.I,
)
WORD_RE = re.compile(r"[A-Za-z]{2,}")


def skip_reason(s):
    if "<?xml" in s or s.lstrip().startswith("<"):
        return "xml"
    if len(s) > 400:
        return "long"
    if not WORD_RE.search(s):
        return "no-words"
    if FILENAME_RE.match(s.strip()):
        return "filename"
    if s.startswith("<<NONSTRING"):
        return "nonstring"
    return None


def sid(text):
    return hashlib.sha1(text.encode("utf-8")).hexdigest()[:12]


def main():
    os.makedirs(WORK, exist_ok=True)
    os.makedirs(DATA, exist_ok=True)
    strings = {}
    index = {}
    skipped = []
    stats = {"total": 0, "unique": 0, "skipped": 0}

    for fn in sorted(os.listdir(CATALOG)):
        if not fn.endswith(".json"):
            continue
        with open(os.path.join(CATALOG, fn), encoding="utf-8-sig") as fh:
            data = json.load(fh)
        asm = data["assembly"]
        index[asm] = {"version": data.get("version"), "resources": {}}
        for stream, items in data["resources"].items():
            if isinstance(items, str):
                continue
            index[asm]["resources"][stream] = {}
            for key, val in items.items():
                stats["total"] += 1
                if not isinstance(val, str) or val.startswith("<<"):
                    skipped.append({"asm": asm, "stream": stream, "key": key, "reason": "nonstring"})
                    stats["skipped"] += 1
                    continue
                reason = skip_reason(val)
                if reason:
                    skipped.append({"asm": asm, "stream": stream, "key": key, "src": val[:200], "reason": reason})
                    stats["skipped"] += 1
                    continue
                i = sid(val)
                strings[i] = val
                index[asm]["resources"][stream][key] = i

    stats["unique"] = len(strings)
    with open(os.path.join(WORK, "strings.json"), "w", encoding="utf-8") as fh:
        json.dump(strings, fh, ensure_ascii=False, indent=0, sort_keys=True)
    with open(os.path.join(DATA, "index.json"), "w", encoding="utf-8") as fh:
        json.dump(index, fh, ensure_ascii=False, indent=1, sort_keys=True)
    with open(os.path.join(WORK, "skipped.json"), "w", encoding="utf-8") as fh:
        json.dump(skipped, fh, ensure_ascii=False, indent=1)

    print(json.dumps(stats, ensure_ascii=False))
    print("assemblies:", len(index))


if __name__ == "__main__":
    sys.exit(main())
