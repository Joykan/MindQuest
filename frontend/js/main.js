import jacClient from './jacclient.js';
import config from './config.js';

const jacClient = new JacClient();
let currentUserId = null;

// API Configuration
const API_URL = config.API_URL || 'https://mindquest-pxjz.onrender.com';

// Initialize app
document.addEventListener('DOMContentLoaded', async () => {
    // Initialize Jac Client
    const initResult = await jacClient.init();
    if (!initResult.success) {
        showMessage('Failed to connect to backend. Please ensure Jaseci is running.', 'error');
        return;
    }

    // Check for saved user ID
    currentUserId = jacClient.getUserId();
    if (currentUserId) {
        jacClient.setUserId(currentUserId);
        showUserStatus(`Welcome back! User ID: ${currentUserId}`);
        hideElement('user-section');
    }

    setupEventListeners();
    loadEmotionHistory();
    checkApiStatus();
});

// Event Listeners
function setupEventListeners() {
    // Tab navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            switchTab(e.target.dataset.tab);
        });
    });

    // User creation
    document.getElementById('create-user-btn').addEventListener('click', createUser);

    // Mood logging
    document.querySelectorAll('.emotion-card').forEach(card => {
        card.addEventListener('click', (e) => {
            const emotion = e.currentTarget.dataset.emotion;
            const category = e.currentTarget.dataset.category;
            selectEmotion(emotion, category);
        });
    });

    document.getElementById('intensity-slider').addEventListener('input', (e) => {
        document.getElementById('intensity-value').textContent = e.target.value;
    });

    document.getElementById('submit-mood-btn').addEventListener('click', submitMood);

    // Journal
    document.getElementById('save-journal-btn').addEventListener('click', saveJournalEntry);
    document.getElementById('get-prompt-btn').addEventListener('click', getJournalingPrompt);

    // Insights
    document.getElementById('generate-insights-btn').addEventListener('click', generateInsights);
    document.getElementById('analyze-patterns-btn').addEventListener('click', analyzePatterns);

    // Activities
    document.getElementById('log-activity-btn').addEventListener('click', logActivity);
    document.getElementById('activity-effectiveness').addEventListener('input', (e) => {
        document.getElementById('effectiveness-value').textContent = e.target.value;
    });

    // Suggestions
    document.getElementById('get-support-btn').addEventListener('click', () => {
        document.getElementById('support-input-container').classList.remove('hidden');
    });
    document.getElementById('submit-support-btn').addEventListener('click', getSupport);

    // Chat
    document.getElementById('chat-send-btn').addEventListener('click', sendMessage);
    document.getElementById('chat-input').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });
}

// Check API Status
async function checkApiStatus() {
    try {
        const response = await fetch(`${API_URL}/health`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });
        
        if (response.ok) {
            updateApiStatus('online');
        } else {
            updateApiStatus('offline');
        }
    } catch (error) {
        updateApiStatus('offline');
        console.error('API status check failed:', error);
    }
}

function updateApiStatus(status) {
    const statusEl = document.querySelector('.api-status-indicator');
    if (statusEl) {
        statusEl.textContent = `API: ${status}`;
        statusEl.className = `api-status-indicator ${status}`;
    }
}

// User Management
async function createUser() {
    const name = document.getElementById('user-name').value;
    const email = document.getElementById('user-email').value;

    if (!name || !email) {
        showMessage('Please enter both name and email', 'error');
        return;
    }

    showLoading(true);
    const result = await jacClient.createUser(name, email);

    if (result.success) {
        currentUserId = result.userId;
        jacClient.setUserId(currentUserId);
        showUserStatus(`Profile created! Welcome, ${name}`);
        hideElement('user-section');
        showMessage('User profile created successfully!', 'success');
    } else {
        showMessage(`Failed to create user: ${result.error}`, 'error');
    }
    showLoading(false);
}

// Mood Logging
function selectEmotion(emotion, category) {
    document.querySelectorAll('.emotion-card').forEach(card => {
        card.classList.remove('selected');
    });
    event.currentTarget.classList.add('selected');

    document.getElementById('mood-details').classList.remove('hidden');
    document.getElementById('mood-details').dataset.emotion = emotion;
    document.getElementById('mood-details').dataset.category = category;
}

