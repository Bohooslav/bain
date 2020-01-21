self.addEventListener('install', (event) => {
  console.log('👷', 'install', event);
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('👷', 'activate', event);
  return self.clients.claim();
});

self.addEventListener('fetch', function (event) {
  // console.log('👷', 'fetch', event);
  event.respondWith(fetch(event.request));
});

// var CACHE_NAME = 'bolls-cache-v1';
// var urlsToCache = [
//   'http: //127.0.0.1:8000/',
//   '/',
//   '/index.html',
//   '/static/bolls/dist/style.css',
//   '/static/bolls/dist/mobile_styles.css',
//   '/static/bolls/dist/client.js',
//   'https://fonts.googleapis.com/css?family=Roboto+Slab:400,700&display=swap&subset=cyrillic,cyrillic-ext,greek,greek-ext,latin-ext,vietnamese'
// ];

// self.addEventListener('install', function (event) {
//   // Perform install steps
//   event.waitUntil(
//     caches.open(CACHE_NAME)
//     .then(function (cache) {
//       console.log('Opened cache');
//       return cache.addAll(urlsToCache);
//     })
//   );
// });

// self.addEventListener('activate', function (event) {
//   console.log('Service Worker activating.');
// });

// self.addEventListener('fetch', function (event) {
//   event.respondWith(
//     caches.match(event.request)
//     .then(function (response) {
//       // Cache hit - return response
//       if (response) {
//         return response;
//       }

//       return fetch(event.request).then(
//         function (response) {
//           // Check if we received a valid response
//           if (!response || response.status !== 200 || response.type !== 'basic') {
//             return response;
//           }

//           // IMPORTANT: Clone the response. A response is a stream
//           // and because we want the browser to consume the response
//           // as well as the cache consuming the response, we need
//           // to clone it so we have two streams.
//           var responseToCache = response.clone();

//           caches.open(CACHE_NAME)
//             .then(function (cache) {
//               cache.put(event.request, responseToCache);
//             });

//           return response;
//         }
//       );
//     })
//   );
// });