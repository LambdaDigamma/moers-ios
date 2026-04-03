import React from "react";
import type { ScreenshotSize } from "../apple-screenshot-sizes";

// =============================================================================
// Types
// =============================================================================

export type CarouselOrientation = "portrait" | "landscape";
export type NumScreens = 1 | 2 | 3 | 4 | 5 | 6;

export interface ScreenMetadata {
  index: number;
  position: 1 | 2 | 3 | 4 | 5 | 6;
  orientation: CarouselOrientation;
  deviceName: string;
}

export interface CarouselConfig {
  deviceDimensions: ScreenshotSize;
  numScreens: NumScreens;
  spacing?: number;
  showOverlay?: boolean;
}

export interface CarouselDimensions {
  width: number;
  height: number;
}

export interface ScreenPosition {
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface StillConfig {
  id: string;
  component: React.FC;
  width: number;
  height: number;
  defaultProps?: Record<string, unknown>;
}

// =============================================================================
// Helper Functions
// =============================================================================

export function getCarouselDimensions(
  config: CarouselConfig,
): CarouselDimensions {
  const { deviceDimensions, numScreens, spacing = 20 } = config;

  return {
    width: deviceDimensions.width * numScreens + spacing * (numScreens - 1),
    height: deviceDimensions.height,
  };
}

export function getScreenshotPosition(
  index: number,
  config: CarouselConfig,
): ScreenPosition {
  const { deviceDimensions, spacing = 20 } = config;

  return {
    left: index * deviceDimensions.width + index * spacing,
    top: 0,
    width: deviceDimensions.width,
    height: deviceDimensions.height,
  };
}

export function createScreenMetadata(
  index: number,
  orientation: CarouselOrientation,
  deviceName: string,
): ScreenMetadata {
  return {
    index,
    position: (index + 1) as ScreenMetadata["position"],
    orientation,
    deviceName,
  };
}

// =============================================================================
// Carousel Overlay Component
// =============================================================================

export const CarouselOverlay: React.FC<{
  config: CarouselConfig;
  color?: string;
  opacity?: number;
}> = ({ config, color = "#00ff00", opacity = 0.5 }) => {
  const { showOverlay = true, spacing = 20 } = config;

  if (!showOverlay || spacing === 0) return null;

  const positions = Array.from({ length: config.numScreens - 1 }, (_, i) =>
    getScreenshotPosition(i + 1, config),
  );

  return (
    <>
      {positions.map((pos, idx) => (
        <div
          key={idx}
          style={{
            position: "absolute",
            left: pos.left - spacing,
            top: pos.top,
            width: spacing,
            height: pos.height,
            backgroundColor: color,
            opacity,
          }}
        />
      ))}
    </>
  );
};

// =============================================================================
// Create Carousel Still (Combined Canvas)
// =============================================================================

export function createCarouselStill<T extends React.ComponentType<any>>({
  component,
  config,
  defaultProps,
}: {
  component: T;
  config: CarouselConfig;
  defaultProps?: React.ComponentProps<T>;
}): StillConfig {
  const dimensions = getCarouselDimensions(config);

  const CarouselComponent: React.FC = () => {
    const Component = component;
    return (
      <div
        style={{
          width: dimensions.width,
          height: dimensions.height,
          position: "relative",
          backgroundColor: "white",
        }}
      >
        <Component {...(defaultProps as any)} />
        <CarouselOverlay config={config} />
      </div>
    );
  };

  return {
    id: `Carousel-${config.numScreens}screens`,
    component: CarouselComponent,
    width: dimensions.width,
    height: dimensions.height,
    defaultProps: defaultProps as Record<string, unknown>,
  };
}

// =============================================================================
// Create Individual Screen Stills
// =============================================================================

export function createCarouselScreens<T extends React.ComponentType<any>>({
  component,
  config,
  deviceName = "Device",
  defaultProps,
}: {
  component: T;
  config: CarouselConfig;
  deviceName?: string;
  defaultProps?: React.ComponentProps<T>;
}): StillConfig[] {
  const { deviceDimensions, numScreens } = config;
  const orientation = deviceDimensions.orientation;

  return Array.from({ length: numScreens }, (_, index) => {
    const metadata = createScreenMetadata(index, orientation, deviceName);

    const ScreenComponent: React.FC = () => {
      const Component = component;
      return (
        <div
          style={{
            width: deviceDimensions.width,
            height: deviceDimensions.height,
            backgroundColor: "white",
          }}
        >
          <Component {...(defaultProps as any)} metadata={metadata} />
        </div>
      );
    };

    return {
      id: `Carousel-screen${index + 1}`,
      component: ScreenComponent,
      width: deviceDimensions.width,
      height: deviceDimensions.height,
      defaultProps: { ...defaultProps, metadata } as Record<string, unknown>,
    };
  });
}

// =============================================================================
// Create Screens from Array of Components (Multiple Components)
// =============================================================================

export function createCarouselFromComponents({
  components,
  config,
  deviceName = "Device",
  defaultProps,
}: {
  components: React.ComponentType<any>[];
  config: CarouselConfig;
  deviceName?: string;
  defaultProps?: Record<string, unknown>;
}): StillConfig {
  const dimensions = getCarouselDimensions(config);
  const { numScreens } = config;
  const orientation = config.deviceDimensions.orientation;

  const CarouselFromComponents: React.FC = () => {
    return (
      <div
        style={{
          width: dimensions.width,
          height: dimensions.height,
          position: "relative",
          backgroundColor: "white",
        }}
      >
        {components.map((Comp, index) => {
          const pos = getScreenshotPosition(index, config);
          const metadata = createScreenMetadata(index, orientation, deviceName);

          return (
            <div
              key={index}
              style={{
                position: "absolute",
                left: pos.left,
                top: pos.top,
                width: pos.width,
                height: pos.height,
              }}
            >
              <Comp {...(defaultProps as any)} metadata={metadata} />
            </div>
          );
        })}
        <CarouselOverlay config={config} />
      </div>
    );
  };

  return {
    id: `Carousel-${numScreens}screens`,
    component: CarouselFromComponents,
    width: dimensions.width,
    height: dimensions.height,
    defaultProps,
  };
}

// =============================================================================
// Fixed Still (for non-carousel use cases)
// =============================================================================

export function fixedStill<T extends React.ComponentType<any>>({
  component,
  width,
  height,
  defaultProps,
}: {
  component: T;
  width: number;
  height: number;
  defaultProps?: React.ComponentProps<T>;
}): StillConfig {
  const StillComponent: React.FC = () => {
    const Component = component;
    return (
      <div style={{ width, height, backgroundColor: "white" }}>
        <Component {...(defaultProps as any)} />
      </div>
    );
  };

  return {
    id: component.displayName || component.name || "Unknown",
    component: StillComponent,
    width,
    height,
    defaultProps: defaultProps as Record<string, unknown>,
  };
}
