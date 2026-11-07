"""Quality report over the translated inventory."""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORK = os.path.join(ROOT, "work")
DATA = os.path.join(ROOT, "data")


def jload(name, default, base=WORK):
    p = os.path.join(base, name)
    if not os.path.exists(p):
        return default
    with open(p, encoding="utf-8-sig") as fh:
        return json.load(fh)


def main():
    strings = jload("strings.json", {})
    trans = jload("translations.json", {}, DATA)
    missing = [k for k in strings if k not in trans]
    mism_ph = []
    mism_key = []
    mism_space = []
    same = []
    long_ratio = []
    cjk = re.compile(r"[一-鿿]")
    for k, src in strings.items():
        zh = trans.get(k)
        if zh is None:
            continue
        if sorted(re.findall(r"\{\d+\}", src)) != sorted(re.findall(r"\{\d+\}", zh)):
            mism_ph.append((src, zh))
        if src.count("_") != zh.count("_"):
            mism_key.append((src, zh))
        if (src[:1] == " ") != (zh[:1] == " ") or (src[-1:] == " ") != (zh[-1:] == " "):
            mism_space.append((src, zh))
        if src == zh:
            same.append(src)
        elif not cjk.search(zh):
            same.append(src + "  =>  " + zh)
        if len(zh) > max(12, len(src) * 3):
            long_ratio.append((src, zh))

    print("strings      : %d" % len(strings))
    print("translated   : %d" % (len(strings) - len(missing)))
    print("missing      : %d" % len(missing))
    print("placeholder  : %d" % len(mism_ph))
    print("underscore   : %d" % len(mism_key))
    print("space-edge   : %d" % len(mism_space))
    print("no-chinese   : %d" % len(same))
    print("suspicious   : %d" % len(long_ratio))
    for title, rows in (("PLACEHOLDER", mism_ph), ("UNDERSCORE", mism_key), ("SUSPICIOUS", long_ratio)):
        if rows:
            print("\n-- %s (first 12)" % title)
            for a, b in rows[:12]:
                print("   %r -> %r" % (a, b))


if __name__ == "__main__":
    sys.exit(main())
