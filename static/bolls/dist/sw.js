var CACHE_NAME = 'v1.2.30';
var urlsToCache = [
  '/',
  '/static/bolls/dist/client.js',
  '/static/bolls/dist/style.css',
  '/static/bolls/fonts/fontstylesheet.css',
  '/static/bolls/dist/mobile_styles.css',
  '/static/bolls/dist/8.jpg',
];

self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
    .then(function (cache) {
      console.log('👷', 'Opened cache');
      return cache.addAll(urlsToCache);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((resp) => {
      return resp || fetch(event.request).then((response) => {
        var responseClone = response.clone();
        if (event.request.url.includes("get-text") || event.request.url.includes("search") || event.request.destination == "font") {
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      });
    }).catch(() => {
      return caches.match('/');
    })
  );
});

self.addEventListener('activate', (event) => {
  var cacheKeeplist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((keyList) => {
      return Promise.all(keyList.map((key) => {
        if (cacheKeeplist.indexOf(key) === -1) {
          return caches.delete(key);
        }
      }));
    })
  );
  console.log('👷', 'SW is activated');
});