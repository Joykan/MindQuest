export function speak(text, lang) {
  if (!window.speechSynthesis) return;
  
  const utterance = new SpeechSynthesisUtterance(text);
  
  switch(lang) {
    case "english":
      utterance.lang = "en-US";
      break;
    case "swahili":
    case "sheng":
      utterance.lang = "sw-KE";
      break;
  }

  window.speechSynthesis.speak(utterance);
}
