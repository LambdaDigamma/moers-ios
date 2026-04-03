import type { Meta, StoryObj } from "@storybook/react";
import { IPhone17Frame, Orientation, IPhone17Color } from "../PhoneFrame";

const meta: Meta<typeof IPhone17Frame> = {
  title: "Device Frames/iPhone 17",
  component: IPhone17Frame,
  parameters: { layout: "centered" },
  argTypes: {
    orientation: {
      control: "select",
      options: ["portrait", "landscape"] as Orientation[],
    },
    color: {
      control: "select",
      options: [
        "Black",
        "White",
        "Lavender",
        "Mist Blue",
        "Sage",
      ] as IPhone17Color[],
    },
  },
};

export default meta;

export const PortraitBlack: StoryObj<typeof meta> = {
  name: "Portrait/Black",
  args: {
    orientation: "portrait",
    color: "Black",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const PortraitWhite: StoryObj<typeof meta> = {
  name: "Portrait/White",
  args: {
    orientation: "portrait",
    color: "White",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const PortraitLavender: StoryObj<typeof meta> = {
  name: "Portrait/Lavender",
  args: {
    orientation: "portrait",
    color: "Lavender",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const PortraitMistBlue: StoryObj<typeof meta> = {
  name: "Portrait/Mist Blue",
  args: {
    orientation: "portrait",
    color: "Mist Blue",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const PortraitSage: StoryObj<typeof meta> = {
  name: "Portrait/Sage",
  args: {
    orientation: "portrait",
    color: "Sage",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const LandscapeBlack: StoryObj<typeof meta> = {
  name: "Landscape/Black",
  args: {
    orientation: "landscape",
    color: "Black",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};
