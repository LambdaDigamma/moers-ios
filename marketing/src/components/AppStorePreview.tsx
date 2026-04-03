import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { z } from "zod";
import type { ScreenshotSize } from "../apple-screenshot-sizes";

export const appStorePreviewSchema = z.object({
  screenshotPaths: z.array(z.string()),
  screenshotSize: z.object({
    width: z.number(),
    height: z.number(),
  }),
  deviceName: z.string(),
  frameColor: z.string().default("Silver"),
  frameType: z.enum(["phone", "tablet"]).default("phone"),
  layout: z.enum(["single", "carousel", "stack"]).default("carousel"),
  spacing: z.number().default(0),
  showDeadZone: z.boolean().default(false),
});

export type AppStorePreviewProps = z.infer<typeof appStorePreviewSchema>;

const AppStorePreview: React.FC<AppStorePreviewProps> = ({
  screenshotPaths,
  screenshotSize,
  layout = "carousel",
  spacing = 0,
  showDeadZone = false,
}) => {
  const { width, height } = screenshotSize;
  const numScreens = screenshotPaths.length;

  if (layout === "single") {
    return (
      <AbsoluteFill style={{ backgroundColor: "white" }}>
        <Img
          src={staticFile(screenshotPaths[0])}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
        />
      </AbsoluteFill>
    );
  }

  // Horizontal carousel layout with optional dead zones
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
      {screenshotPaths.map((path, index) => {
        const left = index * width + index * spacing;
        return (
          <div
            key={index}
            style={{
              position: "absolute",
              left,
              top: 0,
              width,
              height,
              overflow: "hidden",
            }}
          >
            <Img
              src={staticFile(path)}
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
            const left = (i + 1) * width + i * spacing;
            return (
              <div
                key={`deadzone-${i}`}
                style={{
                  position: "absolute",
                  left: left - spacing,
                  top: 0,
                  width: spacing,
                  height,
                  backgroundColor: "black",
                }}
              />
            );
          })}
        </>
      )}
    </AbsoluteFill>
  );
};

export function createAppStorePreviewComposition(options: {
  id: string;
  basePath: string;
  devicePrefix: string;
  screenshotSizes: ScreenshotSize;
  imageCount: number;
  spacing?: number;
  showDeadZone?: boolean;
}) {
  const {
    id,
    basePath,
    devicePrefix,
    screenshotSizes,
    imageCount,
    spacing = 0,
    showDeadZone = false,
  } = options;

  const screenshotPaths = Array.from({ length: imageCount }, (_, i) =>
    i === 0
      ? `${basePath}/${devicePrefix}-0-events.png`
      : i === 1
        ? `${basePath}/${devicePrefix}-1-event_detail.png`
        : i === 2
          ? `${basePath}/${devicePrefix}-2-info.png`
          : i === 3
            ? `${basePath}/${devicePrefix}-3-map.png`
            : `${basePath}/${devicePrefix}-${i}.png`,
  );

  const totalWidth =
    screenshotSizes.width * imageCount + spacing * (imageCount - 1);

  return {
    id,
    component: AppStorePreview,
    width: totalWidth,
    height: screenshotSizes.height,
    defaultProps: {
      screenshotPaths,
      screenshotSize: {
        width: screenshotSizes.width,
        height: screenshotSizes.height,
      },
      deviceName: devicePrefix,
      layout: "carousel",
      spacing,
      showDeadZone,
    },
  };
}
