// MindQuest - Streamlined Companion Agent
// AI Mental-Wellbeing Companion with Gamification

walker personalized_companion {
    has user_id, support_request = "", available_time = 30;
    has response = "", suggestions = [], emotion_context = {}, xp_earned = 0, badges = [];

    root {
        // 1️⃣ Get user node
        user_node = spawn here --> node::user;
        if user_node.id != user_id {
            std.out("User not found: " + user_id);
            report {};
        }
    }

    with entry {
        // 2️⃣ Collect recent emotions for context
        take --> node::emotion;
    }

    emotion {
        if std.length(emotion_context.recent_emotions) < 5 {
            if !emotion_context.recent_emotions {
                emotion_context.recent_emotions = [];
            }
            emotion_context.recent_emotions += [{
                "name": name,
                "intensity": intensity,
                "category": mood_category,
                "timestamp": timestamp
            }];
        }

        // Keep latest emotion for recommendations
        if !emotion_context.latest || timestamp > emotion_context.latest.timestamp {
            emotion_context.latest = {
                "name": name,
                "intensity": intensity,
                "category": mood_category,
                "timestamp": timestamp
            };
        }

        take -->;
    }

    user {
        // 3️⃣ Generate empathetic response
        empathy_prompt = """
        You are a compassionate mental wellbeing companion. Respond empathetically to this user input:
        User Input: """ + support_request + """
        Recent Emotional Context: """ + std.to_json(emotion_context.recent_emotions) + """

        Provide:
        1. A warm, empathetic response
        2. Validation of emotions
        3. Gentle encouragement
        4. Optional actionable suggestion
        """;

        empathy_result = byllm.complete(
            prompt=empathy_prompt,
            model="meta-llama/llama-2-7b-chat-hf",
            temperature=0.7,
            max_tokens=300
        );

        response = empathy_result.content;

        // 4️⃣ Generate suggestions if latest emotion exists
        if emotion_context.latest != null {
            latest = emotion_context.latest;

            // 🌀 Breathing Exercise
            if latest.category == "negative" && latest.intensity > 6 {
                exercise_prompt = """
                Suggest a personalized breathing exercise for someone feeling: """ + latest.name + """
                Provide: name, steps, duration, benefit
                """;

                exercise = byllm.complete(
                    prompt=exercise_prompt,
                    model="meta-llama/llama-2-7b-chat-hf",
                    temperature=0.5
                );

                suggestion_node = spawn here --> node::suggestion(
                    title=exercise.name,
                    content=exercise.steps + "\nDuration: " + exercise.duration,
                    suggestion_type="breathing",
                    priority="high",
                    generated_at=std.time_now()
                );

                spawn user_node --> edge::suggestion_for_user(
                    suggested_at=std.time_now(),
                    status="pending"
                ) --> suggestion_node;

                suggestions += [exercise];
                xp_earned += 10; // award XP
            }

            // 📝 Journaling Prompts
            journal_prompt = """
            Generate 3 reflective journaling prompts for someone feeling: """ + latest.name + """
            Return as JSON array.
            """;

            journal_result = byllm.complete(
                prompt=journal_prompt,
                model="meta-llama/llama-2-7b-chat-hf",
                temperature=0.6
            );

            for prompt in journal_result.prompts {
                suggestion_node = spawn here --> node::suggestion(
                    title="Journaling Prompt",
                    content=prompt,
                    suggestion_type="journaling",
                    priority="medium",
                    generated_at=std.time_now()
                );

                spawn user_node --> edge::suggestion_for_user(
                    suggested_at=std.time_now(),
                    status="pending"
                ) --> suggestion_node;

                suggestions += [prompt];
                xp_earned += 5;
            }

            // 🎯 Activity Recommendations
            activity_prompt = """
            Recommend 3 activities for someone feeling: """ + latest.name + """
            Available time: """ + available_time + """ minutes
            Provide: name, description, expected benefit
            """;

            activity_result = byllm.complete(
                prompt=activity_prompt,
                model="meta-llama/llama-2-7b-chat-hf",
                temperature=0.5
            );

            for act in activity_result.activities {
                suggestion_node = spawn here --> node::suggestion(
                    title=act.name,
                    content=act.description + "\nTime: " + act.time + " minutes",
                    suggestion_type="activity",
                    priority="medium",
                    generated_at=std.time_now()
                );

                spawn user_node --> edge::suggestion_for_user(
                    suggested_at=std.time_now(),
                    status="pending"
                ) --> suggestion_node;

                suggestions += [act];
                xp_earned += 5;
            }
        }

        // 5️⃣ Check for badges
        if user_node.xp + xp_earned >= 50 && !user_node.badges.has("Level 1 Achiever") {
            badges += ["Level 1 Achiever"];
            user_node.badges += ["Level 1 Achiever"];
        }

        // 6️⃣ Final response
        report {
            "empathetic_response": response,
            "emotion_context": emotion_context,
            "suggestions": suggestions,
            "xp_earned": xp_earned,
            "badges_awarded": badges
        };
    }
}