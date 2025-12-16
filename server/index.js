// index.js - Simple server without database
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    message: '🚀 MindQuest API is running!',
    version: '1.0.0',
    endpoints: [
      '/api/health',
      '/api/test',
      '/api/auth/register',
      '/api/auth/login'
    ]
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    server: 'MindQuest API',
    uptime: process.uptime()
  });
});

app.get('/api/test', (req, res) => {
  res.json({
    message: 'Test endpoint working!',
    data: {
      users: 0,
      quizzes: 0,
      features: ['Authentication', 'Quiz System', 'Progress Tracking']
    }
  });
});

// Mock authentication endpoints
app.post('/api/auth/register', (req, res) => {
  const { username, email, password } = req.body;
  
  if (!username || !email || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  
  res.json({
    message: 'User registered successfully (mock)',
    user: {
      id: Math.floor(Math.random() * 1000),
      username,
      email,
      token: 'mock-jwt-token-' + Date.now()
    }
  });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }
  
  res.json({
    message: 'Login successful (mock)',
    user: {
      id: 1,
      username: 'testuser',
      email,
      token: 'mock-jwt-token-' + Date.now()
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ MindQuest Server started on port ${PORT}`);
  console.log(`🌐 http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
});