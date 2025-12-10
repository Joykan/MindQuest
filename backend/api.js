import express from "express";
import cors from "cors";
import { exec } from "child_process";

const app = express();
app.use(express.json());

// 🔥 MOST IMPORTANT — FIX CORS
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.options("*", cors());

// --- HEALTH CHECK ---
app.get("/", (req, res) => {
  res.json({ status: "MindQuest API is running!" });
});

// --- CHAT ENDPOINT ---
app.post("/api/chat", async (req, res) => {
  const userMsg = req.body.message || "";

  exec(
    `jsctl run walker chat { "message": "${userMsg.replace(/"/g, "'")}" }`,
    (error, stdout, stderr) => {
      if (error) {
        console.error("exec error:", error);
        return res.status(500).send("Backend execution error");
      }
      res.json({ reply: stdout });
    }
  );
});

// OPTIONAL BUT NICE: test endpoint
app.get("/api/health", (req, res) => res.send("OK"));

// --- DEPLOY PORT ---
const PORT = process.env.PORT || 8000;
app.listen(PORT, () => console.log(`API running on port ${PORT}`));
