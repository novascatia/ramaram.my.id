module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');

  try {
    const queryParams = new URLSearchParams(req.query).toString();
    const targetUrl = `https://sportsrc.me/api?${queryParams}`;

    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Referer': 'https://sportsrc.me/'
      }
    });

    const textData = await response.text();
    
    // Mengembalikan status asli dan teks respon dari sportsrc agar terlihat di browser
    return res.status(response.status).send(textData);
  } catch (error) {
    return res.status(500).json({ error: 'Fetch failed', details: error.message });
  }
};
