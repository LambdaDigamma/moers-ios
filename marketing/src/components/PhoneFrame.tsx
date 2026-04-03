import React from "react";

export type Orientation = "portrait" | "landscape";

// =============================================================================
// Image loader abstraction for Storybook/Remotion compatibility
// =============================================================================

let ImageComponent: React.FC<{
  src: string;
  style?: React.CSSProperties;
}> = ({ src, style }) => <img src={src} style={style} />;

let pathTransformer: (path: string) => string = (path) => path;

export function setImageLoader(
  loader: React.FC<{ src: string; style?: React.CSSProperties }>,
  transformer?: (path: string) => string,
) {
  ImageComponent = loader;
  if (transformer) {
    pathTransformer = transformer;
  }
}

export function setRemotionImageLoader() {
  let Img: any;
  let staticFile: any;
  try {
    const remotion = require("remotion");
    Img = remotion.Img;
    staticFile = remotion.staticFile;
  } catch {
    return;
  }
  ImageComponent = ({
    src,
    style,
  }: {
    src: string;
    style?: React.CSSProperties;
  }) => <Img style={style} src={src} />;
  pathTransformer = staticFile;
}

// iPhone 17 Pro colors
export type IPhone17ProColor = "Silver" | "Deep Blue" | "Cosmic Orange";

// iPhone 17 Pro Max colors
export type IPhone17ProMaxColor = "Silver" | "Deep Blue" | "Cosmic Orange";

// iPhone 17 colors
export type IPhone17Color =
  | "Black"
  | "White"
  | "Lavender"
  | "Mist Blue"
  | "Sage";

// iPhone 16 Pro colors
export type IPhone16ProColor =
  | "Black Titanium"
  | "White Titanium"
  | "Natural Titanium"
  | "Desert Titanium";

// iPhone 16 Pro Max colors
export type IPhone16ProMaxColor =
  | "Black Titanium"
  | "White Titanium"
  | "Natural Titanium"
  | "Desert Titanium";

// iPhone 16 colors
export type IPhone16Color = "Black" | "White" | "Pink" | "Teal" | "Ultramarine";

// iPhone Air colors
export type IPhoneAirColor =
  | "Space Black"
  | "Cloud White"
  | "Sky Blue"
  | "Light Gold";

// iPad Pro 13" M4 colors
export type IPadPro13M4Color = "Space Gray" | "Silver";

// iPad Air 11" M2 colors
export type IPadAir11M2Color =
  | "Space Gray"
  | "Silver"
  | "Blue"
  | "Purple"
  | "Stardust";

// iPad mini colors
export type IPadMiniColor = "Starlight";

// iPad colors
export type IPadColor = "Silver";

// =============================================================================
// Frame definitions with screen area percentages
// =============================================================================

interface FrameDefinition {
  folder: string;
  screenArea: {
    top: string;
    left: string;
    right: string;
    bottom: string;
    borderRadius: string;
  };
}

