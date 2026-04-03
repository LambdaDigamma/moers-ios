import type { Meta, StoryObj } from "@storybook/react";
import { IPhoneAirFrame, Orientation, IPhoneAirColor } from "../PhoneFrame";

const meta: Meta<typeof IPhoneAirFrame> = {
  title: "Device Frames/iPhone Air",
  component: IPhoneAirFrame,
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
        "Space Black",
        "Cloud White",
        "Sky Blue",
        "Light Gold",
      ] as IPhoneAirColor[],
    },
  },
};

export default meta;

export const PortraitSpaceBlack: StoryObj<typeof meta> = {
  name: "Portrait/Space Black",
  args: {
    orientation: "portrait",
    color: "Space Black",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitCloudWhite: StoryObj<typeof meta> = {
  name: "Portrait/Cloud White",
  args: {
    orientation: "portrait",
    color: "Cloud White",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitSkyBlue: StoryObj<typeof meta> = {
  name: "Portrait/Sky Blue",
  args: {
    orientation: "portrait",
    color: "Sky Blue",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitLightGold: StoryObj<typeof meta> = {
  name: "Portrait/Light Gold",
  args: {
    orientation: "portrait",
    color: "Light Gold",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const LandscapeSpaceBlack: StoryObj<typeof meta> = {
  name: "Landscape/Space Black",
  args: {
    orientation: "landscape",
    color: "Space Black",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};
