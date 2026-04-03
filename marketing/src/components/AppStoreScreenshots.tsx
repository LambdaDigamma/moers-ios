import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { z } from "zod";
import type { ScreenshotSize } from "../apple-screenshot-sizes";
import { iPhone17Pro } from "../apple-screenshot-sizes";

export const appStoreScreenshotSchema = z.object({
  imageUrls: z.array(z.string()),
  screenshotSize: z.object({
    width: z.number(),
    height: z.number(),
  }),
  numScreens: z.number().min(1).max(10),
  spacing: z.number().default(20),
  showDeadZone: z.boolean().default(true),
  deadZoneColor: z.string().default("#000000"),
});

export type AppStoreScreenshotProps = z.infer<typeof appStoreScreenshotSchema>;

function getScreenshotPosition(
  index: number,
  width: number,
  height: number,
  spacing: number,
) {
  return {
    left: index * width + index * spacing,
    top: 0,
  };
}

const AppStoreScreenshotWide: React.FC<AppStoreScreenshotProps> = ({
  imageUrls,
  screenshotSize,
  numScreens,
  spacing = 20,
  showDeadZone = true,
  deadZoneColor = "#000000",
}) => {
  const { width, height } = screenshotSize;
  const totalWidth = numScreens * width + (numScreens - 1) * spacing;

  return (
    <AbsoluteFill
      style={{
        width: totalWidth,
        height,
        backgroundColor: "white",
        position: "relative",
      }}
    >
      {imageUrls.slice(0, numScreens).map((url, index) => {
        const pos = getScreenshotPosition(index, width, height, spacing);
        return (
          <div
            key={index}
            style={{
              position: "absolute",
              left: pos.left,
              top: pos.top,
              width,
              height,
              overflow: "hidden",
            }}
          >
            <Img
              src={staticFile(url)}
              style={{
                width: "100%",
                height: "100%",
                objectFit: "cover",
              }}
            />
          </div>
        );
      })}

      {showDeadZone && spacing > 0 && (
        <>
          {Array.from({ length: numScreens - 1 }, (_, i) => {
            const pos = getScreenshotPosition(i + 1, width, height, spacing);
            return (
              <div
                key={`deadzone-${i}`}
                style={{
                  position: "absolute",
                  left: pos.left - spacing,
                  top: 0,
                  width: spacing,
                  height,
                  backgroundColor: deadZoneColor,
                }}
              />
            );
          })}
        </>
      )}
    </AbsoluteFill>
  );
};

// Single screenshot component (for individual export)
type SingleScreenshotProps = {
  imageUrl: string;
  screenshotSize: ScreenshotSize;
};

export const AppStoreSingleScreenshot: React.FC<SingleScreenshotProps> = ({
  imageUrl,
  screenshotSize,
}) => {
  return (
    <AbsoluteFill
      style={{
        width: screenshotSize.width,
        height: screenshotSize.height,
        backgroundColor: "white",
      }}
    >
      <Img
        src={staticFile(imageUrl)}
        style={{
          width: "100%",
          height: "100%",
          objectFit: "cover",
        }}
      />
    </AbsoluteFill>
  );
};

// Factory to create both wide and individual still exports
export function createAppStoreStillExports(options: {
  basePath: string;
  prefix: string;
  screenshotSizes: ScreenshotSize;
  imageCount: number;
  spacing?: number;
  showDeadZone?: boolean;
  deadZoneColor?: string;
}) {
  const {
    basePath,
    prefix,
    screenshotSizes,
    imageCount,
    spacing = 20,
    showDeadZone = true,
    deadZoneColor = "#000000",
  } = options;

  // Sanitize prefix for composition IDs (only a-z, A-Z, 0-9, CJK, -)
  const safePrefix = prefix.replace(/[^a-zA-Z0-9\u4e00-\u9fff-]/g, "-");

  const imageUrls = Array.from({ length: imageCount }, (_, i) =>
    i === 0
      ? `${basePath}/${prefix}-0-events.png`
      : i === 1
        ? `${basePath}/${prefix}-1-event_detail.png`
        : i === 2
          ? `${basePath}/${prefix}-2-info.png`
          : i === 3
            ? `${basePath}/${prefix}-3-map.png`
            : `${basePath}/${prefix}-${i}.png`,
  );

  const wideId = `appstore-${safePrefix}-wide`;
  const singleIds = Array.from(
    { length: imageCount },
    (_, i) => `appstore-${safePrefix}-${i}`,
  );

  return {
    wide: {
      id: wideId,
      component: AppStoreScreenshotWide,
      width: screenshotSizes.width * imageCount + spacing * (imageCount - 1),
      height: screenshotSizes.height,
      defaultProps: {
        imageUrls,
        screenshotSize: {
          width: screenshotSizes.width,
          height: screenshotSizes.height,
        },
        numScreens: imageCount,
        spacing,
        showDeadZone,
        deadZoneColor,
      },
    },
    singles: singleIds.map((id, index) => ({
      id,
      component: AppStoreSingleScreenshot,
      width: screenshotSizes.width,
      height: screenshotSizes.height,
      defaultProps: {
        imageUrl: imageUrls[index],
        screenshotSize: screenshotSizes,
      },
    })),
  };
}

// Pre-configured exports for the Festival app
export const festivalAppStoreExports = {
  iphone17Pro: createAppStoreStillExports({
    basePath: "moers-festival/en-US",
    prefix: "iPhone 17 Pro",
    screenshotSizes: iPhone17Pro.portrait,
    imageCount: 4,
    spacing: 20,
    showDeadZone: true,
  }),
};
