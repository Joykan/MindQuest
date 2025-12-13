import { Router } from "express";
import { GoogleGenAI } from "@google/genai";
import dotenv from 'dotenv';

dotenv.config();

const router = Router();

// Initialize Gemini AI
let ai;
try {
  ai = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY
  });
} catch (error) {
  console.error('Chat: Gemini init error:', error.message);
  ai = null;
}

// In-memory conversation storage (use database in production)
const conversationHistory = new Map();
const MAX_HISTORY_LENGTH = 20;

// Get or create conversation history
const getConversationHistory = (userId) => {
  if (!conversationHistory.has(userId)) {
    conversationHistory.set(userId, []);
  }
  return conversationHistory.get(userId);
};

// Limit history length
const limitHistory = (history, max = MAX_HISTORY_LENGTH) => {
  return history.length > max ? history.slice(-max) : history;
};

// Main chat endpoint
router.post("/", async (req, res) => {
  try {
    const { message, userId = "anonymous", context = "general" } = req.body;

    // Input validation
    if (!message || typeof message !== 'string') {
      return res.status(400).json({
        success: false,
        error: "Message is required and must be a string"
      });
    }
    
    if (message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: "Message cannot be empty"
      });
    }
    
    if (message.length > 2000) {
      return res.status(400).json({
        success: false,
        error: "Message too long (max 2000 characters)"
      });
    }

    // Get conversation history
    const history = getConversationHistory(userId);
    
    // Context-based system prompt
    const systemPrompts = {
      therapy: "You are a compassionate, empathetic AI assistant trained in therapeutic techniques. Provide supportive, non-judgmental responses that help with emotional processing. Focus on active listening, validation, and gentle guidance. Never give medical advice.",
      coaching: "You are a motivational life coach AI assistant. Help users set goals, overcome obstacles, and build positive habits. Use encouraging language and practical strategies.",
      journaling: "You are a reflective journaling assistant. Help users explore their thoughts and feelings through guided questions and insights. Focus on self-discovery and personal growth.",
      general: "You are MindQuest AI, a helpful and supportive assistant focused on mental wellness and personal growth. Be kind, thoughtful, and provide useful insights."
    };
    
    const systemPrompt = systemPrompts[context] || systemPrompts.general;

    // Build conversation context
    const conversationContext = [
      { role: "user", parts: [{ text: systemPrompt }] },
      ...history.slice(-10).map(msg => ({
        role: msg.role,
        parts: [{ text: msg.text }]
      })),
      { role: "user", parts: [{ text: message }] }
    ];

    let aiResponse;
    
    // Use mock response if AI not available
    if (!ai || process.env.USE_MOCK_AI === 'true') {
      console.log('📝 Using mock chat response');
      const mockResponses = {
        therapy: "I hear you're sharing something important. That sounds challenging. Would you like to explore this feeling further?",
        coaching: "That's an interesting goal! What's one small step you could take toward that today?",
        journaling: "Thank you for sharing that reflection. What aspect of this feels most significant to you right now?",
        general: "Thanks for your message. I'm here to support your mental wellness journey. How can I help you today?"
      };
      aiResponse = mockResponses[context] || mockResponses.general;
    } else {
      // Real AI call
      const response = await ai.models.generateContent({
        model: "gemini-2.0-flash-exp",
        contents: conversationContext,
        generationConfig: {
          temperature: 0.7,
          topP: 0.8,
          topK: 40,
          maxOutputTokens: 1024,
        }
      });
      aiResponse = response.text;
    }

    // Update conversation history
    history.push({
      role: "user",
      text: message,
      timestamp: new Date().toISOString(),
      context
    });
    
    history.push({
      role: "model",
      text: aiResponse,
      timestamp: new Date().toISOString(),
      context
    });

    // Limit history
    conversationHistory.set(userId, limitHistory(history));

    res.json({
      success: true,
      response: aiResponse,
      context,
      historyLength: history.length,
      userId,
      timestamp: new Date().toISOString(),
      mock: process.env.USE_MOCK_AI === 'true'
    });

  } catch (error) {
    console.error("Chat error:", error);
    
    // Fallback responses
    const fallbackResponses = [
      "I'm having trouble processing that right now. Could you try rephrasing your question?",
      "I apologize for the technical difficulty. Let's try a different approach - tell me more about what's on your mind.",
      "It seems I'm experiencing a temporary issue. In the meantime, you might find it helpful to write down your thoughts in your journal."
    ];
    
    const randomFallback = fallbackResponses[Math.floor(Math.random() * fallbackResponses.length)];
    
    const statusCode = error.status === 429 ? 429 : 500;
    
    res.status(statusCode).json({
      success: false,
      error: "Failed to process chat message",
      fallbackResponse: randomFallback,
      details: process.env.NODE_ENV === 'development' ? error.message : undefined,
      timestamp: new Date().toISOString()
    });
  }
});

