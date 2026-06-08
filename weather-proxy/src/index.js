const ROUTE_MAP = {
  "/current":     "/data/2.5/weather",
  "/forecast":    "/data/2.5/forecast",
  "/air":         "/data/2.5/air_pollution",
  "/geo/direct":  "/geo/1.0/direct",
  "/geo/reverse": "/geo/1.0/reverse",
};

export default {
  async fetch(request, env) {
    if (request.method !== "GET") {
      return jsonError(405, "Method not allowed");
    }

    const url = new URL(request.url);
    const owmPath = ROUTE_MAP[url.pathname];

    if (!owmPath) {
      return jsonError(404, `Unknown route: ${url.pathname}`);
    }

    const owmParams = new URLSearchParams(url.searchParams);
    owmParams.set("appid", env.OWM_API_KEY);

    if (!owmParams.has("units")) {
      owmParams.set("units", "metric");
    }

    const owmURL = `${env.OWM_BASE_URL}${owmPath}?${owmParams.toString()}`;

    let owmResponse;
    try {
      owmResponse = await fetch(owmURL, {
        headers: {
          "Accept": "application/json",
          "User-Agent": "WeatherApp-Proxy/1.0",
        },
        cf: {
          cacheTtl: 600,
          cacheEverything: true,
        },
      });
    } catch (err) {
      return jsonError(502, "Failed to reach OpenWeatherMap: " + err.message);
    }

    const body = await owmResponse.text();

    return new Response(body, {
      status: owmResponse.status,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "X-Cache-Age": owmResponse.headers.get("Age") ?? "0",
      },
    });
  },
};

function jsonError(status, message) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
