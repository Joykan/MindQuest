// api.js — MindQuest Backend (Express + Gemini API)
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import bodyParser from "body-parser";

dotenv.config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = process.env.PORT || 4000;
const PROVIDER = process.env.PROVIDER || "GEMINI";
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// ---- Gemini client ----
async function geminiChat(message) {
  const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=" + GEMINI_API_KEY;
  const payload = {
    contents: [
      { parts: [{ text: message }] }
    ]
  };

  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  const data = await res.json();
  try {
    return data.candidates[0].content.parts[0].text;
  } catch {
    return "Sorry, the AI could not respond.";
  }
}

// ---- Memory mock (use DB later) ----
const journalDB = {};

// ---- ROUTES ----

// health check
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// CHAT endpoint
app.post("/api/chat", async (req, res) => {
  try {
    const { message } = req.body;
    if (!message) return res.status(400).json({ error: "Message is required" });

    let reply = "AI provider not configured.";
    if (PROVIDER === "GEMINI") {
      reply = await geminiChat(message);
    }

    res.json({ reply });
  } catch (error) {
    console.error("CHAT ERROR:", error);
    res.status(500).json({ error: "Server error" });
  }
});

// CREATE JOURNAL endpoint
app.post("/api/create_journal", (req, res) => {
  const { user_id, content, entry_type, emotional_tags } = req.body;
  if (!user_id || !content) {
    return res.status(400).json({ error: "user_id and content required" });
  }

  if (!journalDB[user_id]) journalDB[user_id] = [];

  const entry = {
    content,
    entry_type: entry_type || "general",
    emotional_tags: emotional_tags || [],
    timestamp: new Date().toISOString()
  };

  journalDB[user_id].push(entry);
  res.json({ success: true, entry });
});

// GET INSIGHTS endpoint
app.post("/api/get_insights", (req, res) => {
  const { user_id } = req.body;
  if (!user_id) return res.status(400).json({ error: "user_id required" });

  const entries = journalDB[user_id] || [];
  res.json({
    entries_count: entries.length,
    latest_entry: entries.at(-1) || null
  });
});

// ---- START SERVER ----
app.listen(PORT, () => {
  console.log(`🚀 MindQuest API (provider=${PROVIDER}) running on port ${PORT}`);
});