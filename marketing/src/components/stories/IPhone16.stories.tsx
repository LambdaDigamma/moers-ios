import type { Meta, StoryObj } from "@storybook/react";
import { IPhone16Frame, Orientation, IPhone16Color } from "../PhoneFrame";

const meta: Meta<typeof IPhone16Frame> = {
  title: "Device Frames/iPhone 16",
  component: IPhone16Frame,
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
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitWhite: StoryObj<typeof meta> = {
  name: "Portrait/White",
  args: {
    orientation: "portrait",
    color: "White",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitPink: StoryObj<typeof meta> = {
  name: "Portrait/Pink",
  args: {
    orientation: "portrait",
    color: "Pink",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitTeal: StoryObj<typeof meta> = {
  name: "Portrait/Teal",
  args: {
    orientation: "portrait",
    color: "Teal",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitUltramarine: StoryObj<typeof meta> = {
  name: "Portrait/Ultramarine",
  args: {
    orientation: "portrait",
    color: "Ultramarine",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};
