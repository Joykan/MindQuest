/* ===== MINDQUEST APP LOGIC ===== */

// DOM Elements
let currentLanguage = 'en';
let currentContext = 'general';
let chatHistory = [];

// API Configuration - DYNAMIC for dev/production
const API_BASE_URL = (() => {
  // Development - localhost
  if (window.location.hostname === 'localhost' || 
      window.location.hostname === '127.0.0.1') {
    console.log('🔧 Development mode: Using local backend');
    return 'http://localhost:4000';
  }
  
  // Production - Vercel + Render
  // When frontend is on Vercel, backend is on Render
  console.log('🚀 Production mode: Using Render backend');
  return 'https://mindquest-6ree.onrender.com';
})();

console.log('🌐 API Base URL:', API_BASE_URL);

// Initialize the app
document.addEventListener('DOMContentLoaded', function() {
    console.log('🧠 MindQuest AI initialized');
    console.log('📱 Current URL:', window.location.href);
    
    initLanguage();
    initNavigation();
    initChat();
    initMood();
    initJournal();
    initInsights();
    initSettings();
    updateLastSync();
    
    // Test backend connection
    testBackendConnection();
});

// Test backend connection on startup
async function testBackendConnection() {
    try {
        console.log('🔗 Testing backend connection...');
        const response = await fetch(`${API_BASE_URL}/health`);
        if (response.ok) {
            const data = await response.json();
            console.log('✅ Backend connected:', data);
            updateConnectionStatus(true);
        } else {
            console.warn('⚠️ Backend health check failed');
            updateConnectionStatus(false);
        }
    } catch (error) {
        console.error('❌ Backend connection failed:', error);
        updateConnectionStatus(false);
    }
}

function updateConnectionStatus(isConnected) {
    const statusIndicator = document.querySelector('.status-indicator');
    const responseTimeElement = document.getElementById('response-time');
    
    if (statusIndicator) {
        statusIndicator.className = `status-indicator ${isConnected ? 'online' : 'offline'}`;
        statusIndicator.textContent = isConnected ? '✓ SECURE' : '✗ OFFLINE';
    }
    
    if (responseTimeElement) {
        responseTimeElement.textContent = isConnected ? '0.8s' : 'Offline';
        responseTimeElement.className = `stat-value ${isConnected ? '' : 'offline'}`;
    }
    
    // Update active users (simulated)
    const activeUsersElement = document.getElementById('active-users');
    if (activeUsersElement && isConnected) {
        activeUsersElement.textContent = '1';
    }
}

// ===== LANGUAGE MANAGEMENT =====
function initLanguage() {
    // Set language from localStorage or default
    const savedLang = localStorage.getItem('mindquest-lang');
    if (savedLang) {
        setLanguage(savedLang);
    } else {
        setLanguage('en');
    }
    
    // Language buttons in sidebar
    document.querySelectorAll('.lang-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const lang = this.dataset.lang;
            setLanguage(lang);
        });
    });
    
    // Quick language switch in chat
    document.querySelectorAll('.lang-quick-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const lang = this.dataset.lang;
            setLanguage(lang);
        });
    });
    
    // Journal language buttons
    document.querySelectorAll('.journal-lang-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const lang = this.dataset.lang;
            setLanguage(lang);
        });
    });
    
    // Mood language tabs
    document.querySelectorAll('.mood-lang-tab').forEach(tab => {
        tab.addEventListener('click', function() {
            const lang = this.dataset.lang;
            setLanguage(lang);
        });
    });
}

function setLanguage(lang) {
    currentLanguage = lang;
    localStorage.setItem('mindquest-lang', lang);
    updateLanguageButtons();
    updateLanguageIndicators();
    updatePanelTitle();
    
    // Update chat placeholder based on language
    const messageInput = document.querySelector('#message-input');
    if (messageInput) {
        const placeholders = {
            en: "Type your message...",
            sw: "Andika ujumbe wako...",
            sg: "Type your message..."
        };
        messageInput.placeholder = placeholders[lang] || placeholders.en;
    }
}

