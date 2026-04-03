export type Locale = "de-DE" | "en-US";

const translations = {
  "de-DE": {
    slot0_headline: "Dein persönlicher Begleiter fürs moers festival!",
    slot1_headline: "Alle Acts im Überblick",
    slot2_headline: "Alles Wichtige auf einen Blick",
    slot3_headline: "Finde jeden Spielort",
  },
  "en-US": {
    slot0_headline: "Your personal companion for moers festival!",
    slot1_headline: "All acts at a glance",
    slot2_headline: "Everything you need to know",
    slot3_headline: "Find every venue",
  },
} as const;

type TranslationKey = keyof (typeof translations)["de-DE"];

export function t(locale: Locale, key: TranslationKey): string {
  return translations[locale][key];
}