const frameDefinitions: Record<string, FrameDefinition> = {
  "iPhone 17 Pro": {
    folder: "iPhone 17 Pro",
    screenArea: {
      top: "2%",
      left: "5%",
      right: "5%",
      bottom: "2.5%",
      borderRadius: "8%",
    },
  },
  "iPhone 17 Pro Max": {
    folder: "iPhone 17 Pro Max",
    screenArea: {
      top: "2.2%",
      left: "5.1%",
      right: "5.1%",
      bottom: "2.3%",
      borderRadius: "8%",
    },
  },
  "iPhone 17": {
    folder: "iPhone 17",
    screenArea: {
      top: "3.5%",
      left: "11%",
      right: "11%",
      bottom: "3.5%",
      borderRadius: "40px",
    },
  },
  "iPhone 16 Pro": {
    folder: "iPhone 16 Pro",
    screenArea: {
      top: "2.5%",
      left: "5.4%",
      right: "5.5%",
      bottom: "2.7%",
      borderRadius: "80px",
    },
  },
  "iPhone 16 Pro Max": {
    folder: "iPhone 16 Pro Max",
    screenArea: {
      top: "3.5%",
      left: "11.5%",
      right: "11.5%",
      bottom: "3.5%",
      borderRadius: "38px",
    },
  },
  "iPhone 16": {
    folder: "iPhone 16",
    screenArea: {
      top: "3.86%",
      left: "12.22%",
      right: "12.06%",
      bottom: "3.88%",
      borderRadius: "40px",
    },
  },
  "iPhone 16 Plus": {
    folder: "iPhone 16 Plus",
    screenArea: {
      top: "3.5%",
      left: "11.5%",
      right: "11.5%",
      bottom: "3.5%",
      borderRadius: "38px",
    },
  },
  "iPhone Air": {
    folder: "iPhone Air",
    screenArea: {
      top: "3.5%",
      left: "11%",
      right: "11%",
      bottom: "3.5%",
      borderRadius: "40px",
    },
  },
  "iPad Pro 13 - M4": {
    folder: "iPad Pro 13 - M4",
    screenArea: {
      top: "3%",
      left: "7%",
      right: "7%",
      bottom: "3%",
      borderRadius: "12px",
    },
  },
  "iPad Air 11 - M2": {
    folder: 'iPad Air 11" - M2',
    screenArea: {
      top: "3.5%",
      left: "8%",
      right: "8%",
      bottom: "3.5%",
      borderRadius: "12px",
    },
  },
  "iPad mini": {
    folder: "iPad mini",
    screenArea: {
      top: "4%",
      left: "9%",
      right: "9%",
      bottom: "4%",
      borderRadius: "12px",
    },
  },
  iPad: {
    folder: "iPad",
    screenArea: {
      top: "4%",
      left: "8%",
      right: "8%",
      bottom: "4%",
      borderRadius: "16px",
    },
  },
};

function getFrameImagePath(
  device: string,
  orientation: Orientation,
  color?: string,
): string {
  const frameDef = frameDefinitions[device];
  if (!frameDef) {
    throw new Error(`Unknown device: ${device}`);
  }

  if (color) {
    return `${frameDef.folder}/${device} - ${color} - ${orientation.charAt(0).toUpperCase() + orientation.slice(1)}.png`;
  }

  // Try to find a default
  return `${frameDef.folder}/${device} - ${orientation.charAt(0).toUpperCase() + orientation.slice(1)}.png`;
}

// =============================================================================
// Generic PhoneFrame component
// =============================================================================

type PhoneFrameProps = {
  children: React.ReactNode;
  device: string;
  orientation?: Orientation;
  color?: string;
};

export const PhoneFrame: React.FC<PhoneFrameProps> = ({
  children,
  device,
  orientation = "portrait",
  color,
}) => {
  const frameDef = frameDefinitions[device];

  if (!frameDef) {
    // Fallback to generic frame if device not found
    return (
      <div
        style={{
          position: "relative",
          backgroundColor: "#1a1a1a",
          borderRadius: "40px",
          padding: "15px",
          boxShadow: "0 20px 60px rgba(0,0,0,0.5)",
        }}
      >
        <div
          style={{
            position: "relative",
            borderRadius: "40px",
            overflow: "hidden",
            backgroundColor: "white",
          }}
        >
          {children}
        </div>
      </div>
    );
  }

  try {
    const framePath = getFrameImagePath(device, orientation, color);
    const staticFilePath = pathTransformer(`frames/${framePath}`);

    return (
      <div style={{ position: "relative" }}>
        <ImageComponent
          style={{ position: "relative", zIndex: 10 }}
          src={staticFilePath}
        />
        <div
          style={{
            position: "absolute",
            top: frameDef.screenArea.top,
            left: frameDef.screenArea.left,
            right: frameDef.screenArea.right,
            bottom: frameDef.screenArea.bottom,
            zIndex: 0,
            overflow: "hidden",
            borderRadius: frameDef.screenArea.borderRadius,
            backgroundColor: "white",
          }}
        >
          {children}
        </div>
      </div>
    );
  } catch {
    // Fallback if frame image not found
    return (
      <div
        style={{
          position: "relative",
          backgroundColor: "#1a1a1a",
          borderRadius: "40px",
          padding: "15px",
          boxShadow: "0 20px 60px rgba(0,0,0,0.5)",
        }}
      >
        <div
          style={{
            position: "relative",
            borderRadius: "40px",
            overflow: "hidden",
            backgroundColor: "white",
          }}
        >
          {children}
        </div>
      </div>
    );
  }
};

