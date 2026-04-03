import type { Meta, StoryObj } from "@storybook/react";
import { IPadFrame, Orientation, IPadColor } from "../PhoneFrame";

const meta: Meta<typeof IPadFrame> = {
  title: "Device Frames/iPad",
  component: IPadFrame,
  parameters: { layout: "centered" },
  argTypes: {
    orientation: {
      control: "select",
      options: ["portrait", "landscape"] as Orientation[],
    },
    color: {
      control: "select",
      options: ["Silver"] as IPadColor[],
    },
  },
};

export default meta;

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

export const LandscapeSilver: StoryObj<typeof meta> = {
  name: "Landscape/Silver",
  args: {
    orientation: "landscape",
    color: "Silver",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};
