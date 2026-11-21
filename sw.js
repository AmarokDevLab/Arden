const CACHE_NAME='arden-quest-pwa-v45-mobile-abilities';
const ASSETS=['./arden_el_caballero_pwa.html','./manifest.webmanifest','./icons/arden-192.png','./icons/arden-512.png','./icons/apple-touch-icon.png','./assets/arden_banner.png','./assets/arden_labyrinth.png','./assets/tutorial-exploration.png','./assets/tutorial-map.png'];
self.addEventListener('install',event=>{event.waitUntil(caches.open(CACHE_NAME).then(cache=>cache.addAll(ASSETS)).then(()=>self.skipWaiting()))});
self.addEventListener('activate',event=>{event.waitUntil(caches.keys().then(names=>Promise.all(names.filter(name=>name.startsWith('arden-quest-pwa-')&&name!==CACHE_NAME).map(name=>caches.delete(name)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',event=>{
 const req=event.request;
 if(req.method!=='GET'||new URL(req.url).origin!==self.location.origin)return;
 if(req.mode==='navigate'){
  event.respondWith(fetch(req).then(response=>{if(response.ok){const copy=response.clone();caches.open(CACHE_NAME).then(cache=>cache.put(req,copy))}return response}).catch(()=>caches.match(req).then(cached=>cached||caches.match('./arden_el_caballero_pwa.html'))));
  return;
 }
 event.respondWith(caches.match(req).then(cached=>cached||fetch(req)));
});