// =============================================================================
// Typed device-specific components
// =============================================================================

// iPhone 17 Pro
type IPhone17ProFrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPhone17ProColor;
};

export const IPhone17ProFrame: React.FC<IPhone17ProFrameProps> = ({
  children,
  orientation = "portrait",
  color = "Silver",
}) => (
  <PhoneFrame device="iPhone 17 Pro" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPhone 17 Pro Max
type IPhone17ProMaxFrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPhone17ProMaxColor;
};

export const IPhone17ProMaxFrame: React.FC<IPhone17ProMaxFrameProps> = ({
  children,
  orientation = "portrait",
  color = "Silver",
}) => (
  <PhoneFrame
    device="iPhone 17 Pro Max"
    orientation={orientation}
    color={color}
  >
    {children}
  </PhoneFrame>
);

// iPhone 17
type IPhone17FrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPhone17Color;
};

export const IPhone17Frame: React.FC<IPhone17FrameProps> = ({
  children,
  orientation = "portrait",
  color = "Black",
}) => (
  <PhoneFrame device="iPhone 17" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPhone 16 Pro
type IPhone16ProFrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPhone16ProColor;
};

export const IPhone16ProFrame: React.FC<IPhone16ProFrameProps> = ({
  children,
  orientation = "portrait",
  color = "Black Titanium",
}) => (
  <PhoneFrame device="iPhone 16 Pro" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPhone 16 Pro Max
type IPhone16ProMaxFrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPhone16ProMaxColor;
};

export const IPhone16ProMaxFrame: React.FC<IPhone16ProMaxFrameProps> = ({
  children,
  orientation = "portrait",
  color = "Black Titanium",
}) => (
  <PhoneFrame
    device="iPhone 16 Pro Max"
    orientation={orientation}
    color={color}
  >
    {children}
  </PhoneFrame>
);

// iPhone 16
type IPhone16FrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPhone16Color;
};

export const IPhone16Frame: React.FC<IPhone16FrameProps> = ({
  children,
  orientation = "portrait",
  color = "Black",
}) => (
  <PhoneFrame device="iPhone 16" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPhone 16 Plus
type IPhone16PlusFrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPhone16Color;
};

export const IPhone16PlusFrame: React.FC<IPhone16PlusFrameProps> = ({
  children,
  orientation = "portrait",
  color = "Black",
}) => (
  <PhoneFrame device="iPhone 16 Plus" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPhone Air
type IPhoneAirFrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPhoneAirColor;
};

export const IPhoneAirFrame: React.FC<IPhoneAirFrameProps> = ({
  children,
  orientation = "portrait",
  color = "Space Black",
}) => (
  <PhoneFrame device="iPhone Air" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPad Pro 13" M4
type IPadPro13M4FrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPadPro13M4Color;
};

export const IPadPro13M4Frame: React.FC<IPadPro13M4FrameProps> = ({
  children,
  orientation = "portrait",
  color = "Space Gray",
}) => (
  <PhoneFrame device="iPad Pro 13 - M4" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPad Air 11" M2
type IPadAir11M2FrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPadAir11M2Color;
};

export const IPadAir11M2Frame: React.FC<IPadAir11M2FrameProps> = ({
  children,
  orientation = "portrait",
  color = "Space Gray",
}) => (
  <PhoneFrame device="iPad Air 11 - M2" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPad mini
type IPadMiniFrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPadMiniColor;
};

export const IPadMiniFrame: React.FC<IPadMiniFrameProps> = ({
  children,
  orientation = "portrait",
  color = "Starlight",
}) => (
  <PhoneFrame device="iPad mini" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);

// iPad
type IPadFrameProps = {
  children: React.ReactNode;
  orientation?: Orientation;
  color?: IPadColor;
};

export const IPadFrame: React.FC<IPadFrameProps> = ({
  children,
  orientation = "portrait",
  color = "Silver",
}) => (
  <PhoneFrame device="iPad" orientation={orientation} color={color}>
    {children}
  </PhoneFrame>
);
