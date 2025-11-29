const API = (path) => `http://localhost:4000/api/${path}`;

// DOM refs
const content = document.getElementById('content');
const viewTitle = document.getElementById('view-title');
const userIdInput = document.getElementById('user-id');
const apiStatusEl = document.getElementById('api-status');

let state = {
  userId: 'user_1',
  lastHistory: []
};

/* ----------------- helpers ----------------- */
const setViewTitle = (t) => viewTitle.textContent = t;
const toast = (msg) => alert(msg); // tiny fallback — replace later

const checkApi = async () => {
  try {
    const res = await fetch(API('get_emotions'), { method: 'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ user_id: state.userId, days:1 })});
    apiStatusEl.textContent = 'online';
    apiStatusEl.style.color = '#16a34a';
  } catch (e) {
    apiStatusEl.textContent = 'offline';
    apiStatusEl.style.color = '#c2410c';
  }
};

/* ----------------- VIEWS ----------------- */

function renderHome() {
  setViewTitle('Home');
  content.innerHTML = `
    <div class="panel">
      <h3>Welcome to MindQuest</h3>
      <p class="small-muted">Log moods, keep a journal, and get weekly insights. This is a local dev UI that talks to <code>/api/*</code> endpoints.</p>
    </div>

    <div class="panel">
      <h4>Quick actions</h4>
      <div class="form-row" style="margin-top:12px">
        <button id="go-log" class="btn">Log Mood</button>
        <button id="go-journal" class="btn" style="background:#0f766e">Write Journal</button>
        <button id="go-insights" class="btn" style="background:#0b5e54">Get Insights</button>
      </div>
    </div>

    <div id="recent" class="panel">
      <h4>Recent entries</h4>
      <div id="recent-list" class="small-muted">loading…</div>
    </div>
  `;

  document.getElementById('go-log').onclick = () => switchView('log-mood');
  document.getElementById('go-journal').onclick = () => switchView('journal');
  document.getElementById('go-insights').onclick = () => switchView('insights');

  loadRecentEntries();
}

async function loadRecentEntries() {
  const list = document.getElementById('recent-list');
  list.innerHTML = 'loading…';
  try {
    const res = await fetch(API('get_emotions'), {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ user_id: state.userId, days: 3 })
    });
    const data = await res.json();
    // If walker returns a graph object, we try to format naive
    if (!data || (typeof data === 'string' && data.length===0)) {
      list.innerHTML = '<div class="small-muted">no data</div>';
      return;
    }

    // try to present basic items if array-like
    const items = Array.isArray(data) ? data : (data?.data || data?.result || data);
    if (!Array.isArray(items)) {
      list.innerHTML = `<pre class="small-muted">${JSON.stringify(items, null, 2)}</pre>`;
      return;
    }

    if (items.length === 0) {
      list.innerHTML = '<div class="small-muted">No entries</div>';
      return;
    }

    list.innerHTML = items.slice(0,5).map(it => {
      const name = it.name || it.emotion_name || 'entry';
      const time = it.timestamp ? new Date(it.timestamp*1000).toLocaleString() : (it.generated_at || '—');
      const intensity = it.intensity ?? it.score ?? '—';
      return `<div class="list-item"><div><div class="kv">${name}</div><div class="small-muted">${time}</div></div><div class="kv">int ${intensity}</div></div>`;
    }).join('');
  } catch(err) {
    list.innerHTML = `<div class="small-muted">Error loading recent: ${err.message || err}</div>`;
  }
}

function renderLogMood() {
  setViewTitle('Log Mood');
  content.innerHTML = `
    <div class="panel">
      <h3>Log a mood</h3>
      <div class="form-row"><input id="emo-name" class="input" placeholder="Emotion name (e.g. happy, anxious)" /></div>
      <div class="form-row"><input id="emo-intensity" type="number" min="1" max="10" class="input" placeholder="Intensity 1-10" /></div>
      <div class="form-row"><select id="emo-cat" class="input">
        <option value="neutral">neutral</option>
        <option value="positive">positive</option>
        <option value="negative">negative</option>
      </select></div>
      <div class="form-row"><textarea id="emo-notes" placeholder="Notes (optional)"></textarea></div>
      <div class="form-row"><button id="submit-emo" class="btn">Submit Mood</button></div>
      <div id="log-result" class="small-muted"></div>
    </div>
  `;

  document.getElementById('submit-emo').onclick = async () => {
    const name = document.getElementById('emo-name').value.trim();
    const intensity = Number(document.getElementById('emo-intensity').value || 0);
    const mood_category = document.getElementById('emo-cat').value;
    const notes = document.getElementById('emo-notes').value.trim();

    if (!name || intensity < 1 || intensity > 10) {
      toast('Please provide emotion name and intensity (1-10).');
      return;
    }

    const payload = {
      user_id: state.userId,
      emotion_name: name,
      intensity,
      mood_category,
      notes
    };

    try {
      const res = await fetch(API('log_mood'), {
        method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload)
      });
      const data = await res.json();
      document.getElementById('log-result').innerText = 'Saved — response: ' + (JSON.stringify(data).slice(0,200));
      loadRecentEntries();
    } catch(err) {
      document.getElementById('log-result').innerText = 'Error saving: ' + err.message;
    }
  };
}

