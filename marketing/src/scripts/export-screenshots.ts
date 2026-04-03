#!/usr/bin/env bun
import { renderStill, getCompositions } from "@remotion/renderer";
import { bundle } from "@remotion/bundler";
import {
  iPhoneDevices,
  iPadDevices,
  AppleWatchDevices,
} from "../apple-screenshot-sizes";
import path from "path";
import fs from "fs";

const OUTPUT_DIR = "./out/screenshots";

interface ExportOptions {
  device?: string;
  displaySize?: string;
  orientation?: "portrait" | "landscape";
  output?: string;
  locale?: "de-DE" | "en-US";
  list?: boolean;
}

interface DeviceInfo {
  name: string;
  dimensions: { width: number; height: number };
  orientation: "portrait" | "landscape";
  platform: string;
}

function getAllDevices(): DeviceInfo[] {
  const devices: DeviceInfo[] = [];

  for (const [displaySize, deviceList] of Object.entries(iPhoneDevices)) {
    for (const device of deviceList) {
      devices.push({
        name: device.name,
        dimensions: device.portrait,
        orientation: "portrait",
        platform: `iPhone ${displaySize}`,
      });
      devices.push({
        name: device.name,
        dimensions: device.landscape,
        orientation: "landscape",
        platform: `iPhone ${displaySize}`,
      });
    }
  }

  for (const [displaySize, deviceList] of Object.entries(iPadDevices)) {
    for (const device of deviceList) {
      devices.push({
        name: device.name,
        dimensions: device.portrait,
        orientation: "portrait",
        platform: `iPad ${displaySize}`,
      });
      devices.push({
        name: device.name,
        dimensions: device.landscape,
        orientation: "landscape",
        platform: `iPad ${displaySize}`,
      });
    }
  }

  for (const device of AppleWatchDevices.all) {
    devices.push({
      name: device.name,
      dimensions: device.portrait,
      orientation: "portrait",
      platform: "Apple Watch",
    });
  }

  return devices;
}

function listDevices() {
  const devices = getAllDevices();
  console.log("\n📱 Available devices for export:\n");

  let currentPlatform = "";
  for (const device of devices) {
    if (device.platform !== currentPlatform) {
      currentPlatform = device.platform;
      console.log(`\n${currentPlatform}:`);
    }
    console.log(
      `  ${device.name} (${device.orientation}) - ${device.dimensions.width}x${device.dimensions.height}`,
    );
  }
  console.log("\n");
}

async function exportScreenshot(
  compositionId: string,
  outputPath: string,
  width: number,
  height: number,
  locale: "de-DE" | "en-US" = "de-DE",
) {
  console.log(
    `📦 Exporting ${compositionId} [${locale}] (${width}x${height}) to ${outputPath}...`,
  );

  const bundlePath = await bundle({
    entryPoint: path.join(process.cwd(), "src/index.ts"),
    outDir: path.join(process.cwd(), ".remotion/bundle"),
  });

  const comps = await getCompositions(bundlePath, {
    inputProps: { locale },
  });
  const composition = comps.find((c) => c.id === compositionId);

  if (!composition) {
    throw new Error(`No composition with the ID ${compositionId} found`);
  }

  await renderStill({
    composition,
    serveUrl: bundlePath,
    output: outputPath,
    inputProps: { locale },
  });

  console.log(`✅ Exported: ${outputPath}`);
}

async function main() {
  const args = process.argv.slice(2);
  const options: ExportOptions = {};

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case "--list":
      case "-l":
        options.list = true;
        break;
      case "--device":
      case "-d":
        options.device = args[++i];
        break;
      case "--display-size":
      case "-s":
        options.displaySize = args[++i];
        break;
      case "--orientation":
      case "-o":
        options.orientation = args[++i] as "portrait" | "landscape";
        break;
      case "--output":
      case "-out":
        options.output = args[++i];
        break;
      case "--locale":
      case "-loc":
        options.locale = args[++i] as "de-DE" | "en-US";
        break;
      case "--help":
      case "-h":
        printHelp();
        process.exit(0);
    }
  }

  if (options.list) {
    listDevices();
    return;
  }

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const devices = getAllDevices();

  let filtered = devices;
  if (options.device) {
    filtered = filtered.filter((d) =>
      d.name.toLowerCase().includes(options.device!.toLowerCase()),
    );
  }
  if (options.displaySize) {
    filtered = filtered.filter((d) =>
      d.platform.toLowerCase().includes(options.displaySize!.toLowerCase()),
    );
  }
  if (options.orientation) {
    filtered = filtered.filter((d) => d.orientation === options.orientation);
  }

  if (filtered.length === 0) {
    console.log(
      "❌ No devices found matching criteria. Use --list to see available devices.",
    );
    process.exit(1);
  }

  console.log(`\n🎯 Exporting ${filtered.length} screenshot(s)...\n`);

  for (const device of filtered) {
    const filename =
      options.output ||
      `${device.name.replace(/\s+/g, "-")}-${device.orientation}.png`;
    const outputPath = path.join(OUTPUT_DIR, filename);

    console.log(
      `  ${device.name} (${device.orientation}): ${device.dimensions.width}x${device.dimensions.height} -> ${outputPath}`,
    );

    try {
      await exportScreenshot(
        "moers-festival-17-pro",
        outputPath,
        device.dimensions.width,
        device.dimensions.height,
        options.locale ?? "de-DE",
      );
    } catch (e) {
      console.log(`  ⚠️  Could not export (composition may not exist): ${e}`);
    }
  }

  console.log("\n✅ Export complete!");
}

function printHelp() {
  console.log(`
📸 Screenshot Export CLI

Usage: bun run src/scripts/export-screenshots.ts [options]

Options:
  -l, --list              List all available devices
  -d, --device <name>    Filter by device name (e.g., "iPhone 15 Pro")
  -s, --display-size <size>  Filter by display size (e.g., "6.1\\"", "11\\"")
  -o, --orientation <portrait|landscape>  Filter by orientation
  -out, --output <file>   Output filename
  -h, --help             Show this help

Examples:
  # List all available devices
  bun run src/scripts/export-screenshots.ts --list

  # Export all iPhone 15 Pro screenshots
  bun run src/scripts/export-screenshots.ts --device "iPhone 15 Pro"

  # Export all 6.1" iPhones in portrait
  bun run src/scripts/export-screenshots.ts --display-size '6.1"' --orientation portrait

  # Export all iPad 11" landscape screenshots
  bun run src/scripts/export-screenshots.ts --display-size '11"' --orientation landscape
`);
}

main();