function updateLanguageButtons() {
    // Update all language buttons
    document.querySelectorAll('.lang-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.lang === currentLanguage);
    });
    
    document.querySelectorAll('.lang-quick-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.lang === currentLanguage);
    });
    
    document.querySelectorAll('.journal-lang-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.lang === currentLanguage);
    });
    
    document.querySelectorAll('.mood-lang-tab').forEach(tab => {
        tab.classList.toggle('active', tab.dataset.lang === currentLanguage);
    });
}

function updateLanguageIndicators() {
    document.querySelectorAll('.lang-indicator').forEach(indicator => {
        indicator.textContent = currentLanguage.toUpperCase();
    });
    
    // Update header display
    const langDisplay = document.getElementById('current-lang-display');
    if (langDisplay) {
        langDisplay.textContent = currentLanguage.toUpperCase();
    }
}

function updatePanelTitle() {
    const panelTitle = document.getElementById('panel-title');
    if (!panelTitle) return;
    
    const activePanel = document.querySelector('.cyber-panel.active');
    if (!activePanel) return;
    
    const titles = {
        'chat-panel': 'AI Chat Assistant',
        'journal-panel': 'Digital Journal',
        'mood-panel': 'Mood Analysis',
        'insights-panel': 'Wellness Insights',
        'settings-panel': 'Settings'
    };
    
    panelTitle.textContent = titles[activePanel.id] || 'MindQuest AI';
}

// ===== NAVIGATION =====
function initNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    const panels = document.querySelectorAll('.cyber-panel');
    
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            const target = this.dataset.target;
            
            // Update active nav item
            navItems.forEach(nav => nav.classList.remove('active'));
            this.classList.add('active');
            
            // Show target panel
            panels.forEach(panel => {
                panel.classList.remove('active');
                if (panel.id === `${target}-panel`) {
                    panel.classList.add('active');
                }
            });
            
            updatePanelTitle();
            
            // Update insights when switching to insights panel
            if (target === 'insights') {
                updateInsights();
            }
        });
    });
}

// ===== CHAT FUNCTIONALITY =====
function initChat() {
    const chatForm = document.querySelector('#chat-form');
    const messageInput = document.querySelector('#message-input');
    const sendButton = document.querySelector('#send-button');
    const contextSelect = document.querySelector('#context-select');
    const chatContainer = document.querySelector('#chat-container');
    const clearButton = document.querySelector('#clear-chat');
    
    if (!messageInput || !sendButton) {
        console.error('Chat elements not found!');
        return;
    }
    
    console.log('💬 Chat initialized');
    console.log('🔗 API URL:', API_BASE_URL);
    
    // Set current context
    if (contextSelect) {
        contextSelect.value = currentContext;
        contextSelect.addEventListener('change', function() {
            currentContext = this.value;
            localStorage.setItem('mindquest-context', this.value);
        });
    }
    
    // Load saved context
    const savedContext = localStorage.getItem('mindquest-context');
    if (savedContext && contextSelect) {
        contextSelect.value = savedContext;
        currentContext = savedContext;
    }
    
    // Send message function
    function sendMessage() {
        const message = messageInput.value.trim();
        if (!message) {
            messageInput.focus();
            return;
        }
        
        console.log('📤 Sending message:', message);
        
        // Add user message to chat
        addMessageToChat('user', message);
        
        // Clear input and focus
        messageInput.value = '';
        messageInput.focus();
        
        // Send to API
        sendToAPI(message);
        
        // Update last sync
        updateLastSync();
    }
    
    // Send button click
    sendButton.addEventListener('click', sendMessage);
    
    // Enter key shortcut
    messageInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    
    // Clear chat button
    if (clearButton) {
        clearButton.addEventListener('click', function() {
            if (confirm('Clear all chat messages?')) {
                chatHistory = [];
                chatContainer.innerHTML = '';
                localStorage.removeItem('mindquest-chat-history');
                
                // Add welcome message back
                addMessageToChat('ai', 'Hello! I\'m your AI wellness assistant. How can I help you today?');
            }
        });
    }
    
    // Load chat history
    loadChatHistory();
}

