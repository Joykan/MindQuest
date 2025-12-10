export const LANGUAGES = {
  EN: "english",
  SW: "swahili",
  SH: "sheng"
};

// Example responses structure for UI (can expand dynamically)
export const responses = {
  english: (text) => text,
  swahili: (text) => {
    // basic translation or passthrough for now
    return text; 
  },
  sheng: (text) => {
    // simple rules for Sheng vibe
    // could be replaced with backend AI-generated Sheng
    return text
      .replace(/bro/gi, "mbu")           // casual address
      .replace(/stress/gi, "pressure")   // slang translation
      .replace(/check/gi, "cheki");      
  }
};
