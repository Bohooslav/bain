var CACHE_NAME = 'v1.2.0';
var urlsToCache = [
  '/',
  '/static/light.png',
  '/static/bolls/dist/style.css',
  '/static/bolls/dist/mobile_styles.css',
  '/static/bolls/dist/client.js',
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
      return fetch(event.request).then((response) => {
        let responseClone = response.clone();
        if (event.request.url.includes("get-bookmarks") || event.request.url.includes("get-categories") || event.request.url.includes("get-profile-bookmarks") || event.request.url.includes("get-searched-bookmarks") || event.request.url.includes("signup") || event.request.url.includes("accounts"))
          return responseClone;

        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseClone);
        });

        return response;
      }) || resp;
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
});