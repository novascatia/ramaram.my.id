// api/sportsrc-proxy.js (Vercel)

export default async function handler(req, res) {
  try {
    const params = req.query || {};
    const query = new URLSearchParams(params).toString();
    const url = `https://api.sportsrc.org/?${query}`;

    console.log('URL fetched:', url);

    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'application/json',
      }
    });

    const text = await response.text();
    console.log('Response sample:', text.substring(0, 500));

    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    res.status(response.status).send(text);

  } catch (err) {
    console.error('Error:', err);
    
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(500).json({ error: err.message });
  }
}
