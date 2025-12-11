// ===== js/lang.js =====
// Translate/prepare prompt per language or localize small UX behaviour.
// For now we do light transformations; expand with real i18n if needed.

export function translatePrompt(text, lang = "english") {
  if (!text) return text;
  switch(lang) {
    case "swahili":
      // prepend a hint so the AI replies in Swahili
      return `[Respond in Kiswahili]\n` + text;
    case "sheng":
      return `[Respond in Sheng (urban Kenyan slang)]\n` + text;
    default:
      return text; // English
  }
}
