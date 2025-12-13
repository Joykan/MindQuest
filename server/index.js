import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import mongoose from "mongoose";
import path from "path";
import { fileURLToPath } from "url";

// ES modules fix for __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();

// Import routes
import mainRoutes from "./routes/index.js";

const app = express();

// ==== MIDDLEWARE ====
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.FRONTEND_URL || 'https://mindquest-6ree.onrender.com'
    : 'http://localhost:3000',
  credentials: true
}));
app.use(express.json({ limit: "2mb" }));
app.use(express.urlencoded({ extended: true }));

// ==== SERVE STATIC FRONTEND FILES ====
// This is what you're missing!
const clientPath = path.join(__dirname, '..', 'client');
console.log('🔍 Serving frontend from:', clientPath);

// Serve static files (CSS, JS, images)
app.use(express.static(clientPath));

// ==== DATABASE CONNECTION (Optional) ====
if (process.env.MONGODB_URI) {
  mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('✅ Connected to MongoDB'))
    .catch(err => console.error('❌ MongoDB connection error:', err));
}

// ==== API ROUTES ====
app.use("/api", mainRoutes);

// ==== HEALTH ENDPOINTS ====
app.get("/health", (req, res) => {
  res.status(200).json({ 
    status: "OK", 
    message: "Server is running",
    timestamp: new Date().toISOString(),
    clientPath: clientPath,
    files: require('fs').readdirSync(clientPath)
  });
});

app.get("/api/health", (req, res) => {
  res.status(200).json({ 
    status: "OK", 
    message: "API is running",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    geminiConfigured: !!process.env.GEMINI_API_KEY
  });
});

// ==== SERVE FRONTEND FOR ALL OTHER ROUTES (SPA Support) ====
// This catches all routes and serves index.html
app.get('*', (req, res) => {
  const indexPath = path.join(clientPath, 'index.html');
  console.log('📄 Serving index.html from:', indexPath);
  res.sendFile(indexPath);
});

// ==== ERROR HANDLING ====
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

app.use((err, req, res, next) => {
  console.error("Server Error:", err);
  res.status(500).json({ 
    error: "Internal server error",
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// ==== START SERVER ====
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🔥 Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📁 Serving frontend from: ${clientPath}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 App: http://localhost:${PORT}`);
});