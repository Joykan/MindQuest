module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) return res.status(500).json({ error: 'Server misconfigured: GROQ_API_KEY not set' });

  const { model, messages, max_tokens, temperature } = req.body || {};
  if (!messages) return res.status(400).json({ error: 'messages is required' });

  try {
    const groqRes = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({
        model: model || 'openai/gpt-oss-20b',
        messages,
        max_tokens: max_tokens || 300,
        temperature: temperature ?? 0.7,
      }),
    });
    const data = await groqRes.json();
    return res.status(groqRes.status).json(data);
  } catch (err) {
    return res.status(502).json({ error: 'Failed to reach Groq', detail: String(err) });
  }
};
