import type { Meta, StoryObj } from "@storybook/react";
import { IPhone16ProFrame, Orientation, IPhone16ProColor } from "../PhoneFrame";

const meta: Meta<typeof IPhone16ProFrame> = {
  title: "Device Frames/iPhone 16 Pro",
  component: IPhone16ProFrame,
  parameters: { layout: "centered" },
  decorators: [
    (Story) => (
      <div
        style={{
          height: "600px",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <Story />
      </div>
    ),
  ],
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
      ] as IPhone16ProColor[],
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
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitWhiteTitanium: StoryObj<typeof meta> = {
  name: "Portrait/White Titanium",
  args: {
    orientation: "portrait",
    color: "White Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitNaturalTitanium: StoryObj<typeof meta> = {
  name: "Portrait/Natural Titanium",
  args: {
    orientation: "portrait",
    color: "Natural Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitDesertTitanium: StoryObj<typeof meta> = {
  name: "Portrait/Desert Titanium",
  args: {
    orientation: "portrait",
    color: "Desert Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const LandscapeBlackTitanium: StoryObj<typeof meta> = {
  name: "Landscape/Black Titanium",
  args: {
    orientation: "landscape",
    color: "Black Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};
