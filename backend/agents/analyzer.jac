// MindQuest - Analyzer Agent
// Analyzes mood patterns, correlations, and trends in user data

node analyzer_state {
    has analysis_type;
    has results;
    has confidence;
}

walker mood_pattern_analyzer {
    has user_id, time_period = "weekly";
    has patterns = [];
    has emotions_data = [];
    
    can analyze_trend with entry {
        // Analyze emotion trends over time
        std.out("Analyzing mood patterns for user: " + user_id);
        
        // Collect emotion data
        take --> node::user;
    }
    
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
        emotions_data += [{
            "name": name,
            "intensity": intensity,
            "timestamp": timestamp,
            "mood_category": mood_category
        }];
        take -->;
    }
    
    user {
        // Calculate trends using byLLM for pattern recognition
        emotions_json = std.to_json(emotions_data);
        prompt = """
        Analyze the following mood data and identify patterns:
        """ + emotions_json + """
        
        Identify:
        1. Overall trend (trending_up, trending_down, cyclical, stable)
        2. Pattern description
        3. Confidence score (0-1)
        4. Time period pattern
        """;
        
        analysis_result = byllm.complete(
            prompt=prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.3
        );
        
        // Parse and store pattern
        pattern_node = spawn here --> node::mood_pattern(
            pattern_type=analysis_result.pattern_type,
            time_period=time_period,
            detected_at=std.time_now(),
            confidence_score=analysis_result.confidence,
            description=analysis_result.description
        );
        
        spawn here --> edge::user_has_pattern(
            discovered_at=std.time_now(),
            relevance_score=analysis_result.confidence
        ) --> pattern_node;
        
        patterns += [analysis_result];
        std.out("Pattern detected: " + analysis_result.pattern_type);
    }
}

walker correlation_analyzer {
    has user_id;
    has correlations = [];
    
    can analyze_trigger_emotion_correlation with entry {
        // Analyze correlations between triggers and emotions
        std.out("Analyzing trigger-emotion correlations");
        
        take --> node::user;
    }
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            take --> user_node;
        }
    }
    
    with entry {
        take --> node::trigger;
    }
    
    trigger {
        take --> node::emotion;
    }
    
    emotion {
        // Use byLLM to analyze correlation strength
        correlation_prompt = """
        Based on the following data, determine the correlation strength (0-1) 
        between triggers and emotions:
        Trigger: """ + here.name + """
        Emotion: """ + here.name + """
        """;
        
        correlation_result = byllm.complete(
            prompt=correlation_prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.2
        );
        
        // Update edge with correlation data
        if (!has_edge(edge::trigger_influences_emotion)) {
            spawn here --> edge::trigger_influences_emotion(
                influence_strength=correlation_result.strength,
                direction=correlation_result.direction,
                reliability=correlation_result.reliability
            ) --> trigger;
        }
        
        correlations += [correlation_result];
    }
}

walker trend_detector {
    has user_id, lookback_days = 30;
    has trend_data = [];
    
    can detect_trending_patterns with entry {
        // Detect if emotions are trending up or down
        take --> node::user;
    }
    
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
        cutoff_time = std.time_now() - (lookback_days * 86400);
        if (std.time_from_epoch(timestamp) >= cutoff_time) {
            trend_data += [{
                "intensity": intensity,
                "timestamp": timestamp,
                "category": mood_category
            }];
        }
        take -->;
    }
    
    user {
        // Use byLLM to analyze trends
        trend_prompt = """
        Analyze these emotional intensity values over time and determine the trend:
        Data: """ + std.to_json(trend_data) + """
        
        Provide:
        1. Trend direction (up/down/stable/cyclical)
        2. Rate of change
        3. Key insights
        """;
        
        trend_analysis = byllm.complete(
            prompt=trend_prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.3
        );
        
        trend_data += [trend_analysis];
        std.out("Trend detected: " + trend_analysis.trend_direction);
    }
}