async function submitMood() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    const emotionElement = document.getElementById('mood-details');
    const emotion = emotionElement.dataset.emotion;
    const category = emotionElement.dataset.category;
    const intensity = parseInt(document.getElementById('intensity-slider').value);
    const notes = document.getElementById('mood-notes').value;

    if (!emotion) {
        showMessage('Please select an emotion', 'error');
        return;
    }

    showLoading(true);
    
    // Use Spawn() via JacClient to log mood
    const result = await jacClient.logMood(emotion, intensity, notes, category);

    if (result.success) {
        showMessage('Mood logged successfully!', 'success');
        document.getElementById('mood-notes').value = '';
        document.getElementById('intensity-slider').value = 5;
        document.getElementById('intensity-value').textContent = '5';
        emotionElement.classList.add('hidden');
        document.querySelectorAll('.emotion-card').forEach(card => card.classList.remove('selected'));
        
        loadEmotionHistory();
    } else {
        showMessage(`Failed to log mood: ${result.error}`, 'error');
    }
    showLoading(false);
}

async function loadEmotionHistory() {
    if (!currentUserId) return;

    showLoading(true);
    const result = await jacClient.getEmotions(7);

    if (result.success && result.report) {
        const emotions = result.report[0]?.emotions || result.report || [];
        displayEmotionHistory(emotions);
        
        // Also load summary
        const summaryResult = await jacClient.getEmotionSummary(7);
        if (summaryResult.success && summaryResult.report) {
            displayEmotionSummary(summaryResult.report[0] || summaryResult.report);
        }
    }
    showLoading(false);
}

function displayEmotionHistory(emotions) {
    const container = document.getElementById('mood-history');
    if (!emotions || emotions.length === 0) {
        container.innerHTML = '<p>No mood entries yet. Start logging your emotions!</p>';
        return;
    }

    container.innerHTML = '<h3>Recent Mood History</h3>';
    emotions.slice(0, 10).forEach(emotion => {
        const entry = document.createElement('div');
        entry.className = 'mood-entry';
        entry.innerHTML = `
            <span class="emotion-badge ${emotion.mood_category}">${emotion.name}</span>
            <span class="intensity">Intensity: ${emotion.intensity}/10</span>
            <span class="timestamp">${formatDate(emotion.timestamp)}</span>
            ${emotion.notes ? `<p class="notes">${emotion.notes}</p>` : ''}
        `;
        container.appendChild(entry);
    });
}

function displayEmotionSummary(summary) {
    const container = document.getElementById('summary-stats');
    if (!summary || !summary.statistics) return;

    const stats = summary.statistics;
    container.innerHTML = `
        <div class="stat-card">
            <h4>Total Entries</h4>
            <p class="stat-value">${stats.total_entries}</p>
        </div>
        <div class="stat-card">
            <h4>Average Intensity</h4>
            <p class="stat-value">${stats.average_intensity?.toFixed(1) || 'N/A'}</p>
        </div>
        <div class="stat-card">
            <h4>Dominant Category</h4>
            <p class="stat-value">${stats.dominant_category || 'N/A'}</p>
        </div>
    `;
}

// Journal
async function saveJournalEntry() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    const content = document.getElementById('journal-entry').value;
    if (!content.trim()) {
        showMessage('Please enter journal content', 'error');
        return;
    }

    showLoading(true);
    
    try {
        // Use the API endpoint for journal creation
        const response = await fetch(`${API_URL}/api/create_journal`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: currentUserId,
                content: content,
                entry_type: 'freeform',
                emotional_tags: []
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        
        if (data.success) {
            showMessage('Journal entry saved!', 'success');
            document.getElementById('journal-entry').value = '';
            loadJournalEntries();
        } else {
            throw new Error(data.error || 'Failed to save entry');
        }
    } catch (error) {
        showMessage(`Failed to save entry: ${error.message}`, 'error');
        console.error('Journal save error:', error);
    }
    
    showLoading(false);
}

