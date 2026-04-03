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

const Background: React.FC = () => (
  <Img
    src={staticFile("assets/background.png")}
    className="absolute inset-0 object-cover w-full h-full blur-xl scale-105"
  />
);

const Headline: React.FC<{
  children: React.ReactNode;
  style?: React.CSSProperties;
  className?: string;
  fontSize?: number;
}> = ({ children, style, className, fontSize = 96 }) => (
  <h1
    className={clsx(
      "font-typewriter leading-tight font-bold text-white absolute",
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
    <AbsoluteFill className="bg-[#0a0a0a] w-full h-full overflow-hidden">
      {/* ── Slot 0: Timetable — hero intro ── */}
      <ScreenshotSlot index={0}>
        <Background />
        <div className="absolute top-[80px] left-0 right-0 flex justify-center">
          <Img src={staticFile("assets/logo.png")} style={{ width: "40%" }} />
        </div>
        <Headline
          fontSize={100}
          style={{ top: 380, left: 80, right: 80 }}
        >
          {t(l, "slot0_headline")}
        </Headline>
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.9,
            left: 140,
            bottom: -500,
            transform: "rotate(-5deg)",
            transformOrigin: "bottom left",
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
          fontSize={88}
          className="text-center"
          style={{ top: 100, left: 80, right: 80 }}
        >
          {t(l, "slot1_headline")}
        </Headline>
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.8,
            left: "50%",
            top: 420,
            transform: "translateX(-50%) rotate(3deg)",
          }}
        >
          <IPhone17ProFrame>
            <Img
              src={staticFile(`${base}/iPhone 17 Pro-1-event_detail.png`)}
            />
          </IPhone17ProFrame>
        </div>
      </ScreenshotSlot>

      {/* ── Slot 2: Info & Tickets — phone left, headline bottom-right ── */}
      <ScreenshotSlot index={2}>
        <Background />
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.75,
            left: -80,
            top: 180,
            transform: "rotate(-4deg)",
            transformOrigin: "top left",
          }}
        >
          <IPhone17ProFrame>
            <Img src={staticFile(`${base}/iPhone 17 Pro-2-info.png`)} />
          </IPhone17ProFrame>
        </div>
        <Headline
          fontSize={88}
          className="text-right"
          style={{ bottom: 180, left: 80, right: 80 }}
        >
          {t(l, "slot2_headline")}
        </Headline>
      </ScreenshotSlot>

      {/* ── Slot 3: Festival Map — dramatic top-entry, headline bottom ── */}
      <ScreenshotSlot index={3}>
        <Background />
        <div
          className="absolute"
          style={{
            width: screenshotSize.width * 0.82,
            left: "50%",
            top: -200,
            transform: "translateX(-50%) rotate(-8deg)",
          }}
        >
          <IPhone17ProFrame>
            <Img src={staticFile(`${base}/iPhone 17 Pro-3-map.png`)} />
          </IPhone17ProFrame>
        </div>
        <Headline
          fontSize={88}
          className="text-center"
          style={{ bottom: 200, left: 80, right: 80 }}
        >
          {t(l, "slot3_headline")}
        </Headline>
      </ScreenshotSlot>
    </AbsoluteFill>
  );
};
