import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { z } from "zod";
import { IPhone17ProFrame } from "./PhoneFrame";
import {
  ScreenshotCarousel,
  createScreenshotCarouselProps,
} from "./ScreenshotCarousel";
import {
  iPhone17Pro,
  iPhone14Plus,
  iPhone8Plus,
  iPadPro13Gen6,
} from "../apple-screenshot-sizes";
import { useScreenshotContext } from "./ScreenshotContext";

export const FestivalPromoSchema = z.object({});

export type FestivalPromoProps = z.infer<typeof FestivalPromoSchema>;

const ScreenshotSlot: React.FC<{
  index: number;
  children?: React.ReactNode;
}> = ({ index, children }) => {
  const { screenshotSize, spacing } = useScreenshotContext();

  return (
    <div
      style={{
        position: "absolute",
        left: index * (screenshotSize.width + spacing),
        top: 0,
        width: screenshotSize.width,
        height: screenshotSize.height,
      }}
    >
      {children}
    </div>
  );
};

export const FestivalPromo: React.FC<FestivalPromoProps> = () => {
  const screenshotBase = "moers-festival/en-US";
  const { totalScreens } = useScreenshotContext();

  const imageUrls = [
    `${screenshotBase}/iPhone 17 Pro-0-events.png`,
    `${screenshotBase}/iPhone 17 Pro-1-event_detail.png`,
    `${screenshotBase}/iPhone 17 Pro-2-info.png`,
    `${screenshotBase}/iPhone 17 Pro-3-map.png`,
  ];

  return (
    <AbsoluteFill className="bg-[#0a0a0a] w-full h-full overflow-hidden">
      <Img
        src={staticFile("assets/background.png")}
        className="absolute w-full h-full object-cover opacity-25 -z-10"
      />
      {Array.from({ length: Math.min(totalScreens, 3) }).map((_, index) => (
        <ScreenshotSlot
          key={index}
          index={index}
        >
          <div className="bg-red-500 absolute w-full h-full"></div>
        </ScreenshotSlot>
      ))}
    </AbsoluteFill>
  );
};

// =============================================================================
// App Store Still - Uses the carousel system with frames
// This creates the actual App Store deliverables with dead zone overlays
// =============================================================================

// Create App Store stills using the carousel system (with dead zone overlays)
export const createFestivalAppStoreStill = () => {
  const base = "moers-festival/en-US";

  // iPhone 17 Pro - 4 screenshots in carousel (actual App Store format)
  const iphone17ProCarousel = createScreenshotCarouselProps({
    deviceName: "iPhone 17 Pro",
    screenshotSizes: iPhone17Pro.portrait,
    imageUrls: [
      `${base}/iPhone 17 Pro-0-events.png`,
      `${base}/iPhone 17 Pro-1-event_detail.png`,
      `${base}/iPhone 17 Pro-2-info.png`,
      `${base}/iPhone 17 Pro-3-map.png`,
    ],
    numScreens: 4,
    spacing: 20,
    showOverlay: true, // Shows dead zones between screenshots
  });

  // iPhone 14 Plus - 4 screenshots
  const iphone14PlusCarousel = createScreenshotCarouselProps({
    deviceName: "iPhone 14 Plus",
    screenshotSizes: iPhone14Plus.portrait,
    imageUrls: [
      `${base}/iPhone 14 Plus-0-events.png`,
      `${base}/iPhone 14 Plus-1-event_detail.png`,
      `${base}/iPhone 14 Plus-2-info.png`,
      `${base}/iPhone 14 Plus-3-map.png`,
    ],
    numScreens: 4,
    spacing: 20,
    showOverlay: true,
  });

  // iPhone 8 Plus - 4 screenshots
  const iphone8PlusCarousel = createScreenshotCarouselProps({
    deviceName: "iPhone 8 Plus",
    screenshotSizes: iPhone8Plus.portrait,
    imageUrls: [
      `${base}/iPhone 8 Plus-0-events.png`,
      `${base}/iPhone 8 Plus-1-event_detail.png`,
      `${base}/iPhone 8 Plus-2-info.png`,
      `${base}/iPhone 8 Plus-3-map.png`,
    ],
    numScreens: 4,
    spacing: 20,
    showOverlay: true,
  });

  // iPad Pro - 1 screenshot
  const ipadProCarousel = createScreenshotCarouselProps({
    deviceName: 'iPad Pro 13"',
    screenshotSizes: iPadPro13Gen6.portrait,
    imageUrls: [`${base}/iPad Pro (12.9-inch) (6th generation)-0-events.png`],
    numScreens: 1,
    spacing: 0,
    showOverlay: false,
  });

  return {
    iphone17Pro: iphone17ProCarousel,
    iphone14Plus: iphone14PlusCarousel,
    iphone8Plus: iphone8PlusCarousel,
    ipadPro: ipadProCarousel,
  };
};

function calculateDimensions(
  props: ReturnType<typeof createScreenshotCarouselProps>,
) {
  const { deviceDimensions, numScreens, spacing } = props;
  return {
    width: deviceDimensions.width * numScreens + spacing * (numScreens - 1),
    height: deviceDimensions.height,
  };
}

// Export compositions for App Store delivery
export const festivalAppStoreStills = (() => {
  const stills = createFestivalAppStoreStill();
  return {
    iphone17Pro: {
      id: "festival-appstore-iphone17pro",
      component: ScreenshotCarousel,
      ...calculateDimensions(stills.iphone17Pro),
      defaultProps: stills.iphone17Pro,
    },
    iphone14Plus: {
      id: "festival-appstore-iphone14plus",
      component: ScreenshotCarousel,
      ...calculateDimensions(stills.iphone14Plus),
      defaultProps: stills.iphone14Plus,
    },
    iphone8Plus: {
      id: "festival-appstore-iphone8plus",
      component: ScreenshotCarousel,
      ...calculateDimensions(stills.iphone8Plus),
      defaultProps: stills.iphone8Plus,
    },
    ipadPro: {
      id: "festival-appstore-ipadpro",
      component: ScreenshotCarousel,
      ...calculateDimensions(stills.ipadPro),
      defaultProps: stills.ipadPro,
    },
  };
})();
