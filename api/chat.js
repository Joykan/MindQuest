// api/chat.js

module.exports = async (req, res) => {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader(
    'Access-Control-Allow-Methods',
    'POST, OPTIONS'
  );
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type'
  );

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  // Only POST is allowed
  if (req.method !== 'POST') {
    return res.status(405).json({
      error: 'Method not allowed',
    });
  }

  // Get Groq API key from Vercel environment variables
  const apiKey = process.env.GROQ_API_KEY;

  if (!apiKey) {
    console.error('GROQ_API_KEY is not configured');

    return res.status(500).json({
      error: 'Server misconfigured: GROQ_API_KEY not set',
    });
  }

  try {
    const body = req.body || {};

    const {
      model,
      messages,
      max_tokens,
      temperature,
    } = body;

    // Validate messages
    if (!Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({
        error: 'messages is required and must be a non-empty array',
      });
    }

    // Use the requested model or the default model
    const selectedModel =
      model || 'openai/gpt-oss-20b';

    console.log(
      `MindQuest request received. Model: ${selectedModel}`
    );

    // Send request to Groq
    const groqRes = await fetch(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        method: 'POST',

        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },

        body: JSON.stringify({
          model: selectedModel,
          messages,
          max_tokens: max_tokens || 300,
          temperature:
            typeof temperature === 'number'
              ? temperature
              : 0.7,
        }),
      }
    );

    const data = await groqRes.json();

    console.log(
      `Groq response status: ${groqRes.status}`
    );

    // Forward Groq's response directly to Flutter
    return res.status(groqRes.status).json(data);
  } catch (error) {
    console.error('Groq request failed:', error);

    return res.status(502).json({
      error: 'Failed to reach Groq',
      detail: String(error),
    });
  }
};
