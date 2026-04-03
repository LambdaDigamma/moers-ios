import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { ScreenshotCanvas } from "../ScreenshotCanvas";
import { iPhone17Pro } from "../../apple-screenshot-sizes";

const BASE = "moers-festival/en-US";
const DEVICE = "iPhone 17 Pro";
const { width, height } = iPhone17Pro.portrait;

export const Screen1: React.FC = () => (
  <AbsoluteFill>
    <Img
      src={staticFile(`${BASE}/${DEVICE}-0-events.png`)}
      style={{ width: "100%", height: "100%", objectFit: "cover" }}
    />
  </AbsoluteFill>
);

export const Screen2: React.FC = () => (
  <AbsoluteFill>
    <Img
      src={staticFile(`${BASE}/${DEVICE}-1-event_detail.png`)}
      style={{ width: "100%", height: "100%", objectFit: "cover" }}
    />
  </AbsoluteFill>
);

export const Screen3: React.FC = () => (
  <AbsoluteFill>
    <Img
      src={staticFile(`${BASE}/${DEVICE}-2-info.png`)}
      style={{ width: "100%", height: "100%", objectFit: "cover" }}
    />
  </AbsoluteFill>
);

export const Screen4: React.FC = () => (
  <AbsoluteFill>
    <Img
      src={staticFile(`${BASE}/${DEVICE}-3-map.png`)}
      style={{ width: "100%", height: "100%", objectFit: "cover" }}
    />
  </AbsoluteFill>
);

export const Canvas: React.FC = () => (
  <ScreenshotCanvas screenshotWidth={width} screenshotHeight={height}>
    <Screen1 />
    <Screen2 />
    <Screen3 />
    <Screen4 />
  </ScreenshotCanvas>
);
