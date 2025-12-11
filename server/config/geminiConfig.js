import { GoogleGenAI } from '@google/genai';

// Initialize the client.
// It automatically looks for the GEMINI_API_KEY environment variable.
// Make sure this key is set in your .env file.
const ai = new GoogleGenAI({});

// Export the initialized client.
export default ai;