async function getJournalingPrompt() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    showLoading(true);
    
    try {
        // Use chat API to generate a journaling prompt
        const response = await fetch(`${API_URL}/api/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                message: 'Generate a thoughtful journaling prompt for someone looking to explore their emotions and mental wellbeing.' 
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        const prompt = data.reply || 'Write about what you\'re feeling right now.';
        
        document.getElementById('journal-entry').value = `Prompt: ${prompt}\n\n`;
        showMessage('Journaling prompt generated!', 'success');
    } catch (error) {
        showMessage('Failed to generate prompt', 'error');
        console.error('Prompt generation error:', error);
    }
    
    showLoading(false);
}

async function loadJournalEntries() {
    if (!currentUserId) return;
    
    showLoading(true);
    
    try {
        const response = await fetch(`${API_URL}/api/get_insights`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: currentUserId })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        
        if (data.all_entries && data.all_entries.length > 0) {
            displayJournalEntries(data.all_entries);
        }
    } catch (error) {
        console.error('Failed to load journal entries:', error);
    }
    
    showLoading(false);
}

function displayJournalEntries(entries) {
    const container = document.getElementById('journal-history');
    if (!container) return;
    
    container.innerHTML = '<h3>Recent Journal Entries</h3>';
    
    entries.slice(0, 5).forEach(entry => {
        const entryDiv = document.createElement('div');
        entryDiv.className = 'journal-entry';
        entryDiv.innerHTML = `
            <p class="journal-content">${entry.content}</p>
            <span class="timestamp">${formatDate(entry.timestamp)}</span>
        `;
        container.appendChild(entryDiv);
    });
}

// Insights
async function generateInsights() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    showLoading(true);
    
    try {
        const response = await fetch(`${API_URL}/api/get_insights`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: currentUserId })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        
        displayInsights(data);
        showMessage('Insights generated!', 'success');
    } catch (error) {
        showMessage(`Failed to generate insights: ${error.message}`, 'error');
        console.error('Insights error:', error);
    }
    
    showLoading(false);
}

async function analyzePatterns() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    showLoading(true);
    
    try {
        // Use chat API to analyze patterns
        const response = await fetch(`${API_URL}/api/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                message: `Analyze my mental health patterns and provide insights on my emotional wellbeing trends.` 
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        
        showMessage('Pattern analysis completed!', 'success');
        
        // Display the analysis
        const analysisDiv = document.createElement('div');
        analysisDiv.className = 'insight-card';
        analysisDiv.innerHTML = `
            <h4>Pattern Analysis</h4>
            <p>${data.reply}</p>
        `;
        
        const container = document.getElementById('insights-content');
        container.insertBefore(analysisDiv, container.firstChild);
    } catch (error) {
        showMessage(`Failed to analyze patterns: ${error.message}`, 'error');
        console.error('Pattern analysis error:', error);
    }
    
    showLoading(false);
}

function displayInsights(data) {
    const container = document.getElementById('insights-content');
    container.innerHTML = '';

    if (!data || data.entries_count === 0) {
        container.innerHTML = '<p>No insights available yet. Keep logging your moods to generate insights!</p>';
        return;
    }

    const card = document.createElement('div');
    card.className = 'insight-card';
    card.innerHTML = `
        <h4>Your Mental Health Summary</h4>
        <p><strong>Total Entries:</strong> ${data.entries_count}</p>
        ${data.latest_entry ? `
            <p><strong>Latest Entry:</strong> ${formatDate(data.latest_entry.timestamp)}</p>
            <p>${data.latest_entry.content}</p>
        ` : ''}
    `;
    container.appendChild(card);
}

// Activities
async function logActivity() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    const name = document.getElementById('activity-name').value;
    const category = document.getElementById('activity-category').value;
    const duration = parseInt(document.getElementById('activity-duration').value);
    const effectiveness = parseInt(document.getElementById('activity-effectiveness').value);

    if (!name || !duration) {
        showMessage('Please fill in all required fields', 'error');
        return;
    }

    showLoading(true);
    const result = await jacClient.logActivity(name, category, duration, effectiveness);

    if (result.success) {
        showMessage('Activity logged successfully!', 'success');
        document.getElementById('activity-name').value = '';
        document.getElementById('activity-duration').value = '';
        document.getElementById('activity-effectiveness').value = 5;
        document.getElementById('effectiveness-value').textContent = '5';
    } else {
        showMessage(`Failed to log activity: ${result.error}`, 'error');
    }
    showLoading(false);
}

