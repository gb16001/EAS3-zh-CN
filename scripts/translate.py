"""Batch-translate the string inventory through Codex, resumably.

Usage:
  python -I scripts/translate.py plan [--size N]
  python -I scripts/translate.py run  [--limit N]
  python -I scripts/translate.py status
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WORK = os.path.join(ROOT, "work")
DATA = os.path.join(ROOT, "data")
BATCHES = os.path.join(WORK, "batches")
OUTS = os.path.join(WORK, "out")
CODEX = os.environ.get("CODEX_ASK") or os.path.expanduser(
    r"~\.claude\skills\codex\scripts\codex_ask.py"
)

GLOSSARY = """驱动器=Drive；轴=Axis/Axes；主轴/主站=Master；从站=Slave；反馈=Feedback；环路=Loop；
整定=Tuning；增益=Gain；换相=Commutation；记录器=Recorder；终端=Terminal；工作区=Workspace；
工具集=Toolset；参数浏览器=Parameters Explorer；下载=Download（到驱动器）；上传=Upload；
曲线=Profile；稳定=Settling；编码器=Encoder；电机=Motor；控制器=Controller；故障=Fault；
警告=Warning；错误=Error；使能=Enable；禁用=Disable；自整定=Auto Tuning；建立时间=Settling Time"""

PROMPT = """你是工业运动控制软件的专业本地化译员，把 Elmo Application Studio III 的界面英文翻译成简体中文（中国大陆工控行业用语）。

输入文件：{inp}
输出文件：{out}

输入是 JSON：{{"assembly":"...", "items":[{{"id":"...","src":"英文原文"}}...]}}。
请把 items 里每条 src 译成中文，写到输出文件，格式为纯 JSON 对象：
{{"<id>": "<中文译文>", ...}}
必须覆盖全部 {count} 个 id，一个不漏，不要输出任何解释文字。

硬性规则：
1. 严格保留占位符 {{0}} {{1}} {{2}} 等，位置和数量必须与原文一致。
2. 保留转义换行 \\n、制表符 \\t、以及原文首尾空格。
3. 保留下划线快捷键标记（如 _File、Save _As）和 & 符号。
4. 不翻译：Elmo、EAS、EtherCAT、Maestro、Platinum、Gold、SimplIQ、PIV、PWM、GMAS、Blockly、Python、CoE、PDO、SDO、Safe-OP、CANopen、Modbus、CiA402、DS402、SCP、TFTP、SQL、CSV、JSON、XML、GUI、API、DLL、USB、TCP、IP。
5. 不翻译型号、寄存器名、参数名（如 CA[17]、PL[1]、ER[5]、UM[4]）、单位符号。
6. 纯品牌名、纯单位、纯数字、纯符号的条目，原样输出。
7. 术语表（必须遵守）：
{glossary}
8. 译文简洁，符合按钮/标签长度；原文没有句号就不要加句号；问句照常保留问号。
9. 界面用语用词：Ok=确定，Cancel=取消，Apply=应用，Close=关闭，Browse=浏览……，Settings=设置，Advanced=高级。

完成后只需确保输出文件已写入。"""


def jload(path, default):
    if not os.path.exists(path):
        return default
    with open(path, encoding="utf-8-sig") as fh:
        return json.load(fh)


def jsave(path, obj):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(obj, fh, ensure_ascii=False, indent=0, sort_keys=True)
    os.replace(tmp, path)


def plan(size):
    strings = jload(os.path.join(WORK, "strings.json"), {})
    os.makedirs(BATCHES, exist_ok=True)
    ids = sorted(strings)
    seq = 0
    total = 0
    for i in range(0, len(ids), size):
        chunk = ids[i:i + size]
        seq += 1
        name = "b%04d.json" % seq
        payload = {"items": [{"id": s, "src": strings[s]} for s in chunk]}
        jsave(os.path.join(BATCHES, name), payload)
        total += len(chunk)
    print("batches=%d strings=%d" % (seq, total))


def placeholders(s):
    return sorted(re.findall(r"\{\d+\}", s))


def validate(batch, result):
    problems = []
    for item in batch["items"]:
        i = item["id"]
        if i not in result:
            problems.append(("missing", i, item["src"], None))
            continue
        zh = result[i]
        if not isinstance(zh, str) or not zh.strip():
            problems.append(("empty", i, item["src"], zh))
        elif placeholders(item["src"]) != placeholders(zh):
            problems.append(("placeholder", i, item["src"], zh))
    return problems


def run(limit, only="", shard="0/1"):
    os.makedirs(OUTS, exist_ok=True)
    translations = jload(os.path.join(DATA, "translations.json"), {})
    batches = sorted(glob.glob(os.path.join(BATCHES, "*.json")))
    if only:
        batches = [b for b in batches if only in os.path.basename(b)]
    wid, wnum = [int(x) for x in shard.split("/")]
    batches = [b for i, b in enumerate(batches) if i % wnum == wid]
    done = 0
    for bp in batches:
        if limit and done >= limit:
            break
        batch = jload(bp, None)
        if batch is None:
            continue
        need = [it for it in batch["items"] if it["id"] not in translations]
        if not need:
            continue
        name = os.path.basename(bp)
        out = os.path.join(OUTS, name)
        sub = dict(batch, items=need)
        in_name = "inbox_%s.json" % name
        tmp_in = os.path.join(WORK, in_name)
        jsave(tmp_in, sub)
        if os.path.exists(out):
            os.remove(out)
        prompt = PROMPT.format(
            inp="work/" + in_name, out="work/out/" + name,
            count=len(need), glossary=GLOSSARY,
        )
        print("[%s] %d strings ..." % (name, len(need)), flush=True)
        t0 = time.time()
        try:
            p = subprocess.run(
                [sys.executable, "-I", CODEX, "-s", "workspace-write", "-C", ROOT, prompt],
                capture_output=True, text=True, timeout=2400,
            )
            ok = p.returncode == 0
        except subprocess.TimeoutExpired:
            ok = False
            p = None
        dt = time.time() - t0
        result = jload(out, {}) if os.path.exists(out) else {}
        problems = validate(sub, result) if result else [("nofile", "", "", None)]
        good = {k: v for k, v in result.items() if isinstance(v, str) and v.strip()}
        if good:
            translations = jload(os.path.join(DATA, "translations.json"), {})
            translations.update(good)
            jsave(os.path.join(DATA, "translations.json"), translations)
        print("    -> %d/%d ok, %d problems, %.0fs, rc=%s"
              % (len(good), len(need), len(problems), dt, (p.returncode if p else "timeout")),
              flush=True)
        for pr in problems[:5]:
            print("       %s %s %r -> %r" % pr, flush=True)
        if not ok and not good:
            print("    !! batch failed, will retry next run", flush=True)
        done += 1
    print("translations now:", len(translations))


def status():
    strings = jload(os.path.join(WORK, "strings.json"), {})
    translations = jload(os.path.join(DATA, "translations.json"), {})
    missing = [k for k in strings if k not in translations]
    print("total unique: %d" % len(strings))
    print("translated  : %d" % (len(strings) - len(missing)))
    print("remaining   : %d" % len(missing))
    batches = glob.glob(os.path.join(BATCHES, "*.json"))
    print("batches     : %d" % len(batches))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["plan", "run", "status"])
    ap.add_argument("--size", type=int, default=400)
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--only", default="")
    ap.add_argument("--shard", default="0/1")
    a = ap.parse_args()
    if a.cmd == "plan":
        plan(a.size)
    elif a.cmd == "run":
        run(a.limit, a.only, a.shard)
    else:
        status()


if __name__ == "__main__":
    main()
