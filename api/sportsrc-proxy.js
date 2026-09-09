export default async function handler(request, res) {
  try {
    const url = new URL(request.url);
    const searchParams = url.searchParams.toString();
    const targetUrl = `https://sportsrc.me/api?${searchParams}`;

    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Referer': 'https://sportsrc.me/'
      }
    });

    const data = await response.text();

    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(response.status).end(data);
  } catch (error) {
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.status(500).end(JSON.stringify({ error: error.message }));
  }
}
