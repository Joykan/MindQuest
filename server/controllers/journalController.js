import { GoogleGenAI } from "@google/genai";
import dotenv from 'dotenv';

dotenv.config();

// Initialize Gemini AI
let ai;
try {
  ai = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY
  });
  console.log('✅ Gemini AI initialized');
} catch (error) {
  console.error('❌ Gemini initialization error:', error.message);
  ai = null;
}

// Helper function for fallback/mock insights
const generateFallbackInsights = (journalText) => {
  const text = journalText.toLowerCase();
  
  // Simple keyword analysis for fallback
  const emotionalKeywords = {
    positive: ['happy', 'good', 'great', 'excited', 'proud', 'love', 'joy'],
    negative: ['sad', 'bad', 'angry', 'anxious', 'stress', 'worry', 'fear'],
    neutral: ['okay', 'fine', 'normal', 'average', 'regular']
  };
  
  let emotionalTone = 'neutral';
  for (const [tone, keywords] of Object.entries(emotionalKeywords)) {
    if (keywords.some(keyword => text.includes(keyword))) {
      emotionalTone = tone;
      break;
    }
  }
  
  return {
    emotionalTone,
    keyThemes: extractKeyWords(text),
    cognitiveDistortions: [],
    reframingSuggestions: [
      "Practice gratitude by listing three things you're thankful for",
      "Try reframing negative thoughts with evidence-based thinking",
      "Consider discussing these feelings with a trusted friend"
    ],
    selfCareRecommendations: [
      "Get 7-8 hours of sleep tonight",
      "Take a 10-minute walk in nature",
      "Drink a glass of water and stretch"
    ],
    summary: `Analysis suggests ${emotionalTone} emotional tone. ${text.length > 50 ? 'Consider exploring this topic further in your journal.' : 'Try adding more details for deeper insights.'}`
  };
};

// Helper: Extract keywords from text
function extractKeyWords(text) {
  const commonWords = new Set(['the', 'and', 'but', 'for', 'with', 'that', 'this', 'have', 'was', 'were']);
  const words = text.toLowerCase().split(/\W+/);
  const wordCount = {};
  
  words.forEach(word => {
    if (word.length > 3 && !commonWords.has(word)) {
      wordCount[word] = (wordCount[word] || 0) + 1;
    }
  });
  
  return Object.entries(wordCount)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([word]) => word);
}

// Create Journal Entry
export const createJournal = async (req, res) => {
  try {
    const { text, mood, tags = [], userId = "default" } = req.body;
    
    if (!text || typeof text !== 'string') {
      return res.status(400).json({ 
        error: "Journal text is required and must be a string" 
      });
    }
    
    // Here you would save to MongoDB
    // Example: const journal = await Journal.create({ text, mood, tags, userId });
    
    res.status(201).json({ 
      status: "success", 
      message: "Journal saved successfully",
      data: { 
        text: text.substring(0, 100) + (text.length > 100 ? '...' : ''),
        mood,
        tags,
        userId,
        createdAt: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Journal creation error:', error);
    res.status(500).json({ 
      error: "Failed to save journal",
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get All Journals
export const getJournals = async (req, res) => {
  try {
    const { userId = "default", limit = 10 } = req.query;
    
    // Here you would fetch from MongoDB
    // Example: const journals = await Journal.find({ userId }).limit(parseInt(limit));
    
    res.json({ 
      status: "success", 
      data: [], // Replace with actual data from DB
      count: 0,
      userId,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Get journals error:', error);
    res.status(500).json({ 
      error: "Failed to fetch journals",
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get AI Insights
export const getInsights = async (req, res) => {
  try {
    const { journalText } = req.body;
    
    // Input validation
    if (!journalText || typeof journalText !== 'string') {
      return res.status(400).json({ 
        error: "Journal text is required and must be a string" 
      });
    }
    
    if (journalText.trim().length < 3) {
      return res.status(400).json({ 
        error: "Journal text must be at least 3 characters long" 
      });
    }
    
    // Use mock responses if configured
    if (process.env.USE_MOCK_AI === 'true') {
      console.log('📝 Using mock AI insights');
      const mockInsights = generateFallbackInsights(journalText);
      return res.json({
        status: "success",
        insights: mockInsights,
        mock: true,
        timestamp: new Date().toISOString()
      });
    }
    
    // Use real Gemini AI
    if (!ai) {
      throw new Error('Gemini AI not initialized. Check API key.');
    }
    
    const prompt = `
      Analyze this journal entry and provide psychological insights:
      
      "${journalText}"
      
      Please provide a JSON object with these exact fields:
      - emotionalTone: string (positive/negative/neutral/mixed)
      - keyThemes: array of 3-5 strings (main topics)
      - cognitiveDistortions: array of strings (if any, else empty)
      - reframingSuggestions: array of 3 strings (helpful reframes)
      - selfCareRecommendations: array of 3 strings (practical self-care)
      - summary: string (brief 1-2 sentence overall insight)
      
      Keep the response focused, empathetic, and clinically informed.
    `;
    
    const response = await ai.models.generateContent({
      model: "gemini-2.0-flash-exp",
      contents: prompt,
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 500,
      }
    });
    
    const aiText = response.text;
    let insights;
    
    try {
      // Try to extract JSON
      const jsonMatch = aiText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        insights = JSON.parse(jsonMatch[0]);
      } else {
        throw new Error('No JSON found in response');
      }
    } catch (parseError) {
      console.warn('Could not parse AI response as JSON, using fallback');
      insights = generateFallbackInsights(journalText);
      insights.note = 'AI response format issue - using enhanced fallback';
    }
    
    res.json({
      status: "success",
      insights,
      timestamp: new Date().toISOString(),
      textLength: journalText.length
    });
    
  } catch (error) {
    console.error('Insights Error:', error.message);
    
    // Provide helpful fallback
    const fallbackInsights = generateFallbackInsights(req.body.journalText || '');
    
    res.status(error.status === 429 ? 429 : 500).json({
      status: error.status === 429 ? "rate_limited" : "partial_success",
      insights: fallbackInsights,
      error: error.message.includes('quota') || error.status === 429 
        ? "API quota/rate limit reached. Using fallback insights." 
        : "AI service issue. Using fallback insights.",
      note: "Consider enabling USE_MOCK_AI=true for development",
      timestamp: new Date().toISOString()
    });
  }
};

// Additional helper function if needed
export const analyzeMood = async (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text) {
      return res.status(400).json({ error: "Text required" });
    }
    
    // Simple mood detection
    const moods = {
      happy: ['happy', 'joy', 'excited', 'great', 'wonderful', 'love'],
      sad: ['sad', 'upset', 'cry', 'unhappy', 'depressed'],
      anxious: ['anxious', 'worried', 'stress', 'nervous', 'panic'],
      angry: ['angry', 'mad', 'frustrated', 'annoyed', 'irritated'],
      calm: ['calm', 'peaceful', 'relaxed', 'chill', 'serene']
    };
    
    const textLower = text.toLowerCase();
    let detectedMood = 'neutral';
    let confidence = 0;
    
    for (const [mood, keywords] of Object.entries(moods)) {
      const matches = keywords.filter(keyword => textLower.includes(keyword)).length;
      if (matches > confidence) {
        confidence = matches;
        detectedMood = mood;
      }
    }
    
    res.json({
      mood: detectedMood,
      confidence: confidence / 5, // Normalize
      detectedKeywords: moods[detectedMood].filter(k => textLower.includes(k)),
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Mood analysis error:', error);
    res.status(500).json({ 
      error: "Mood analysis failed",
      mood: "unknown"
    });
  }
};