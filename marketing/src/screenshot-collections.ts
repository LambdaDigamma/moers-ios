import { type ScreenshotSize, iPhone17Pro, iPhone17ProMax } from "./apple-screenshot-sizes";

export const INTER_SCREENSHOT_SPACING = 20;

export interface CollectionConfig {
  id: string;
  slotSize: ScreenshotSize;
  numberOfScreens: number;
  slotNames: string[];
}

export const collectionConfigs: CollectionConfig[] = [
  {
    id: "moers-festival-17-pro",
    slotSize: iPhone17Pro.portrait,
    numberOfScreens: 4,
    slotNames: ["01-timetable", "02-event-detail", "03-info", "04-map"],
  },
  {
    id: "moers-festival-17-pro-max",
    slotSize: iPhone17ProMax.portrait,
    numberOfScreens: 4,
    slotNames: ["01-timetable", "02-event-detail", "03-info", "04-map"],
  },
];