function addMessageToChat(sender, text) {
    const chatContainer = document.querySelector('#chat-container');
    if (!chatContainer) return;
    
    const messageDiv = document.createElement('div');
    messageDiv.className = `chat-message ${sender}`;
    
    const timestamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    
    messageDiv.innerHTML = `
        <span class="message-sender">${sender === 'ai' ? 'MindQuest AI' : 'You'}</span>
        <p class="message-text">${text}</p>
        <span class="message-time">${timestamp}</span>
    `;
    
    chatContainer.appendChild(messageDiv);
    chatContainer.scrollTop = chatContainer.scrollHeight;
    
    // Save to history (skip initial welcome message if it's a duplicate)
    if (!(sender === 'ai' && text.includes('Hello! I\'m your AI wellness assistant'))) {
        chatHistory.push({ sender, text, time: timestamp });
        saveChatHistory();
    }
}

async function sendToAPI(message) {
    const sendButton = document.querySelector('#send-button');
    const responseTimeElement = document.getElementById('response-time');
    
    try {
        // Show loading state
        const originalText = sendButton.innerHTML;
        sendButton.disabled = true;
        sendButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending...';
        
        const startTime = Date.now();
        
        console.log('📡 Calling API:', `${API_BASE_URL}/api/chat`);
        
        const response = await fetch(`${API_BASE_URL}/api/chat`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                message,
                context: currentContext,
                language: currentLanguage
            })
        });
        
        const endTime = Date.now();
        const responseTime = ((endTime - startTime) / 1000).toFixed(1);
        
        if (responseTimeElement) {
            responseTimeElement.textContent = `${responseTime}s`;
        }
        
        const data = await response.json();
        
        console.log('📥 API Response:', data);
        
        if (data.success) {
            let responseText = data.response;
            // Add indicator if using fallback
            if (data.source === 'fallback') {
                responseText += ' 🔄';
                console.log('🔄 Using fallback response');
            }
            addMessageToChat('ai', responseText);
        } else {
            addMessageToChat('ai', `Error: ${data.message || 'Failed to get response'}`);
        }
    } catch (error) {
        console.error('❌ API Error:', error);
        
        // Fallback responses when API is completely down
        const fallbackResponses = {
            therapy: currentLanguage === 'sw' 
                ? 'Naelewa hii ni muhimu. Unaweza kujaribu kuielezea tena?' 
                : currentLanguage === 'sg'
                ? 'I get this is important. Unaweza try ku-rephrase?'
                : 'I understand this is important. Could you try rephrasing your concern?',
            coaching: currentLanguage === 'sw'
                ? 'Nifikirie juu ya hilo. Wakati huo huo, ni lengo gani maalum unalofanya kazi?'
                : currentLanguage === 'sg'
                ? 'Let me think about that. Meanwhile, ni specific goal gani unafanya kazi?'
                : 'Let me think about that. In the meantime, what specific goal are you working toward?',
            general: currentLanguage === 'sw'
                ? 'Samahani kwa tatizo la kiufundi. Tafadhali jaribu tena.'
                : currentLanguage === 'sg'
                ? 'Sorry for the tech issue. Please try again.'
                : 'I apologize for the technical issue. Could you please rephrase or try again?'
        };
        
        const fallback = fallbackResponses[currentContext] || fallbackResponses.general;
        addMessageToChat('ai', fallback + ' (Offline Mode)');
        
        // Update connection status
        updateConnectionStatus(false);
    } finally {
        // Restore button
        sendButton.disabled = false;
        sendButton.innerHTML = '<i class="fas fa-paper-plane"></i> Send';
    }
}

