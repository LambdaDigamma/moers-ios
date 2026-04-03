import React from "react";
import { Still } from "remotion";
import {
  ScreenshotCarousel,
  createScreenshotCarouselProps,
} from "./components/ScreenshotCarousel";
import {
  iPhone17Pro,
  iPhone14Plus,
  iPhone8Plus,
  iPadPro13Gen6,
} from "./apple-screenshot-sizes";

const BASE_URL = "moers-festival/en-US";

export const festivalScreenshots = {
  iphone17Pro: createScreenshotCarouselProps({
    deviceName: "iPhone 17 Pro",
    screenshotSizes: iPhone17Pro.portrait,
    imageUrls: [
      `${BASE_URL}/iPhone 17 Pro-0-events.png`,
      `${BASE_URL}/iPhone 17 Pro-1-event_detail.png`,
      `${BASE_URL}/iPhone 17 Pro-2-info.png`,
      `${BASE_URL}/iPhone 17 Pro-3-map.png`,
    ],
    spacing: 20,
    showOverlay: true,
  }),

  iphone14Plus: createScreenshotCarouselProps({
    deviceName: "iPhone 14 Plus",
    screenshotSizes: iPhone14Plus.portrait,
    imageUrls: [
      `${BASE_URL}/iPhone 14 Plus-0-events.png`,
      `${BASE_URL}/iPhone 14 Plus-1-event_detail.png`,
      `${BASE_URL}/iPhone 14 Plus-2-info.png`,
      `${BASE_URL}/iPhone 14 Plus-3-map.png`,
    ],
    spacing: 20,
    showOverlay: true,
  }),

  iphone8Plus: createScreenshotCarouselProps({
    deviceName: "iPhone 8 Plus",
    screenshotSizes: iPhone8Plus.portrait,
    imageUrls: [
      `${BASE_URL}/iPhone 8 Plus-0-events.png`,
      `${BASE_URL}/iPhone 8 Plus-1-event_detail.png`,
      `${BASE_URL}/iPhone 8 Plus-2-info.png`,
      `${BASE_URL}/iPhone 8 Plus-3-map.png`,
    ],
    spacing: 20,
    showOverlay: true,
  }),

  ipadPro13: createScreenshotCarouselProps({
    deviceName: 'iPad Pro 13"',
    screenshotSizes: iPadPro13Gen6.portrait,
    imageUrls: [
      `${BASE_URL}/iPad Pro (12.9-inch) (6th generation)-0-events.png`,
    ],
    spacing: 20,
    showOverlay: true,
  }),
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

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Still
        id="festival-iphone17pro"
        component={ScreenshotCarousel}
        width={calculateDimensions(festivalScreenshots.iphone17Pro).width}
        height={calculateDimensions(festivalScreenshots.iphone17Pro).height}
        defaultProps={festivalScreenshots.iphone17Pro}
      />

      <Still
        id="festival-iphone14plus"
        component={ScreenshotCarousel}
        width={calculateDimensions(festivalScreenshots.iphone14Plus).width}
        height={calculateDimensions(festivalScreenshots.iphone14Plus).height}
        defaultProps={festivalScreenshots.iphone14Plus}
      />

      <Still
        id="festival-iphone8plus"
        component={ScreenshotCarousel}
        width={calculateDimensions(festivalScreenshots.iphone8Plus).width}
        height={calculateDimensions(festivalScreenshots.iphone8Plus).height}
        defaultProps={festivalScreenshots.iphone8Plus}
      />

      <Still
        id="festival-ipadpro13"
        component={ScreenshotCarousel}
        width={calculateDimensions(festivalScreenshots.ipadPro13).width}
        height={calculateDimensions(festivalScreenshots.ipadPro13).height}
        defaultProps={festivalScreenshots.ipadPro13}
      />
    </>
  );
};
