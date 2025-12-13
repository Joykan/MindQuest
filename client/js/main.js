// -----------------------------
// MindQuest frontend main.js
// Frontend-only version
// -----------------------------

import { LANGUAGES, responses } from "./lang.js";

// ---------- Config ----------
let currentLang = LANGUAGES.EN; // default
const chatContainer = document.getElementById("chatContainer");

// Backend URL configuration
const CONFIG = {
  backendUrl: localStorage.getItem('MQ_BACKEND_URL') || 'http://localhost:5000'
};

// ---------- API Status Functions ----------
function setApiStatus(txt, ok=true) {
  const apiStatusEl = document.getElementById('api-status');
  if (!apiStatusEl) return;
  apiStatusEl.textContent = txt;
  apiStatusEl.style.color = ok ? '#34d399' : '#f97316';
}

async function checkApi() {
  try {
    const res = await fetch(`${CONFIG.backendUrl}/health`);
    if (res.ok) {
      setApiStatus('online');
      return true;
    }
    setApiStatus('offline', false);
    return false;
  } catch (e) {
    setApiStatus('offline', false);
    return false;
  }
}

// ---------- Language Selector ----------
document.getElementById("langSelect")?.addEventListener("change", (e) => {
  currentLang = e.target.value;
});

// ---------- Process AI Reply ----------
export async function processReply(text) {
  showTypingIndicator();

  try {
    // Call your actual backend API
    const res = await fetch(`${CONFIG.backendUrl}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        message: text, 
        context: 'general',
        userId: 'user-' + Date.now()
      })
    });
    
    const data = await res.json();
    hideTypingIndicator();
    
    if (data.success) {
      addChatBubble(data.response, "ai");
      speak(data.response);
    } else {
      addChatBubble("Sorry, I couldn't process that. Please try again.", "ai");
    }
  } catch (error) {
    hideTypingIndicator();
    addChatBubble("Network error. Check if backend is running.", "ai");
    console.error('API Error:', error);
  }
}

// ---------- Add Chat Bubble ----------
function addChatBubble(message, sender = "ai") {
  if (!chatContainer) return;
  const bubble = document.createElement("div");
  bubble.classList.add("chat-bubble", sender);
  bubble.textContent = message;
  chatContainer.appendChild(bubble);
  chatContainer.scrollTop = chatContainer.scrollHeight;
}

// ---------- Typing Indicator ----------
function showTypingIndicator() {
  if (!chatContainer) return;
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
  if ('speechSynthesis' in window) {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'en-US';
    speechSynthesis.speak(utterance);
  }
}

// ---------- Initialize on Load ----------
document.addEventListener('DOMContentLoaded', () => {
  console.log('MindQuest frontend initialized');
  
  // Check API connection
  checkApi();
  
  // Setup API URL save button if exists
  const saveApiBtn = document.getElementById('save-api-url');
  const apiUrlInput = document.getElementById('api-url-input');
  
  if (saveApiBtn && apiUrlInput) {
    saveApiBtn.addEventListener('click', () => {
      const url = apiUrlInput.value.trim();
      if (!url) return alert('Enter backend URL');
      
      CONFIG.backendUrl = url.replace(/\/+$/, '');
      localStorage.setItem('MQ_BACKEND_URL', CONFIG.backendUrl);
      checkApi();
      alert('Saved backend URL: ' + CONFIG.backendUrl);
    });
    
    // Show current URL in input
    apiUrlInput.value = CONFIG.backendUrl;
  }
  
  // Setup chat form if exists
  const chatForm = document.getElementById('chatForm');
  const chatInput = document.getElementById('chatInput');
  
  if (chatForm && chatInput) {
    chatForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const message = chatInput.value.trim();
      if (!message) return;
      
      // Add user message
      addChatBubble(message, "user");
      chatInput.value = "";
      
      // Get AI reply
      await processReply(message);
    });
  }
});

// Make config available globally
window.MindQuestConfig = CONFIG;
window.checkApi = checkApi;