function saveChatHistory() {
    localStorage.setItem('mindquest-chat-history', JSON.stringify(chatHistory.slice(-50)));
}

function loadChatHistory() {
    const saved = localStorage.getItem('mindquest-chat-history');
    const chatContainer = document.querySelector('#chat-container');
    
    if (!chatContainer) return;
    
    // Clear existing messages except the first welcome message
    const existingMessages = chatContainer.querySelectorAll('.chat-message');
    if (existingMessages.length > 1) {
        for (let i = 1; i < existingMessages.length; i++) {
            existingMessages[i].remove();
        }
    }
    
    if (saved) {
        chatHistory = JSON.parse(saved);
        
        chatHistory.forEach(msg => {
            const messageDiv = document.createElement('div');
            messageDiv.className = `chat-message ${msg.sender}`;
            
            messageDiv.innerHTML = `
                <span class="message-sender">${msg.sender === 'ai' ? 'MindQuest AI' : 'You'}</span>
                <p class="message-text">${msg.text}</p>
                <span class="message-time">${msg.time}</span>
            `;
            
            chatContainer.appendChild(messageDiv);
        });
        
        chatContainer.scrollTop = chatContainer.scrollHeight;
    }
}

// ===== MOOD TRACKER =====
function initMood() {
    const moodForm = document.querySelector('#mood-form');
    const quickMoodBtn = document.querySelector('#quick-mood');
    
    if (!moodForm) return;
    
    moodForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        analyzeMood();
    });
    
    if (quickMoodBtn) {
        quickMoodBtn.addEventListener('click', function() {
            const quickMoods = [
                "Feeling good today, energetic and focused.",
                "A bit tired but optimistic about the day.",
                "Stressed with work but managing.",
                "Happy and content with how things are going.",
                "Anxious about upcoming events.",
                "Calm and at peace with myself."
            ];
            
            const randomMood = quickMoods[Math.floor(Math.random() * quickMoods.length)];
            document.querySelector('#mood-text').value = randomMood;
            analyzeMood();
        });
    }
}

async function analyzeMood() {
    const moodText = document.querySelector('#mood-text').value.trim();
    const moodResult = document.querySelector('#mood-result');
    
    if (!moodText) {
        alert('Please describe your mood first.');
        return;
    }
    
    if (!moodResult) return;
    
    // Show loading
    moodResult.innerHTML = `
        <div style="color: var(--text-muted); text-align: center; padding: 40px; grid-column: 1 / -1;">
            <i class="fas fa-spinner fa-spin" style="font-size: 48px; margin-bottom: 20px; color: var(--primary);"></i>
            <p>Analyzing your mood...</p>
        </div>
    `;
    
    try {
        // Simulate API call delay
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Generate analysis based on text
        const moodLevel = estimateMoodLevel(moodText);
        const energyLevel = estimateEnergyLevel(moodText);
        const suggestion = generateSuggestion(moodLevel, energyLevel);
        
        const moodColors = {
            positive: '#10b981',
            neutral: '#f59e0b',
            negative: '#ef4444'
        };
        
        const wheelColor = moodColors[moodLevel.category] || moodColors.neutral;
        
        moodResult.innerHTML = `
            <div class="mood-visual">
                <div class="mood-wheel" style="background: conic-gradient(${wheelColor} 0%, ${wheelColor} ${moodLevel.percentage}%, var(--border) ${moodLevel.percentage}%, var(--border) 100%);">
                    <div style="background: var(--bg-card); width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                        <span style="font-weight: bold; color: ${wheelColor};">${moodLevel.percentage}%</span>
                    </div>
                </div>
            </div>
            <div class="mood-details">
                <h4>Mood Analysis</h4>
                <div class="mood-info">
                    <span class="mood-label">Overall Tone:</span>
                    <span class="mood-value" style="color: ${wheelColor}">${moodLevel.label}</span>
                </div>
                <div class="mood-info">
                    <span class="mood-label">Energy Level:</span>
                    <span class="mood-value" style="color: ${energyLevel.color}">${energyLevel.label}</span>
                </div>
                <div class="mood-info">
                    <span class="mood-label">Detected:</span>
                    <span class="mood-value" style="color: var(--primary)">${moodLevel.keywords.join(', ')}</span>
                </div>
                <div class="scan-line"></div>
                <p class="mood-suggestion">${suggestion}</p>
            </div>
        `;
        
        // Save mood entry
        saveMoodEntry(moodText, moodLevel, energyLevel);
        
        // Clear input
        document.querySelector('#mood-text').value = '';
        
    } catch (error) {
        console.error('Mood analysis error:', error);
        moodResult.innerHTML = `
            <div style="color: var(--error); text-align: center; padding: 40px; grid-column: 1 / -1;">
                <i class="fas fa-exclamation-triangle" style="font-size: 48px; margin-bottom: 20px;"></i>
                <p>Failed to analyze mood. Please try again.</p>
            </div>
        `;
    }
}

