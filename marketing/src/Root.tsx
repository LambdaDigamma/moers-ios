import "./index.css";
import React from "react";
import { Still } from "remotion";
import { FestivalPromo } from "./components/FestivalPromo";
import { iPhone17Pro, ScreenshotSize } from "./apple-screenshot-sizes";
import { setRemotionImageLoader } from "./components/PhoneFrame";
import { ScreenshotProvider } from "./components/ScreenshotContext";

setRemotionImageLoader();

interface ScreenshotCollection {
  name: string;
  /** A component type or a pre-rendered JSX element to display as the canvas. */
  canvas: React.ComponentType | React.ReactElement;
  screenshotSize: ScreenshotSize;
  numberOfScreens: number;
}

/** Wraps a canvas with a dead-zone overlay and returns a stable component for use with Remotion Still. */
function toStillComponent(
  canvas: React.ComponentType | React.ReactElement,
  screenshotSize: ScreenshotSize,
  numberOfScreens: number,
  spacing: number,
): React.ComponentType {
  const Canvas = React.isValidElement(canvas)
    ? () => canvas
    : (canvas as React.ComponentType);

  return function WithDeadZone() {
    return (
      <ScreenshotProvider
        screenshotSize={screenshotSize}
        spacing={spacing}
        totalScreens={numberOfScreens}
      >
        <div style={{ position: "relative", width: "100%", height: "100%" }}>
          <Canvas />
          {spacing > 0 &&
            Array.from({ length: numberOfScreens - 1 }, (_, i) => (
              <div
                key={i}
                style={{
                  position: "absolute",
                  top: 0,
                  left: (i + 1) * screenshotSize.width + i * spacing,
                  width: spacing,
                  height: screenshotSize.height,
                  backgroundColor: "rgba(255, 0, 0, 0.4)",
                  pointerEvents: "none",
                }}
              />
            ))}
        </div>
      </ScreenshotProvider>
    );
  };
}

const screenshotCollections: ScreenshotCollection[] = [
  {
    name: "moers-festival-17-pro",
    canvas: FestivalPromo,
    numberOfScreens: 4,
    screenshotSize: iPhone17Pro.portrait,
  },
];

const INTER_SCREENSHOT_SPACING = 20;

// Pre-build stable Still components outside of render so they are not recreated on every render.
const collectionEntries = screenshotCollections.map((c) => ({
  ...c,
  StillComponent: toStillComponent(
    c.canvas,
    c.screenshotSize,
    c.numberOfScreens,
    INTER_SCREENSHOT_SPACING,
  ),
}));

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {collectionEntries.map((collection) => (
        <Still
          key={collection.name}
          id={collection.name}
          component={collection.StillComponent}
          width={
            collection.screenshotSize.width * collection.numberOfScreens +
            INTER_SCREENSHOT_SPACING * (collection.numberOfScreens - 1)
          }
          height={collection.screenshotSize.height}
        />
      ))}
    </>
  );
};
