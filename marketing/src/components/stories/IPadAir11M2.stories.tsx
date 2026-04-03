import type { Meta, StoryObj } from "@storybook/react";
import { IPadAir11M2Frame, Orientation, IPadAir11M2Color } from "../PhoneFrame";

const meta: Meta<typeof IPadAir11M2Frame> = {
  title: "Device Frames/iPad Air 11 M2",
  component: IPadAir11M2Frame,
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
        "Space Gray",
        "Silver",
        "Blue",
        "Purple",
        "Stardust",
      ] as IPadAir11M2Color[],
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

export const PortraitBlue: StoryObj<typeof meta> = {
  name: "Portrait/Blue",
  args: {
    orientation: "portrait",
    color: "Blue",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitPurple: StoryObj<typeof meta> = {
  name: "Portrait/Purple",
  args: {
    orientation: "portrait",
    color: "Purple",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};

export const PortraitStardust: StoryObj<typeof meta> = {
  name: "Portrait/Stardust",
  args: {
    orientation: "portrait",
    color: "Stardust",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#ff0000" }} />
    ),
  },
};
