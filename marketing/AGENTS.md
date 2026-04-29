# Marketing And Remotion Instructions

This subtree contains the Remotion/React project used for App Store marketing and screenshot stills.

## Project Facts

- Package root: `marketing`
- Main Remotion root: `marketing/src/Root.tsx`
- Components live under `marketing/src/components`.
- Screenshot sizes and device mappings live in `marketing/src/apple-screenshot-sizes.ts` and `marketing/src/screenshot-collections.ts`.
- Localized marketing copy lives in `marketing/src/i18n/translations.ts`.
- Public assets live under `marketing/public`.
- Generated outputs include `marketing/out`, `marketing/dist`, and `marketing/storybook-static`; do not edit generated output by hand.

## Commands

- Install dependencies when needed: `npm install`
- Remotion studio: `npm run dev`
- Lint and typecheck: `npm run lint`
- Storybook: `npm run storybook`
- Build Storybook: `npm run build-storybook`
- Render default still: `npm run render`
- Export German stills: `npm run export:de`
- Export English stills: `npm run export:en`
- Export all stills: `npm run export:all`
- Start image server: `npm run server`

Some scripts call `bun` internally. Use the package scripts instead of rewriting the script commands unless the task is specifically about script maintenance.

## Remotion Patterns

- Define stills in `Root.tsx` using stable component references.
- Keep screenshot dimensions tied to the Apple screenshot size registry.
- Use existing screenshot context components instead of ad hoc layout globals.
- Use `staticFile()` for public assets and keep paths relative to `marketing/public`.
- Keep locale handling restricted to supported locales unless the task includes localization expansion.
- For text changes, update both `de-DE` and `en-US` translations when applicable.

## Validation

- Run `npm run lint` for TypeScript or React changes.
- For visual changes, run Storybook or Remotion Studio and inspect the affected compositions.
- For export pipeline changes, run the narrowest relevant export command before `export:all`.
- Do not upload screenshots or sync App Store assets from this directory unless explicitly requested.
