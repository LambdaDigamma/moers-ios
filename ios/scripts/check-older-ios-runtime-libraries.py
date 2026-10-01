#!/usr/bin/env python3
"""Check Swift compatibility libraries before installing on an older iOS simulator.

Pass the .app from a build for the selected older runtime. A build for a newer
runtime can omit these libraries because that OS provides them.
"""

import argparse
from pathlib import Path
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("app", type=Path, help="App bundle from the current simulator build")
    app = parser.parse_args().app.resolve()
    if not app.is_dir() or app.suffix != ".app":
        parser.error("Pass an existing .app bundle")

    macho_headers = {
        bytes.fromhex(header)
        for header in ("feedface", "feedfacf", "cefaedfe", "cffaedfe", "cafebabe", "bebafeca", "cafebabf", "bfbafeca")
    }
    missing = set()
    checked = 0
    for binary in app.rglob("*"):
        is_bundle_executable = (
            binary.parent.suffix in {".app", ".appex", ".framework"}
            and binary.name == binary.parent.stem
        )
        if binary.suffix != ".dylib" and not is_bundle_executable:
            continue
        if not binary.is_file():
            continue
        with binary.open("rb") as stream:
            if stream.read(4) not in macho_headers:
                continue
        checked += 1
        dependencies = subprocess.run(
            ["xcrun", "otool", "-L", str(binary)], check=True, capture_output=True, text=True
        ).stdout
        for line in dependencies.splitlines()[1:]:
            parts = line.strip().split()
            if not parts:
                continue
            dependency = parts[0]
            if not dependency.startswith("@rpath/libswiftCompatibility"):
                continue
            name = Path(dependency).name
            framework_folders = [app / "Frameworks"]
            framework_folders += [parent / "Frameworks" for parent in binary.parents if parent.suffix == ".appex"]
            if not any((folder / name).is_file() for folder in framework_folders):
                missing.add(f"{binary.relative_to(app)} requires {name}")

    if missing:
        print("Missing Swift compatibility libraries:", file=sys.stderr)
        for dependency in sorted(missing):
            print(f"  {dependency}", file=sys.stderr)
        print("Rebuild for the selected older runtime and use that exact build output.", file=sys.stderr)
        return 1
    if not checked:
        print("No Mach-O binaries found in the app bundle.", file=sys.stderr)
        return 1
    print(f"Checked {checked} Mach-O binaries; all referenced Swift compatibility libraries are embedded.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
