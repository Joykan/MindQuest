// MindQuest API Gateway - Node.js + Express
// Connects frontend to Jaseci walkers

import express from "express";
import { exec } from "child_process";

const app = express();
app.use(express.json());

// Helper: Run Jaseci walker
function runWalker(walker, params = {}) {
  return new Promise((resolve, reject) => {
    const cmd = `jsctl -j walker run ${walker} -p '${JSON.stringify(params)}'`;

    exec(cmd, (err, stdout, stderr) => {
      if (err || stderr) {
        reject(stderr || err.message);
      }
      try {
        resolve(JSON.parse(stdout));
      } catch {
        resolve(stdout);
      }
    });
  });
}

// ---------- API ROUTES ----------

// Log mood
app.post("/api/log_mood", async (req, res) => {
  try {
    const data = await runWalker("api_log_mood", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Get emotions history
app.post("/api/get_emotions", async (req, res) => {
  try {
    const data = await runWalker("api_get_emotions", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Log activity
app.post("/api/log_activity", async (req, res) => {
  try {
    const data = await runWalker("api_log_activity", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Create journal entry
app.post("/api/create_journal", async (req, res) => {
  try {
    const data = await runWalker("api_create_journal", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Get insights
app.post("/api/get_insights", async (req, res) => {
  try {
    const data = await runWalker("api_get_insights", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Analyze mood patterns
app.post("/api/analyze_patterns", async (req, res) => {
  try {
    const data = await runWalker("api_analyze_patterns", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Personalized support
app.post("/api/get_support", async (req, res) => {
  try {
    const data = await runWalker("api_get_support", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Get suggestions
app.post("/api/get_suggestions", async (req, res) => {
  try {
    const data = await runWalker("api_get_suggestions", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// Emotion summary
app.post("/api/emotion_summary", async (req, res) => {
  try {
    const data = await runWalker("api_get_emotion_summary", req.body);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error });
  }
});

// ---------- SERVER START ----------
app.listen(4000, () => {
  console.log("MindQuest API is running on port 4000 🚀");
  console.log("Frontend can now call http://localhost:4000/api/... endpoints");
});
