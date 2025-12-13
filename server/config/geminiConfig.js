// server/config/geminiConfig.js
import { GoogleGenAI } from "@google/genai";
import dotenv from 'dotenv';

dotenv.config(); // This loads variables from .env

// Pass a configuration object with your apiKey
const ai = new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY
});

export default ai;