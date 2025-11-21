// MindQuest - Companion Agent
// Provides empathetic responses and suggestions using byLLM

walker empathetic_response {
    has user_id, emotional_input, input_type = "text";
    has response;
    has suggestions = [];
    
    can generate_empathetic_response with entry {
        // Generate empathetic, supportive response to user's emotional input
        std.out("Generating empathetic response for user: " + user_id);
        
        // Get user's recent emotional context
        take --> node::user;
    }
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            take --> user_node;
        }
    }
    
    with entry {
        // Collect recent emotions for context
        take --> node::emotion;
    }
    
    emotion {
        // Get last 5 emotions for context
        if (std.length(emotions_context) < 5) {
            emotions_context += [{
                "name": name,
                "intensity": intensity,
                "timestamp": timestamp
            }];
        }
        take -->;
    }
    
    user {
        emotions_context = [];
        take --> node::emotion;
    }
    
    user {
        // Generate empathetic response using byLLM
        empathy_prompt = """
        You are a compassionate mental wellbeing companion. Respond empathetically to this user input:
        
        User Input: """ + emotional_input + """
        Input Type: """ + input_type + """
        Recent Emotional Context: """ + std.to_json(emotions_context) + """
        
        Provide:
        1. A warm, empathetic response that acknowledges their feelings
        2. Validation of their emotions
        3. Gentle encouragement
        4. A specific, actionable suggestion if appropriate
        
        Be genuine, supportive, and non-judgmental.
        """;
        
        empathy_response = byllm.complete(
            prompt=empathy_prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.7,
            max_tokens=300
        );
        
        response = empathy_response.content;
        
        // Generate suggestions
        if (empathy_response.suggestion) {
            suggestion_node = spawn here --> node::suggestion(
                title=empathy_response.suggestion.title,
                content=empathy_response.suggestion.content,
                suggestion_type=empathy_response.suggestion.type,
                priority=empathy_response.suggestion.priority,
                generated_at=std.time_now(),
                context=std.to_json({"input": emotional_input, "input_type": input_type})
            );
            
            spawn user_node --> edge::suggestion_for_user(
                suggested_at=std.time_now(),
                status="pending"
            ) --> suggestion_node;
            
            suggestions += [suggestion_node];
        }
        
        std.out("Empathetic response generated");
    }
}

walker breathing_exercise_suggestion {
    has user_id, current_emotion;
    has exercise_suggestion;
    
    can suggest_breathing_exercise with entry {
        // Generate personalized breathing exercise suggestion
        take --> node::user;
    }
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            // Generate breathing exercise
            breathing_prompt = """
            Suggest a personalized breathing exercise for someone experiencing: """ + current_emotion + """
            
            Provide:
            1. Exercise name
            2. Step-by-step instructions
            3. Duration
            4. Why this exercise is suitable
            """;
            
            exercise = byllm.complete(
                prompt=breathing_prompt,
                model="meta-llama/llama-2-7b-chat-hf",
                temperature=0.5
            );
            
            suggestion_node = spawn here --> node::suggestion(
                title=exercise.name,
                content=exercise.instructions,
                suggestion_type="breathing",
                priority="high",
                generated_at=std.time_now(),
                context=std.to_json({"trigger_emotion": current_emotion})
            );
            
            spawn user_node --> edge::suggestion_for_user(
                suggested_at=std.time_now(),
                status="pending"
            ) --> suggestion_node;
            
            exercise_suggestion = exercise;
            std.out("Breathing exercise suggested: " + exercise.name);
        }
    }
}

walker journaling_prompt_generator {
    has user_id, emotional_state;
    has journaling_prompts = [];
    
    can generate_journaling_prompts with entry {
        // Generate reflective journaling prompts based on emotional state
        take --> node::user;
    }
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            // Generate journaling prompts
            prompt_generation = """
            Generate 3 reflective journaling prompts for someone feeling: """ + emotional_state + """
            
            Prompts should:
            1. Encourage self-reflection
            2. Be non-judgmental
            3. Help process emotions
            4. Be specific to the emotional state
            
            Return as JSON array of prompts.
            """;
            
            prompts_result = byllm.complete(
                prompt=prompt_generation,
                model="meta-llama/llama-2-7b-chat-hf",
                temperature=0.6
            );
            
            // Create suggestions for each prompt
            for prompt in prompts_result.prompts {
                suggestion_node = spawn here --> node::suggestion(
                    title="Journaling Prompt",
                    content=prompt,
                    suggestion_type="journaling",
                    priority="medium",
                    generated_at=std.time_now(),
                    context=std.to_json({"emotional_state": emotional_state})
                );
                
                spawn user_node --> edge::suggestion_for_user(
                    suggested_at=std.time_now(),
                    status="pending"
                ) --> suggestion_node;
                
                journaling_prompts += [prompt];
            }
            
            std.out("Journaling prompts generated: " + journaling_prompts.length);
        }
    }
}

