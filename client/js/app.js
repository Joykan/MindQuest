// ===== js/app.js =====
import { speak } from "./voice.js";

// Elements
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

// Default backend
let API_CHAT = "http://localhost:5000/api/chat";
let API_JOURNAL = "http://localhost:5000/api/create_journal";
let API_INSIGHTS = "http://localhost:5000/api/get_insights";

// -----------------
// Navigation
// -----------------
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

// -----------------
// Save API URL
// -----------------
saveApiBtn.addEventListener("click", () => {
  if (apiInput.value.trim() === "") return;
  const base = apiInput.value.trim();
  API_CHAT = `${base}/api/chat`;
  API_JOURNAL = `${base}/api/create_journal`;
  API_INSIGHTS = `${base}/api/get_insights`;
  apiStatus.textContent = "set ✅";
});

// -----------------
// Append Chat Message
// -----------------
function appendMessage(text, sender) {
  const div = document.createElement("div");
  div.textContent = text;
  div.classList.add("chat-bubble", sender);
  chatMessages.appendChild(div);
  chatMessages.scrollTop = chatMessages.scrollHeight;
}

// Typing indicator
function showTyping() {
  const div = document.createElement("div");
  div.classList.add("chat-bubble", "ai", "typing");
  div.innerHTML = `<span></span><span></span><span></span>`;
  chatMessages.appendChild(div);
  chatMessages.scrollTop = chatMessages.scrollHeight;
  return div;
}

// -----------------
// Chat Send
// -----------------
sendBtn.addEventListener("click", sendChat);
userInput.addEventListener("keypress", (e) => {
  if (e.key === "Enter") sendChat();
});

async function sendChat() {
  const msg = userInput.value.trim();
  if (!msg) return;
  appendMessage(msg, "user");
  userInput.value = "";

  // Typing indicator
  const typingDiv = showTyping();

  try {
    const res = await fetch(API_CHAT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: msg, lang: langSelect.value })
    });
    const data = await res.json();
    chatMessages.removeChild(typingDiv);
    appendMessage(data.data?.reply || "AI didn't respond", "ai");
  } catch (err) {
    chatMessages.removeChild(typingDiv);
    appendMessage("Error connecting to backend", "ai");
    console.error(err);
  }
}

// -----------------
// Journal Save
// -----------------
saveJournalBtn.addEventListener("click", async () => {
  const text = journalEntry.value.trim();
  if (!text) return;

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
    console.error(err);
  }
});

// -----------------
// Insights Fetch
// -----------------
insightsBtn.addEventListener("click", async () => {
  insightsArea.textContent = "Processing...";
  try {
    const res = await fetch(API_INSIGHTS, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({})
    });
    const data = await res.json();
    insightsArea.textContent = JSON.stringify(data.data || "No insights yet", null, 2);
  } catch (err) {
    insightsArea.textContent = "Error fetching insights";
    console.error(err);
  }
});
