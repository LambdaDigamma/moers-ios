import React, { createContext, useContext } from "react";
import type { ScreenshotSize } from "../apple-screenshot-sizes";

export interface ScreenshotContextValue {
  screenshotSize: ScreenshotSize;
  spacing: number;
  totalScreens: number;
}

const ScreenshotContext = createContext<ScreenshotContextValue | null>(null);

export interface ScreenshotProviderProps {
  screenshotSize: ScreenshotSize;
  spacing?: number;
  totalScreens: number;
  children: React.ReactNode;
}

export const ScreenshotProvider: React.FC<ScreenshotProviderProps> = ({
  screenshotSize,
  spacing = 20,
  totalScreens,
  children,
}) => {
  return (
    <ScreenshotContext.Provider
      value={{ screenshotSize, spacing, totalScreens }}
    >
      {children}
    </ScreenshotContext.Provider>
  );
};

export function useScreenshotContext(): ScreenshotContextValue {
  const context = useContext(ScreenshotContext);
  if (!context) {
    throw new Error(
      "useScreenshotContext must be used within a ScreenshotProvider",
    );
  }
  return context;
}
