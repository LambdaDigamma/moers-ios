import type { Meta, StoryObj } from "@storybook/react";
import {
  IPadPro11M4Color,
  IPadPro11M4Frame,
  Orientation,
} from "../PhoneFrame";

const meta: Meta<typeof IPadPro11M4Frame> = {
  title: "Device Frames/iPad Pro 11 M4",
  component: IPadPro11M4Frame,
  parameters: { layout: "centered" },
  decorators: [
    (Story) => (
      <div
        style={{
          minHeight: "600px",
          minWidth: "800px",
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
      options: ["Space Gray", "Silver"] as IPadPro11M4Color[],
    },
  },
};

export default meta;

export const PortraitSpaceGray: StoryObj<typeof meta> = {
  name: "Portrait/Space Gray",
  args: {
    orientation: "portrait",
    color: "Space Gray",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitSilver: StoryObj<typeof meta> = {
  name: "Portrait/Silver",
  args: {
    orientation: "portrait",
    color: "Silver",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const LandscapeSpaceGray: StoryObj<typeof meta> = {
  name: "Landscape/Space Gray",
  args: {
    orientation: "landscape",
    color: "Space Gray",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const LandscapeSilver: StoryObj<typeof meta> = {
  name: "Landscape/Silver",
  args: {
    orientation: "landscape",
    color: "Silver",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};
