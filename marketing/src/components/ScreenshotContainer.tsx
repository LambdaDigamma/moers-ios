import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { useScreenshotContext } from "./ScreenshotContext";

type ScreenshotContainerProps = {
  imageUrl: string;
  children?: React.ReactNode;
};

/**
 * ScreenshotContainer wraps a single screenshot image and provides layout
 * capabilities inside the exported single image. It uses the ScreenshotContext
 * to get the screenshot dimensions.
 *
 * Usage:
 * <ScreenshotContainer imageUrl="path/to/screenshot.png">
 *   <YourCustomLayout />
 * </ScreenshotContainer>
 */
export const ScreenshotContainer: React.FC<ScreenshotContainerProps> = ({
  imageUrl,
  children,
}) => {
  const { screenshotSize } = useScreenshotContext();

  return (
    <AbsoluteFill
      style={{
        width: screenshotSize.width,
        height: screenshotSize.height,
        backgroundColor: "white",
        position: "relative",
      }}
    >
      <Img
        src={staticFile(imageUrl)}
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          objectFit: "cover",
        }}
      />
      {children && (
        <div
          style={{
            position: "absolute",
            top: 0,
            left: 0,
            width: "100%",
            height: "100%",
          }}
        >
          {children}
        </div>
      )}
    </AbsoluteFill>
  );
};
