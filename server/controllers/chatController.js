import { success, error } from "../utils/response.js";
import { getAIResponse } from "../services/geminiService.js";

export const getChatResponse = async (req, res) => {
  try {
    const { history } = req.body;

    if (!Array.isArray(history) || history.length === 0) {
      return error(res, "Conversation history required.", 400);
    }

    const reply = await getAIResponse(history);

    return success(res, { reply }, "Gemini AI replied");
  } catch (err) {
    return error(res, err.message || "Internal server error", 500);
  }
};
