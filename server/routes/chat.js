import { Router } from "express";
import { GoogleGenAI } from "@google/genai";
import dotenv from 'dotenv';

dotenv.config();

const router = Router(); // ⭐ THIS LINE IS CRITICAL
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// Language-specific prompts
const systemPrompts = {
  en: {
    therapy: "You are a compassionate therapist. Respond in English. Keep responses SHORT (1-2 sentences).",
    coaching: "You are a motivational coach. Respond in English. Give concise advice.",
    general: "You are MindQuest AI. Respond in English. Keep responses BRIEF and helpful."
  },
  sw: {
    therapy: "Wewe ni mtaalamu wa afya ya akili. Jibu kwa Kiswahili. Toa majibu MAFUPA (sentensi 1-2).",
    coaching: "Wewe ni kocha wa motisha. Jibu kwa Kiswahili. Toa ushauri mfupi.",
    general: "Wewe ni MindQuest AI. Jibu kwa Kiswahili. Toa majibu MAFUPA na yenye kusaidia."
  },
  sg: {
    therapy: "You ni therapist. Reply in Sheng. Keep replies SHORT (1-2 sentences).",
    coaching: "You ni coach. Reply in Sheng. Give short advice.",
    general: "You ni MindQuest AI. Reply in Sheng. Keep replies SHORT na helpful."
  }
};

// POST /api/chat
router.post("/", async (req, res) => {
  try {
    const { message, context = "general", language = "en" } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: "Message is required" });
    }

    const prompts = systemPrompts[language] || systemPrompts.en;
    const systemPrompt = prompts[context] || prompts.general;

    // Build conversation
    const conversation = [
      { role: "user", parts: [{ text: systemPrompt }] },
      { role: "user", parts: [{ text: message }] }
    ];

    const response = await ai.models.generateContent({
      model: "gemini-2.0-flash-exp",
      contents: conversation,
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 150, // Short responses
      }
    });

    res.json({
      success: true,
      response: response.text,
      language,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error("Chat error:", error);
    res.status(500).json({
      success: false,
      error: "Chat failed",
      message: error.message
    });
  }
});

// GET /api/chat/health
router.get("/health", (req, res) => {
  res.json({ status: "chat route active" });
});

// ⭐ CRITICAL: Export the router
export default router;