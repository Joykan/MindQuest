// frontend/js/app.js
const API_BASE = (window.__API_BASE__ || '') || ''; // empty => same origin; change to deployed backend if needed
const chatWindow = document.getElementById('chat-window');
const input = document.getElementById('chat-input');
const sendBtn = document.getElementById('send-btn');

function append(msg, who='bot') {
  const d = document.createElement('div');
  d.style.marginBottom = '8px';
  d.innerHTML = `<strong>${who === 'user' ? 'You' : 'MindQuest'}:</strong> ${msg}`;
  chatWindow.appendChild(d);
  chatWindow.scrollTop = chatWindow.scrollHeight;
}

sendBtn.onclick = async () => {
  const text = input.value.trim();
  if (!text) return;
  append(text, 'user');
  input.value = '';
  append('…thinking', 'bot');
  try {
    const res = await fetch(API_BASE + '/api/chat', {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({message: text})
    });
    const data = await res.json();
    // remove last '…thinking' message (simple)
    chatWindow.lastChild.remove();
    if (res.ok) {
      append(data.reply || JSON.stringify(data));
    } else {
      append('Error: ' + (data?.details || data?.error || JSON.stringify(data)));
    }
  } catch (e) {
    chatWindow.lastChild.remove();
    append('Network error: ' + e.message);
  }
};
