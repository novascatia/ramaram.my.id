module.exports = async (req, res) => {
  // Mengambil parameter query dari request frontend
  const queryParams = new URLSearchParams(req.query).toString();
  
  // Sesuaikan URL target dengan endpoint asli yang biasa diakses sportsrc
  const targetUrl = `https://sportsrc.me/api?` + queryParams;

  try {
    // Menggunakan fetch bawaan Node.js tanpa require('node-fetch')
    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Referer': 'https://sportsrc.me/'
      }
    });

    if (!response.ok) {
      throw new Error(`Target responded with status: ${response.status}`);
    }

    const data = await response.json();
    
    // Mengizinkan CORS dan mengirim data kembali ke frontend
    res.setHeader('Access-Control-Allow-Origin', '*');
    return res.status(200).json(data);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};
