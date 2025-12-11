import { success, error } from "../utils/response.js";
import { getAIResponse } from "../services/geminiService.js";

export const getChatResponse = async (req, res) => {
  // 1. Expect the full conversation history from the request body
  const { history } = req.body; 

  if (!Array.isArray(history) || history.length === 0) {
    return error(res, "No conversation history provided or history is empty.", 400);
  }

  try {
    // 2. Pass the full history to the service function
    const reply = await getAIResponse(history);
    success(res, { reply }, "Gemini AI replied");
  } catch (err) {
    // Note: The service now throws a custom error, which we catch here
    error(res, err.message || "Internal Server Error", 500);
  }
};