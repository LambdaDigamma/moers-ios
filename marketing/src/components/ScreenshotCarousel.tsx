import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { z } from "zod";
import type { ScreenshotSize } from "../apple-screenshot-sizes";

export const screenshotSchema = z.object({
  imageUrls: z.array(z.string()),
  deviceName: z.string(),
  deviceDimensions: z.object({
    width: z.number(),
    height: z.number(),
    orientation: z.enum(["portrait", "landscape"]),
  }),
  numScreens: z.number().min(1).max(6),
  spacing: z.number().default(20),
  showOverlay: z.boolean().default(true),
  overlayColor: z.string().default("#00ff00"),
});

export type ScreenshotProps = z.infer<typeof screenshotSchema>;

function getScreenshotPosition(
  index: number,
  deviceWidth: number,
  deviceHeight: number,
  spacing: number,
): { left: number; top: number } {
  return {
    left: index * deviceWidth + index * spacing,
    top: 0,
  };
}

export const ScreenshotCarousel: React.FC<ScreenshotProps> = ({
  imageUrls,
  deviceDimensions,
  numScreens,
  spacing = 20,
  showOverlay = true,
  overlayColor = "#00ff00",
}) => {
  const { width: deviceWidth, height: deviceHeight } = deviceDimensions;

  const totalWidth = numScreens * deviceWidth + (numScreens - 1) * spacing;

  return (
    <AbsoluteFill
      style={{
        width: totalWidth,
        height: deviceHeight,
        backgroundColor: "white",
        position: "relative",
      }}
    >
      {imageUrls.slice(0, numScreens).map((url, index) => {
        const pos = getScreenshotPosition(
          index,
          deviceWidth,
          deviceHeight,
          spacing,
        );
        return (
          <div
            key={index}
            style={{
              position: "absolute",
              left: pos.left,
              top: pos.top,
              width: deviceWidth,
              height: deviceHeight,
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
      )
      {showOverlay && spacing > 0 && (
        <>
          {Array.from({ length: numScreens - 1 }, (_, i) => {
            const pos = getScreenshotPosition(
              i + 1,
              deviceWidth,
              deviceHeight,
              spacing,
            );
            return (
              <div
                key={`overlay-${i}`}
                style={{
                  position: "absolute",
                  left: pos.left - spacing,
                  top: 0,
                  width: spacing,
                  height: deviceHeight,
                  backgroundColor: overlayColor,
                  opacity: 0.5,
                }}
              />
            );
          })}
        </>
      )}
    </AbsoluteFill>
  );
};

// Helper to create props from known device sizes
export function createScreenshotCarouselProps(options: {
  deviceName: string;
  imageUrls: string[];
  screenshotSizes: ScreenshotSize;
  numScreens?: number;
  spacing?: number;
  showOverlay?: boolean;
}) {
  const {
    deviceName,
    imageUrls,
    screenshotSizes,
    spacing = 20,
    showOverlay = true,
  } = options;
  const numScreens = options.numScreens || imageUrls.length;

  return {
    imageUrls,
    deviceName,
    deviceDimensions: {
      width: screenshotSizes.width,
      height: screenshotSizes.height,
      orientation: screenshotSizes.orientation,
    },
    numScreens,
    spacing,
    showOverlay,
    overlayColor: "#00ff00",
  };
}
