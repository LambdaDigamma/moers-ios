import "./index.css";
import React from "react";
import { Still } from "remotion";
import type { ZodType } from "zod";
import { MoersFestivaliPhone17Pro, FestivalPromoSchema } from "./components/MoersFestivaliPhone17Pro";
import {
  iPhone17Pro,
  iPhone17ProMax,
  ScreenshotSize,
} from "./apple-screenshot-sizes";
import { setRemotionImageLoader } from "./components/PhoneFrame";
import { ScreenshotProvider } from "./components/ScreenshotContext";

setRemotionImageLoader();

type AnyProps = Record<string, unknown>;

interface ScreenshotCollection {
  name: string;
  canvas: React.ComponentType<AnyProps>;
  screenshotSize: ScreenshotSize;
  numberOfScreens: number;
  schema: ZodType<AnyProps>;
  defaultProps: AnyProps;
}

/** Wraps a canvas with a dead-zone overlay and returns a stable component for use with Remotion Still. */
function toStillComponent(
  canvas: React.ComponentType<AnyProps>,
  screenshotSize: ScreenshotSize,
  numberOfScreens: number,
  spacing: number,
): React.ComponentType<AnyProps> {
  const Canvas = canvas;

  return function WithDeadZone(props: AnyProps) {
    return (
      <ScreenshotProvider
        screenshotSize={screenshotSize}
        spacing={spacing}
        totalScreens={numberOfScreens}
      >
        <div style={{ position: "relative", width: "100%", height: "100%" }}>
          <Canvas {...props} />
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

export const INTER_SCREENSHOT_SPACING = 20;

export const screenshotCollections: ScreenshotCollection[] = [
  {
    name: "moers-festival-17-pro",
    canvas: MoersFestivaliPhone17Pro as React.ComponentType<AnyProps>,
    numberOfScreens: 4,
    screenshotSize: iPhone17Pro.portrait,
    schema: FestivalPromoSchema as ZodType<AnyProps>,
    defaultProps: { locale: "de-DE" },
  },
  {
    name: "moers-festival-17-pro-max",
    canvas: MoersFestivaliPhone17Pro as React.ComponentType<AnyProps>,
    numberOfScreens: 4,
    screenshotSize: iPhone17ProMax.portrait,
    schema: FestivalPromoSchema as ZodType<AnyProps>,
    defaultProps: { locale: "de-DE" },
  },
];

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
          schema={collection.schema}
          defaultProps={collection.defaultProps}
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