// Get conversation history
router.get("/history", (req, res) => {
  try {
    const { userId = "anonymous", limit = 20 } = req.query;
    const history = getConversationHistory(userId);
    
    res.json({
      success: true,
      userId,
      history: history.slice(-parseInt(limit)),
      messageCount: history.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: "Failed to retrieve chat history"
    });
  }
});

// Clear conversation history
router.delete("/history", (req, res) => {
  try {
    const { userId = "anonymous" } = req.body;
    
    if (conversationHistory.has(userId)) {
      conversationHistory.delete(userId);
    }
    
    res.json({
      success: true,
      message: `Chat history cleared for user: ${userId}`,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: "Failed to clear chat history"
    });
  }
});

// Mood analysis endpoint
router.post("/analyze-mood", async (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text || typeof text !== 'string') {
      return res.status(400).json({
        error: "Text is required for mood analysis"
      });
    }

    const prompt = `
      Analyze the emotional tone of this text and provide a mood assessment.
      
      Text: "${text.substring(0, 500)}"
      
      Return ONLY a JSON object with these exact fields:
      - primaryMood: string (choose from: happy, sad, anxious, neutral, excited, calm, angry, mixed)
      - confidence: number between 0 and 1
      - keywords: array of 3-5 emotional keywords found
      - intensity: string (low, medium, high)
      - suggestion: string (one brief, practical suggestion for emotional support)
    `;

    let moodAnalysis;
    
    if (!ai || process.env.USE_MOCK_AI === 'true') {
      // Mock analysis
      moodAnalysis = {
        primaryMood: "neutral",
        confidence: 0.5,
        keywords: ["neutral", "reflective"],
        intensity: "medium",
        suggestion: "Consider exploring these feelings further in your journal."
      };
    } else {
      const response = await ai.models.generateContent({
        model: "gemini-2.0-flash-exp",
        contents: prompt,
        generationConfig: {
          temperature: 0.3,
          maxOutputTokens: 256,
        }
      });

      const aiText = response.text;
      
      try {
        const jsonMatch = aiText.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          moodAnalysis = JSON.parse(jsonMatch[0]);
        } else {
          throw new Error('No JSON in response');
        }
      } catch (parseError) {
        moodAnalysis = {
          primaryMood: "neutral",
          confidence: 0.5,
          keywords: ["neutral"],
          intensity: "medium",
          suggestion: "Unable to analyze mood. Try describing your feelings in more detail."
        };
      }
    }

    res.json({
      success: true,
      analysis: moodAnalysis,
      textLength: text.length,
      timestamp: new Date().toISOString(),
      mock: process.env.USE_MOCK_AI === 'true'
    });

  } catch (error) {
    console.error("Mood analysis error:", error);
    res.status(500).json({
      success: false,
      error: "Failed to analyze mood",
      analysis: {
        primaryMood: "unknown",
        confidence: 0,
        keywords: [],
        intensity: "unknown",
        suggestion: "Service temporarily unavailable"
      }
    });
  }
});

export default router;