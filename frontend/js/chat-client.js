// frontend/js/chat-client.js
// Use deployed backend URL
const API_URL = 'https://mindquest-pxjz.onrender.com';

const chatSendBtn = document.getElementById('send-btn') || document.getElementById('chat-send-btn') || null;
const userInputEl = document.getElementById('user-input') || document.getElementById('chat-input') || null;
const chatBox = document.getElementById('chat-box') || document.getElementById('chat-messages');

if (!chatSendBtn || !userInputEl || !chatBox) {
  console.warn("chat-client: couldn't find UI elements. Make sure chat-client.js is loaded after DOM elements.");
} else {
  function appendMessage(who, text) {
    const el = document.createElement('div');
    el.className = `chat-line ${who === 'user' ? 'user-msg' : 'bot-msg'}`;
    el.style.margin = '8px 0';
    el.innerHTML = `<strong>${who === 'user' ? 'You' : 'MindQuest'}:</strong> <span>${text}</span>`;
    chatBox.appendChild(el);
    chatBox.scrollTop = chatBox.scrollHeight;
  }

  async function sendMessage() {
    const message = userInputEl.value.trim();
    if (!message) return;

    appendMessage('user', message);
    userInputEl.value = '';
    
    // show a placeholder waiting message
    const waitEl = document.createElement('div');
    waitEl.className = 'chat-line bot-msg';
    waitEl.innerHTML = `<strong>MindQuest:</strong> <em>thinking…</em>`;
    waitEl.id = 'thinking-indicator';
    chatBox.appendChild(waitEl);
    chatBox.scrollTop = chatBox.scrollHeight;

    try {
      const res = await fetch(`${API_URL}/api/chat`, {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({ message })
      });
      
      // Remove thinking indicator
      document.getElementById('thinking-indicator')?.remove();

      if (!res.ok) {
        throw new Error(`HTTP error! status: ${res.status}`);
      }

      const data = await res.json();

      if (data.reply) {
        appendMessage('bot', data.reply);
      } else {
        const errText = data?.error || data?.details || 'Unknown error';
        appendMessage('bot', `Error: ${errText}`);
      }
    } catch (err) {
      console.error("sendMessage error", err);
      document.getElementById('thinking-indicator')?.remove();
      appendMessage('bot', `Network error: ${err.message || err}. Please check if the API is running.`);
    }
  }

  chatSendBtn.addEventListener('click', sendMessage);
  userInputEl.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  });
  
  console.log('Chat client initialized with API:', API_URL);
}