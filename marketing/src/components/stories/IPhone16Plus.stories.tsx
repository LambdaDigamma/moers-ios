import type { Meta, StoryObj } from "@storybook/react";
import { IPhone16PlusFrame, Orientation, IPhone16Color } from "../PhoneFrame";

const meta: Meta<typeof IPhone16PlusFrame> = {
  title: "Device Frames/iPhone 16 Plus",
  component: IPhone16PlusFrame,
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
        "Pink",
        "Teal",
        "Ultramarine",
      ] as IPhone16Color[],
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
