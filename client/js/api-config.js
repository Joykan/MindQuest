// MindQuest API Configuration
window.MindQuestAPI = {
  // Backend URL - check localStorage or use default
  backendUrl: localStorage.getItem('MQ_BACKEND_URL') || 'http://localhost:5000',
  
  // Test connection
  async testConnection() {
    try {
      const response = await fetch(this.backendUrl + '/health');
      const data = await response.json();
      console.log('✅ Backend connected:', data);
      return { connected: true, data };
    } catch (error) {
      console.error('❌ Backend connection failed:', error);
      return { connected: false, error: error.message };
    }
  },
  
  // API methods
  async chat(message, context = 'general') {
    const response = await fetch(`${this.backendUrl}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message, context })
    });
    return response.json();
  },
  
  async createJournal(journalData) {
    const response = await fetch(`${this.backendUrl}/api/create_journal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(journalData)
    });
    return response.json();
  },
  
  async getInsights(journalText) {
    const response = await fetch(`${this.backendUrl}/api/get_insights`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ journalText })
    });
    return response.json();
  },
  
  async analyzeMood(text) {
    const response = await fetch(`${this.backendUrl}/api/analyze_mood`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text })
    });
    return response.json();
  }
};

console.log('MindQuest API configured. Backend:', window.MindQuestAPI.backendUrl);

// Auto-test on load
if (typeof window !== 'undefined') {
  window.addEventListener('DOMContentLoaded', () => {
    window.MindQuestAPI.testConnection();
  });
}