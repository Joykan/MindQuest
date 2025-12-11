// ===== js/voice.js =====

const synth = window.speechSynthesis;

// Speak AI response
export function speak(text, lang = "en-US") {
  if (!text || !synth) return;

  const utter = new SpeechSynthesisUtterance(text);

  // Language selection mapping
  switch(lang) {
    case "swahili": utter.lang = "sw-KE"; break;
    case "sheng": utter.lang = "en-US"; break; // fallback
    default: utter.lang = "en-US";
  }

  utter.rate = 1.0; // speed
  utter.pitch = 1.2; // pitch for cyber effect
  synth.speak(utter);
}
