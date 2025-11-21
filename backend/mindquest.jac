// MindQuest - Main Application File
// AI Mental-Wellbeing Companion using Jaseci

// Import node and edge definitions
import {*} with "nodes.jac";
import {*} with "edges.jac";
import {*} with "walkers.jac";
import {*} with "./agents/analyzer.jac";
import {*} with "./agents/insights.jac";
import {*} with "./agents/companion.jac";

// Main graph structure
graph mindquest {
    has anchor mindquest_root;
}

// API Walkers - Exposed endpoints for frontend
walker api_log_mood {
    has user_id, emotion_name, intensity, notes = "", mood_category;
    root {
        spawn here walker::log_mood(
            user_id=user_id,
            emotion_name=emotion_name,
            intensity=intensity,
            notes=notes,
            mood_category=mood_category
        );
        report here;
    }
}

walker api_get_emotions {
    has user_id, days = 7;
    root {
        spawn here walker::get_user_emotions(user_id=user_id, days=days);
        report here;
    }
}

walker api_log_activity {
    has user_id, activity_name, category, duration, effectiveness_rating;
    root {
        spawn here walker::log_activity(
            user_id=user_id,
            activity_name=activity_name,
            category=category,
            duration=duration,
            effectiveness_rating=effectiveness_rating
        );
        report here;
    }
}

walker api_create_journal {
    has user_id, content, entry_type = "freeform", emotional_tags = "[]";
    root {
        spawn here walker::create_journal_entry(
            user_id=user_id,
            content=content,
            entry_type=entry_type,
            emotional_tags=emotional_tags
        );
        report here;
    }
}

walker api_get_insights {
    has user_id;
    root {
        // Run analyzer to detect patterns
        spawn here walker::mood_pattern_analyzer(user_id=user_id, time_period="weekly");
        // Generate insights from patterns
        spawn here walker::insight_generator(user_id=user_id);
        report here;
    }
}

walker api_analyze_patterns {
    has user_id, time_period = "weekly";
    root {
        spawn here walker::mood_pattern_analyzer(user_id=user_id, time_period=time_period);
        spawn here walker::correlation_analyzer(user_id=user_id);
        spawn here walker::trend_detector(user_id=user_id);
        report here;
    }
}

walker api_get_support {
    has user_id, support_request;
    root {
        spawn here walker::personalized_support(
            user_id=user_id,
            support_request=support_request
        );
        report here;
    }
}

walker api_get_suggestions {
    has user_id, suggestion_type = "all";
    has suggestions = [];
    
    root {
        take --> node::user;
    }
    
    with entry {
        take --> node::suggestion;
    }
    
    suggestion {
        if (suggestion_type == "all" || suggestion_type == suggestion_type) {
            if (edge.type == "suggestion_for_user" && edge.status == "pending") {
                suggestions += [{
                    "id": id,
                    "title": title,
                    "content": content,
                    "type": suggestion_type,
                    "priority": priority,
                    "generated_at": generated_at
                }];
            }
        }
        take -->;
    }
    
    user {
        report suggestions;
    }
}

walker api_get_emotion_summary {
    has user_id, days = 7;
    has summary = {};
    
    root {
        spawn here walker::get_emotion_history(user_id=user_id);
        take --> node::user;
    }
    
    with entry {
        take --> node::emotion;
    }
    
    emotion {
        cutoff_time = std.time_now() - (days * 86400);
        if (std.time_from_epoch(timestamp) >= cutoff_time) {
            if (!summary.has_key(mood_category)) {
                summary[mood_category] = [];
            }
            summary[mood_category] += [{
                "name": name,
                "intensity": intensity,
                "timestamp": timestamp
            }];
        }
        take -->;
    }
    
    user {
        // Calculate summary statistics
        summary_stats = {
            "total_entries": 0,
            "average_intensity": 0,
            "dominant_category": "neutral",
            "time_range_days": days
        };
        
        total_intensity = 0;
        total_count = 0;
        category_counts = {};
        
        for category, entries in summary {
            total_count += entries.length;
            for entry in entries {
                total_intensity += entry.intensity;
            }
            category_counts[category] = entries.length;
        }
        
        if (total_count > 0) {
            summary_stats["total_entries"] = total_count;
            summary_stats["average_intensity"] = total_intensity / total_count;
            
            // Find dominant category
            max_count = 0;
            for category, count in category_counts {
                if (count > max_count) {
                    max_count = count;
                    summary_stats["dominant_category"] = category;
                }
            }
        }
        
        summary["statistics"] = summary_stats;
        report summary;
    }
}

// Initialize walker
walker init {
    root {
        spawn here --> graph::mindquest;
        std.out("=== MindQuest ===");
        std.out("AI Mental-Wellbeing Companion");
        std.out("Initialized successfully!");
    }
}

// Development/Testing walkers
walker test_create_user {
    has name = "Test User", email = "test@mindquest.com";
    root {
        spawn here walker::create_user(name=name, email=email, preferences="{}");
        report here;
    }
}

walker test_full_flow {
    has user_id;
    root {
        std.out("Testing full flow for user: " + user_id);
        
        // 1. Log a mood
        spawn here walker::log_mood(
            user_id=user_id,
            emotion_name="anxious",
            intensity=7,
            mood_category="negative",
            notes="Feeling overwhelmed with work"
        );
        
        // 2. Analyze patterns
        spawn here walker::mood_pattern_analyzer(user_id=user_id);
        
        // 3. Generate insights
        spawn here walker::insight_generator(user_id=user_id);
        
        // 4. Get support
        spawn here walker::personalized_support(
            user_id=user_id,
            support_request="I'm feeling really anxious about my upcoming deadline"
        );
        
        std.out("Test flow completed");
        report here;
    }
}

