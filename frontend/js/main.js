import { LANGUAGES, responses } from "./lang.js";

let currentLang = LANGUAGES.EN; // default

document.getElementById("langSelect").addEventListener("change", (e) => {
  currentLang = e.target.value;
});

const chatContainer = document.getElementById("chatContainer");

export async function processReply(text) {
  showTypingIndicator();
  
  // simulate AI thinking delay
  await new Promise(r => setTimeout(r, 800));
  
  hideTypingIndicator();
  const output = responses[currentLang](text);
  addChatBubble(output, "ai");
  speak(output);
}

function addChatBubble(message, sender = "ai") {
  const bubble = document.createElement("div");
  bubble.classList.add("chat-bubble", sender);
  bubble.textContent = message;
  chatContainer.appendChild(bubble);
  chatContainer.scrollTop = chatContainer.scrollHeight;
}

function showTypingIndicator() {
  const typing = document.createElement("div");
  typing.id = "typingIndicator";
  typing.classList.add("typing");
  typing.innerHTML = '<span></span><span></span><span></span>';
  chatContainer.appendChild(typing);
  chatContainer.scrollTop = chatContainer.scrollHeight;
}

function hideTypingIndicator() {
  const typing = document.getElementById("typingIndicator");
  if (typing) typing.remove();
}

function speak(text) {
  if (!window.speechSynthesis) return;
  const utterance = new SpeechSynthesisUtterance(text);
  switch(currentLang) {
    case LANGUAGES.EN: utterance.lang = "en-US"; break;
    case LANGUAGES.SW:
    case LANGUAGES.SH: utterance.lang = "sw-KE"; break;
  }
  window.speechSynthesis.speak(utterance);
}