function renderJournal() {
  setViewTitle('Journal');
  content.innerHTML = `
    <div class="panel">
      <h3>Write a journal entry</h3>
      <div class="form-row"><input id="j-title" class="input" placeholder="Title (optional)" /></div>
      <div class="form-row"><textarea id="j-content" placeholder="Write your thoughts..."></textarea></div>
      <div class="form-row"><button id="submit-j" class="btn">Save Entry</button></div>
      <div id="j-result" class="small-muted"></div>
    </div>
  `;
  document.getElementById('submit-j').onclick = async () => {
    const contentText = document.getElementById('j-content').value.trim();
    if (!contentText) return toast('Empty journal — write something.');

    const payload = {
      user_id: state.userId,
      content: contentText,
      entry_type: 'freeform',
      emotional_tags: '[]'
    };

    try {
      const res = await fetch(API('create_journal'), { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) });
      const data = await res.json();
      document.getElementById('j-result').innerText = 'Saved — ' + (data?.data?.id || JSON.stringify(data).slice(0,120));
    } catch(err) {
      document.getElementById('j-result').innerText = 'Error: ' + err.message;
    }
  };
}

function renderInsights() {
  setViewTitle('Insights');
  content.innerHTML = `
    <div class="panel">
      <h3>Weekly Insights</h3>
      <div class="small-muted">This will run analysis and return insights for the selected user.</div>
      <div class="form-row" style="margin-top:12px">
        <button id="get-insights" class="btn">Get Insights</button>
      </div>
      <pre id="insights-area" class="small-muted" style="margin-top:12px;white-space:pre-wrap"></pre>
    </div>
  `;

  document.getElementById('get-insights').onclick = async () => {
    const out = document.getElementById('insights-area');
    out.textContent = 'Analyzing…';
    try {
      const res = await fetch(API('get_insights'), {
        method:'POST', headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ user_id: state.userId })
      });
      const data = await res.json();
      out.textContent = JSON.stringify(data, null, 2);
    } catch(err) {
      out.textContent = 'Error: ' + err.message;
    }
  };
}

async function renderHistory() {
  setViewTitle('History');
  content.innerHTML = `<div class="panel"><h3>History (last 30 days)</h3><div id="history-area" class="small-muted">loading…</div></div>`;
  const area = document.getElementById('history-area');

  try {
    const res = await fetch(API('get_emotion_summary'), {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ user_id: state.userId, days: 30 })
    });
    const data = await res.json();
    area.innerHTML = `<pre>${JSON.stringify(data, null, 2)}</pre>`;
    state.lastHistory = data;
  } catch(err) {
    area.innerText = 'Error: ' + err.message;
  }
}

/* ----------------- view switching ----------------- */
const views = {
  'home': renderHome,
  'log-mood': renderLogMood,
  'journal': renderJournal,
  'insights': renderInsights,
  'history': renderHistory
};

function switchView(name) {
  // nav active
  document.querySelectorAll('.nav-btn').forEach(btn => btn.classList.toggle('active', btn.dataset.view === name));
  // render
  const renderer = views[name] || renderHome;
  renderer();
}

/* ----------------- init ----------------- */
function init() {
  // default user
  state.userId = localStorage.getItem('mq_user') || 'user_1';
  userIdInput.value = state.userId;

  // nav
  document.querySelectorAll('.nav-btn').forEach(b => {
    b.addEventListener('click', (e) => {
      const v = e.currentTarget.dataset.view;
      switchView(v);
    });
  });

  document.getElementById('refresh-btn').onclick = async () => {
    const val = userIdInput.value.trim();
    if (val) {
      state.userId = val;
      localStorage.setItem('mq_user', val);
      await checkApi();
      switchView('home');
    }
  };

  // initial checks
  checkApi();
  switchView('home');
}

init();
