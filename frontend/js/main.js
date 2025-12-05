// Main application logic for MindQuest
// Uses JacClient with Spawn() for all backend interactions

const jacClient = new JacClient();
let currentUserId = null;

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
    const result = await jacClient.createJournalEntry(content, 'freeform', []);

    if (result.success) {
        showMessage('Journal entry saved!', 'success');
        document.getElementById('journal-entry').value = '';
        loadJournalEntries();
    } else {
        showMessage(`Failed to save entry: ${result.error}`, 'error');
    }
    showLoading(false);
}

async function getJournalingPrompt() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    showLoading(true);
    // Get current emotion for personalized prompt
    const emotionsResult = await jacClient.getEmotions(1);
    const latestEmotion = emotionsResult.report?.[0]?.emotions?.[0] || { name: 'neutral' };

    // Use Spawn() to get journaling prompt
    const result = await jacClient.spawn('api_get_journaling_prompt', {
        user_id: currentUserId,
        emotional_state: latestEmotion.name || 'neutral'
    });

    if (result.success && result.report) {
        const prompt = result.report[0]?.content || result.report[0]?.prompt || 
                      'Write about what you\'re feeling right now.';
        document.getElementById('journal-entry').value = `Prompt: ${prompt}\n\n`;
        showMessage('Journaling prompt generated!', 'success');
    } else {
        showMessage('Failed to generate prompt', 'error');
    }
    showLoading(false);
}

async function loadJournalEntries() {
    // Implementation to load and display journal entries
    // This would require a corresponding backend walker
}

// Insights
async function generateInsights() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    showLoading(true);
    const result = await jacClient.getInsights();

    if (result.success) {
        displayInsights(result.report || []);
        showMessage('Insights generated!', 'success');
    } else {
        showMessage(`Failed to generate insights: ${result.error}`, 'error');
    }
    showLoading(false);
}

async function analyzePatterns() {
    if (!currentUserId) {
        showMessage('Please create a user profile first', 'error');
        return;
    }

    showLoading(true);
    const result = await jacClient.analyzePatterns('weekly');

    if (result.success) {
        showMessage('Pattern analysis completed!', 'success');
        // Refresh insights after analysis
        await generateInsights();
    } else {
        showMessage(`Failed to analyze patterns: ${result.error}`, 'error');
    }
    showLoading(false);
}

function displayInsights(insights) {
    const container = document.getElementById('insights-content');
    container.innerHTML = '';

    if (!insights || insights.length === 0) {
        container.innerHTML = '<p>No insights available yet. Keep logging your moods to generate insights!</p>';
        return;
    }

    insights.forEach(insight => {
        const card = document.createElement('div');
        card.className = 'insight-card';
        card.innerHTML = `
            <h4>${insight.type || 'Insight'}</h4>
            <p>${insight.insight || insight.content || JSON.stringify(insight)}</p>
            ${insight.recommendations ? `<p class="recommendations"><strong>Recommendations:</strong> ${insight.recommendations}</p>` : ''}
        `;
        container.appendChild(card);
    });
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
    // Use Spawn() via JacClient to get support
    const result = await jacClient.getSupport(supportRequest);

    if (result.success) {
        showMessage('Support response generated!', 'success');
        document.getElementById('support-request').value = '';
        
        // Load suggestions
        await loadSuggestions();
    } else {
        showMessage(`Failed to get support: ${result.error}`, 'error');
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

    suggestions.forEach(suggestion => {
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
    if (show) {
        loading.classList.remove('hidden');
    } else {
        loading.classList.add('hidden');
    }
}

function showMessage(message, type = 'info') {
    const messagesContainer = document.getElementById('messages');
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
    status.textContent = message;
    status.classList.remove('hidden');
}

function hideElement(elementId) {
    document.getElementById(elementId).classList.add('hidden');
}

function formatDate(timestamp) {
    if (!timestamp) return 'N/A';
    const date = new Date(timestamp * 1000 || timestamp);
    return date.toLocaleString();
}

// Auto-load suggestions on suggestions tab
document.querySelector('[data-tab="suggestions"]').addEventListener('click', () => {
    if (currentUserId) {
        loadSuggestions();
    }
});

// Chat to GPT endpoint
document.getElementById('chat-send-btn').addEventListener('click', sendMessage);

async function sendMessage() {
    const input = document.getElementById('chat-input');
    const message = input.value.trim();
    if (!message) return;

    addChatMessage('user', message);
    input.value = '';
    
    try {
        const response = await fetch('http://localhost:4000/api/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message })
        });

        const data = await response.json();
        const reply = data.reply || "Oops! I couldn't think of a reply.";
        addChatMessage('bot', reply);
    } catch (err) {
        addChatMessage('bot', 'Server error. Try again later.');
        console.error(err);
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
