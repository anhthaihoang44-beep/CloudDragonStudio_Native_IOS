"""Extract PNG screenshot attachments from an Xcode .xcresult bundle."""

import json
import shutil
import subprocess
import sys
from pathlib import Path


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)


def extract_via_attachments_cmd(xcresult: Path, out_dir: Path) -> bool:
    res = run(["xcrun", "xcresulttool", "export", "attachments", "--path", str(xcresult), "--output-path", str(out_dir)])
    if res.returncode != 0:
        return False
    manifest = out_dir / "manifest.json"
    if manifest.exists():
        data = json.loads(manifest.read_text(encoding="utf-8"))
        # Rename exported files to clean human-readable attachment names when available
        entries = data if isinstance(data, list) else data.get("attachments", [])
        for entry in entries:
            for att in (entry.get("attachments", [entry]) if isinstance(entry, dict) else []):
                exported = att.get("exportedFileName")
                suggested = att.get("suggestedHumanReadableName") or exported
                if not exported or not suggested:
                    continue
                src = out_dir / exported
                if src.exists():
                    safe_name = suggested.replace("/", "_").replace(" ", "_")
                    if not safe_name.lower().endswith(".png"):
                        safe_name += ".png"
                    dst = out_dir / safe_name
                    if src != dst:
                        shutil.move(str(src), str(dst))
    return any(out_dir.rglob("*.png"))


def extract_via_legacy_json(xcresult: Path, out_dir: Path) -> bool:
    for flags in (["--legacy"], []):
        res = run(["xcrun", "xcresulttool", "get", *flags, "--format", "json", "--path", str(xcresult)])
        if res.returncode != 0:
            continue
        root = json.loads(res.stdout)
        found = []

        def walk(node):
            if isinstance(node, dict):
                if "payloadRef" in node and isinstance(node["payloadRef"], dict):
                    ref_id = node["payloadRef"].get("id", {}).get("_value")
                    name = node.get("name", {}).get("_value", "screenshot")
                    if ref_id:
                        found.append((name, ref_id))
                for v in node.values():
                    walk(v)
            elif isinstance(node, list):
                for v in node:
                    walk(v)

        walk(root)
        for idx, (name, ref_id) in enumerate(found):
            safe = f"{idx:02d}_{name.replace(' ', '_')}"
            if not safe.lower().endswith(".png"):
                safe += ".png"
            out_file = out_dir / safe
            exp = run(["xcrun", "xcresulttool", "export", *flags, "--type", "file", "--path", str(xcresult), "--id", ref_id, "--output-path", str(out_file)])
            if exp.returncode != 0 and out_file.exists():
                out_file.unlink()
        if any(out_dir.glob("*.png")):
            return True
    return False


def main():
    if len(sys.argv) < 3:
        print("Usage: extract_xcresult_screenshots.py <xcresult> <out_dir>")
        sys.exit(1)
    xcresult = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)
    if not xcresult.exists():
        print(f"Missing xcresult: {xcresult}")
        sys.exit(0)
    ok = extract_via_attachments_cmd(xcresult, out_dir)
    if not ok:
        ok = extract_via_legacy_json(xcresult, out_dir)
    pngs = sorted(out_dir.rglob("*.png"))
    print(f"Extracted {len(pngs)} PNG screenshots into {out_dir}")
    for p in pngs:
        print(f" - {p.name} ({p.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
