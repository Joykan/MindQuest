// ===== js/voice.js =====
const synth = typeof window !== "undefined" ? window.speechSynthesis : null;

export function speak(text, lang = "english") {
  if (!text || !synth) return;

  const utter = new SpeechSynthesisUtterance(text);
  // simple mapping
  if (lang === "swahili") utter.lang = "sw-KE";
  else if (lang === "sheng") utter.lang = "en-US";
  else utter.lang = "en-US";

  utter.rate = 1.0;
  utter.pitch = 1.05;
  // gentle volume ramp
  utter.volume = 1.0;
  synth.speak(utter);
}
