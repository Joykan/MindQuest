function speak(text) {
  if (!window.speechSynthesis) return;
  
  const utterance = new SpeechSynthesisUtterance(text);
  
  // Optionally set language/accent
  switch(currentLang) {
    case LANGUAGES.EN:
      utterance.lang = "en-US";
      break;
    case LANGUAGES.SW:
    case LANGUAGES.SH:
      utterance.lang = "sw-KE";  // Kenyan Swahili accent
      break;
  }
  
  window.speechSynthesis.speak(utterance);
}
