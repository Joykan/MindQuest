import ai from '../config/geminiConfig.js'; // Import the initialized AI client

/**
 * Generates a response from the Gemini model while maintaining conversation history.
 * @param {Array<Object>} history - The full conversation history (user and model messages).
 * @returns {Promise<string>} The AI's text reply.
 */
export const getAIResponse = async (history) => {
  if (!Array.isArray(history) || history.length === 0) {
    return "Please provide a valid conversation history.";
  }

  try {
    // 1. Create a new chat session
    const chat = ai.chats.create({
      model: "gemini-1.5-flash",
      // 2. Initialize the chat with the history of all PREVIOUS turns.
      //    We slice off the last message, which is the user's *current* prompt.
      history: history.slice(0, -1),
    });

    // 3. Get the text of the latest user message
    const latestUserMessage = history[history.length - 1].parts[0].text;

    // 4. Send the latest message as a string
    const response = await chat.sendMessage({ message: latestUserMessage });

    return response?.text || "Sorry, I didn't understand that.";
  } catch (err) {
    console.error("Gemini API error FULL:", err);
    throw new Error("Oops, something went wrong with the AI.");
  }
};