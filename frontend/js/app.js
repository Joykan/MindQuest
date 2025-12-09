// frontend/js/app.js
(() => {
  // Config: default backend URL for production
  const CONFIG = {
    backendUrl: localStorage.getItem('MQ_BACKEND_URL') || 'https://mindquest-pxjz.onrender.com'
  };

  // DOM refs
  const navBtns = document.querySelectorAll('.nav-btn');
  const views = document.querySelectorAll('.view');
  const viewTitle = document.getElementById('view-title');
  const apiStatusEl = document.getElementById('api-status');

  const chatMessages = document.getElementById('chat-messages');
  const userInput = document.getElementById('user-input');
  const sendBtn = document.getElementById('send-btn');
  const apiUrlInput = document.getElementById('api-url-input');
  const saveApiBtn = document.getElementById('save-api-url');

  const journalEntry = document.getElementById('journal-entry');
  const saveJournalBtn = document.getElementById('save-journal');

  const getInsightsBtn = document.getElementById('get-insights');
  const insightsArea = document.getElementById('insights-area');

  // init UI values
  if (apiUrlInput) apiUrlInput.value = CONFIG.backendUrl;
  setApiStatus('checking…');

  // helpers
  function setApiStatus(txt, ok = true) {
    if (!apiStatusEl) return;
    apiStatusEl.textContent = txt;
    apiStatusEl.style.color = ok ? '#34d399' : '#f97316';
  }

  function switchView(name) {
    navBtns.forEach(b => b.classList.toggle('active', b.dataset.view === name));
    views.forEach(v => v.classList.toggle('active', v.id === `view-${name}`));
    if (viewTitle) viewTitle.textContent = name.charAt(0).toUpperCase() + name.slice(1);
  }

  // add nav listeners
  navBtns.forEach(b => b.addEventListener('click', () => switchView(b.dataset.view)));

  // Save API URL
  if (saveApiBtn) {
    saveApiBtn.addEventListener('click', () => {
      const v = apiUrlInput.value.trim();
      if (!v) return alert('Enter backend URL (e.g. https://my-backend.onrender.com)');
      CONFIG.backendUrl = v.replace(/\/+$/,''); // strip trailing slash
      localStorage.setItem('MQ_BACKEND_URL', CONFIG.backendUrl);
      checkApi();
      alert('Saved backend URL: ' + CONFIG.backendUrl);
    });
  }

  // Append message
  function appendMessage(role, text) {
    if (!chatMessages) return;
    const el = document.createElement('div');
    el.style.marginBottom = '8px';
    el.style.padding = '8px';
    el.style.borderRadius = '8px';
    el.style.maxWidth = '88%';
    if (role === 'user') {
      el.style.marginLeft = 'auto';
      el.style.background = 'linear-gradient(90deg,#063b2f,#065f46)';
      el.style.color = '#d1fae5';
    } else {
      el.style.background = 'linear-gradient(90deg,#04283a,#073b5a)';
      el.style.color = '#e6f7ff';
    }
    el.innerText = text;
    chatMessages.appendChild(el);
    chatMessages.scrollTop = chatMessages.scrollHeight;
  }

  // API call: send chat
  async function sendChat(userText) {
    if (!userText || !userText.trim()) return;
    appendMessage('user', userText);
    if (userInput) userInput.value = '';
    setApiStatus('sending…');

    try {
      const res = await fetch(`${CONFIG.backendUrl}/api/chat`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ message: userText })
      });

      if (!res.ok) {
        const err = await res.json().catch(()=>({error:'unknown'}));
        setApiStatus(`error: ${err?.error || res.statusText}`, false);
        appendMessage('assistant', `Sorry — backend returned error: ${err?.error || res.statusText}`);
        return;
      }

      const data = await res.json();
      const reply = data.reply || data?.choices?.[0]?.text || JSON.stringify(data);
      setApiStatus('online');
      appendMessage('assistant', reply);
    } catch (e) {
      setApiStatus('offline', false);
      appendMessage('assistant', `Network error: ${e.message || e}`);
    }
  }

  // send button handlers
  if (sendBtn) {
    sendBtn.addEventListener('click', () => sendChat(userInput?.value || ''));
  }
  if (userInput) {
    userInput.addEventListener('keydown', (ev) => {
      if (ev.key === 'Enter' && !ev.shiftKey) {
        ev.preventDefault();
        sendChat(userInput.value);
      }
    });
  }

  // Journal save (uses backend endpoint if available)
  if (saveJournalBtn) {
    saveJournalBtn.addEventListener('click', async () => {
      const content = journalEntry?.value.trim() || '';
      if (!content) return alert('Write something first');
      appendMessage('user', `[journal] ${content.slice(0,80)}${content.length>80?'…':''}`);
      try {
        const res = await fetch(`${CONFIG.backendUrl}/api/create_journal`, {
          method:'POST', headers:{'Content-Type':'application/json'},
          body: JSON.stringify({ user_id: 'user_1', content })
        });
        const d = await res.json();
        const resultEl = document.getElementById('journal-result');
        if (resultEl) resultEl.innerText = 'Saved ✓';
        if (journalEntry) journalEntry.value = '';
      } catch (e) {
        const resultEl = document.getElementById('journal-result');
        if (resultEl) resultEl.innerText = 'Save failed: ' + (e.message||e);
      }
    });
  }

  // Insights
  if (getInsightsBtn) {
    getInsightsBtn.addEventListener('click', async () => {
      if (insightsArea) insightsArea.textContent = 'Analyzing…';
      try {
        const res = await fetch(`${CONFIG.backendUrl}/api/get_insights`, {
          method:'POST', headers:{'Content-Type':'application/json'},
          body: JSON.stringify({ user_id: 'user_1' })
        });
        const d = await res.json();
        if (insightsArea) insightsArea.textContent = JSON.stringify(d, null, 2);
      } catch (e) {
        if (insightsArea) insightsArea.textContent = 'Error: ' + (e.message || e);
      }
    });
  }

  // Simple health check to display API status
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

  // initial check
  checkApi();
})();