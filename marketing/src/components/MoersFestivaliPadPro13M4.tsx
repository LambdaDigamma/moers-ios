import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { clsx } from "clsx";
import { IPadPro11M4Frame } from "./PhoneFrame";
import { useScreenshotContext } from "./ScreenshotContext";
import { loadFestivalFonts } from "../fonts";
import { t, type Locale } from "../i18n/translations";
import {
  FestivalPromoProps,
} from "./MoersFestivaliPhone17Pro";

loadFestivalFonts();

const ScreenshotSlot: React.FC<{
  index: number;
  children?: React.ReactNode;
  className?: string;
}> = ({ index, children, className }) => {
  const { screenshotSize, spacing } = useScreenshotContext();

  return (
    <div
      style={{
        left: index * (screenshotSize.width + spacing),
        width: screenshotSize.width,
        height: screenshotSize.height,
      }}
      className={clsx("absolute top-0 overflow-visible", className)}
    >
      {children}
    </div>
  );
};

const NoiseOverlay: React.FC = () => (
  <svg className="absolute inset-0 w-full h-full opacity-[0.15] pointer-events-none">
    <filter id="noiseFilter-iPad">
      <feTurbulence
        type="fractalNoise"
        baseFrequency="0.65"
        numOctaves="3"
        stitchTiles="stitch"
      />
    </filter>
    <rect width="100%" height="100%" filter="url(#noiseFilter-iPad)" />
  </svg>
);

const Background: React.FC = () => (
  <div className="absolute inset-0 overflow-hidden">
    <Img
      src={staticFile("assets/background.png")}
      className="absolute inset-0 object-cover w-full h-full blur-2xl scale-110 opacity-70"
    />
    <NoiseOverlay />
  </div>
);

const Headline: React.FC<{
  children: React.ReactNode;
  style?: React.CSSProperties;
  className?: string;
  fontSize?: number;
}> = ({ children, style, className, fontSize = 96 }) => (
  <h1
    className={clsx(
      "font-typewriter leading-[1.08] font-bold text-white absolute tracking-tight drop-shadow-2xl whitespace-pre-line",
      className,
    )}
    style={{
      fontSize,
      textShadow: "0 8px 28px rgba(0,0,0,0.72)",
      ...style,
    }}
  >
    {children}
  </h1>
);

const FramedScreenshot: React.FC<{
  src: string;
}> = ({ src }) => (
  <Img
    src={src}
    style={{
      width: "100%",
      height: "100%",
      objectFit: "cover",
      display: "block",
    }}
  />
);

export const MoersFestivaliPadPro13M4: React.FC<FestivalPromoProps> = ({
  locale = "de-DE",
}) => {
  const { screenshotSize } = useScreenshotContext();
  const l = locale as Locale;
  const base = `moers-festival/${locale}`;
  const rawDevice = "iPad Pro 11-inch (M5)";

  return (
    <AbsoluteFill className="bg-[#050505] w-full h-full overflow-hidden">
      {/* ── Slot 0: Combined events + detail ── */}
      <ScreenshotSlot index={0}>
        <Background />
        <div className="absolute top-[44px] left-0 right-0 flex justify-center z-10">
          <Img
            src={staticFile("assets/logo.png")}
            style={{
              width: "17%",
              filter: "drop-shadow(0 10px 30px rgba(0,0,0,0.5))",
            }}
          />
        </div>
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.68,
            left: "50%",
            top: 390,
            transform: "translateX(-50%) rotate(-1deg)",
            filter: "drop-shadow(0 34px 110px rgba(0,0,0,0.82))",
          }}
        >
          <IPadPro11M4Frame orientation="landscape">
            <FramedScreenshot src={staticFile(`${base}/${rawDevice}-0-events.png`)} />
          </IPadPro11M4Frame>
        </div>
        <Headline
          fontSize={78}
          className="text-center px-[230px] z-10"
          style={{ bottom: 86, left: 0, right: 0 }}
        >
          {t(l, "slot0_headline")}
        </Headline>
      </ScreenshotSlot>

      {/* ── Slot 1: Festival Map ── */}
      <ScreenshotSlot index={1}>
        <Background />
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.82,
            left: "50%",
            top: 80,
            transform: "translateX(-50%) rotate(-1.5deg)",
            filter: "drop-shadow(0 34px 110px rgba(0,0,0,0.82))",
          }}
        >
          <IPadPro11M4Frame orientation="landscape">
            <FramedScreenshot src={staticFile(`${base}/${rawDevice}-1-map.png`)} />
          </IPadPro11M4Frame>
        </div>
        <Headline
          fontSize={82}
          className="text-center px-[260px] z-10"
          style={{ bottom: 82, left: 0, right: 0 }}
        >
          {t(l, "slot3_headline")}
        </Headline>
      </ScreenshotSlot>

      {/* ── Slot 2: Info ── */}
      <ScreenshotSlot index={2}>
        <Background />
        <div
          className="absolute opacity-40 blur-sm"
          style={{
            top: 58,
            right: -50,
            width: "34%",
          }}
        >
          <Img src={staticFile("assets/moon.png")} className="w-full h-auto" />
        </div>
        <Headline
          fontSize={76}
          className="text-center px-[220px] z-10"
          style={{ top: 120, left: 0, right: 0 }}
        >
          {t(l, "slot2_headline")}
        </Headline>
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.80,
            left: "50%",
            top: 360,
            transform: "translateX(-50%) rotate(1.25deg)",
            filter: "drop-shadow(0 34px 110px rgba(0,0,0,0.82))",
          }}
        >
          <IPadPro11M4Frame orientation="landscape">
            <FramedScreenshot src={staticFile(`${base}/${rawDevice}-2-info.png`)} />
          </IPadPro11M4Frame>
        </div>
      </ScreenshotSlot>
    </AbsoluteFill>
  );
};
