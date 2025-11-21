// MindQuest - Core Walkers
// Basic walkers for mood logging, graph traversal, and data management

walker init {
    root {
        spawn here --> graph::empty;
        std.out("MindQuest initialized");
    }
}

walker create_user {
    has name, email, preferences = "{}";
    
    root {
        user_node = spawn here --> node::user(
            name=name,
            email=email,
            preferences=preferences,
            created_at=std.time_now()
        );
        std.out("User created: " + user_node.name);
        take --> user_node;
    }
}

walker log_mood {
    has user_id, emotion_name, intensity, notes = "", mood_category;
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            emotion_node = spawn here --> node::emotion(
                name=emotion_name,
                intensity=intensity,
                timestamp=std.time_now(),
                notes=notes,
                mood_category=mood_category
            );
            spawn user_node --> edge::user_has_emotion(recorded_at=std.time_now()) --> emotion_node;
            std.out("Mood logged: " + emotion_name + " (intensity: " + intensity + ")");
            take --> emotion_node;
        }
    }
}

walker get_user_emotions {
    has user_id, days = 7;
    has emotions = [];
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            take --> user_node;
        }
    }
    
    with entry {
        take --> node::emotion;
    }
    
    emotion {
        cutoff_time = std.time_now() - (days * 86400); // days to seconds
        if (std.time_from_epoch(timestamp) >= cutoff_time) {
            emotions += [{
                "name": name,
                "intensity": intensity,
                "timestamp": timestamp,
                "mood_category": mood_category,
                "notes": notes
            }];
        }
        take -->;
    }
}

walker update_trigger {
    has user_id, trigger_name, category, impact_score;
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            // Find or create trigger
            trigger_node = spawn here --> node::trigger(
                name=trigger_name,
                category=category,
                impact_score=impact_score,
                frequency=1
            );
            take --> trigger_node;
        }
    }
}

walker log_activity {
    has user_id, activity_name, category, duration, effectiveness_rating;
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            activity_node = spawn here --> node::activity(
                name=activity_name,
                category=category,
                duration=duration,
                effectiveness_score=effectiveness_rating
            );
            spawn user_node --> edge::user_has_activity(
                performed_at=std.time_now(),
                effectiveness_rating=effectiveness_rating
            ) --> activity_node;
            std.out("Activity logged: " + activity_name);
            take --> activity_node;
        }
    }
}

walker create_journal_entry {
    has user_id, content, entry_type = "freeform", emotional_tags = "[]";
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            word_count = std.length(std.split(content, " "));
            entry_node = spawn here --> node::journal_entry(
                content=content,
                timestamp=std.time_now(),
                entry_type=entry_type,
                emotional_tags=emotional_tags,
                word_count=word_count
            );
            spawn user_node --> edge::user_has_journal_entry(
                created_at=std.time_now(),
                privacy_level="private"
            ) --> entry_node;
            std.out("Journal entry created: " + word_count + " words");
            take --> entry_node;
        }
    }
}

walker get_emotion_history {
    has user_id;
    has history = [];
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            take --> user_node;
        }
    }
    
    with entry {
        take --> node::emotion;
    }
    
    emotion {
        history += [{
            "id": id,
            "name": name,
            "intensity": intensity,
            "timestamp": timestamp,
            "mood_category": mood_category
        }];
        take -->;
    }
}

