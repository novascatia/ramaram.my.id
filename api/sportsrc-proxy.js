const fetch = require('node-fetch'); // atau sesuaikan dengan library fetch yang kamu pakai

module.exports = async (req, res) => {
  // Mengambil parameter query dari URL request
  const queryParams = new URLSearchParams(req.query).toString();
  const targetUrl = `https://sportsrc.me/api?` + queryParams; // sesuaikan dengan endpoint asli sportsrc kamu

  try {
    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0',
        'Referer': 'https://sportsrc.me/'
      }
    });
    
    const data = await response.json();
    
    // Mengizinkan CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
