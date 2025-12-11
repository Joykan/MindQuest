// -----------------------------
// MindQuest frontend main.js
// 10/10 senior dev vibes
// -----------------------------

import { LANGUAGES, responses } from "./lang.js";

// ---------- Config ----------
let currentLang = LANGUAGES.EN; // default
const chatContainer = document.getElementById("chatContainer");

// ---------- Language Selector ----------
document.getElementById("langSelect").addEventListener("change", (e) => {
  currentLang = e.target.value;
});

// ---------- Process AI Reply ----------
export async function processReply(text) {
  showTypingIndicator();

  // simulate AI thinking delay
  await new Promise((r) => setTimeout(r, 800));

  hideTypingIndicator();
  const output = responses[currentLang](text);
  addChatBubble(output, "ai");
  speak(output);
}

// ---------- Add Chat Bubble ----------
function addChatBubble(message, sender = "ai") {
  const bubble = document.createElement("div");
  bubble.classList.add("chat-bubble", sender);
  bubble.textContent = message;
  chatContainer.appendChild(bubble);
  chatContainer.scrollTop = chatContainer.scrollHeight;
}

// ---------- Typing Indicator ----------
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

// ---------- Text-to-Speech ----------
function speak(text) {
  if (!window.speechSynthesis) return;
  const utterance = new SpeechSynthesisUtterance(text);

  switch (currentLang) {
    case LANGUAGES.EN:
      utterance.lang = "en-US";
      break;
    case LANGUAGES.SW:
    case LANGUAGES.SH:
      utterance.lang = "sw-KE";
      break;
  }

  window.speechSynthesis.speak(utterance);
}

// ---------- Optional: Send User Message ----------
export function sendUserMessage(text) {
  if (!text) return;
  addChatBubble(text, "user");
  // call AI backend
  fetch("/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message: text }),
  })
    .then((res) => res.json())
    .then((data) => processReply(data.reply))
    .catch((err) => processReply("Oops! Something broke 😅"));
}
