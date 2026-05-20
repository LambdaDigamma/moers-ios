export type Locale = "de-DE" | "en-US";

const translations = {
  "de-DE": {
    slot0_headline: "Dein persönlicher Begleiter fürs \nmoers festival!",
    slot1_headline: "Alle Acts im \nÜberblick",
    slot2_headline: "Alles Wichtige auf einen Blick",
    slot3_headline: "Finde jeden \nSpielort",
    download_headline: "Jetzt die App\nherunterladen",
  },
  "en-US": {
    slot0_headline: "Your personal companion for moers festival!",
    slot1_headline: "All acts at \na glance",
    slot2_headline: "Everything you \nneed to know",
    slot3_headline: "Find every \nvenue",
    download_headline: "Download\nthe app now",
  },
} as const;

type TranslationKey = keyof (typeof translations)["de-DE"];

export function t(locale: Locale, key: TranslationKey): string {
  return translations[locale][key];
}
