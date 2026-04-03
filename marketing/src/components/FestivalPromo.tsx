import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { z } from "zod";
import { IPhone17ProFrame } from "./PhoneFrame";
import { useScreenshotContext } from "./ScreenshotContext";
import { clsx } from "clsx";
import { loadFestivalFonts } from "../fonts";

loadFestivalFonts();

export const FestivalPromoSchema = z.object({});

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
      className={clsx("absolute top-0", className)}
    >
      {children}
    </div>
  );
};

export const FestivalPromo: React.FC<FestivalPromoProps> = () => {
  const screenshotBase = "moers-festival/en-US";

  const imageUrls = [
    `${screenshotBase}/iPhone 17 Pro-0-events.png`,
    `${screenshotBase}/iPhone 17 Pro-1-event_detail.png`,
    `${screenshotBase}/iPhone 17 Pro-2-info.png`,
    `${screenshotBase}/iPhone 17 Pro-3-map.png`,
  ];

  return (
    <AbsoluteFill className="bg-[#0a0a0a] w-full h-full overflow-hidden">
      <Img
        src={staticFile("assets/background.png")}
        className="absolute inset-0 object-cover w-full h-full blur-xl scale-105"
      />
      <ScreenshotSlot
        index={0}
        className="flex flex-col justify-start p-[80px]"
      >
        <Img src={staticFile("assets/logo.png")} className="w-[40%] mx-auto" />
        <h1
          className="font-typewriter leading-tight font-bold text-white mt-[100px]"
          style={{
            fontSize: 100,
          }}
        >
          Dein persönlicher Begleiter fürs moers festival!
        </h1>
      </ScreenshotSlot>
      <div
        className="absolute left-[140px] -bottom-[500px] -rotate-5"
        style={{ width: useScreenshotContext().screenshotSize.width * 0.9 }}
      >
        <IPhone17ProFrame>
          <Img src={staticFile(imageUrls[0])} />
        </IPhone17ProFrame>
      </div>
    </AbsoluteFill>
  );
};
