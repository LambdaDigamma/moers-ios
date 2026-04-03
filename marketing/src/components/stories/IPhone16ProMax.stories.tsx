import type { Meta, StoryObj } from "@storybook/react";
import {
  IPhone16ProMaxFrame,
  Orientation,
  IPhone16ProMaxColor,
} from "../PhoneFrame";

const meta: Meta<typeof IPhone16ProMaxFrame> = {
  title: "Device Frames/iPhone 16 Pro Max",
  component: IPhone16ProMaxFrame,
  parameters: { layout: "centered" },
  argTypes: {
    orientation: {
      control: "select",
      options: ["portrait", "landscape"] as Orientation[],
    },
    color: {
      control: "select",
      options: [
        "Black Titanium",
        "White Titanium",
        "Natural Titanium",
        "Desert Titanium",
      ] as IPhone16ProMaxColor[],
    },
  },
};

export default meta;

export const PortraitBlackTitanium: StoryObj<typeof meta> = {
  name: "Portrait/Black Titanium",
  args: {
    orientation: "portrait",
    color: "Black Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const PortraitWhiteTitanium: StoryObj<typeof meta> = {
  name: "Portrait/White Titanium",
  args: {
    orientation: "portrait",
    color: "White Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const PortraitNaturalTitanium: StoryObj<typeof meta> = {
  name: "Portrait/Natural Titanium",
  args: {
    orientation: "portrait",
    color: "Natural Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const PortraitDesertTitanium: StoryObj<typeof meta> = {
  name: "Portrait/Desert Titanium",
  args: {
    orientation: "portrait",
    color: "Desert Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};