walker activity_recommendation {
    has user_id, current_emotion, available_time = 30;
    has activity_recommendations = [];
    
    can recommend_activities with entry {
        // Recommend activities based on current emotional state and time available
        take --> node::user;
    }
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            // Get user's activity history for context
            take --> node::activity;
        }
    }
    
    with entry {
        take --> node::activity;
    }
    
    activity {
        // Collect effective activities
        activity_history += [{
            "name": name,
            "category": category,
            "effectiveness": effectiveness_score
        }];
        take -->;
    }
    
    user {
        activity_history = [];
        take --> node::activity;
    }
    
    user {
        // Generate activity recommendations
        activity_prompt = """
        Recommend activities for someone feeling: """ + current_emotion + """
        Available time: """ + available_time + """ minutes
        Previous effective activities: """ + std.to_json(activity_history) + """
        
        Provide:
        1. 3 activity recommendations
        2. Why each activity is suitable
        3. Expected time and effort
        4. Expected emotional benefit
        """;
        
        recommendations = byllm.complete(
            prompt=activity_prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.5
        );
        
        // Create suggestions
        for activity_rec in recommendations.activities {
            suggestion_node = spawn here --> node::suggestion(
                title=activity_rec.name,
                content=activity_rec.description + "\nTime: " + activity_rec.time + " minutes",
                suggestion_type="activity",
                priority=activity_rec.priority,
                generated_at=std.time_now(),
                context=std.to_json({
                    "current_emotion": current_emotion,
                    "expected_benefit": activity_rec.benefit
                })
            );
            
            spawn user_node --> edge::suggestion_for_user(
                suggested_at=std.time_now(),
                status="pending"
            ) --> suggestion_node;
            
            activity_recommendations += [activity_rec];
        }
        
        std.out("Activities recommended: " + activity_recommendations.length);
    }
}

walker personalized_support {
    has user_id, support_request;
    has support_response;
    
    can provide_personalized_support with entry {
        // Comprehensive support response combining empathy, suggestions, and insights
        std.out("Providing personalized support for user: " + user_id);
        
        // First, get empathetic response
        spawn here walker::empathetic_response(
            user_id=user_id,
            emotional_input=support_request,
            input_type="text"
        );
        
        // Get user's current emotional state
        take --> node::user;
    }
    
    root {
        user_node = spawn here --> node::user;
        if (user_node.id == user_id) {
            take --> user_node;
        }
    }
    
    with entry {
        // Get most recent emotion
        take --> node::emotion;
    }
    
    emotion {
        // Get latest emotion
        if (latest_emotion == null || timestamp > latest_emotion.timestamp) {
            latest_emotion = {
                "name": name,
                "intensity": intensity,
                "category": mood_category
            };
        }
        take -->;
    }
    
    user {
        latest_emotion = null;
        take --> node::emotion;
    }
    
    user {
        // Generate comprehensive support
        if (latest_emotion != null) {
            // Generate breathing exercise if needed
            if (latest_emotion.category == "negative" && latest_emotion.intensity > 6) {
                spawn here walker::breathing_exercise_suggestion(
                    user_id=user_id,
                    current_emotion=latest_emotion.name
                );
            }
            
            // Generate journaling prompts
            spawn here walker::journaling_prompt_generator(
                user_id=user_id,
                emotional_state=latest_emotion.name
            );
            
            // Recommend activities
            spawn here walker::activity_recommendation(
                user_id=user_id,
                current_emotion=latest_emotion.name,
                available_time=30
            );
        }
        
        support_response = {
            "empathetic_response": response,
            "emotion_context": latest_emotion,
            "suggestions_generated": true
        };
        
        std.out("Personalized support provided");
    }
}

