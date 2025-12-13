// Frontend app.js - MindQuest Client Application

console.log('MindQuest frontend app.js loaded');

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  console.log('DOM loaded, initializing MindQuest...');
  
  // Check API availability
  if (window.MindQuestAPI) {
    console.log('✅ API found:', window.MindQuestAPI.backendUrl);
    
    // Test connection
    window.MindQuestAPI.testConnection().then(result => {
      if (result.connected) {
        console.log('🎉 Backend connected successfully!');
        showStatus('Connected to backend', 'success');
      } else {
        console.warn('⚠️ Backend connection failed');
        showStatus('Backend connection failed', 'error');
      }
    });
  } else {
    console.error('❌ MindQuestAPI not available');
    showStatus('API configuration missing', 'error');
  }
  
  // Setup UI components
  setupUI();
});

// Show status message
function showStatus(message, type = 'info') {
  const statusEl = document.getElementById('api-status') || createStatusElement();
  
  statusEl.textContent = message;
  statusEl.className = `status status-${type}`;
  
  // Auto-hide success messages after 5 seconds
  if (type === 'success') {
    setTimeout(() => {
      if (statusEl.textContent === message) {
        statusEl.textContent = 'Ready';
        statusEl.className = 'status status-info';
      }
    }, 5000);
  }
}

// Create status element if it doesn't exist
function createStatusElement() {
  let statusEl = document.getElementById('api-status');
  if (!statusEl) {
    statusEl = document.createElement('div');
    statusEl.id = 'api-status';
    statusEl.className = 'status';
    document.body.insertBefore(statusEl, document.body.firstChild);
  }
  return statusEl;
}

// Setup UI components and event listeners
function setupUI() {
  console.log('Setting up UI components...');
  
  // Journal form
  const journalForm = document.getElementById('journal-form');
  if (journalForm) {
    journalForm.addEventListener('submit', handleJournalSubmit);
    console.log('✓ Journal form initialized');
  }
  
  // Chat form
  const chatForm = document.getElementById('chat-form');
  if (chatForm) {
    chatForm.addEventListener('submit', handleChatSubmit);
    console.log('✓ Chat form initialized');
  }
  
  // Mood analysis
  const moodBtn = document.getElementById('analyze-mood-btn');
  if (moodBtn) {
    moodBtn.addEventListener('click', handleMoodAnalysis);
    console.log('✓ Mood analysis initialized');
  }
  
  // Setup backend URL configuration if elements exist
  const apiUrlInput = document.getElementById('api-url-input');
  const saveApiBtn = document.getElementById('save-api-btn');
  
  if (apiUrlInput && saveApiBtn) {
    // Show current backend URL
    apiUrlInput.value = window.MindQuestAPI ? window.MindQuestAPI.backendUrl : 'http://localhost:5000';
    
    saveApiBtn.addEventListener('click', () => {
      const newUrl = apiUrlInput.value.trim();
      if (!newUrl) {
        alert('Please enter a backend URL');
        return;
      }
      
      if (window.MindQuestAPI) {
        window.MindQuestAPI.backendUrl = newUrl.replace(/\/+$/, '');
        localStorage.setItem('MQ_BACKEND_URL', window.MindQuestAPI.backendUrl);
        
        // Test new connection
        window.MindQuestAPI.testConnection().then(result => {
          if (result.connected) {
            showStatus(`Connected to: ${window.MindQuestAPI.backendUrl}`, 'success');
          } else {
            showStatus('Failed to connect to new URL', 'error');
          }
        });
      }
    });
    console.log('✓ Backend URL config initialized');
  }
}

// Handle journal submission
async function handleJournalSubmit(e) {
  e.preventDefault();
  
  const textInput = document.getElementById('journal-text');
  const moodSelect = document.getElementById('journal-mood');
  
  if (!textInput || !textInput.value.trim()) {
    alert('Please enter some journal text');
    return;
  }
  
  const journalData = {
    text: textInput.value,
    mood: moodSelect ? moodSelect.value : undefined
  };
  
  showStatus('Saving journal...', 'info');
  
  try {
    const result = await window.MindQuestAPI.createJournal(journalData);
    
    if (result.status === 'success') {
      showStatus('Journal saved successfully!', 'success');
      
      // Get AI insights
      showStatus('Getting AI insights...', 'info');
      const insights = await window.MindQuestAPI.getInsights(journalData.text);
      
      if (insights.status === 'success') {
        displayInsights(insights);
        showStatus('AI analysis complete!', 'success');
      }
      
      // Clear form
      textInput.value = '';
      if (moodSelect) moodSelect.value = '';
    }
  } catch (error) {
    console.error('Journal error:', error);
    showStatus('Failed to save journal', 'error');
  }
}

