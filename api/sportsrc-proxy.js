export default async function handler(req, res) {
  try {
    const params = req.query || {};
    const apiKey = process.env.sportsrc_api_key;
    
    if (!apiKey) {
      return res.status(500).json({ error: 'API key not configured' });
    }
    
    const query = new URLSearchParams(params).toString();
    const url = `https://api.sportsrc.org/v2/?${query}`;

    console.log('Fetching:', url);
    console.log('Params:', params);

    const response = await fetch(url, {
      headers: {
        'X-API-KEY': apiKey,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      }
    });

    console.log('Response status:', response.status);

    const text = await response.text();

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    
    res.status(response.status).send(text);

  } catch (err) {
    console.error('Proxy error:', err);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(500).json({ error: err.message });
  }
}
