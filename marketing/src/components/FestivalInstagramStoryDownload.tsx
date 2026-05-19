import React from "react";
import { AbsoluteFill, Img, staticFile } from "remotion";
import { loadFestivalFonts } from "../fonts";

loadFestivalFonts();

export const INSTAGRAM_STORY_WIDTH = 1080;
export const INSTAGRAM_STORY_HEIGHT = 1920;

const NoiseOverlay: React.FC = () => (
  <svg className="absolute inset-0 w-full h-full opacity-[0.15] pointer-events-none">
    <filter id="noiseFilter-instagram-story">
      <feTurbulence
        type="fractalNoise"
        baseFrequency="0.65"
        numOctaves="3"
        stitchTiles="stitch"
      />
    </filter>
    <rect
      width="100%"
      height="100%"
      filter="url(#noiseFilter-instagram-story)"
    />
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

export const FestivalInstagramStoryDownload: React.FC = () => (
  <AbsoluteFill className="bg-[#050505] w-full h-full overflow-hidden">
    <Background />
    <div
      className="absolute inset-0 flex items-center justify-center px-[40px]"
      style={{ transform: "translateY(-180px)" }}
    >
      <h1
        className="font-typewriter leading-[1.05] font-bold text-white text-center tracking-tight drop-shadow-2xl whitespace-nowrap"
        style={{
          fontSize: 100,
          textShadow: "0 10px 34px rgba(0,0,0,0.72)",
        }}
      >
        App herunterladen
      </h1>
    </div>
  </AbsoluteFill>
);
