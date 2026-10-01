#!/usr/bin/env python3
"""Prepare the app's Settings bundle from tracked resources, without changing them."""

import argparse
import os
from pathlib import Path
import plistlib
import re
import shutil
import tempfile


LICENSE_NAMES = (
    "com.mono0926.LicensePlist",
    "com.mono0926.LicensePlist.plist",
    "com.mono0926.LicensePlist.latest_result.txt",
)
BUILD_SETTING = re.compile(r"\$\(([^)]+)\)|\$\{([^}]+)\}")


def expand_version(value, environment):
    def replace(match):
        name = match.group(1) or match.group(2)
        if name not in environment:
            raise ValueError(f"Missing build setting for version field: {name}")
        return environment[name]

    return BUILD_SETTING.sub(replace, str(value))


def prepare_bundle(template, licenses, info_plist, output, environment):
    with info_plist.open("rb") as source:
        info = plistlib.load(source)
    version = expand_version(info["CFBundleShortVersionString"], environment)
    build = expand_version(info["CFBundleVersion"], environment)

    # A complete replacement removes old licences and avoids cp's nested-directory copy.
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="moers-settings-", dir=output.parent) as temporary:
        staged = Path(temporary) / "Settings.bundle"
        shutil.copytree(
            template, staged,
            ignore=lambda directory, names: LICENSE_NAMES if Path(directory) == template else [],
        )
        for name in LICENSE_NAMES:
            source = licenses / name
            if source.is_dir():
                shutil.copytree(source, staged / name)
            else:
                shutil.copy2(source, staged / name)

        root_path = staged / "Root.plist"
        with root_path.open("rb") as source:
            root = plistlib.load(source)
        specifiers = [
            item for item in root["PreferenceSpecifiers"] if item.get("Key") == "version_preference"
        ]
        if len(specifiers) != 1:
            raise ValueError("Settings Root.plist must have one version_preference")
        specifiers[0]["DefaultValue"] = f"{version} ({build})"
        with root_path.open("wb") as destination:
            plistlib.dump(root, destination, sort_keys=False)

        if output.exists():
            shutil.rmtree(output)
        staged.replace(output)


def resource_paths(root, licenses):
    return {
        path.relative_to(root) for path in root.rglob("*")
        if (path.relative_to(root).parts[0] in LICENSE_NAMES) == licenses
    }


def file_lists(project_directory):
    resources = project_directory / "Moers/Resources"
    debug = resources / "Debug/Settings.bundle"
    release = resources / "Release/Settings.bundle"
    template_paths = resource_paths(debug, licenses=False)
    if template_paths != resource_paths(release, licenses=False):
        raise ValueError("Debug and Release Settings templates must declare the same file paths")
    license_paths = resource_paths(debug, licenses=True)
    inputs = [
        "$(SRCROOT)/scripts/prepare-settings-bundle.py",
        "$(INFOPLIST_FILE)",
        "$(PROJECT_FILE_PATH)/project.pbxproj",
        "$(SRCROOT)/Moers/Resources/$(MOERS_SETTINGS_BUNDLE_VARIANT)/Settings.bundle",
    ]
    inputs += [
        f"$(SRCROOT)/Moers/Resources/$(MOERS_SETTINGS_BUNDLE_VARIANT)/Settings.bundle/{path}"
        for path in sorted(template_paths)
    ]
    inputs += [
        f"$(SRCROOT)/Moers/Resources/Debug/Settings.bundle/{path}"
        for path in sorted(license_paths)
    ]
    output_root = "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/Settings.bundle"
    outputs = [output_root] + [
        f"{output_root}/{path}" for path in sorted(template_paths | license_paths)
    ]
    return "\n".join(inputs) + "\n", "\n".join(outputs) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    prepare = commands.add_parser("prepare")
    for name in ["template", "licenses", "info-plist", "output"]:
        prepare.add_argument(f"--{name}", type=Path, required=True)
    refresh = commands.add_parser("refresh-file-lists")
    refresh.add_argument("--project-directory", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    if args.command == "prepare":
        prepare_bundle(args.template, args.licenses, args.info_plist, args.output, os.environ)
    else:
        inputs, outputs = file_lists(args.project_directory)
        directory = args.project_directory / "scripts"
        (directory / "settings-bundle-inputs.xcfilelist").write_text(inputs)
        (directory / "settings-bundle-outputs.xcfilelist").write_text(outputs)


if __name__ == "__main__":
    main()
