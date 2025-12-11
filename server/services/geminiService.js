import ai from "../config/geminiConfig.js";

/**
 * history format:
 * [
 *   { role: "user", text: "Hello" },
 *   { role: "model", text: "Hi, how can I help?" }
 * ]
 */

export const getAIResponse = async (history) => {
  try {
    // Convert history to SDK format
    const formattedHistory = history.map(h => ({
      role: h.role,
      parts: [{ text: h.text }]
    }));

    // Create chat session
    const chat = ai.startChat({
      model: "gemini-1.5-flash",
      history: formattedHistory,
    });

    // Last user message
    const latestUserMessage = history[history.length - 1].text;

    // Send message
    const result = await chat.sendMessage(latestUserMessage);

    const reply = result.response.text();

    return reply || "AI didn't send any text.";
  } catch (err) {
    console.error("Gemini API error FULL:", err);
    throw new Error("AI failed to respond.");
  }
};