function estimateMoodLevel(text) {
    const lowerText = text.toLowerCase();
    let score = 50; // Neutral start
    
    const positiveWords = ['happy', 'good', 'great', 'excellent', 'wonderful', 'joy', 'love', 'peace', 'calm', 'content', 'excited', 'optimistic', 'hopeful', 'grateful'];
    const negativeWords = ['sad', 'bad', 'terrible', 'awful', 'angry', 'anxious', 'stressed', 'worried', 'tired', 'exhausted', 'frustrated', 'depressed', 'lonely', 'overwhelmed'];
    
    positiveWords.forEach(word => {
        if (lowerText.includes(word)) score += 10;
    });
    
    negativeWords.forEach(word => {
        if (lowerText.includes(word)) score -= 10;
    });
    
    score = Math.max(0, Math.min(100, score));
    
    let category, label;
    if (score >= 70) {
        category = 'positive';
        label = 'Positive';
    } else if (score >= 40) {
        category = 'neutral';
        label = 'Neutral';
    } else {
        category = 'negative';
        label = 'Needs Support';
    }
    
    // Extract keywords
    const keywords = [];
    [...positiveWords, ...negativeWords].forEach(word => {
        if (lowerText.includes(word) && !keywords.includes(word)) {
            keywords.push(word);
        }
    });
    
    return {
        percentage: score,
        category,
        label,
        keywords: keywords.slice(0, 3)
    };
}

function estimateEnergyLevel(text) {
    const lowerText = text.toLowerCase();
    
    const highEnergyWords = ['energetic', 'excited', 'active', 'productive', 'motivated', 'focused'];
    const lowEnergyWords = ['tired', 'exhausted', 'drained', 'fatigued', 'sleepy', 'lethargic'];
    
    let highCount = 0;
    let lowCount = 0;
    
    highEnergyWords.forEach(word => {
        if (lowerText.includes(word)) highCount++;
    });
    
    lowEnergyWords.forEach(word => {
        if (lowerText.includes(word)) lowCount++;
    });
    
    if (highCount > lowCount) {
        return { label: 'High', color: '#10b981' };
    } else if (lowCount > highCount) {
        return { label: 'Low', color: '#ef4444' };
    } else {
        return { label: 'Medium', color: '#f59e0b' };
    }
}

function generateSuggestion(moodLevel, energyLevel) {
    if (moodLevel.category === 'positive' && energyLevel.label === 'High') {
        return 'Great energy! Consider channeling this into a creative project or physical activity.';
    } else if (moodLevel.category === 'positive' && energyLevel.label === 'Low') {
        return 'You seem content but low on energy. A gentle walk or light stretching might help.';
    } else if (moodLevel.category === 'negative') {
        return 'I notice some difficult emotions. Consider talking to someone you trust or practicing deep breathing.';
    } else {
        return 'A balanced state. This is a good time for reflection or planning your next steps.';
    }
}

