#!/usr/bin/env bun
/**
 * Renders registered Instagram carousel compositions and slices each wide still
 * into named 1080x1440 slides.
 *
 * Usage:
 *   bun run src/scripts/export-instagram-carousels.ts [--locale de-DE|en-US] [--out ./out/instagram]
 */

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import {
  instagramCarouselCollections,
  INTER_SCREENSHOT_SPACING,
} from "../Root";

type Locale = "de-DE" | "en-US";

interface InstagramCarouselCollection {
  name: string;
  slideNames: string[];
  screenshotSize: {
    width: number;
    height: number;
  };
}

interface CliOptions {
  locale: Locale;
  outDir: string;
}

function parseArgs(args: string[]): CliOptions {
  const options: CliOptions = {
    locale: "de-DE",
    outDir: "./out/instagram",
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];

    if (arg === "--locale" || arg === "-l") {
      const locale = args[++i];

      if (locale !== "de-DE" && locale !== "en-US") {
        throw new Error("Expected --locale to be de-DE or en-US.");
      }

      options.locale = locale;
      continue;
    }

    if (arg === "--out" || arg === "-o") {
      const outDir = args[++i];

      if (!outDir) {
        throw new Error("Expected --out to be followed by a directory.");
      }

      options.outDir = outDir;
      continue;
    }

    if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    }

    throw new Error(`Unknown argument: ${arg}`);
  }

  return options;
}

function run(command: string, args: string[]) {
  const result = spawnSync(command, args, {
    stdio: "inherit",
  });

  if (result.error) {
    throw result.error;
  }

  if (result.status !== 0) {
    throw new Error(`${command} exited with status ${result.status ?? "unknown"}.`);
  }
}

function renderWideStill(
  collection: InstagramCarouselCollection,
  widePng: string,
  locale: Locale,
) {
  run("npx", [
    "remotion",
    "still",
    collection.name,
    widePng,
    "--props",
    JSON.stringify({ locale }),
  ]);
}

function getSlideFileName(index: number, name: string) {
  return `${String(index + 1).padStart(2, "0")}-${name}.png`;
}

function sliceSlides(
  collection: InstagramCarouselCollection,
  widePng: string,
  compositionDir: string,
) {
  const { width, height } = collection.screenshotSize;

  for (let i = 0; i < collection.slideNames.length; i++) {
    const x = i * (width + INTER_SCREENSHOT_SPACING);
    const outFile = path.join(
      compositionDir,
      getSlideFileName(i, collection.slideNames[i]),
    );

    run("magick", [
      widePng,
      "-crop",
      `${width}x${height}+${x}+0`,
      "+repage",
      outFile,
    ]);

    console.log(`  Wrote ${path.basename(outFile)} from x=${x}`);
  }
}

function printHelp() {
  console.log(`
Instagram carousel export

Usage:
  bun run src/scripts/export-instagram-carousels.ts [--locale de-DE|en-US] [--out ./out/instagram]

Options:
  -l, --locale <locale>  Locale to render. Supported: de-DE, en-US.
  -o, --out <dir>        Output root directory. Default: ./out/instagram.
  -h, --help             Show this help.
`);
}

function main() {
  const options = parseArgs(process.argv.slice(2));
  const collections: readonly InstagramCarouselCollection[] =
    instagramCarouselCollections;
  const localeOutDir = path.join(options.outDir, options.locale);

  fs.mkdirSync(localeOutDir, { recursive: true });

  console.log(
    `Rendering ${collections.length} Instagram carousel collection(s) for ${options.locale}.`,
  );

  for (const collection of collections) {
    const compositionDir = path.join(localeOutDir, collection.name);
    const widePng = path.join(compositionDir, "_wide.png");

    fs.mkdirSync(compositionDir, { recursive: true });

    try {
      console.log(`Rendering ${collection.name} wide still...`);
      renderWideStill(collection, widePng, options.locale);

      console.log(
        `Slicing ${collection.name} into ${collection.slideNames.length} slides...`,
      );
      sliceSlides(collection, widePng, compositionDir);
    } finally {
      if (fs.existsSync(widePng)) {
        fs.unlinkSync(widePng);
      }
    }
  }

  console.log(`Done. Instagram carousel slides written to ${localeOutDir}.`);
}

main();
