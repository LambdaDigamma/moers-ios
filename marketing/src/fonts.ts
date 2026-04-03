import { loadFont } from "@remotion/fonts";
import { staticFile } from "remotion";

export const loadFestivalFonts = async () => {
  await Promise.all([
    loadFont({
      family: "Atkinson Hyperlegible",
      url: staticFile("fonts/atkinson-hyperlegible-v10-latin-regular.woff2"),
      weight: "400",
    }),
    loadFont({
      family: "Atkinson Hyperlegible",
      url: staticFile("fonts/atkinson-hyperlegible-v10-latin-700.woff2"),
      weight: "700",
    }),
    loadFont({
      family: "Splendid 66",
      url: staticFile("fonts/SplendidN.woff"),
      weight: "400",
    }),
    loadFont({
      family: "Splendid 66",
      url: staticFile("fonts/SplendidI.woff"),
      weight: "400",
      style: "italic",
    }),
    loadFont({
      family: "Splendid 66",
      url: staticFile("fonts/SplendidB.woff"),
      weight: "700",
    }),
    loadFont({
      family: "TravelingTypewriter",
      url: staticFile("fonts/TravelingTypewriter.woff"),
      weight: "400",
    }),
  ]);
};

export const FONTS = {
  SPLENDID: "Splendid 66",
  SPLENDID_BOLD: "Splendid 66 Bold",
  SPLENDID_ITALIC: "Splendid 66 light",
  ATKINSON: "Atkinson Hyperlegible",
  TYPEWRITER: "TravelingTypewriter",
} as const;
