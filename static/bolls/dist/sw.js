var CACHE_NAME = 'v1';
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

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
    .then(function (response) {
      if (response) {
        return response; // if valid response is found in cache return it
      } else {
        try {
          return fetch(event.request) //fetch from internet
            .then(function (res) {
              return caches.open(CACHE_NAME)
                .then(function (cache) {
                  cache.put(event.request.url, res.clone()); //save the response for future
                  return res; // return the fetched data
                })
            })
            .catch(function (err) { // fallback mechanism
              return caches.open(CACHE_NAME)
                .then(function (cache) {
                  return cache.match('/');
                });
            });
        } catch (error) {
          console.log(error);
        }
      }
    })
  );
});