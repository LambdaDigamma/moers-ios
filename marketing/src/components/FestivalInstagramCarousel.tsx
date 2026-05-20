import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { z } from "zod";
import { clsx } from "clsx";
import { IPhone17ProFrame } from "./PhoneFrame";
import { useScreenshotContext } from "./ScreenshotContext";
import { loadFestivalFonts } from "../fonts";
import { t, type Locale } from "../i18n/translations";

loadFestivalFonts();

export const INSTAGRAM_CAROUSEL_WIDTH = 1080;
export const INSTAGRAM_CAROUSEL_HEIGHT = 1440;
export const INSTAGRAM_CAROUSEL_SLIDE_NAMES = [
  "companion",
  "acts",
  "map",
  "info",
  "download",
] as const;

export const FestivalInstagramCarouselSchema = z.object({
  locale: z.enum(["de-DE", "en-US"]).default("de-DE"),
});

export type FestivalInstagramCarouselProps = z.infer<
  typeof FestivalInstagramCarouselSchema
>;

const PHONE_FRAME_RATIO = "1350 / 2760";

const ScreenshotSlot: React.FC<{
  index: number;
  children: React.ReactNode;
}> = ({ index, children }) => {
  const { screenshotSize, spacing } = useScreenshotContext();

  return (
    <div
      className="absolute top-0 overflow-hidden"
      style={{
        left: index * (screenshotSize.width + spacing),
        width: screenshotSize.width,
        height: screenshotSize.height,
      }}
    >
      {children}
    </div>
  );
};

const NoiseOverlay: React.FC<{ id: string }> = ({ id }) => (
  <svg className="absolute inset-0 w-full h-full opacity-[0.15] pointer-events-none">
    <filter id={id}>
      <feTurbulence
        type="fractalNoise"
        baseFrequency="0.65"
        numOctaves="3"
        stitchTiles="stitch"
      />
    </filter>
    <rect width="100%" height="100%" filter={`url(#${id})`} />
  </svg>
);

const Background: React.FC<{ index: number }> = ({ index }) => (
  <div className="absolute inset-0 overflow-hidden">
    <Img
      src={staticFile("assets/background.png")}
      className="absolute inset-0 object-cover w-full h-full blur-2xl scale-110 opacity-70"
    />
    <div className="absolute inset-0 bg-black/15" />
    <NoiseOverlay id={`noiseFilter-instagram-carousel-${index}`} />
  </div>
);

const Headline: React.FC<{
  children: React.ReactNode;
  className?: string;
  fontSize?: number;
  style?: React.CSSProperties;
}> = ({ children, className, fontSize = 74, style }) => (
  <h1
    className={clsx(
      "absolute font-typewriter leading-[1.06] font-bold text-white text-center drop-shadow-2xl whitespace-pre-line",
      className,
    )}
    style={{
      fontSize,
      letterSpacing: 0,
      textShadow: "0 10px 34px rgba(0,0,0,0.72)",
      ...style,
    }}
  >
    {children}
  </h1>
);

const FramedPhone: React.FC<{
  src: string;
  className?: string;
  style?: React.CSSProperties;
}> = ({ src, className, style }) => (
  <div
    className={clsx("absolute", className)}
    style={{
      aspectRatio: PHONE_FRAME_RATIO,
      filter: "drop-shadow(0 28px 90px rgba(0,0,0,0.8))",
      ...style,
    }}
  >
    <IPhone17ProFrame>
      <Img
        src={src}
        style={{
          width: "100%",
          height: "100%",
          objectFit: "cover",
          display: "block",
        }}
      />
    </IPhone17ProFrame>
  </div>
);

const FestivalLogo: React.FC = () => (
  <Img
    src={staticFile("assets/logo.png")}
    className="absolute left-1/2 top-[70px] z-10"
    style={{
      width: 360,
      transform: "translateX(-50%)",
      filter: "drop-shadow(0 10px 30px rgba(0,0,0,0.5))",
    }}
  />
);

const MoonDecoration: React.FC = () => (
  <div
    className="absolute opacity-40 blur-sm"
    style={{
      top: 70,
      right: -130,
      width: 500,
    }}
  >
    <Img src={staticFile("assets/moon.png")} className="w-full h-auto" />
  </div>
);

const DownloadLink: React.FC = () => (
  <p
    className="absolute left-1/2 px-[58px] py-[24px] font-atkinson font-bold text-center rounded-full bg-white text-black drop-shadow-2xl whitespace-nowrap"
    style={{
      top: 780,
      transform: "translateX(-50%)",
      fontSize: 48,
      letterSpacing: 0,
      boxShadow: "0 18px 54px rgba(0,0,0,0.55)",
    }}
  >
    moers-festival.de/app
  </p>
);

export const FestivalInstagramCarousel: React.FC<
  FestivalInstagramCarouselProps
> = ({ locale = "de-DE" }) => {
  const l = locale as Locale;
  const base = `moers-festival/${locale}`;

  return (
    <AbsoluteFill className="bg-[#050505] w-full h-full overflow-hidden">
      <ScreenshotSlot index={0}>
        <Background index={0} />
        <FestivalLogo />
        <Headline
          fontSize={74}
          className="left-0 right-0 px-[120px] "
          style={{ top: 335 }}
        >
          {t(l, "slot0_headline")}
        </Headline>
        <FramedPhone
          src={staticFile(`${base}/iPhone 17 Pro-0-events.png`)}
          style={{
            width: 690,
            left: "50%",
            bottom: -670,
            transform: "translateX(-50%) rotate(-2deg)",
          }}
        />
      </ScreenshotSlot>

      <ScreenshotSlot index={1}>
        <Background index={1} />
        <Headline
          fontSize={82}
          className="left-0 right-0 px-[100px]"
          style={{ top: 100 }}
        >
          {t(l, "slot1_headline")}
        </Headline>
        <FramedPhone
          src={staticFile(`${base}/iPhone 17 Pro-1-event_detail.png`)}
          style={{
            width: 720,
            left: "50%",
            top: 350,
            transform: "translateX(-50%) rotate(2deg)",
          }}
        />
      </ScreenshotSlot>

      <ScreenshotSlot index={2}>
        <Background index={2} />
        <FramedPhone
          src={staticFile(`${base}/iPhone 17 Pro-3-map.png`)}
          style={{
            width: 760,
            left: "50%",
            top: -500,
            transform: "translateX(-50%) rotate(-2deg)",
          }}
        />
        <Headline
          fontSize={82}
          className="left-0 right-0 px-[104px]"
          style={{ bottom: 100 }}
        >
          {t(l, "slot3_headline")}
        </Headline>
      </ScreenshotSlot>

      <ScreenshotSlot index={3}>
        <Background index={3} />
        {/*<MoonDecoration />*/}
        <FramedPhone
          src={staticFile(`${base}/iPhone 17 Pro-2-info.png`)}
          style={{
            width: 620,
            left: "50%",
            top: -120,
            transform: "translateX(-50%)",
          }}
        />
        <Headline
          fontSize={72}
          className="left-0 right-0 px-[80px]"
          style={{ bottom: 80 }}
        >
          {t(l, "slot2_headline")}
        </Headline>
      </ScreenshotSlot>

      <ScreenshotSlot index={4}>
        <Background index={4} />
        <MoonDecoration />
        <FestivalLogo />
        <Headline
          fontSize={88}
          className="left-0 right-0 px-[72px]"
          style={{ top: 540 }}
        >
          {t(l, "download_headline")}
        </Headline>
        <DownloadLink />
      </ScreenshotSlot>
    </AbsoluteFill>
  );
};
