export const LANGUAGES = {
  EN: "english",
  SW: "swahili",
  SH: "sheng"
};

export const responses = {
  english: (text) => text,
  swahili: (text) => text, // expand with real translations if needed
  sheng: (text) => text
    .replace(/bro/gi, "mbu")
    .replace(/stress/gi, "pressure")
    .replace(/check/gi, "cheki")
};
