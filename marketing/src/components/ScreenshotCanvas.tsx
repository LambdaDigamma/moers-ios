import React from "react";
import { AbsoluteFill } from "remotion";
import type { ScreenshotSize } from "../apple-screenshot-sizes";

type ScreenshotCanvasProps = {
  screenshotWidth: number;
  screenshotHeight: number;
  spacing?: number;
  showDeadZone?: boolean;
  children: React.ReactNode;
};

/**
 * Lays out screenshot slot children side by side on a single wide canvas.
 * Dead-zone markers show where cuts happen during export.
 *
 * The Remotion Still that wraps this component must have:
 *   width  = screenshotWidth * count + spacing * (count - 1)
 *   height = screenshotHeight
 *
 * Use `screenshotCanvasDimensions` to compute those values.
 */
export const ScreenshotCanvas: React.FC<ScreenshotCanvasProps> = ({
  screenshotWidth,
  screenshotHeight,
  spacing = 20,
  showDeadZone = true,
  children,
}) => {
  const slots = React.Children.toArray(children);

  return (
    <AbsoluteFill>
      {slots.map((child, i) => (
        <div
          key={i}
          style={{
            position: "absolute",
            left: i * (screenshotWidth + spacing),
            top: 0,
            width: screenshotWidth,
            height: screenshotHeight,
            overflow: "hidden",
          }}
        >
          {child}
        </div>
      ))}

      {showDeadZone &&
        spacing > 0 &&
        Array.from({ length: slots.length - 1 }, (_, i) => (
          <div
            key={`dz-${i}`}
            style={{
              position: "absolute",
              left: (i + 1) * screenshotWidth + i * spacing,
              top: 0,
              width: spacing,
              height: screenshotHeight,
              backgroundColor: "rgba(255, 0, 0, 0.35)",
            }}
          />
        ))}
    </AbsoluteFill>
  );
};

/** Returns the total { width, height } for a ScreenshotCanvas Still. */
export function screenshotCanvasDimensions(
  size: ScreenshotSize,
  count: number,
  spacing = 20,
): { width: number; height: number } {
  return {
    width: size.width * count + spacing * (count - 1),
    height: size.height,
  };
}
