// MindQuest - Edge Definitions
// Relationship types between nodes in the OSP graph

edge user_has_emotion {
    has recorded_at;
    has context; // additional context about this recording
}

edge emotion_has_trigger {
    has correlation_strength; // 0-1 how strong the correlation
    has frequency; // how often this trigger leads to this emotion
    has first_observed;
}

edge emotion_links_to_emotion {
    has transition_probability; // 0-1 likelihood of transitioning
    has time_gap; // typical time between emotions in minutes
    has observed_count; // how many times this transition was observed
}

edge activity_impacts_emotion {
    has impact_strength; // 0-1 how much the activity affects the emotion
    has effect_type; // "positive", "negative", "neutral"
    has consistency_score; // 0-1 how consistently this effect occurs
}

edge trigger_influences_emotion {
    has influence_strength; // 0-1 strength of influence
    has direction; // "positive" or "negative"
    has reliability; // 0-1 how reliable this influence is
}

edge user_has_activity {
    has performed_at;
    has effectiveness_rating; // user's rating 1-10
    has notes; // user notes about the activity
}

edge user_has_journal_entry {
    has created_at;
    has privacy_level; // "private", "shared"
}

edge suggestion_for_user {
    has suggested_at;
    has status; // "pending", "completed", "dismissed"
    has feedback; // user feedback on the suggestion
}

edge user_has_pattern {
    has discovered_at;
    has relevance_score; // 0-1 how relevant this pattern is
    has action_taken; // what user did with this pattern info
}

edge emotion_triggers_suggestion {
    has trigger_condition; // condition that triggered this suggestion
    has suggested_at;
    has applied; // whether user applied the suggestion
}

// Graph traversal helper edges
edge follows {
    has sequence_order;
}

edge correlates_with {
    has correlation_coefficient; // -1 to 1
    has evidence_count; // number of observations
}

