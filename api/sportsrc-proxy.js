export default async function handler(req, res) {
  try {
    // Mengambil query parameters dari request URL
    const urlObj = new URL(req.url, `https://${req.headers.host}`);
    const queryParams = urlObj.searchParams.toString();
    const targetUrl = `https://sportsrc.me/api?${queryParams}`;

    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Referer': 'https://sportsrc.me/'
      }
    });

    const data = await response.json();

    // Mengizinkan CORS dan mengirim response menggunakan res.status().json()
    res.setHeader('Access-Control-Allow-Origin', '*');
    return res.status(response.status).json(data);
  } catch (error) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    return res.status(500).json({ error: error.message });
  }
}
