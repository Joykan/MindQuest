import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

// ES modules fix
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();

const app = express();
const PORT = process.env.PORT || 10000;  // CRITICAL: Render uses 10000

// Middleware
app.use(cors());
app.use(express.json());

// Log all requests
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Find client folder
console.log("=== LOOKING FOR CLIENT FILES ===");
console.log("Current dir:", __dirname);
console.log("Process CWD:", process.cwd());

const possiblePaths = [
  path.join(process.cwd(), 'client'),
  path.join(__dirname, '..', 'client'),
  path.join(__dirname, 'client'),
  '/opt/render/project/src/client',  // Render's typical path
];

let clientPath = null;
for (const p of possiblePaths) {
  console.log(`Checking: ${p}`);
  try {
    if (fs.existsSync(p) && fs.existsSync(path.join(p, 'index.html'))) {
      clientPath = p;
      console.log(`✅ FOUND CLIENT AT: ${p}`);
      console.log(`📄 Files:`, fs.readdirSync(p));
      break;
    }
  } catch (err) {
    console.log(`❌ Error checking ${p}:`, err.message);
  }
}

// Serve static files if found
if (clientPath) {
  app.use(express.static(clientPath));
  console.log(`✅ Serving static files from: ${clientPath}`);
} else {
  console.error('❌ CLIENT FOLDER NOT FOUND ANYWHERE!');
  console.error('Searched paths:', possiblePaths);
}

// Health endpoint (MUST work)
app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    service: "MindQuest AI",
    port: PORT,
    clientPath: clientPath,
    clientExists: !!clientPath,
    timestamp: new Date().toISOString(),
    nodeVersion: process.version
  });
});

// API endpoints
app.get("/api/health", (req, res) => {
  res.json({ 
    status: "API OK",
    timestamp: new Date().toISOString()
  });
});

app.post("/api/chat", (req, res) => {
  const { message } = req.body || {};
  res.json({
    success: true,
    response: `Test: ${message || "No message"}`,
    timestamp: new Date().toISOString()
  });
});

// Serve frontend for all routes
app.get("*", (req, res) => {
  if (clientPath && fs.existsSync(path.join(clientPath, 'index.html'))) {
    res.sendFile(path.join(clientPath, 'index.html'));
  } else {
    res.status(200).send(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>MindQuest AI - Debug</title>
        <style>
          body { font-family: Arial; padding: 40px; }
          .success { color: green; }
          .error { color: red; }
        </style>
      </head>
      <body>
        <h1>MindQuest AI</h1>
        <p>Backend is running ✅</p>
        <p>Client path: ${clientPath || 'Not found'}</p>
        <p><a href="/health">Health Check</a></p>
        <p><a href="/api/health">API Health</a></p>
      </body>
      </html>
    `);
  }
});

// Start server - CRITICAL: Listen on 0.0.0.0 for Render
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 SERVER STARTED on port ${PORT}`);
  console.log(`📡 Listening on: 0.0.0.0:${PORT}`);
  console.log(`🔗 Health: http://0.0.0.0:${PORT}/health`);
  console.log(`🌐 Public URL: https://mindquest-6ree.onrender.com`);
});