const CACHE = 'ready72-v4';
const CORE = ['./', 'main.dart.js', 'flutter_bootstrap.js', 'flutter.js', 'manifest.json', 'assets/FontManifest.json'];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    for (const url of CORE) {
      try { await cache.add(url); } catch (_) {}
    }
    self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  event.respondWith((async () => {
    const cached = await caches.match(request);
    if (cached) return cached;
    try {
      const response = await fetch(request);
      if (response && response.status === 200) {
        const copy = response.clone();
        const cache = await caches.open(CACHE);
        cache.put(request, copy);
      }
      return response;
    } catch (_) {
      const fallback = await caches.match('./');
      if (fallback) return fallback;
      throw _;
    }
  })());
});