// Handle chat submission
async function handleChatSubmit(e) {
  e.preventDefault();
  
  const chatInput = document.getElementById('chat-input');
  if (!chatInput || !chatInput.value.trim()) {
    alert('Please enter a message');
    return;
  }
  
  const message = chatInput.value;
  
  // Add user message to UI
  addChatMessage(message, 'user');
  
  showStatus('AI thinking...', 'info');
  
  try {
    const response = await window.MindQuestAPI.chat(message, 'general');
    
    if (response.success) {
      addChatMessage(response.response, 'ai');
      showStatus('AI responded', 'success');
    } else {
      addChatMessage('Sorry, I encountered an error.', 'ai');
      showStatus('AI response failed', 'error');
    }
  } catch (error) {
    console.error('Chat error:', error);
    addChatMessage('Network error. Please check connection.', 'ai');
    showStatus('Chat failed', 'error');
  }
  
  // Clear input
  chatInput.value = '';
}

// Handle mood analysis
async function handleMoodAnalysis() {
  const moodText = document.getElementById('mood-text') || 
                   document.getElementById('journal-text');
  
  if (!moodText || !moodText.value.trim()) {
    alert('Please enter some text to analyze');
    return;
  }
  
  const text = moodText.value;
  showStatus('Analyzing mood...', 'info');
  
  try {
    const result = await window.MindQuestAPI.analyzeMood(text);
    
    if (result.mood && result.mood !== 'unknown') {
      showStatus(`Mood: ${result.mood} (${Math.round(result.confidence * 100)}% confidence)`, 'success');
      alert(`Detected mood: ${result.mood}\nConfidence: ${Math.round(result.confidence * 100)}%\nKeywords: ${result.detectedKeywords?.join(', ') || 'none'}`);
    } else {
      showStatus('Could not determine mood', 'error');
    }
  } catch (error) {
    console.error('Mood analysis error:', error);
    showStatus('Mood analysis failed', 'error');
  }
}

// Add chat message to UI
function addChatMessage(text, sender) {
  const chatContainer = document.getElementById('chatContainer') || createChatContainer();
  
  const messageDiv = document.createElement('div');
  messageDiv.className = `chat-message ${sender}`;
  messageDiv.textContent = text;
  
  chatContainer.appendChild(messageDiv);
  chatContainer.scrollTop = chatContainer.scrollHeight;
}

// Create chat container if it doesn't exist
function createChatContainer() {
  const container = document.createElement('div');
  container.id = 'chatContainer';
  container.style.cssText = `
    max-height: 400px;
    overflow-y: auto;
    border: 1px solid #ddd;
    padding: 10px;
    margin: 10px 0;
    border-radius: 5px;
  `;
  
  // Try to insert after chat form
  const chatForm = document.getElementById('chat-form');
  if (chatForm) {
    chatForm.parentNode.insertBefore(container, chatForm.nextSibling);
  } else {
    document.body.appendChild(container);
  }
  
  return container;
}

// Display insights
function displayInsights(insights) {
  const container = document.getElementById('insights-container') || createInsightsContainer();
  
  const insightsData = insights.insights || {};
  
  container.innerHTML = `
    <div class="insights-card">
      <h3>AI Insights</h3>
      <p><strong>Emotional Tone:</strong> ${insightsData.emotionalTone || 'Not detected'}</p>
      ${insightsData.keyThemes ? `<p><strong>Key Themes:</strong> ${insightsData.keyThemes.join(', ')}</p>` : ''}
      ${insightsData.summary ? `<p><strong>Summary:</strong> ${insightsData.summary}</p>` : ''}
      ${insightsData.selfCareRecommendations ? `
        <p><strong>Self-care Suggestions:</strong></p>
        <ul>${insightsData.selfCareRecommendations.map(rec => `<li>${rec}</li>`).join('')}</ul>
      ` : ''}
      <small>Analyzed at: ${new Date().toLocaleTimeString()}</small>
    </div>
  `;
}

// Create insights container
function createInsightsContainer() {
  const container = document.createElement('div');
  container.id = 'insights-container';
  container.style.cssText = `
    margin: 20px 0;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    border-left: 4px solid #4f46e5;
  `;
  
  document.body.appendChild(container);
  return container;
}

// Make functions available globally
window.MindQuestApp = {
  handleJournalSubmit,
  handleChatSubmit,
  handleMoodAnalysis,
  showStatus,
  setupUI
};

console.log('MindQuestApp initialized');