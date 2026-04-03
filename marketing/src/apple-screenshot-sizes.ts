// Apple App Store Screenshot Sizes Library
// Provides typed access to screenshot dimensions for various Apple devices

export type Platform =
  | "iPhone"
  | "iPad"
  | "Mac"
  | "AppleTV"
  | "AppleVisionPro"
  | "AppleWatch";
export type Orientation = "portrait" | "landscape";

export interface ScreenshotSize {
  width: number;
  height: number;
  orientation: Orientation;
  description?: string;
}

// Device with portrait/landscape accessors
export interface DeviceScreenshot {
  name: string;
  portrait: ScreenshotSize;
  landscape: ScreenshotSize;
}

// Device with multiple screenshot sizes
export interface DeviceMultiScreenshot {
  name: string;
  screenshotSizes: ScreenshotSize[];
}

// =============================================================================
// iPhone Devices
// =============================================================================

// 6.9" Display
export const iPhoneAir: DeviceScreenshot = {
  name: "iPhone Air",
  portrait: { width: 1260, height: 2736, orientation: "portrait" },
  landscape: { width: 2736, height: 1260, orientation: "landscape" },
};
export const iPhone17ProMax: DeviceScreenshot = {
  name: "iPhone 17 Pro Max",
  portrait: { width: 1260, height: 2736, orientation: "portrait" },
  landscape: { width: 2736, height: 1260, orientation: "landscape" },
};
export const iPhone16ProMax: DeviceScreenshot = {
  name: "iPhone 16 Pro Max",
  portrait: { width: 1260, height: 2736, orientation: "portrait" },
  landscape: { width: 2736, height: 1260, orientation: "landscape" },
};
export const iPhone16Plus: DeviceScreenshot = {
  name: "iPhone 16 Plus",
  portrait: { width: 1260, height: 2736, orientation: "portrait" },
  landscape: { width: 2736, height: 1260, orientation: "landscape" },
};
export const iPhone15ProMax: DeviceScreenshot = {
  name: "iPhone 15 Pro Max",
  portrait: { width: 1260, height: 2736, orientation: "portrait" },
  landscape: { width: 2736, height: 1260, orientation: "landscape" },
};
export const iPhone15Plus: DeviceScreenshot = {
  name: "iPhone 15 Plus",
  portrait: { width: 1260, height: 2736, orientation: "portrait" },
  landscape: { width: 2736, height: 1260, orientation: "landscape" },
};
export const iPhone14ProMax: DeviceScreenshot = {
  name: "iPhone 14 Pro Max",
  portrait: { width: 1260, height: 2736, orientation: "portrait" },
  landscape: { width: 2736, height: 1260, orientation: "landscape" },
};

// 6.5" Display
export const iPhone14Plus: DeviceScreenshot = {
  name: "iPhone 14 Plus",
  portrait: { width: 1284, height: 2778, orientation: "portrait" },
  landscape: { width: 2778, height: 1284, orientation: "landscape" },
};
export const iPhone13ProMax: DeviceScreenshot = {
  name: "iPhone 13 Pro Max",
  portrait: { width: 1284, height: 2778, orientation: "portrait" },
  landscape: { width: 2778, height: 1284, orientation: "landscape" },
};
export const iPhone12ProMax: DeviceScreenshot = {
  name: "iPhone 12 Pro Max",
  portrait: { width: 1284, height: 2778, orientation: "portrait" },
  landscape: { width: 2778, height: 1284, orientation: "landscape" },
};
export const iPhone11ProMax: DeviceScreenshot = {
  name: "iPhone 11 Pro Max",
  portrait: { width: 1242, height: 2688, orientation: "portrait" },
  landscape: { width: 2688, height: 1242, orientation: "landscape" },
};
export const iPhone11: DeviceScreenshot = {
  name: "iPhone 11",
  portrait: { width: 1242, height: 2688, orientation: "portrait" },
  landscape: { width: 2688, height: 1242, orientation: "landscape" },
};
export const iPhoneXSMax: DeviceScreenshot = {
  name: "iPhone XS Max",
  portrait: { width: 1242, height: 2688, orientation: "portrait" },
  landscape: { width: 2688, height: 1242, orientation: "landscape" },
};
export const iPhoneXR: DeviceScreenshot = {
  name: "iPhone XR",
  portrait: { width: 1242, height: 2688, orientation: "portrait" },
  landscape: { width: 2688, height: 1242, orientation: "landscape" },
};

