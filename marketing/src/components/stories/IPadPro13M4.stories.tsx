import type { Meta, StoryObj } from "@storybook/react";
import { IPadPro13M4Frame, Orientation, IPadPro13M4Color } from "../PhoneFrame";

const meta: Meta<typeof IPadPro13M4Frame> = {
  title: "Device Frames/iPad Pro 13 M4",
  component: IPadPro13M4Frame,
  parameters: { layout: "centered" },
  argTypes: {
    orientation: {
      control: "select",
      options: ["portrait", "landscape"] as Orientation[],
    },
    color: {
      control: "select",
      options: ["Space Gray", "Silver"] as IPadPro13M4Color[],
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
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const PortraitSilver: StoryObj<typeof meta> = {
  name: "Portrait/Silver",
  args: {
    orientation: "portrait",
    color: "Silver",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const LandscapeSpaceGray: StoryObj<typeof meta> = {
  name: "Landscape/Space Gray",
  args: {
    orientation: "landscape",
    color: "Space Gray",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};
