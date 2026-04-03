import React from "react";
import type {
  DeviceScreenshot,
  DeviceMultiScreenshot,
} from "../apple-screenshot-sizes";

export interface StillConfig {
  id: string;
  component: React.FC;
  width: number;
  height: number;
  defaultProps?: Record<string, unknown>;
}

export function deviceStill<T extends React.ComponentType<any>>({
  component,
  device,
  orientation = "portrait",
  defaultProps,
}: {
  component: T;
  device: DeviceScreenshot;
  orientation?: "portrait" | "landscape";
  defaultProps?: React.ComponentProps<T>;
}): StillConfig {
  const size = orientation === "portrait" ? device.portrait : device.landscape;

  const StillComponent: React.FC = () => {
    const Component = component;
    return (
      <div
        style={{
          width: size.width,
          height: size.height,
          backgroundColor: "white",
        }}
      >
        <Component {...(defaultProps as any)} />
      </div>
    );
  };

  return {
    id: device.name.replace(/\s+/g, "-"),
    component: StillComponent,
    width: size.width,
    height: size.height,
    defaultProps: defaultProps as Record<string, unknown>,
  };
}

export function deviceStillAuto<T extends React.ComponentType<any>>({
  component,
  device,
  defaultProps,
}: {
  component: T;
  device: DeviceScreenshot;
  defaultProps?: React.ComponentProps<T>;
}): StillConfig {
  return deviceStill({
    component,
    device,
    orientation: "portrait",
    defaultProps,
  });
}

export function deviceStillMulti<T extends React.ComponentType<any>>({
  component,
  device,
  sizeIndex = 0,
  defaultProps,
}: {
  component: T;
  device: DeviceMultiScreenshot;
  sizeIndex?: number;
  defaultProps?: React.ComponentProps<T>;
}): StillConfig {
  const size = device.screenshotSizes[sizeIndex];
  if (!size) {
    throw new Error(
      `Invalid size index ${sizeIndex} for device ${device.name}`,
    );
  }

  const StillComponent: React.FC = () => {
    const Component = component;
    return (
      <div
        style={{
          width: size.width,
          height: size.height,
          backgroundColor: "white",
        }}
      >
        <Component {...(defaultProps as any)} />
      </div>
    );
  };

  return {
    id: `${device.name.replace(/\s+/g, "-")}-${sizeIndex}`,
    component: StillComponent,
    width: size.width,
    height: size.height,
    defaultProps: defaultProps as Record<string, unknown>,
  };
}

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