function saveMoodEntry(text, moodLevel, energyLevel) {
    const entries = JSON.parse(localStorage.getItem('mindquest-mood') || '[]');
    entries.push({
        text,
        moodLevel,
        energyLevel,
        language: currentLanguage,
        timestamp: new Date().toISOString()
    });
    localStorage.setItem('mindquest-mood', JSON.stringify(entries.slice(-100)));
}

// ===== JOURNAL =====
function initJournal() {
    const journalForm = document.querySelector('#journal-form');
    const saveJournalBtn = document.querySelector('#save-journal');
    
    if (!journalForm) return;
    
    journalForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        analyzeJournal();
    });
    
    if (saveJournalBtn) {
        saveJournalBtn.addEventListener('click', function() {
            const journalText = document.querySelector('#journal-text').value.trim();
            if (!journalText) {
                alert('Please write something first.');
                return;
            }
            
            saveJournalEntry(journalText);
            document.querySelector('#journal-text').value = '';
            
            // Show confirmation
            const insightsOutput = document.querySelector('#insights-output');
            if (insightsOutput) {
                insightsOutput.innerHTML = `
                    <div style="color: var(--success); display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-check-circle"></i> Journal entry saved successfully!
                    </div>
                `;
                
                setTimeout(() => {
                    insightsOutput.innerHTML = `
                        <p style="color: var(--text-muted); font-style: italic;">
                            Your journal analysis will appear here...
                        </p>
                    `;
                }, 2000);
            }
        });
    }
}

async function analyzeJournal() {
    const journalText = document.querySelector('#journal-text').value.trim();
    const insightsOutput = document.querySelector('#insights-output');
    
    if (!journalText) {
        alert('Please write a journal entry first.');
        return;
    }
    
    if (!insightsOutput) return;
    
    // Show loading
    insightsOutput.innerHTML = `
        <div style="color: var(--text-muted); text-align: center; padding: 20px;">
            <i class="fas fa-spinner fa-spin" style="margin-right: 10px;"></i>
            Analyzing your journal entry...
        </div>
    `;
    
    try {
        // Simulate API call delay
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        // Generate insights
        const wordCount = journalText.split(/\s+/).length;
        const hasQuestions = /[?]/.test(journalText);
        const isReflective = journalText.length > 100 && (journalText.includes('I feel') || journalText.includes('I think'));
        
        const insights = [];
        
        if (wordCount < 50) {
            insights.push('Consider writing more details to gain deeper insights.');
        } else if (wordCount > 200) {
            insights.push('Detailed reflection detected. This is great for self-awareness.');
        }
        
        if (hasQuestions) {
            insights.push('You seem to be exploring questions. This is a sign of growth.');
        }
        
        if (isReflective) {
            insights.push('Reflective thinking noted. This practice enhances emotional intelligence.');
        }
        
        insightsOutput.innerHTML = `
            <div style="color: var(--text-muted); margin-bottom: 10px;">Analysis complete:</div>
            <div style="color: var(--primary); line-height: 1.6; margin-bottom: 15px;">
                <strong>Key Observations:</strong><br>
                ${insights.length > 0 ? insights.join('<br>') : 'Your entry shows balanced expression.'}
            </div>
            <div style="background: var(--bg-darker); padding: 12px; border-radius: 6px; margin: 15px 0; border-left: 3px solid var(--primary);">
                <strong>Word Count:</strong> ${wordCount} words<br>
                <strong>Reflection Level:</strong> ${isReflective ? 'High' : 'Moderate'}<br>
                <strong>Questioning:</strong> ${hasQuestions ? 'Present' : 'Not detected'}
            </div>
            <div class="scan-line" style="margin: 15px 0;"></div>
            <div style="font-size: 13px; color: var(--text-muted);">
                <i class="fas fa-lightbulb" style="color: var(--primary); margin-right: 8px;"></i>
                Suggestion: ${getJournalSuggestion(wordCount, hasQuestions)}
            </div>
        `;
        
        // Save journal entry
        saveJournalEntry(journalText);
        
        // Clear input
        document.querySelector('#journal-text').value = '';
        
    } catch (error) {
        console.error('Journal analysis error:', error);
        insightsOutput.innerHTML = `
            <div style="color: var(--error);">
                <i class="fas fa-exclamation-triangle"></i> Failed to analyze journal. Please try again.
            </div>
        `;
    }
}

