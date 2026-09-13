export default async function handler(req, res) {
  try {
    const apiKey = process.env.sportsrc_api_key;
    
    if (!apiKey) {
      return res.status(500).json({ error: 'API key not configured' });
    }
    
    const params = req.query || {};
    const query = new URLSearchParams(params).toString();
    const url = `https://api.sportsrc.org/v2/?${query}`;

    const response = await fetch(url, {
      headers: {
        'X-API-KEY': apiKey,
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15',
      }
    });

    const text = await response.text();

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    
    res.status(response.status).send(text);

  } catch (err) {
    console.error('Proxy error:', err.message);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(500).json({ error: err.message });
  }
}
