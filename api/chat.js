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

    // Supported Groq models, tried in order of preference.
    // The model is controlled by the server so that deprecated
    // model names from the frontend cannot break the request.
    const modelsToTry = [
      'openai/gpt-oss-20b',
      'openai/gpt-oss-120b',
      'llama-4-scout-17b-16e-instruct',
    ];

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
            max_tokens:
              typeof max_tokens === 'number'
                ? max_tokens
                : 300,
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

      // If successful, return the response
      if (groqRes.status === 200) {
        return res.status(200).json(data);
      }

      // If the model is unavailable or decommissioned,
      // try the next supported model.
      const errorCode =
        data &&
        data.error &&
        data.error.code;

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

      // For other errors such as rate limits,
      // invalid requests, authentication errors, etc.,
      // return the error immediately.
      return res.status(groqRes.status).json(data);
    }

    // All models failed
    return res.status(404).json(
      lastError || {
        error: 'No available model found',
      }
    );
  } catch (error) {
    console.error('Groq request failed:', error);

    return res.status(502).json({
      error: 'Failed to reach Groq',
    });
  }
};