function getJournalSuggestion(wordCount, hasQuestions) {
    if (wordCount < 30) {
        return 'Try writing for 5 more minutes to explore deeper thoughts.';
    } else if (hasQuestions) {
        return 'Consider exploring answers to your questions in your next entry.';
    } else {
        return 'Continue this daily practice for maximum benefit.';
    }
}

function saveJournalEntry(text) {
    const entries = JSON.parse(localStorage.getItem('mindquest-journal') || '[]');
    entries.push({
        text,
        language: currentLanguage,
        timestamp: new Date().toISOString(),
        wordCount: text.split(/\s+/).length
    });
    localStorage.setItem('mindquest-journal', JSON.stringify(entries.slice(-100)));
}

// ===== INSIGHTS =====
function initInsights() {
    updateInsights();
}

function updateInsights() {
    // Chat stats
    const chatStats = document.getElementById('chat-stats');
    if (chatStats) {
        const history = JSON.parse(localStorage.getItem('mindquest-chat-history') || '[]');
        const userMessages = history.filter(msg => msg.sender === 'user').length;
        chatStats.innerHTML = `
            <strong>Total Messages:</strong> ${history.length}<br>
            <strong>Your Messages:</strong> ${userMessages}<br>
            <strong>AI Responses:</strong> ${history.length - userMessages}
        `;
    }
    
    // Mood stats
    const moodStats = document.getElementById('mood-stats');
    if (moodStats) {
        const moods = JSON.parse(localStorage.getItem('mindquest-mood') || '[]');
        const recentMoods = moods.slice(-7);
        
        if (recentMoods.length > 0) {
            const avgMood = recentMoods.reduce((sum, entry) => sum + entry.moodLevel.percentage, 0) / recentMoods.length;
            moodStats.innerHTML = `
                <strong>Recent Entries:</strong> ${recentMoods.length}<br>
                <strong>Avg. Mood:</strong> ${Math.round(avgMood)}%<br>
                <strong>Last Entry:</strong> ${new Date(recentMoods[recentMoods.length - 1].timestamp).toLocaleDateString()}
            `;
        } else {
            moodStats.innerHTML = `No mood entries yet.<br>Start tracking to see insights.`;
        }
    }
    
    // Journal stats
    const journalStats = document.getElementById('journal-stats');
    if (journalStats) {
        const journals = JSON.parse(localStorage.getItem('mindquest-journal') || '[]');
        const totalWords = journals.reduce((sum, entry) => sum + entry.wordCount, 0);
        
        journalStats.innerHTML = `
            <strong>Total Entries:</strong> ${journals.length}<br>
            <strong>Total Words:</strong> ${totalWords}<br>
            <strong>Avg. Length:</strong> ${journals.length > 0 ? Math.round(totalWords / journals.length) : 0} words
        `;
    }
    
    // Weekly summary
    const weeklySummary = document.getElementById('weekly-summary');
    if (weeklySummary) {
        const today = new Date();
        const weekStart = new Date(today.setDate(today.getDate() - 7));
        
        const allChats = JSON.parse(localStorage.getItem('mindquest-chat-history') || '[]');
        const allMoods = JSON.parse(localStorage.getItem('mindquest-mood') || '[]');
        const allJournals = JSON.parse(localStorage.getItem('mindquest-journal') || '[]');
        
        const weeklyActivity = allChats.length + allMoods.length + allJournals.length;
        
        let summary = '';
        if (weeklyActivity === 0) {
            summary = 'No activity this week. Start using the app to see personalized insights.';
        } else if (weeklyActivity < 5) {
            summary = 'Light activity this week. Consider using the journal or mood tracker daily for better insights.';
        } else if (weeklyActivity < 15) {
            summary = 'Good engagement this week. Your consistency is helping build meaningful patterns.';
        } else {
            summary = 'Excellent engagement! You\'re actively working on your mental wellness.';
        }
        
        weeklySummary.innerHTML = `
            <strong>Weekly Activity:</strong> ${weeklyActivity} interactions<br><br>
            ${summary}
        `;
    }
}

