// MindQuest API Configuration - With SHORTER responses
window.MindQuestAPI = {
    backendUrl: localStorage.getItem('MQ_BACKEND_URL') || 'http://localhost:5000',
    
    async testConnection() {
        try {
            const response = await fetch(this.backendUrl + '/health');
            const data = await response.json();
            console.log('✓ Backend connected');
            return { connected: true, data };
        } catch (error) {
            console.error('✗ Backend connection failed:', error);
            return { connected: false, error: error.message };
        }
    },
    
    async chat(message, context = 'general') {
        const response = await fetch(`${this.backendUrl}/api/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                message, 
                context,
                // ADD THIS to request shorter responses
                responseLength: 'short',
                maxTokens: 150  // Limit response length
            })
        });
        const data = await response.json();
        
        // Truncate response if it's too long
        if (data.response && data.response.length > 200) {
            data.response = data.response.substring(0, 200) + '...';
        }
        
        return data;
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
            body: JSON.stringify({ 
                journalText,
                // Request concise insights
                concise: true,
                format: 'bulletpoints'
            })
        });
        const data = await response.json();
        
        // Simplify insights if they're too verbose
        if (data.insights && data.insights.summary && data.insights.summary.length > 100) {
            data.insights.summary = data.insights.summary.substring(0, 100) + '...';
        }
        
        return data;
    },
    
    async analyzeMood(text) {
        const response = await fetch(`${this.backendUrl}/api/analyze_mood`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                text,
                concise: true  // Request short analysis
            })
        });
        return response.json();
    }
};

console.log('MindQuest API ready');