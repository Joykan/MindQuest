// MindQuest - Node Definitions
// OSP Graph structure for mental wellbeing companion

node user {
    has name;
    has email;
    has created_at;
    has preferences; // JSON string for user preferences
    
    // User profile information
    can initialize with name, email, preferences;
}

node emotion {
    has name; // e.g., "happy", "anxious", "calm", "sad", "frustrated"
    has intensity; // 1-10 scale
    has timestamp;
    has notes; // optional text notes from user
    has mood_category; // "positive", "negative", "neutral"
    
    // Emotional state data
    can initialize with name, intensity, timestamp, notes, mood_category;
}

node trigger {
    has name; // e.g., "work stress", "social interaction", "exercise"
    has category; // "environmental", "social", "physical", "thought"
    has frequency; // how often it occurs
    has impact_score; // 1-10 how much it affects mood
    
    // Trigger identification
    can initialize with name, category, frequency, impact_score;
}

node activity {
    has name; // e.g., "meditation", "exercise", "reading", "socializing"
    has category; // "self_care", "social", "physical", "creative", "mindfulness"
    has duration; // in minutes
    has effectiveness_score; // 1-10 how effective for mood improvement
    
    // Activity tracking
    can initialize with name, category, duration, effectiveness_score;
}

node suggestion {
    has title;
    has content; // suggestion text
    has suggestion_type; // "breathing", "journaling", "activity", "reflection"
    has priority; // "high", "medium", "low"
    has generated_at;
    has context; // JSON string for suggestion context
    
    // AI-generated suggestions
    can initialize with title, content, suggestion_type, priority, generated_at, context;
}

node journal_entry {
    has content; // journal text
    has timestamp;
    has entry_type; // "freeform", "prompted", "reflection"
    has emotional_tags; // JSON array of emotion names
    has word_count;
    
    // Journal entries
    can initialize with content, timestamp, entry_type, emotional_tags, word_count;
}

node mood_pattern {
    has pattern_type; // "trending_up", "trending_down", "cyclical", "stable"
    has time_period; // "daily", "weekly", "monthly"
    has detected_at;
    has confidence_score; // 0-1 how confident the pattern detection is
    has description; // text description of the pattern
    
    // Pattern analysis results
    can initialize with pattern_type, time_period, detected_at, confidence_score, description;
}