// ===== SETTINGS =====
function initSettings() {
    const exportBtn = document.getElementById('export-data');
    const clearBtn = document.getElementById('clear-data');
    const resetBtn = document.getElementById('reset-settings');
    
    if (exportBtn) {
        exportBtn.addEventListener('click', exportData);
    }
    
    if (clearBtn) {
        clearBtn.addEventListener('click', clearAllData);
    }
    
    if (resetBtn) {
        resetBtn.addEventListener('click', resetSettings);
    }
    
    // Load saved response length preference
    const savedLength = localStorage.getItem('mindquest-response-length') || 'short';
    const radioButtons = document.querySelectorAll('input[name="response-length"]');
    radioButtons.forEach(radio => {
        if (radio.value === savedLength) {
            radio.checked = true;
        }
        radio.addEventListener('change', function() {
            localStorage.setItem('mindquest-response-length', this.value);
        });
    });
}

function exportData() {
    const data = {
        chatHistory: JSON.parse(localStorage.getItem('mindquest-chat-history') || '[]'),
        moodEntries: JSON.parse(localStorage.getItem('mindquest-mood') || '[]'),
        journalEntries: JSON.parse(localStorage.getItem('mindquest-journal') || '[]'),
        settings: {
            language: localStorage.getItem('mindquest-lang') || 'en',
            context: localStorage.getItem('mindquest-context') || 'general',
            responseLength: localStorage.getItem('mindquest-response-length') || 'short'
        },
        exportDate: new Date().toISOString()
    };
    
    const dataStr = JSON.stringify(data, null, 2);
    const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
    
    const exportFileDefaultName = `mindquest-export-${new Date().toISOString().split('T')[0]}.json`;
    
    const linkElement = document.createElement('a');
    linkElement.setAttribute('href', dataUri);
    linkElement.setAttribute('download', exportFileDefaultName);
    linkElement.click();
    
    alert('Data exported successfully!');
}

function clearAllData() {
    if (confirm('This will delete ALL your chat history, mood entries, and journal entries. This action cannot be undone. Continue?')) {
        localStorage.clear();
        alert('All data cleared. The page will reload.');
        location.reload();
    }
}

function resetSettings() {
    if (confirm('Reset all settings to defaults?')) {
        localStorage.removeItem('mindquest-lang');
        localStorage.removeItem('mindquest-context');
        localStorage.removeItem('mindquest-response-length');
        alert('Settings reset. The page will reload.');
        location.reload();
    }
}

// ===== UTILITY FUNCTIONS =====
function updateLastSync() {
    const lastSyncElement = document.getElementById('last-sync');
    if (lastSyncElement) {
        const now = new Date();
        lastSyncElement.textContent = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }
}

// Update insights every minute when on insights panel
setInterval(() => {
    const activePanel = document.querySelector('.cyber-panel.active');
    if (activePanel && activePanel.id === 'insights-panel') {
        updateInsights();
    }
}, 60000);

// Update last sync every minute
setInterval(updateLastSync, 60000);