// Suggestions & Support
async function getSupport() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    const supportRequest = document.getElementById('support-request').value;
    if (!supportRequest.trim()) {
        showMessage('Please tell us what\'s on your mind', 'error');
        return;
    }

    showLoading(true);
    
    try {
        const response = await fetch(`${API_URL}/api/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: supportRequest })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        
        showMessage('Support response generated!', 'success');
        document.getElementById('support-request').value = '';
        
        // Display the support response
        displaySuggestions([{
            title: 'AI Support Response',
            content: data.reply,
            type: 'support',
            priority: 'high'
        }]);
    } catch (error) {
        showMessage(`Failed to get support: ${error.message}`, 'error');
        console.error('Support error:', error);
    }
    
    showLoading(false);
}

async function loadSuggestions() {
    if (!currentUserId) return;

    showLoading(true);
    const result = await jacClient.getSuggestions('all');

    if (result.success && result.report) {
        displaySuggestions(result.report[0] || result.report);
    }
    showLoading(false);
}

function displaySuggestions(suggestions) {
    const container = document.getElementById('suggestions-list');
    container.innerHTML = '';

    if (!suggestions || suggestions.length === 0) {
        container.innerHTML = '<p>No suggestions available. Get support to receive personalized suggestions!</p>';
        return;
    }

    const suggestionsArray = Array.isArray(suggestions) ? suggestions : [suggestions];

    suggestionsArray.forEach(suggestion => {
        const card = document.createElement('div');
        card.className = `suggestion-card ${suggestion.type || suggestion.suggestion_type || ''}`;
        card.innerHTML = `
            <div class="suggestion-header">
                <h4>${suggestion.title || 'Suggestion'}</h4>
                <span class="priority-badge ${suggestion.priority || 'medium'}">${suggestion.priority || 'medium'}</span>
            </div>
            <p class="suggestion-content">${suggestion.content}</p>
            <div class="suggestion-type">Type: ${suggestion.type || suggestion.suggestion_type || 'general'}</div>
        `;
        container.appendChild(card);
    });
}

// Chat functionality
async function sendMessage() {
    const input = document.getElementById('chat-input');
    const message = input.value.trim();
    if (!message) return;

    addChatMessage('user', message);
    input.value = '';
    
    // Show typing indicator
    const typingDiv = document.createElement('div');
    typingDiv.className = 'chat-message bot typing';
    typingDiv.id = 'typing-indicator';
    typingDiv.textContent = 'AI is typing...';
    document.getElementById('chat-messages').appendChild(typingDiv);
    
    try {
        const response = await fetch(`${API_URL}/api/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message })
        });

        // Remove typing indicator
        document.getElementById('typing-indicator')?.remove();

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        const reply = data.reply || "Oops! I couldn't think of a reply.";
        addChatMessage('bot', reply);
        
        // Update API status
        updateApiStatus('online');
    } catch (err) {
        document.getElementById('typing-indicator')?.remove();
        addChatMessage('bot', `Network error: ${err.message}. Please check if the API is running.`);
        console.error('Chat error:', err);
        updateApiStatus('offline');
    }
}

function addChatMessage(sender, text) {
    const chatMessages = document.getElementById('chat-messages');
    const msgDiv = document.createElement('div');
    msgDiv.className = `chat-message ${sender}`;
    msgDiv.textContent = text;
    chatMessages.appendChild(msgDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

// UI Helpers
function switchTab(tabName) {
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });

    document.getElementById(tabName).classList.add('active');
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
}

function showLoading(show) {
    const loading = document.getElementById('loading');
    if (loading) {
        if (show) {
            loading.classList.remove('hidden');
        } else {
            loading.classList.add('hidden');
        }
    }
}

function showMessage(message, type = 'info') {
    const messagesContainer = document.getElementById('messages');
    if (!messagesContainer) return;
    
    const messageEl = document.createElement('div');
    messageEl.className = `message ${type}`;
    messageEl.textContent = message;
    messagesContainer.appendChild(messageEl);

    setTimeout(() => {
        messageEl.remove();
    }, 5000);
}

function showUserStatus(message) {
    const status = document.getElementById('user-status');
    if (status) {
        status.textContent = message;
        status.classList.remove('hidden');
    }
}

function hideElement(elementId) {
    const element = document.getElementById(elementId);
    if (element) {
        element.classList.add('hidden');
    }
}

function formatDate(timestamp) {
    if (!timestamp) return 'N/A';
    const date = new Date(timestamp * 1000 || timestamp);
    return date.toLocaleString();
}

// Auto-load suggestions on suggestions tab
const suggestionsTab = document.querySelector('[data-tab="suggestions"]');
if (suggestionsTab) {
    suggestionsTab.addEventListener('click', () => {
        if (currentUserId) {
            loadSuggestions();
        }
    });
}