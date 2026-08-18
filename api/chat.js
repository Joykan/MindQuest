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

    // Models to try in order of preference
    // NOTE: replace the decommissioned model 'llama3-8b-8192' with a supported model.
    // Recommended replacement: 'meta-llama-3-8b-instruct'
    const modelsToTry = [
      model,
      'meta-llama-3-8b-instruct',
      'llama-3.1-8b-instant',
      'llama-3.3-70b-versatile',
      'mixtral-8x7b-32768',
    ].filter(Boolean);

    let lastError = null;

    for (const selectedModel of modelsToTry) {
      console.log(
        `MindQuest request — trying model: ${selectedModel}`
      );

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
        `Groq response status for ${selectedModel}: ${groqRes.status}`,
        data && data.error ? data.error : ''
      );

      // If successful, return
      if (groqRes.status === 200) {
        return res.status(200).json(data);
      }

      // If model not found or decommissioned, try next model
      const errorCode = data && data.error && data.error.code;
      if (
        groqRes.status === 404 ||
        errorCode === 'model_not_found' ||
        errorCode === 'model_decommissioned'
      ) {
        console.log(
          `Model ${selectedModel} not available (code=${errorCode}), trying next...`
        );
        lastError = data;
        continue;
      }

      // For other errors (rate limit, invalid request, etc.), return as-is
      return res.status(groqRes.status).json(data);
    }

    // All models failed
    return res.status(404).json(
      lastError || { error: 'No available model found' }
    );
  } catch (error) {
    console.error('Groq request failed:', error);

    return res.status(502).json({
      error: 'Failed to reach Groq',
    });
  }
};
