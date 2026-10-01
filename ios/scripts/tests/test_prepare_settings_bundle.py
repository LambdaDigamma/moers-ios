import importlib.util
import os
from pathlib import Path
import plistlib
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "prepare-settings-bundle.py"
SPEC = importlib.util.spec_from_file_location("prepare_settings_bundle", SCRIPT)
BUILDER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BUILDER)


class PrepareSettingsBundleTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="settings build tests ")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.debug = self.root / "Debug/Settings.bundle"
        self.release = self.root / "Release/Settings.bundle"
        self.output = self.root / "Built App.app/Settings.bundle"
        self.info = self.root / "Info.plist"
        self.write_plist(self.info, {"CFBundleShortVersionString": "3.3.3", "CFBundleVersion": "66"})
        for template in [self.debug, self.release]:
            specifiers = [{"Key": "version_preference", "DefaultValue": "old version"}]
            if template == self.debug:
                specifiers.append({"Key": "environment", "DefaultValue": "production"})
            self.write_plist(template / "Root.plist", {"PreferenceSpecifiers": specifiers})
            self.write_plist(template / "com.mono0926.LicensePlist.plist", {"PreferenceSpecifiers": []})
            self.write_plist(template / "com.mono0926.LicensePlist/Current.plist", {"FooterText": "Licence text"})
            (template / "com.mono0926.LicensePlist.latest_result.txt").write_text("fixture result")
            (template / "en.lproj").mkdir()
            (template / "en.lproj/Root.strings").write_text('"Version" = "Version";')
        self.write_plist(self.release / "com.mono0926.LicensePlist/Old.plist", {"FooterText": "Old"})
        self.write_plist(
            self.release / "com.mono0926.LicensePlist/com.mono0926.LicensePlist/Old.plist",
            {"FooterText": "Nested old licence"},
        )

    def write_plist(self, path, value):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(plistlib.dumps(value))

    def prepare(self, template, environment=None):
        BUILDER.prepare_bundle(template, self.debug, self.info, self.output, environment or {})

    def specifiers(self):
        return plistlib.loads((self.output / "Root.plist").read_bytes())["PreferenceSpecifiers"]

    def test_debug_keeps_development_settings_and_sets_app_version(self):
        self.prepare(self.debug)
        self.assertEqual(self.specifiers()[0]["DefaultValue"], "3.3.3 (66)")
        self.assertEqual(self.specifiers()[1]["Key"], "environment")
        self.assertTrue((self.output / "en.lproj/Root.strings").is_file())

    def test_release_uses_shared_licenses_without_nested_or_old_files(self):
        before = {path: path.read_bytes() for path in self.root.rglob("*") if path.is_file()}
        self.prepare(self.release)
        self.assertEqual(len(self.specifiers()), 1)
        license_files = {path.name for path in (self.output / "com.mono0926.LicensePlist").iterdir()}
        self.assertEqual(license_files, {"Current.plist"})
        for path, content in before.items():
            self.assertEqual(path.read_bytes(), content, str(path))

    def test_rebuild_removes_a_deleted_license_from_the_output(self):
        self.prepare(self.debug)
        (self.debug / "com.mono0926.LicensePlist/Current.plist").unlink()
        self.write_plist(self.debug / "com.mono0926.LicensePlist/New.plist", {"FooterText": "New"})
        self.prepare(self.debug)
        self.assertFalse((self.output / "com.mono0926.LicensePlist/Current.plist").exists())
        self.assertTrue((self.output / "com.mono0926.LicensePlist/New.plist").is_file())

    def test_version_uses_build_settings_and_finds_the_version_specifier_by_key(self):
        self.write_plist(self.info, {
            "CFBundleShortVersionString": "${MARKETING_VERSION}",
            "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
        })
        self.write_plist(self.debug / "Root.plist", {
            "PreferenceSpecifiers": [{"Key": "environment"}, {"Key": "version_preference"}],
        })
        self.prepare(self.debug, {"MARKETING_VERSION": "3.4.0", "CURRENT_PROJECT_VERSION": "67"})
        self.assertEqual(self.specifiers()[1]["DefaultValue"], "3.4.0 (67)")

    def test_invalid_version_does_not_replace_the_previous_bundle(self):
        self.prepare(self.debug)
        before = (self.output / "Root.plist").read_bytes()
        self.write_plist(self.info, {"CFBundleShortVersionString": "3.3.3", "CFBundleVersion": "$(MISSING)"})
        with self.assertRaises(ValueError):
            self.prepare(self.debug)
        self.assertEqual((self.output / "Root.plist").read_bytes(), before)

    def test_missing_license_input_does_not_replace_the_previous_bundle(self):
        self.prepare(self.debug)
        before = (self.output / "Root.plist").read_bytes()
        (self.debug / "com.mono0926.LicensePlist.plist").unlink()
        with self.assertRaises(FileNotFoundError):
            self.prepare(self.debug)
        self.assertEqual((self.output / "Root.plist").read_bytes(), before)

    def test_command_accepts_paths_with_spaces(self):
        subprocess.run([
            os.sys.executable, str(SCRIPT), "prepare", "--template", str(self.release),
            "--licenses", str(self.debug), "--info-plist", str(self.info), "--output", str(self.output),
        ], check=True)
        self.assertEqual(self.specifiers()[0]["DefaultValue"], "3.3.3 (66)")


if __name__ == "__main__":
    unittest.main()
