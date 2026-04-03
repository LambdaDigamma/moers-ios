import type { Meta, StoryObj } from "@storybook/react";
import {
  PhoneFrame,
  IPhone17ProFrame,
  IPhoneAirFrame,
  IPadPro13M4Frame,
} from "./PhoneFrame";

const meta: Meta<typeof PhoneFrame> = {
  title: "Device Frames/PhoneFrame",
  component: PhoneFrame,
  parameters: {
    layout: "centered",
  },
  tags: ["autodocs"],
  argTypes: {
    orientation: {
      control: "select",
      options: ["portrait", "landscape"],
    },
    device: {
      control: "select",
      options: [
        "iPhone 17 Pro",
        "iPhone 17 Pro Max",
        "iPhone 17",
        "iPhone 16 Pro",
        "iPhone 16 Pro Max",
        "iPhone 16",
        "iPhone 16 Plus",
        "iPhone Air",
        "iPad Pro 13 - M4",
        "iPad Air 11 - M2",
        "iPad mini",
        "iPad",
      ],
    },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    device: "iPhone 17 Pro",
    orientation: "portrait",
    color: "Silver",
    children: (
      <div
        style={{
          width: "100%",
          height: "100%",
          background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: "white",
          fontSize: "24px",
          fontWeight: "bold",
        }}
      >
        Hello
      </div>
    ),
  },
};

export const Landscape: Story = {
  args: {
    device: "iPhone 17 Pro",
    orientation: "landscape",
    color: "Silver",
    children: (
      <div
        style={{
          width: "100%",
          height: "100%",
          background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: "white",
          fontSize: "24px",
          fontWeight: "bold",
        }}
      >
        Hello
      </div>
    ),
  },
};

export const iPhone17ProSilver: Story = {
  args: {
    device: "iPhone 17 Pro",
    orientation: "portrait",
    color: "Silver",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const iPhone17ProDeepBlue: Story = {
  args: {
    device: "iPhone 17 Pro",
    orientation: "portrait",
    color: "Deep Blue",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const iPhone17ProCosmicOrange: Story = {
  args: {
    device: "iPhone 17 Pro",
    orientation: "portrait",
    color: "Cosmic Orange",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const iPhone16ProBlackTitanium: Story = {
  args: {
    device: "iPhone 16 Pro",
    orientation: "portrait",
    color: "Black Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const iPhone16ProNaturalTitanium: Story = {
  args: {
    device: "iPhone 16 Pro",
    orientation: "portrait",
    color: "Natural Titanium",
    children: (
      <div style={{ width: "100%", height: "100%", background: "#f0f0f0" }} />
    ),
  },
};

export const AllColors: Story = {
  render: () => (
    <div
      style={{
        display: "flex",
        flexWrap: "wrap",
        gap: "40px",
        justifyContent: "center",
        padding: "40px",
      }}
    >
      {(["Silver", "Deep Blue", "Cosmic Orange"] as const).map((color) => (
        <div key={color} style={{ textAlign: "center" }}>
          <IPhone17ProFrame orientation="portrait" color={color}>
            <div
              style={{ width: "100%", height: "100%", background: "#f0f0f0" }}
            />
          </IPhone17ProFrame>
          <p style={{ marginTop: "8px", fontSize: "12px" }}>{color}</p>
        </div>
      ))}
    </div>
  ),
};

export const AllIPadColors: Story = {
  render: () => (
    <div
      style={{
        display: "flex",
        flexWrap: "wrap",
        gap: "40px",
        justifyContent: "center",
        padding: "40px",
      }}
    >
      {(["Space Gray", "Silver"] as const).map((color) => (
        <div key={color} style={{ textAlign: "center" }}>
          <IPadPro13M4Frame orientation="portrait" color={color}>
            <div
              style={{ width: "100%", height: "100%", background: "#f0f0f0" }}
            />
          </IPadPro13M4Frame>
          <p style={{ marginTop: "8px", fontSize: "12px" }}>{color}</p>
        </div>
      ))}
    </div>
  ),
};

export const AlliPhoneAirColors: Story = {
  render: () => (
    <div
      style={{
        display: "flex",
        flexWrap: "wrap",
        gap: "40px",
        justifyContent: "center",
        padding: "40px",
      }}
    >
      {(["Space Black", "Cloud White", "Sky Blue", "Light Gold"] as const).map(
        (color) => (
          <div key={color} style={{ textAlign: "center" }}>
            <IPhoneAirFrame orientation="portrait" color={color}>
              <div
                style={{ width: "100%", height: "100%", background: "#f0f0f0" }}
              />
            </IPhoneAirFrame>
            <p style={{ marginTop: "8px", fontSize: "12px" }}>{color}</p>
          </div>
        ),
      )}
    </div>
  ),
};

export const SpacingDebug: Story = {
  render: () => (
    <div
      style={{
        display: "flex",
        flexWrap: "wrap",
        gap: "40px",
        justifyContent: "center",
        padding: "40px",
      }}
    >
      <div style={{ textAlign: "center" }}>
        <IPhone17ProFrame orientation="portrait" color="Silver">
          <div
            style={{
              width: "100%",
              height: "100%",
              background: `repeating-linear-gradient(
                0deg,
                transparent,
                transparent 9px,
                #ff0000 9px,
                #ff0000 10px
              ),
              repeating-linear-gradient(
                90deg,
                transparent,
                transparent 9px,
                #ff0000 9px,
                #ff0000 10px
              )`,
            }}
          />
        </IPhone17ProFrame>
        <p style={{ marginTop: "8px", fontSize: "12px" }}>Grid: 10px</p>
      </div>
      <div style={{ textAlign: "center" }}>
        <IPhone17ProFrame orientation="landscape" color="Silver">
          <div
            style={{
              width: "100%",
              height: "100%",
              background: `repeating-linear-gradient(
                0deg,
                transparent,
                transparent 9px,
                #ff0000 9px,
                #ff0000 10px
              ),
              repeating-linear-gradient(
                90deg,
                transparent,
                transparent 9px,
                #ff0000 9px,
                #ff0000 10px
              )`,
            }}
          />
        </IPhone17ProFrame>
        <p style={{ marginTop: "8px", fontSize: "12px" }}>
          Landscape Grid: 10px
        </p>
      </div>
    </div>
  ),
};
