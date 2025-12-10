// -----------------------------
// MindQuest frontend: unified JS
// -----------------------------
const LANGUAGES = { EN:'english', SW:'swahili', SH:'sheng' };
const responses = {
  english: text => text,
  swahili: text => text,
  sheng: text => text.replace(/bro/gi,'mbu').replace(/stress/gi,'pressure').replace(/check/gi,'cheki')
};

// Config & DOM refs
const CONFIG = { backendUrl: localStorage.getItem('MQ_BACKEND_URL') || 'https://mindquest-pxjz.onrender.com' };
const chatContainer = document.getElementById('chatContainer');
const userInput = document.getElementById('user-input');
const sendBtn = document.getElementById('send-btn');
const navBtns = document.querySelectorAll('.nav-btn');
const views = document.querySelectorAll('.view');
const viewTitle = document.getElementById('view-title');
const apiStatusEl = document.getElementById('api-status');
const apiUrlInput = document.getElementById('api-url-input');
const saveApiBtn = document.getElementById('save-api-url');
const langSelect = document.getElementById('langSelect');
const journalEntry = document.getElementById('journal-entry');
const saveJournalBtn = document.getElementById('save-journal');
const getInsightsBtn = document.getElementById('get-insights');
const insightsArea = document.getElementById('insights-area');

let currentLang = LANGUAGES.EN;

// ------------------ Helpers ------------------
function setApiStatus(txt, ok=true){if(!apiStatusEl)return; apiStatusEl.textContent=txt; apiStatusEl.style.color=ok?'#34d399':'#f97316';}
function switchView(name){navBtns.forEach(b=>b.classList.toggle('active',b.dataset.view===name));views.forEach(v=>v.classList.toggle('active',v.id==='view-'+name));if(viewTitle)viewTitle.textContent=name.charAt(0).toUpperCase()+name.slice(1);}
function showTypingIndicator(){const t=document.createElement('div');t.id='typingIndicator';t.classList.add('typing');t.innerHTML='<span></span><span></span><span></span>';chatContainer.appendChild(t);chatContainer.scrollTop=chatContainer.scrollHeight;}
function hideTypingIndicator(){const t=document.getElementById('typingIndicator');if(t)t.remove();}
function speak(text){if(!window.speechSynthesis)return; const u=new SpeechSynthesisUtterance(text);switch(currentLang){case LANGUAGES.EN:u.lang='en-US';break;case LANGUAGES.SW:case LANGUAGES.SH:u.lang='sw-KE';break;} window.speechSynthesis.speak(u);}
async function checkApi(){try{const res=await fetch(`${CONFIG.backendUrl}/health`); if(res.ok){setApiStatus('online'); return true;} setApiStatus('offline',false); return false;}catch(e){setApiStatus('offline',false);return false;}}

// ------------------ Chat bubble with emotion glow ------------------
function addChatBubble(msg, sender='ai', emotion='neutral'){
  const b = document.createElement('div');
  b.classList.add('chat-bubble', sender);

  // Glow based on emotion
  let color = '#00ffcc'; // default neon
  switch(emotion.toLowerCase()){
    case 'happy': color='#00ff66'; break;
    case 'sad': color='#0066ff'; break;
    case 'angry': color='#ff0033'; break;
    case 'stress': color='#ff9900'; break;
    case 'neutral': color='#aa00ff'; break;
  }

  b.style.borderColor = sender==='user' ? '#ff00ff' : color;
  b.style.boxShadow = `0 0 8px ${color}, 0 0 20px ${color}`;
  b.textContent = msg;

  chatContainer.appendChild(b);
  chatContainer.scrollTop = chatContainer.scrollHeight;
}

// ------------------ Event Listeners ------------------
navBtns.forEach(b=>b.addEventListener('click',()=>switchView(b.dataset.view)));
if(saveApiBtn)saveApiBtn.addEventListener('click',()=>{const v=apiUrlInput.value.trim();if(!v)return alert('Enter backend URL'); CONFIG.backendUrl=v.replace(/\/+$/,''); localStorage.setItem('MQ_BACKEND_URL',CONFIG.backendUrl); checkApi(); alert('Saved backend URL: '+CONFIG.backendUrl);});
if(langSelect) langSelect.addEventListener('change',e=>currentLang=e.target.value);

// ------------------ Chat ------------------
async function processReply(text, emotion='neutral'){
  showTypingIndicator();
  await new Promise(r=>setTimeout(r, 800));
  hideTypingIndicator();
  const out = responses[currentLang](text);
  addChatBubble(out, 'ai', emotion);
  speak(out);
}

async function sendChat(userText){
  if(!userText?.trim()) return;
  addChatBubble(userText,'user');
  if(userInput) userInput.value='';
  setApiStatus('sending…');
  try{
    const res = await fetch(`${CONFIG.backendUrl}/api/chat`,{
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({message:userText})
    });
    if(!res.ok){const err=await res.json().catch(()=>({error:'unknown'})); setApiStatus(`error: ${err?.error||res.statusText}`,false); addChatBubble(`Sorry — backend returned error: ${err?.error||res.statusText}`,'ai'); return;}
    const data = await res.json();
    const reply = data.reply || data?.choices?.[0]?.text || JSON.stringify(data);
    const emotion = data.emotion || 'neutral';
    setApiStatus('online');
    processReply(reply, emotion);
  }catch(e){setApiStatus('offline',false); addChatBubble(`Network error: ${e.message||e}`,'ai');}
}

if(sendBtn) sendBtn.addEventListener('click',()=>sendChat(userInput?.value));
if(userInput) userInput.addEventListener('keydown', ev=>{if(ev.key==='Enter'&&!ev.shiftKey){ev.preventDefault(); sendChat(userInput.value);}});

// ------------------ Journal ------------------
if(saveJournalBtn)saveJournalBtn.addEventListener('click',async()=>{
  const content = journalEntry?.value.trim() || '';
  if(!content) return alert('Write something first');
  addChatBubble(`[journal] ${content.slice(0,80)}${content.length>80?'…':''}`,'user');
  try{
    const res = await fetch(`${CONFIG.backendUrl}/api/create_journal`,{
      method:'POST', headers:{'Content-Type':'application/json'},
      body:JSON.stringify({user_id:'user_1',content})
    });
    const d = await res.json();
    const r = document.getElementById('journal-result');
    if(r) r.innerText='Saved ✓';
    if(journalEntry) journalEntry.value='';
  }catch(e){
    const r = document.getElementById('journal-result');
    if(r) r.innerText='Save failed: '+(e.message||e);
  }
});

// ------------------ Insights ------------------
if(getInsightsBtn) getInsightsBtn.addEventListener('click', async()=>{
  if(insightsArea) insightsArea.textContent='Analyzing…';
  try{
    const res = await fetch(`${CONFIG.backendUrl}/api/get_insights`,{
      method:'POST', headers:{'Content-Type':'application/json'},
      body:JSON.stringify({user_id:'user_1'})
    });
    const d = await res.json();
    if(insightsArea) insightsArea.textContent=JSON.stringify(d,null,2);
  }catch(e){
    if(insightsArea) insightsArea.textContent='Error: '+(e.message||e);
  }
});

// ------------------ Init ------------------
checkApi();
