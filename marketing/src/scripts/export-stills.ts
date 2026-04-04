#!/usr/bin/env bun
/**
 * Renders the festival promo wide canvas and slices it into individual
 * App Store screenshots ready for upload.
 *
 * Usage:
 *   bun run src/scripts/export-stills.ts [--locale de-DE|en-US] [--out ./out/screenshots]
 */

import { execSync } from "child_process";
import path from "path";
import fs from "fs";

// ── Config ────────────────────────────────────────────────────────────────────

const COMPOSITION_ID = "moers-festival-17-pro";
const SLOT_WIDTH = 1206;
const SLOT_HEIGHT = 2622;
const SPACING = 20;
const NUM_SLOTS = 4;

const SLOT_NAMES = [
  "01-timetable",
  "02-event-detail",
  "03-info",
  "04-map",
];

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

// ── Paths ─────────────────────────────────────────────────────────────────────

const localeOutDir = path.join(outDir, locale);
const widePng = path.join(localeOutDir, "_wide.png");

fs.mkdirSync(localeOutDir, { recursive: true });

// ── Step 1: Render wide canvas ────────────────────────────────────────────────

console.log(`\n🎨 Rendering wide canvas [${locale}]...`);

execSync(
  `npx remotion still ${COMPOSITION_ID} "${widePng}" --props '{"locale":"${locale}"}'`,
  { stdio: "inherit" },
);

// ── Step 2: Slice into individual screenshots ─────────────────────────────────

console.log(`\n✂️  Slicing into ${NUM_SLOTS} screenshots...`);

for (let i = 0; i < NUM_SLOTS; i++) {
  const x = i * (SLOT_WIDTH + SPACING);
  const outFile = path.join(localeOutDir, `${SLOT_NAMES[i]}.png`);

  execSync(
    `magick "${widePng}" -crop ${SLOT_WIDTH}x${SLOT_HEIGHT}+${x}+0 +repage "${outFile}"`,
    { stdio: "inherit" },
  );

  console.log(`  ✅ ${path.basename(outFile)} (x=${x})`);
}

// ── Step 3: Clean up wide canvas ─────────────────────────────────────────────

fs.unlinkSync(widePng);

console.log(`\n🚀 Done! Screenshots saved to ${localeOutDir}\n`);
