#!/usr/bin/env bun
/**
 * Renders all registered compositions and slices them into individual
 * App Store screenshots ready for upload.
 *
 * Usage:
 *   bun run src/scripts/export-stills.ts [--locale de-DE|en-US] [--out ./out/screenshots]
 */

import { execSync } from "child_process";
import path from "path";
import fs from "fs";
import { screenshotCollections, INTER_SCREENSHOT_SPACING } from "../Root";

// ── CLI args ──────────────────────────────────────────────────────────────────

const args = process.argv.slice(2);
let locale: "de-DE" | "en-US" = "de-DE";
let outDir = "./out/screenshots";

for (let i = 0; i < args.length; i++) {
  if ((args[i] === "--locale" || args[i] === "-l") && args[i + 1]) {
    locale = args[++i] as "de-DE" | "en-US";
  } else if ((args[i] === "--out" || args[i] === "-o") && args[i + 1]) {
    outDir = args[++i];
  }
}

// ── Render all registered compositions ─────────────────────────────────────

const localeOutDir = path.join(outDir, locale);

fs.mkdirSync(localeOutDir, { recursive: true });

console.log(`\n🎨 Rendering ${screenshotCollections.length} compositions for [${locale}]...\n`);

let totalRendered = 0;

for (const collection of screenshotCollections) {
  const SLOT_WIDTH = collection.screenshotSize.width;
  const SLOT_HEIGHT = collection.screenshotSize.height;
  const NUM_SLOTS = collection.numberOfScreens;
  const SPACING = INTER_SCREENSHOT_SPACING;

  const compositionDir = path.join(localeOutDir, collection.name);
  fs.mkdirSync(compositionDir, { recursive: true });

  const widePng = path.join(compositionDir, "_wide.png");

  console.log(`📐 Rendering ${collection.name} (${SLOT_WIDTH}x${SLOT_HEIGHT}, ${NUM_SLOTS} screens)...`);

  execSync(
    `npx remotion still "${collection.name}" "${widePng}" --props '{"locale":"${locale}"}'`,
    { stdio: "inherit" },
  );

  console.log(`✂️  Slicing into ${NUM_SLOTS} screenshots...`);

  for (let i = 0; i < NUM_SLOTS; i++) {
    const x = i * (SLOT_WIDTH + SPACING);
    const outFile = path.join(compositionDir, `${String(i + 1).padStart(2, "0")}.png`);

    execSync(
      `magick "${widePng}" -crop ${SLOT_WIDTH}x${SLOT_HEIGHT}+${x}+0 +repage "${outFile}"`,
      { stdio: "inherit" },
    );

    console.log(`  ✅ ${path.basename(outFile)} (x=${x})`);
    totalRendered++;
  }

  fs.unlinkSync(widePng);
}

console.log(`\n🚀 Done! Rendered ${totalRendered} screenshots to ${localeOutDir}\n`);
