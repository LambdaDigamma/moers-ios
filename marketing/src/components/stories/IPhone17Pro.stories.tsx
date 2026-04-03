import type { Meta, StoryObj } from "@storybook/react";
import { IPhone17ProFrame, Orientation, IPhone17ProColor } from "../PhoneFrame";

const meta: Meta<typeof IPhone17ProFrame> = {
  title: "Device Frames/iPhone 17 Pro",
  component: IPhone17ProFrame,
  parameters: { layout: "centered" },
  argTypes: {
    orientation: {
      control: "select",
      options: ["portrait", "landscape"] as Orientation[],
    },
    color: {
      control: "select",
      options: ["Silver", "Deep Blue", "Cosmic Orange"] as IPhone17ProColor[],
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
      <div
        style={{
          width: "100%",
          height: "100%",
          background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
        }}
      />
    ),
  },
};

export const PortraitDeepBlue: StoryObj<typeof meta> = {
  name: "Portrait/Deep Blue",
  args: {
    orientation: "portrait",
    color: "Deep Blue",
    children: (
      <div
        style={{
          width: "100%",
          height: "100%",
          background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
        }}
      />
    ),
  },
};

export const PortraitCosmicOrange: StoryObj<typeof meta> = {
  name: "Portrait/Cosmic Orange",
  args: {
    orientation: "portrait",
    color: "Cosmic Orange",
    children: (
      <div
        style={{
          width: "100%",
          height: "100%",
          background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
        }}
      />
    ),
  },
};

export const LandscapeSilver: StoryObj<typeof meta> = {
  name: "Landscape/Silver",
  args: {
    orientation: "landscape",
    color: "Silver",
    children: (
      <div
        style={{
          width: "100%",
          height: "100%",
          background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
        }}
      />
    ),
  },
};
