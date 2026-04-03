import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { z } from "zod";
import { IPhone17ProFrame } from "./PhoneFrame";

const festivalColors = {
  background: "#0a0a0a",
  accent: "#ff6b35",
  text: "#ffffff",
  secondary: "#888888",
};

const Text: React.FC<{
  style?: React.CSSProperties;
  children: React.ReactNode;
}> = ({ style, children }) => <div style={style}>{children}</div>;

export const FestivalPromoSchema = z.object({
  backgroundImage: z.string().optional(),
});

export type FestivalPromoProps = z.infer<typeof FestivalPromoSchema>;

const FEATURES = [
  { icon: "◉", label: "Events" },
  { icon: "◎", label: "Details" },
  { icon: "◈", label: "Info" },
  { icon: "◇", label: "Map" },
];

export const FestivalPromo: React.FC<FestivalPromoProps> = ({
  backgroundImage,
}) => {
  const screenshotBase = "moers-festival/en-US";

  return (
    <AbsoluteFill
      style={{
        backgroundColor: festivalColors.background,
        width: "100%",
        height: "100%",
        overflow: "hidden",
      }}
    >
      <Img
        src={staticFile("assets/background.png")}
        style={{
          width: "100%",
          height: "100%",
          objectFit: "cover",
          opacity: 0.25,
        }}
      />

      <div
        style={{
          position: "absolute",
          top: 40,
          left: 0,
          right: 0,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          zIndex: 10,
        }}
      >
        <Text
          style={{
            fontFamily: "monospace",
            fontSize: 32,
            fontWeight: 700,
            color: festivalColors.text,
            letterSpacing: 4,
          }}
        >
          MOERS FESTIVAL
        </Text>
        <Text
          style={{
            fontFamily: "monospace",
            fontSize: 12,
            fontWeight: 400,
            color: festivalColors.accent,
            letterSpacing: 2,
            marginTop: 4,
          }}
        >
          MOERS 2026
        </Text>
      </div>

      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: 30,
        }}
      >
        <div
          style={{
            transform: "rotate(-8deg) translateX(20px) translateY(-40px)",
            zIndex: 3,
          }}
        >
          <IPhone17ProFrame color="Silver">
            <Img
              src={staticFile(`${screenshotBase}/iPhone 17 Pro-0-events.png`)}
              style={{ width: "100%", height: "100%", objectFit: "cover" }}
            />
          </IPhone17ProFrame>
        </div>

        <div
          style={{
            transform: "rotate(2deg) translateX(-10px) translateY(10px)",
            zIndex: 2,
          }}
        >
          <IPhone17ProFrame color="Silver">
            <Img
              src={staticFile(
                `${screenshotBase}/iPhone 17 Pro-1-event_detail.png`,
              )}
              style={{ width: "100%", height: "100%", objectFit: "cover" }}
            />
          </IPhone17ProFrame>
        </div>

        <div
          style={{
            transform: "rotate(12deg) translateX(0px) translateY(50px)",
            zIndex: 1,
          }}
        >
          <IPhone17ProFrame color="Silver">
            <Img
              src={staticFile(`${screenshotBase}/iPhone 17 Pro-2-info.png`)}
              style={{ width: "100%", height: "100%", objectFit: "cover" }}
            />
          </IPhone17ProFrame>
        </div>
      </div>

      <div
        style={{
          position: "absolute",
          bottom: 40,
          left: 0,
          right: 0,
          display: "flex",
          justifyContent: "center",
          gap: 40,
        }}
      >
        {FEATURES.map((feature, index) => (
          <div
            key={index}
            style={{
              display: "flex",
              alignItems: "center",
              gap: 6,
            }}
          >
            <Text
              style={{
                fontFamily: "monospace",
                fontSize: 10,
                fontWeight: 600,
                color: festivalColors.accent,
              }}
            >
              {feature.icon}
            </Text>
            <Text
              style={{
                fontFamily: "monospace",
                fontSize: 10,
                fontWeight: 400,
                color: festivalColors.secondary,
              }}
            >
              {feature.label}
            </Text>
          </div>
        ))}
      </div>

      <div
        style={{
          position: "absolute",
          bottom: 20,
          left: 0,
          right: 0,
          display: "flex",
          justifyContent: "center",
        }}
      >
        <Text
          style={{
            fontFamily: "monospace",
            fontSize: 8,
            fontWeight: 400,
            color: festivalColors.secondary,
            letterSpacing: 1,
          }}
        >
          APP STORE →
        </Text>
      </div>
    </AbsoluteFill>
  );
};

// =============================================================================
// App Store Still - Uses the carousel system with frames
// This creates the actual App Store deliverables with dead zone overlays
// =============================================================================

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
