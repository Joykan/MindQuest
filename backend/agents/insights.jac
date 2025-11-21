// MindQuest - Insights Agent
// Generates actionable insights from analyzed patterns

walker insight_generator {
    has user_id;
    has insights = [];
    
    can generate_personalized_insights with entry {
        // Generate insights based on mood patterns and correlations
        std.out("Generating insights for user: " + user_id);
        
        take --> node::user;
    }
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            take --> user_node;
        }
    }
    
    with entry {
        take --> node::mood_pattern;
    }
    
    mood_pattern {
        // Generate insight based on pattern
        insight_prompt = """
        Based on this mood pattern analysis, generate a personalized insight:
        Pattern Type: """ + pattern_type + """
        Description: """ + description + """
        Confidence: """ + confidence_score + """
        
        Provide:
        1. A clear, empathetic insight about what this pattern means
        2. Actionable recommendations
        3. Contextual understanding
        """;
        
        insight_result = byllm.complete(
            prompt=insight_prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.4
        );
        
        insights += [{
            "type": "pattern_insight",
            "pattern_type": pattern_type,
            "insight": insight_result.insight,
            "recommendations": insight_result.recommendations,
            "confidence": confidence_score
        }];
        
        take -->;
    }
    
    user {
        // Generate summary insight
        if (insights.length > 0) {
            summary_prompt = """
            Synthesize these insights into a cohesive understanding:
            """ + std.to_json(insights) + """
            
            Provide a summary that:
            1. Highlights key patterns
            2. Offers personalized understanding
            3. Suggests next steps
            """;
            
            summary_insight = byllm.complete(
                prompt=summary_prompt,
                model="meta-llama/llama-2-7b-chat-hf",
                temperature=0.4
            );
            
            insights += [{
                "type": "summary",
                "content": summary_insight
            }];
            
            std.out("Insights generated: " + insights.length + " insights");
        }
    }
}

walker activity_effectiveness_insight {
    has user_id;
    has activity_insights = [];
    
    can analyze_activity_effectiveness with entry {
        // Analyze which activities are most effective for the user
        take --> node::user;
    }
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            take --> user_node;
        }
    }
    
    with entry {
        take --> node::activity;
    }
    
    activity {
        // Analyze activity effectiveness
        take --> node::emotion;
    }
    
    emotion {
        // Use byLLM to determine activity impact
        activity_prompt = """
        Analyze the effectiveness of this activity on emotional state:
        Activity: """ + activity.name + """
        Activity Category: """ + activity.category + """
        Emotion After: """ + here.name + """
        
        Determine:
        1. Effectiveness rating (0-1)
        2. Impact type (positive/negative/neutral)
        3. Consistency score
        """;
        
        effectiveness_analysis = byllm.complete(
            prompt=activity_prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.3
        );
        
        // Update edge
        if (!has_edge(edge::activity_impacts_emotion)) {
            spawn activity --> edge::activity_impacts_emotion(
                impact_strength=effectiveness_analysis.effectiveness,
                effect_type=effectiveness_analysis.impact_type,
                consistency_score=effectiveness_analysis.consistency
            ) --> here;
        }
        
        activity_insights += [effectiveness_analysis];
    }
    
    user {
        // Generate activity recommendations
        if (activity_insights.length > 0) {
            recommendation_prompt = """
            Based on these activity effectiveness analyses, recommend:
            """ + std.to_json(activity_insights) + """
            
            1. Top 3 most effective activities
            2. When to use each activity
            3. Activity combinations that work well
            """;
            
            recommendations = byllm.complete(
                prompt=recommendation_prompt,
                model="meta-llama/llama-2-7b-chat-hf",
                temperature=0.4
            );
            
            activity_insights += [{
                "recommendations": recommendations
            }];
        }
    }
}

walker trigger_identification_insight {
    has user_id;
    has trigger_insights = [];
    
    can identify_pattern_triggers with entry {
        // Identify common triggers from emotional patterns
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
        take --> node::trigger;
    }
    
    trigger {
        // Analyze trigger-emotion relationship
        trigger_prompt = """
        Analyze this trigger-emotion relationship:
        Trigger: """ + name + """
        Category: """ + category + """
        Impact Score: """ + impact_score + """
        
        Provide:
        1. Trigger strength assessment
        2. Coping strategies
        3. Early warning signs
        """;
        
        trigger_analysis = byllm.complete(
            prompt=trigger_prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.3
        );
        
        trigger_insights += [{
            "trigger": name,
            "analysis": trigger_analysis,
            "impact": impact_score
        }];
    }
    
    user {
        if (trigger_insights.length > 0) {
            std.out("Trigger insights generated: " + trigger_insights.length);
        }
    }
}

