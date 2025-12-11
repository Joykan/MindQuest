// ===== js/app.js =====
import { speak } from "./voice.js";
import { translatePrompt } from "./lang.js";

// DOM
const chatMessages = document.getElementById("chat-messages");
const userInput = document.getElementById("user-input");
const sendBtn = document.getElementById("send-btn");
const apiStatus = document.getElementById("api-status");

const journalEntry = document.getElementById("journal-entry");
const saveJournalBtn = document.getElementById("save-journal");
const journalResult = document.getElementById("journal-result");

const insightsBtn = document.getElementById("get-insights");
const insightsArea = document.getElementById("insights-area");

const apiInput = document.getElementById("api-url-input");
const saveApiBtn = document.getElementById("save-api-url");

const langSelect = document.getElementById("langSelect");

// Panels & Navigation
const navButtons = document.querySelectorAll(".nav-btn");
const views = document.querySelectorAll(".view");

// Default backend (dev)
let API_BASE = "http://localhost:5000";
let API_CHAT = `${API_BASE}/api/chat`;
let API_JOURNAL = `${API_BASE}/api/create_journal`;
let API_INSIGHTS = `${API_BASE}/api/get_insights`;

// Navigation
navButtons.forEach(btn => {
  btn.addEventListener("click", () => {
    const target = btn.dataset.view;
    views.forEach(v => v.classList.remove("active"));
    document.getElementById("view-" + target).classList.add("active");
    navButtons.forEach(b => b.classList.remove("active"));
    btn.classList.add("active");
    document.getElementById("view-title").textContent = target.charAt(0).toUpperCase() + target.slice(1);
  });
});

// Save API URL
saveApiBtn.addEventListener("click", () => {
  if (apiInput.value.trim() === "") return;
  API_BASE = apiInput.value.trim().replace(/\/$/, "");
  API_CHAT = `${API_BASE}/api/chat`;
  API_JOURNAL = `${API_BASE}/api/create_journal`;
  API_INSIGHTS = `${API_BASE}/api/get_insights`;
  apiStatus.textContent = `${API_BASE} ✅`;
});

// Utils - append message
function appendMessage(text, sender, opts = {}) {
  const div = document.createElement("div");
  div.classList.add("chat-bubble", sender);
  if (opts.html) div.innerHTML = text;
  else div.textContent = text;
  // subtle pulse
  div.style.animation = "neonPulse 0.6s ease-out";
  chatMessages.appendChild(div);
  chatMessages.scrollTop = chatMessages.scrollHeight;
  return div;
}

// typing indicator
function showTyping() {
  const div = document.createElement("div");
  div.classList.add("chat-bubble", "ai", "typing");
  div.innerHTML = `<span></span><span></span><span></span>`;
  chatMessages.appendChild(div);
  chatMessages.scrollTop = chatMessages.scrollHeight;
  return div;
}

// Send chat
sendBtn.addEventListener("click", sendChat);
userInput.addEventListener("keypress", (e) => { if (e.key === "Enter") sendChat(); });

async function sendChat() {
  const msg = userInput.value.trim();
  if (!msg) return;
  appendMessage(msg, "user");
  userInput.value = "";

  // show typing
  const typingDiv = showTyping();

  // translate/pipeline (language)
  const lang = langSelect.value || "english";
  const prompt = translatePrompt(msg, lang);

  try {
    const res = await fetch(API_CHAT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: prompt, lang })
    });
    const data = await res.json();
    chatMessages.removeChild(typingDiv);

    const reply = data?.data?.reply || data?.reply || "AI didn't respond";
    appendMessage(reply, "ai");

    // speak it
    speak(reply, lang);
  } catch (err) {
    if (typingDiv && typingDiv.parentNode) chatMessages.removeChild(typingDiv);
    appendMessage("Error connecting to backend", "ai");
    console.error("Chat error:", err);
  }
}

// Journal save
saveJournalBtn.addEventListener("click", async () => {
  const text = journalEntry.value.trim();
  if (!text) return;
  journalResult.textContent = "Saving…";
  try {
    const res = await fetch(API_JOURNAL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ content: text })
    });
    const data = await res.json();
    journalResult.textContent = data.message || "Saved ✅";
    journalEntry.value = "";
  } catch (err) {
    journalResult.textContent = "Error saving journal";
    console.error("Journal save error:", err);
  }
});

// Insights
insightsBtn.addEventListener("click", async () => {
  insightsArea.textContent = "Processing…";
  try {
    const res = await fetch(API_INSIGHTS, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({})
    });
    const data = await res.json();
    insightsArea.textContent = JSON.stringify(data.data || data || "No insights yet", null, 2);
  } catch (err) {
    insightsArea.textContent = "Error fetching insights";
    console.error("Insights error:", err);
  }
});

// small UX nicety: focus input on chat view
document.querySelectorAll(".nav-btn").forEach(btn => {
  btn.addEventListener("click", () => {
    setTimeout(() => {
      const active = document.querySelector(".panel.view.active");
      const input = active?.querySelector("input, textarea");
      if (input) input.focus();
    }, 120);
  });
});
