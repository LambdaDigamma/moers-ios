import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { z } from "zod";
import { IPhone17ProFrame } from "./PhoneFrame";
import { useScreenshotContext } from "./ScreenshotContext";
import { clsx } from "clsx";
import { loadFestivalFonts } from "../fonts";
import { t, type Locale } from "../i18n/translations";

loadFestivalFonts();

export const FestivalPromoSchema = z.object({
  locale: z.enum(["de-DE", "en-US"]).default("de-DE"),
});

export type FestivalPromoProps = z.infer<typeof FestivalPromoSchema>;

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
    <filter id="noiseFilter">
      <feTurbulence 
        type="fractalNoise" 
        baseFrequency="0.65" 
        numOctaves="3" 
        stitchTiles="stitch" 
      />
    </filter>
    <rect width="100%" height="100%" filter="url(#noiseFilter)" />
  </svg>
);

const Background: React.FC = () => (
  <div className="absolute inset-0 overflow-hidden">
    <Img
      src={staticFile("assets/background.png")}
      className="absolute inset-0 object-cover w-full h-full blur-2xl scale-110 opacity-60"
    />
    <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-black/20 to-black/70" />
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
      "font-typewriter leading-[1.1] font-bold text-white absolute tracking-tight drop-shadow-2xl",
      className,
    )}
    style={{ fontSize, ...style }}
  >
    {children}
  </h1>
);

export const FestivalPromo: React.FC<FestivalPromoProps> = ({
  locale = "de-DE",
}) => {
  const { screenshotSize } = useScreenshotContext();
  const l = locale as Locale;
  const base = `moers-festival/${locale}`;

  return (
    <AbsoluteFill className="bg-[#050505] w-full h-full overflow-hidden">
      {/* ── Slot 0: Timetable — hero intro ── */}
      <ScreenshotSlot index={0}>
        <Background />
        <div className="absolute top-[100px] left-0 right-0 flex justify-center z-10">
          <Img 
            src={staticFile("assets/logo.png")} 
            style={{ width: "45%", filter: "drop-shadow(0 10px 30px rgba(0,0,0,0.5))" }} 
          />
        </div>
        <Headline
          fontSize={110}
          className="px-[90px]"
          style={{ top: 480, left: 0, right: 0 }}
        >
          {t(l, "slot0_headline")}
        </Headline>
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.90,
            left: "52%",
            bottom: -580,
            transform: "translateX(-50%) rotate(-2deg)",
            filter: "drop-shadow(0 30px 100px rgba(0,0,0,0.8))",
          }}
        >
          <IPhone17ProFrame>
            <Img src={staticFile(`${base}/iPhone 17 Pro-0-events.png`)} />
          </IPhone17ProFrame>
        </div>
      </ScreenshotSlot>

      {/* ── Slot 1: Event Detail — centered phone, headline top ── */}
      <ScreenshotSlot index={1}>
        <Background />
        <Headline
          fontSize={100}
          className="text-center px-12"
          style={{ top: 120, left: 0, right: 0 }}
        >
          {t(l, "slot1_headline")}
        </Headline>
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.85,
            left: "50%",
            top: 460,
            transform: "translateX(-50%) rotate(2deg)",
            filter: "drop-shadow(0 30px 100px rgba(0,0,0,0.8))",
          }}
        >
          <IPhone17ProFrame>
            <Img
              src={staticFile(`${base}/iPhone 17 Pro-1-event_detail.png`)}
            />
          </IPhone17ProFrame>
        </div>
      </ScreenshotSlot>

      {/* ── Slot 2: Festival Map — dramatic top-entry, headline bottom ── */}
      <ScreenshotSlot index={2}>
        <Background />
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.88,
            left: "50%",
            top: -250,
            transform: "translateX(-50%) rotate(-2deg)",
            filter: "drop-shadow(0 30px 100px rgba(0,0,0,0.8))",
          }}
        >
          <IPhone17ProFrame>
            <Img src={staticFile(`${base}/iPhone 17 Pro-3-map.png`)} />
          </IPhone17ProFrame>
        </div>
        
        {/* Decorative Bird */}
        {/*<Img */}
        {/*  src={staticFile("assets/vogel_white.png")} */}
        {/*  className="absolute opacity-20"*/}
        {/*  style={{*/}
        {/*    width: "40%",*/}
        {/*    right: 40,*/}
        {/*    top: 400,*/}
        {/*    transform: "rotate(15deg) scaleX(-1)",*/}
        {/*    filter: "blur(1px)",*/}
        {/*  }}*/}
        {/*/>*/}

        <Headline
          fontSize={100}
          className="text-center px-12"
          style={{ bottom: 240, left: 0, right: 0 }}
        >
          {t(l, "slot3_headline")}
        </Headline>
      </ScreenshotSlot>

      {/* ── Slot 3: Info & Tickets — phone left, headline bottom-right ── */}
      <ScreenshotSlot index={3}>
        <Background />
        
        {/* Decorative Moon */}
        <div 
          className="absolute opacity-40 blur-sm"
          style={{
            top: 80,
            right: -100,
            width: "60%",
          }}
        >
          <Img src={staticFile("assets/moon.png")} className="w-full h-auto" />
        </div>

        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.8,
            left: 90,
            top: 180,
            transform: "rotate(-2deg)",
            filter: "drop-shadow(0 30px 100px rgba(0,0,0,0.8))",
          }}
        >
          <IPhone17ProFrame>
            <Img src={staticFile(`${base}/iPhone 17 Pro-2-info.png`)} />
          </IPhone17ProFrame>
        </div>


        <Headline
          fontSize={100}
          className="text-center px-[100px] leading-[1.05]"
          style={{ bottom: 160, left: 0, right: 0 }}
        >
          {t(l, "slot2_headline")}
        </Headline>
      </ScreenshotSlot>
    </AbsoluteFill>
  );
};
