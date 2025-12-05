// backend/api.js
import { GoogleGenAI } from "@google/genai";
import express from "express";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();
const app = express();
app.use(express.json());
app.use(cors());

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY
});

app.post("/api/chat", async (req, res) => {
  try {
    const { message } = req.body;
    if (!message) return res.status(400).json({ error: "Missing message" });

    const completion = await ai.models.generateContent({
      model: "gemini-2.5-flash",       // or another supported Gemini model
      contents: message,
      temperature: 0.7
    });

    res.json({ reply: completion.text });
  } catch (err) {
    console.error("Chat error", err);
    res.status(500).json({ error: "Server error", details: err.message });
  }
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`MindQuest API (Gemini) running on port ${PORT} 🚀`));
