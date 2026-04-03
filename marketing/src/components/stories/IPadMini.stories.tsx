import type { Meta, StoryObj } from "@storybook/react";
import { IPadMiniFrame, Orientation, IPadMiniColor } from "../PhoneFrame";

const meta: Meta<typeof IPadMiniFrame> = {
  title: "Device Frames/iPad mini",
  component: IPadMiniFrame,
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
      options: ["Starlight"] as IPadMiniColor[],
    },
  },
};

export default meta;

export const PortraitStarlight: StoryObj<typeof meta> = {
  name: "Portrait/Starlight",
  args: {
    orientation: "portrait",
    color: "Starlight",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const LandscapeStarlight: StoryObj<typeof meta> = {
  name: "Landscape/Starlight",
  args: {
    orientation: "landscape",
    color: "Starlight",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};