// 6.3" Display
export const iPhone17Pro: DeviceScreenshot = {
  name: "iPhone 17 Pro",
  portrait: { width: 1206, height: 2622, orientation: "portrait" },
  landscape: { width: 2622, height: 1206, orientation: "landscape" },
};
export const iPhone17: DeviceScreenshot = {
  name: "iPhone 17",
  portrait: { width: 1179, height: 2556, orientation: "portrait" },
  landscape: { width: 2556, height: 1179, orientation: "landscape" },
};
export const iPhone16Pro: DeviceScreenshot = {
  name: "iPhone 16 Pro",
  portrait: { width: 1206, height: 2622, orientation: "portrait" },
  landscape: { width: 2622, height: 1206, orientation: "landscape" },
};
export const iPhone16: DeviceScreenshot = {
  name: "iPhone 16",
  portrait: { width: 1179, height: 2556, orientation: "portrait" },
  landscape: { width: 2556, height: 1179, orientation: "landscape" },
};
export const iPhone15Pro: DeviceScreenshot = {
  name: "iPhone 15 Pro",
  portrait: { width: 1179, height: 2556, orientation: "portrait" },
  landscape: { width: 2556, height: 1179, orientation: "landscape" },
};
export const iPhone15: DeviceScreenshot = {
  name: "iPhone 15",
  portrait: { width: 1179, height: 2556, orientation: "portrait" },
  landscape: { width: 2556, height: 1179, orientation: "landscape" },
};
export const iPhone14Pro: DeviceScreenshot = {
  name: "iPhone 14 Pro",
  portrait: { width: 1179, height: 2556, orientation: "portrait" },
  landscape: { width: 2556, height: 1179, orientation: "landscape" },
};

