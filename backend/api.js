import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import axios from "axios";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 4000;

// ---- GEMINI CONFIG ----
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = process.env.GEMINI_MODEL || "gemini-1.5-flash-latest";

if (!GEMINI_API_KEY) {
  console.error("❌ Missing GEMINI_API_KEY in .env");
  process.exit(1);
}

// Gemini REST endpoint
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;


// ========== 💬 Chat With Gemini ==========
async function chatWithGemini(message) {
  try {
    const response = await axios.post(
      GEMINI_URL,
      {
        contents: [
          {
            parts: [{ text: message }],
          },
        ],
      },
      {
        headers: { "Content-Type": "application/json" },
      }
    );

    // Extract text safely
    const reply =
      response.data?.candidates?.[0]?.content?.parts?.[0]?.text ||
      "I’m here, talk to me 😌";

    return reply;
  } catch (err) {
    console.error("Gemini Error:", err.response?.data || err.message);
    return "Something went wrong talking to Gemini 😭";
  }
}


// ========== 🌐 API ROUTES ==========

// Chat route
app.post("/chat", async (req, res) => {
  const message = req.body.message;

  if (!message) {
    return res.status(400).json({
      error: "Message is required",
    });
  }

  const reply = await chatWithGemini(message);
  return res.json({ reply });
});

// Health check
app.get("/", (req, res) => {
  res.json({
    status: "MindQuest backend running",
    provider: "Gemini",
    model: GEMINI_MODEL,
  });
});

// Start server
app.listen(PORT, () =>
  console.log(`🚀 MindQuest Gemini API listening on port ${PORT}`)
);
