import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


PROJECT = Path(__file__).resolve().parents[2] / "Moers.xcodeproj/project.pbxproj"


class PrepareFuelAPIKeyTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="fuel configuration tests ")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.resources = self.root / "Moers/Resources"
        self.resources.mkdir(parents=True)
        self.sample = self.resources / "Tankerkoenig-Info-Sample.plist"
        self.config = self.resources / "Tankerkoenig-Info.plist"
        # Synthetic text only. These tests do not access either real configuration plist.
        self.sample.write_text("sample fixture")
        project = json.loads(subprocess.check_output([
            "plutil", "-convert", "json", "-o", "-", str(PROJECT),
        ]))
        self.phase = project["objects"]["DF782D8728D1DCA9000BDC89"]

    def run_phase(self):
        script = self.phase["shellScript"]
        if isinstance(script, list):
            script = "\n".join(script)
        environment = dict(os.environ, SRCROOT=str(self.root))
        return subprocess.run(["/bin/sh", "-c", script], env=environment, capture_output=True, check=True)

    def test_missing_configuration_is_created_from_the_sample(self):
        self.run_phase()
        self.assertEqual(self.config.read_text(), "sample fixture")

    def test_existing_configuration_is_preserved_after_sample_changes(self):
        self.config.write_text("custom fixture")
        before = self.config.stat().st_mtime_ns
        self.sample.write_text("new sample fixture")
        self.run_phase()
        self.assertEqual(self.config.read_text(), "custom fixture")
        self.assertEqual(self.config.stat().st_mtime_ns, before)


if __name__ == "__main__":
    unittest.main()