// 6.1" Display
export const iPhone17e: DeviceScreenshot = {
  name: "iPhone 17e",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone16e: DeviceScreenshot = {
  name: "iPhone 16e",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone14: DeviceScreenshot = {
  name: "iPhone 14",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone13Pro: DeviceScreenshot = {
  name: "iPhone 13 Pro",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone13: DeviceScreenshot = {
  name: "iPhone 13",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone13Mini: DeviceScreenshot = {
  name: "iPhone 13 mini",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone12Pro: DeviceScreenshot = {
  name: "iPhone 12 Pro",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone12: DeviceScreenshot = {
  name: "iPhone 12",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone12Mini: DeviceScreenshot = {
  name: "iPhone 12 mini",
  portrait: { width: 1170, height: 2532, orientation: "portrait" },
  landscape: { width: 2532, height: 1170, orientation: "landscape" },
};
export const iPhone11Pro: DeviceScreenshot = {
  name: "iPhone 11 Pro",
  portrait: { width: 1125, height: 2436, orientation: "portrait" },
  landscape: { width: 2436, height: 1125, orientation: "landscape" },
};
export const iPhoneXS: DeviceScreenshot = {
  name: "iPhone XS",
  portrait: { width: 1125, height: 2436, orientation: "portrait" },
  landscape: { width: 2436, height: 1125, orientation: "landscape" },
};
export const iPhoneX: DeviceScreenshot = {
  name: "iPhone X",
  portrait: { width: 1125, height: 2436, orientation: "portrait" },
  landscape: { width: 2436, height: 1125, orientation: "landscape" },
};

// 5.5" Display
export const iPhone8Plus: DeviceScreenshot = {
  name: "iPhone 8 Plus",
  portrait: { width: 1242, height: 2208, orientation: "portrait" },
  landscape: { width: 2208, height: 1242, orientation: "landscape" },
};
export const iPhone7Plus: DeviceScreenshot = {
  name: "iPhone 7 Plus",
  portrait: { width: 1242, height: 2208, orientation: "portrait" },
  landscape: { width: 2208, height: 1242, orientation: "landscape" },
};
export const iPhone6SPlus: DeviceScreenshot = {
  name: "iPhone 6S Plus",
  portrait: { width: 1242, height: 2208, orientation: "portrait" },
  landscape: { width: 2208, height: 1242, orientation: "landscape" },
};
export const iPhone6Plus: DeviceScreenshot = {
  name: "iPhone 6 Plus",
  portrait: { width: 1242, height: 2208, orientation: "portrait" },
  landscape: { width: 2208, height: 1242, orientation: "landscape" },
};

// 4.7" Display
export const iPhoneSE3rdGen: DeviceScreenshot = {
  name: "iPhone SE (3rd generation)",
  portrait: { width: 750, height: 1334, orientation: "portrait" },
  landscape: { width: 1334, height: 750, orientation: "landscape" },
};
export const iPhoneSE2ndGen: DeviceScreenshot = {
  name: "iPhone SE (2nd generation)",
  portrait: { width: 750, height: 1334, orientation: "portrait" },
  landscape: { width: 1334, height: 750, orientation: "landscape" },
};
export const iPhone8: DeviceScreenshot = {
  name: "iPhone 8",
  portrait: { width: 750, height: 1334, orientation: "portrait" },
  landscape: { width: 1334, height: 750, orientation: "landscape" },
};
export const iPhone7: DeviceScreenshot = {
  name: "iPhone 7",
  portrait: { width: 750, height: 1334, orientation: "portrait" },
  landscape: { width: 1334, height: 750, orientation: "landscape" },
};
export const iPhone6S: DeviceScreenshot = {
  name: "iPhone 6S",
  portrait: { width: 750, height: 1334, orientation: "portrait" },
  landscape: { width: 1334, height: 750, orientation: "landscape" },
};
export const iPhone6: DeviceScreenshot = {
  name: "iPhone 6",
  portrait: { width: 750, height: 1334, orientation: "portrait" },
  landscape: { width: 1334, height: 750, orientation: "landscape" },
};

// 4" Display
export const iPhoneSE1stGen: DeviceScreenshot = {
  name: "iPhone SE (1st generation)",
  portrait: { width: 640, height: 1136, orientation: "portrait" },
  landscape: { width: 1136, height: 640, orientation: "landscape" },
};
export const iPhone5S: DeviceScreenshot = {
  name: "iPhone 5S",
  portrait: { width: 640, height: 1136, orientation: "portrait" },
  landscape: { width: 1136, height: 640, orientation: "landscape" },
};
export const iPhone5C: DeviceScreenshot = {
  name: "iPhone 5C",
  portrait: { width: 640, height: 1136, orientation: "portrait" },
  landscape: { width: 1136, height: 640, orientation: "landscape" },
};
export const iPhone5: DeviceScreenshot = {
  name: "iPhone 5",
  portrait: { width: 640, height: 1136, orientation: "portrait" },
  landscape: { width: 1136, height: 640, orientation: "landscape" },
};

// 3.5" Display
export const iPhone4S: DeviceScreenshot = {
  name: "iPhone 4S",
  portrait: { width: 640, height: 960, orientation: "portrait" },
  landscape: { width: 960, height: 640, orientation: "landscape" },
};
export const iPhone4: DeviceScreenshot = {
  name: "iPhone 4",
  portrait: { width: 640, height: 960, orientation: "portrait" },
  landscape: { width: 960, height: 640, orientation: "landscape" },
};

// =============================================================================
// iPad Devices
// =============================================================================

// 13" Display
export const iPadPro13M5: DeviceScreenshot = {
  name: "iPad Pro (M5)",
  portrait: { width: 2064, height: 2752, orientation: "portrait" },
  landscape: { width: 2752, height: 2064, orientation: "landscape" },
};
export const iPadPro13M4: DeviceScreenshot = {
  name: "iPad Pro (M4)",
  portrait: { width: 2064, height: 2752, orientation: "portrait" },
  landscape: { width: 2752, height: 2064, orientation: "landscape" },
};
export const iPadPro13Gen6: DeviceScreenshot = {
  name: "iPad Pro (6th generation)",
  portrait: { width: 2064, height: 2752, orientation: "portrait" },
  landscape: { width: 2752, height: 2064, orientation: "landscape" },
};
export const iPadPro13Gen5: DeviceScreenshot = {
  name: "iPad Pro (5th generation)",
  portrait: { width: 2048, height: 2732, orientation: "portrait" },
  landscape: { width: 2732, height: 2048, orientation: "landscape" },
};
export const iPadPro13Gen4: DeviceScreenshot = {
  name: "iPad Pro (4th generation)",
  portrait: { width: 2048, height: 2732, orientation: "portrait" },
  landscape: { width: 2732, height: 2048, orientation: "landscape" },
};
export const iPadPro13Gen3: DeviceScreenshot = {
  name: "iPad Pro (3rd generation)",
  portrait: { width: 2048, height: 2732, orientation: "portrait" },
  landscape: { width: 2732, height: 2048, orientation: "landscape" },
};
export const iPadPro13Gen1: DeviceScreenshot = {
  name: "iPad Pro (1st generation)",
  portrait: { width: 2048, height: 2732, orientation: "portrait" },
  landscape: { width: 2732, height: 2048, orientation: "landscape" },
};
export const iPadAir13M4: DeviceScreenshot = {
  name: "iPad Air (M4)",
  portrait: { width: 2064, height: 2752, orientation: "portrait" },
  landscape: { width: 2752, height: 2064, orientation: "landscape" },
};
export const iPadAir13M3: DeviceScreenshot = {
  name: "iPad Air (M3)",
  portrait: { width: 2064, height: 2752, orientation: "portrait" },
  landscape: { width: 2752, height: 2064, orientation: "landscape" },
};
export const iPadAir13M2: DeviceScreenshot = {
  name: "iPad Air (M2)",
  portrait: { width: 2064, height: 2752, orientation: "portrait" },
  landscape: { width: 2752, height: 2064, orientation: "landscape" },
};

// 12.9" Display
export const iPadPro12_9Gen2: DeviceScreenshot = {
  name: "iPad Pro (2nd generation)",
  portrait: { width: 2048, height: 2732, orientation: "portrait" },
  landscape: { width: 2732, height: 2048, orientation: "landscape" },
};

// 11" Display
export const iPadPro11M5: DeviceScreenshot = {
  name: "iPad Pro (M5)",
  portrait: { width: 1488, height: 2266, orientation: "portrait" },
  landscape: { width: 2266, height: 1488, orientation: "landscape" },
};
export const iPadPro11M4: DeviceScreenshot = {
  name: "iPad Pro (M4)",
  portrait: { width: 1488, height: 2266, orientation: "portrait" },
  landscape: { width: 2266, height: 1488, orientation: "landscape" },
};
export const iPadPro11Gen4: DeviceScreenshot = {
  name: "iPad Pro (4th generation)",
  portrait: { width: 1668, height: 2388, orientation: "portrait" },
  landscape: { width: 2388, height: 1668, orientation: "landscape" },
};
export const iPadPro11Gen3: DeviceScreenshot = {
  name: "iPad Pro (3rd generation)",
  portrait: { width: 1668, height: 2388, orientation: "portrait" },
  landscape: { width: 2388, height: 1668, orientation: "landscape" },
};
export const iPadPro11Gen2: DeviceScreenshot = {
  name: "iPad Pro (2nd generation)",
  portrait: { width: 1668, height: 2388, orientation: "portrait" },
  landscape: { width: 2388, height: 1668, orientation: "landscape" },
};
export const iPadPro11Gen1: DeviceScreenshot = {
  name: "iPad Pro (1st generation)",
  portrait: { width: 1668, height: 2388, orientation: "portrait" },
  landscape: { width: 2388, height: 1668, orientation: "landscape" },
};
export const iPadAir11M4: DeviceScreenshot = {
  name: "iPad Air (M4)",
  portrait: { width: 1640, height: 2360, orientation: "portrait" },
  landscape: { width: 2360, height: 1640, orientation: "landscape" },
};
export const iPadAir11M3: DeviceScreenshot = {
  name: "iPad Air (M3)",
  portrait: { width: 1640, height: 2360, orientation: "portrait" },
  landscape: { width: 2360, height: 1640, orientation: "landscape" },
};
export const iPadAir11M2: DeviceScreenshot = {
  name: "iPad Air (M2)",
  portrait: { width: 1640, height: 2360, orientation: "portrait" },
  landscape: { width: 2360, height: 1640, orientation: "landscape" },
};
export const iPadAir11Gen5: DeviceScreenshot = {
  name: "iPad Air (5th generation)",
  portrait: { width: 1640, height: 2360, orientation: "portrait" },
  landscape: { width: 2360, height: 1640, orientation: "landscape" },
};
export const iPadAir11Gen4: DeviceScreenshot = {
  name: "iPad Air (4th generation)",
  portrait: { width: 1640, height: 2360, orientation: "portrait" },
  landscape: { width: 2360, height: 1640, orientation: "landscape" },
};
export const iPad10Gen: DeviceScreenshot = {
  name: "iPad (10th generation)",
  portrait: { width: 1640, height: 2360, orientation: "portrait" },
  landscape: { width: 2360, height: 1640, orientation: "landscape" },
};
export const iPadMiniA17Pro: DeviceScreenshot = {
  name: "iPad mini (A17 Pro)",
  portrait: { width: 1640, height: 2360, orientation: "portrait" },
  landscape: { width: 2360, height: 1640, orientation: "landscape" },
};
export const iPadMini6: DeviceScreenshot = {
  name: "iPad mini (6th generation)",
  portrait: { width: 1640, height: 2360, orientation: "portrait" },
  landscape: { width: 2360, height: 1640, orientation: "landscape" },
};

// 10.5" Display
export const iPadPro10_5: DeviceScreenshot = {
  name: "iPad Pro",
  portrait: { width: 1668, height: 2224, orientation: "portrait" },
  landscape: { width: 2224, height: 1668, orientation: "landscape" },
};
export const iPadAir3: DeviceScreenshot = {
  name: "iPad Air (3rd generation)",
  portrait: { width: 1668, height: 2224, orientation: "portrait" },
  landscape: { width: 2224, height: 1668, orientation: "landscape" },
};
export const iPad9: DeviceScreenshot = {
  name: "iPad (9th generation)",
  portrait: { width: 1668, height: 2224, orientation: "portrait" },
  landscape: { width: 2224, height: 1668, orientation: "landscape" },
};
export const iPad8: DeviceScreenshot = {
  name: "iPad (8th generation)",
  portrait: { width: 1668, height: 2224, orientation: "portrait" },
  landscape: { width: 2224, height: 1668, orientation: "landscape" },
};
export const iPad7: DeviceScreenshot = {
  name: "iPad (7th generation)",
  portrait: { width: 1668, height: 2224, orientation: "portrait" },
  landscape: { width: 2224, height: 1668, orientation: "landscape" },
};

// 9.7" Display
export const iPadPro9_7: DeviceScreenshot = {
  name: "iPad Pro",
  portrait: { width: 1536, height: 2048, orientation: "portrait" },
  landscape: { width: 2048, height: 1536, orientation: "landscape" },
};
export const iPadAir: DeviceScreenshot = {
  name: "iPad Air",
  portrait: { width: 1536, height: 2048, orientation: "portrait" },
  landscape: { width: 2048, height: 1536, orientation: "landscape" },
};
export const iPadAir2: DeviceScreenshot = {
  name: "iPad Air 2",
  portrait: { width: 1536, height: 2048, orientation: "portrait" },
  landscape: { width: 2048, height: 1536, orientation: "landscape" },
};
export const iPadGen: DeviceScreenshot = {
  name: "iPad",
  portrait: { width: 1536, height: 2048, orientation: "portrait" },
  landscape: { width: 2048, height: 1536, orientation: "landscape" },
};
export const iPad2: DeviceScreenshot = {
  name: "iPad 2",
  portrait: { width: 768, height: 1024, orientation: "portrait" },
  landscape: { width: 1024, height: 768, orientation: "landscape" },
};
export const iPad6: DeviceScreenshot = {
  name: "iPad (6th generation)",
  portrait: { width: 1536, height: 2048, orientation: "portrait" },
  landscape: { width: 2048, height: 1536, orientation: "landscape" },
};
export const iPad5: DeviceScreenshot = {
  name: "iPad (5th generation)",
  portrait: { width: 1536, height: 2048, orientation: "portrait" },
  landscape: { width: 2048, height: 1536, orientation: "landscape" },
};
export const iPad4: DeviceScreenshot = {
  name: "iPad (4th generation)",
  portrait: { width: 1536, height: 2048, orientation: "portrait" },
  landscape: { width: 2048, height: 1536, orientation: "landscape" },
};
export const iPad3: DeviceScreenshot = {
  name: "iPad (3rd generation)",
  portrait: { width: 1536, height: 2048, orientation: "portrait" },
  landscape: { width: 2048, height: 1536, orientation: "landscape" },
};
export const iPadMini5: DeviceScreenshot = {
  name: "iPad mini (5th generation)",
  portrait: { width: 768, height: 1024, orientation: "portrait" },
  landscape: { width: 1024, height: 768, orientation: "landscape" },
};
export const iPadMini4: DeviceScreenshot = {
  name: "iPad mini 4",
  portrait: { width: 768, height: 1024, orientation: "portrait" },
  landscape: { width: 1024, height: 768, orientation: "landscape" },
};
export const iPadMini3: DeviceScreenshot = {
  name: "iPad mini 3",
  portrait: { width: 768, height: 1024, orientation: "portrait" },
  landscape: { width: 1024, height: 768, orientation: "landscape" },
};
export const iPadMini2: DeviceScreenshot = {
  name: "iPad mini 2",
  portrait: { width: 768, height: 1024, orientation: "portrait" },
  landscape: { width: 1024, height: 768, orientation: "landscape" },
};

// =============================================================================
// Mac
// =============================================================================

export const Mac: DeviceMultiScreenshot = {
  name: "Mac",
  screenshotSizes: [
    { width: 1280, height: 800, orientation: "landscape" },
    { width: 1440, height: 900, orientation: "landscape" },
    { width: 2560, height: 1600, orientation: "landscape" },
    { width: 2880, height: 1800, orientation: "landscape" },
  ],
};

// =============================================================================
// Apple TV
// =============================================================================

export const AppleTV: DeviceMultiScreenshot = {
  name: "Apple TV",
  screenshotSizes: [
    { width: 1920, height: 1080, orientation: "landscape" },
    { width: 3840, height: 2160, orientation: "landscape" },
  ],
};

// =============================================================================
// Apple Vision Pro
// =============================================================================

export const AppleVisionPro: DeviceScreenshot = {
  name: "Apple Vision Pro",
  portrait: { width: 3840, height: 2160, orientation: "landscape" },
  landscape: { width: 3840, height: 2160, orientation: "landscape" },
};

// =============================================================================
// Apple Watch
// =============================================================================

export const AppleWatchUltra3: DeviceScreenshot = {
  name: "Ultra 3",
  portrait: { width: 422, height: 514, orientation: "portrait" },
  landscape: { width: 514, height: 422, orientation: "landscape" },
};
export const AppleWatchUltra2: DeviceScreenshot = {
  name: "Ultra 2",
  portrait: { width: 410, height: 502, orientation: "portrait" },
  landscape: { width: 502, height: 410, orientation: "landscape" },
};
export const AppleWatchUltra: DeviceScreenshot = {
  name: "Ultra",
  portrait: { width: 410, height: 502, orientation: "portrait" },
  landscape: { width: 502, height: 410, orientation: "landscape" },
};
export const AppleWatchSeries11: DeviceScreenshot = {
  name: "Series 11",
  portrait: { width: 416, height: 496, orientation: "portrait" },
  landscape: { width: 496, height: 416, orientation: "landscape" },
};
export const AppleWatchSeries10: DeviceScreenshot = {
  name: "Series 10",
  portrait: { width: 416, height: 496, orientation: "portrait" },
  landscape: { width: 496, height: 416, orientation: "landscape" },
};
export const AppleWatchSeries9: DeviceScreenshot = {
  name: "Series 9",
  portrait: { width: 396, height: 484, orientation: "portrait" },
  landscape: { width: 484, height: 396, orientation: "landscape" },
};
export const AppleWatchSeries8: DeviceScreenshot = {
  name: "Series 8",
  portrait: { width: 396, height: 484, orientation: "portrait" },
  landscape: { width: 484, height: 396, orientation: "landscape" },
};
export const AppleWatchSeries7: DeviceScreenshot = {
  name: "Series 7",
  portrait: { width: 396, height: 484, orientation: "portrait" },
  landscape: { width: 484, height: 396, orientation: "landscape" },
};
export const AppleWatchSeries6: DeviceScreenshot = {
  name: "Series 6",
  portrait: { width: 368, height: 448, orientation: "portrait" },
  landscape: { width: 448, height: 368, orientation: "landscape" },
};
export const AppleWatchSeries5: DeviceScreenshot = {
  name: "Series 5",
  portrait: { width: 368, height: 448, orientation: "portrait" },
  landscape: { width: 448, height: 368, orientation: "landscape" },
};
export const AppleWatchSeries4: DeviceScreenshot = {
  name: "Series 4",
  portrait: { width: 368, height: 448, orientation: "portrait" },
  landscape: { width: 448, height: 368, orientation: "landscape" },
};
export const AppleWatchSE3: DeviceScreenshot = {
  name: "SE 3",
  portrait: { width: 368, height: 448, orientation: "portrait" },
  landscape: { width: 448, height: 368, orientation: "landscape" },
};
export const AppleWatchSE: DeviceScreenshot = {
  name: "SE",
  portrait: { width: 368, height: 448, orientation: "portrait" },
  landscape: { width: 448, height: 368, orientation: "landscape" },
};
export const AppleWatchSeries3: DeviceScreenshot = {
  name: "Series 3",
  portrait: { width: 312, height: 390, orientation: "portrait" },
  landscape: { width: 390, height: 312, orientation: "landscape" },
};

// =============================================================================
// Device Collections
// =============================================================================

export const iPhoneDevices = {
  '6.9"': [
    iPhoneAir,
    iPhone17ProMax,
    iPhone16ProMax,
    iPhone16Plus,
    iPhone15ProMax,
    iPhone15Plus,
    iPhone14ProMax,
  ],
  '6.5"': [
    iPhone14Plus,
    iPhone13ProMax,
    iPhone12ProMax,
    iPhone11ProMax,
    iPhone11,
    iPhoneXSMax,
    iPhoneXR,
  ],
  '6.3"': [
    iPhone17Pro,
    iPhone17,
    iPhone16Pro,
    iPhone16,
    iPhone15Pro,
    iPhone15,
    iPhone14Pro,
  ],
  '6.1"': [
    iPhone17e,
    iPhone16e,
    iPhone14,
    iPhone13Pro,
    iPhone13,
    iPhone13Mini,
    iPhone12Pro,
    iPhone12,
    iPhone12Mini,
    iPhone11Pro,
    iPhoneXS,
    iPhoneX,
  ],
  '5.5"': [iPhone8Plus, iPhone7Plus, iPhone6SPlus, iPhone6Plus],
  '4.7"': [iPhoneSE3rdGen, iPhoneSE2ndGen, iPhone8, iPhone7, iPhone6S, iPhone6],
  '4"': [iPhoneSE1stGen, iPhone5S, iPhone5C, iPhone5],
  '3.5"': [iPhone4S, iPhone4],
} as const;

export const iPadDevices = {
  '13"': [
    iPadPro13M5,
    iPadPro13M4,
    iPadPro13Gen6,
    iPadPro13Gen5,
    iPadPro13Gen4,
    iPadPro13Gen3,
    iPadPro13Gen1,
    iPadAir13M4,
    iPadAir13M3,
    iPadAir13M2,
  ],
  '12.9"': [iPadPro12_9Gen2],
  '11"': [
    iPadPro11M5,
    iPadPro11M4,
    iPadPro11Gen4,
    iPadPro11Gen3,
    iPadPro11Gen2,
    iPadPro11Gen1,
    iPadAir11M4,
    iPadAir11M3,
    iPadAir11M2,
    iPadAir11Gen5,
    iPadAir11Gen4,
    iPad10Gen,
    iPadMiniA17Pro,
    iPadMini6,
  ],
  '10.5"': [iPadPro10_5, iPadAir3, iPad9, iPad8, iPad7],
  '9.7"': [
    iPadPro9_7,
    iPadAir,
    iPadAir2,
    iPadGen,
    iPad2,
    iPad6,
    iPad5,
    iPad4,
    iPad3,
    iPadMini5,
    iPadMini4,
    iPadMini3,
    iPadMini2,
  ],
} as const;

export const AppleWatchDevices = {
  all: [
    AppleWatchUltra3,
    AppleWatchUltra2,
    AppleWatchUltra,
    AppleWatchSeries11,
    AppleWatchSeries10,
    AppleWatchSeries9,
    AppleWatchSeries8,
    AppleWatchSeries7,
    AppleWatchSeries6,
    AppleWatchSeries5,
    AppleWatchSeries4,
    AppleWatchSE3,
    AppleWatchSE,
    AppleWatchSeries3,
  ],
} as const;

// =============================================================================
// Helper Functions
// =============================================================================

export function getAllPlatforms(): Platform[] {
  return ["iPhone", "iPad", "Mac", "AppleTV", "AppleVisionPro", "AppleWatch"];
}

export function isIphonePlatform(platform: string): platform is "iPhone" {
  return platform === "iPhone";
}
export function isIpadPlatform(platform: string): platform is "iPad" {
  return platform === "iPad";
}
export function isMacPlatform(platform: string): platform is "Mac" {
  return platform === "Mac";
}
export function isAppleTvPlatform(platform: string): platform is "AppleTV" {
  return platform === "AppleTV";
}
export function isAppleVisionProPlatform(
  platform: string,
): platform is "AppleVisionPro" {
  return platform === "AppleVisionPro";
}
export function isAppleWatchPlatform(
  platform: string,
): platform is "AppleWatch" {
  return platform === "AppleWatch";
}
