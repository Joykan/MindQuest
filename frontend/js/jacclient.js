// Jac Client - Wrapper for Jaseci API calls using Spawn()
// This file provides a client interface to interact with Jaseci backend walkers

class JacClient {
    constructor(baseUrl = 'http://localhost:8000') {
        this.baseUrl = baseUrl;
        this.graphId = null;
        this.userId = null;
    }

    // Initialize connection and get graph ID
    async init() {
        try {
            // Connect to Jaseci API
            const response = await fetch(`${this.baseUrl}/js/walker_run`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `token ${this.getToken()}`
                },
                body: JSON.stringify({
                    name: 'init',
                    ctx: {},
                    nd: 'root'
                })
            });

            const data = await response.json();
            if (data.report && data.report.length > 0) {
                this.graphId = data.report[0].jid || data.report[0].id;
                return { success: true, graphId: this.graphId };
            }
            return { success: false, error: 'Failed to initialize' };
        } catch (error) {
            console.error('Init error:', error);
            return { success: false, error: error.message };
        }
    }

    // Spawn a walker (core Jac Client functionality)
    async spawn(walkerName, context = {}) {
        try {
            const response = await fetch(`${this.baseUrl}/js/walker_run`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `token ${this.getToken()}`
                },
                body: JSON.stringify({
                    name: walkerName,
                    ctx: context,
                    nd: this.graphId || 'root',
                    snt: 'active:graph'
                })
            });

            const data = await response.json();
            return {
                success: true,
                report: data.report || [],
                final_node: data.final_node
            };
        } catch (error) {
            console.error(`Spawn error for ${walkerName}:`, error);
            return { success: false, error: error.message };
        }
    }

    // Create user
    async createUser(name, email, preferences = {}) {
        const result = await this.spawn('api_create_user', {
            name: name,
            email: email,
            preferences: JSON.stringify(preferences)
        });

        if (result.success && result.report.length > 0) {
            this.userId = result.report[0].jid || result.report[0].id;
            return { success: true, userId: this.userId, user: result.report[0] };
        }
        return { success: false, error: 'Failed to create user' };
    }

    // Log mood using Spawn()
    async logMood(emotionName, intensity, notes = '', moodCategory) {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_log_mood', {
            user_id: this.userId,
            emotion_name: emotionName,
            intensity: intensity,
            notes: notes,
            mood_category: moodCategory
        });
    }

    // Get emotion history
    async getEmotions(days = 7) {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_get_emotions', {
            user_id: this.userId,
            days: days
        });
    }

    // Log activity
    async logActivity(activityName, category, duration, effectivenessRating) {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_log_activity', {
            user_id: this.userId,
            activity_name: activityName,
            category: category,
            duration: duration,
            effectiveness_rating: effectivenessRating
        });
    }

    // Create journal entry
    async createJournalEntry(content, entryType = 'freeform', emotionalTags = []) {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_create_journal', {
            user_id: this.userId,
            content: content,
            entry_type: entryType,
            emotional_tags: JSON.stringify(emotionalTags)
        });
    }

    // Get insights
    async getInsights() {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_get_insights', {
            user_id: this.userId
        });
    }

    // Analyze patterns
    async analyzePatterns(timePeriod = 'weekly') {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_analyze_patterns', {
            user_id: this.userId,
            time_period: timePeriod
        });
    }

    // Get support and suggestions
    async getSupport(supportRequest) {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_get_support', {
            user_id: this.userId,
            support_request: supportRequest
        });
    }

    // Get suggestions
    async getSuggestions(suggestionType = 'all') {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_get_suggestions', {
            user_id: this.userId,
            suggestion_type: suggestionType
        });
    }

    // Get emotion summary
    async getEmotionSummary(days = 7) {
        if (!this.userId) {
            return { success: false, error: 'User not created' };
        }

        return await this.spawn('api_get_emotion_summary', {
            user_id: this.userId,
            days: days
        });
    }

    // Get or create token (for demo purposes)
    getToken() {
        let token = localStorage.getItem('jaseci_token');
        if (!token) {
            // In production, this should be obtained through proper authentication
            token = 'demo_token';
            localStorage.setItem('jaseci_token', token);
        }
        return token;
    }

    // Set user ID
    setUserId(userId) {
        this.userId = userId;
        localStorage.setItem('mindquest_user_id', userId);
    }

    // Get saved user ID
    getUserId() {
        if (!this.userId) {
            this.userId = localStorage.getItem('mindquest_user_id');
        }
        return this.userId;
    }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = JacClient;
}

