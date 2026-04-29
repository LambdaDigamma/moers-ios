# GitHub Workflow Instructions

This directory contains release automation, not general CI. Keep workflow edits conservative and do not change release behavior unless the user explicitly asks.

## Current Workflows

- `android-release.yml`: manual city Android release to Google Play internal track.
- `festival-android-release.yml`: manual festival Android release to Google Play internal track.
- `ios-release.yml`: manual city iOS release to TestFlight/App Store Connect.
- `festival-ios-release.yml`: manual festival iOS release, optional screenshot update, release-note generation, and App Store Connect upload.

## Rules

- Preserve `workflow_dispatch` inputs unless the requested change is specifically about release triggering.
- Do not add automatic `push` or tag triggers to release workflows without explicit approval.
- Do not weaken secret handling, signing setup, version bumping, tagging, or upload steps.
- Do not run `gh workflow run`, release fastlane lanes, Google Play uploads, App Store Connect uploads, or signing steps without explicit approval.
- If editing generated commit messages in workflows, prefer Conventional Commits for new messages. Existing release-bot messages may not follow that format; do not churn them unless asked.
- For macOS runner or Xcode changes, preserve comments explaining current pins unless you have verified the replacement on the current date.

## Validation

- For workflow-only edits, validate YAML shape with local inspection where possible.
- If GitHub CLI checks are requested, use read-only commands first, such as `gh workflow list`, `gh run list`, or `gh run view`.
- For release workflow changes, explain which secrets and external services are affected; do not print secret values.
