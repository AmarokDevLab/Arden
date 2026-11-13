# Arden el Caballero — Salas, jefes y estadísticas (PWA)

## Instalación en GitHub Pages

1. Antes de subir la actualización del juego, abre tu proyecto de **Supabase → SQL Editor** y ejecuta `ACTUALIZACION_SUPABASE_ARDEN.sql`. No borra tus niveles anteriores ni tus cuentas.
2. En GitHub, reemplaza `arden_el_caballero_pwa.html`, `sw.js` y los demás archivos del ZIP, manteniendo las rutas de `icons/`.
3. Si ya instalaste la PWA, ciérrala y vuelve a abrirla con conexión a internet para actualizar su caché. Si continúa una versión antigua, limpia los datos del sitio o reinstala la aplicación.
4. Entra con el mismo correo. La pantalla **CUENTA** mostrará las estadísticas y logros adquiridos.

## Salas diferentes

- **Combate:** vence a todos los guardianes para desbloquear un cofre.
- **Flechas:** sobrevive unos segundos esquivando proyectiles dentro de la habitación; no necesitas derrotar enemigos.
- **Acertijo:** pisa los interruptores **2 → 1 → 3**, en ese orden. Una equivocación reinicia la secuencia, no el nivel.
- **Tesoro:** descubre una sala con cofre sin enemigos.
- **Secreta:** descubre una cámara de reliquias adicionales y un cofre.

El mapa sigue siendo procedural. Las salas son opcionales, salvo las llaves y el jefe necesarios para salir. El número real de salas depende de las posiciones válidas del laberinto.

## Jefes

Rotación por nivel: **Gólem → Espectro → Hechicero**. El gólem marca una onda sísmica antes de golpear, el espectro anuncia su teletransportación y el hechicero anuncia proyectiles. Se conservan la esquiva (Shift/↗) y los escudos (Q/🛡).

## Progreso guardado

- Al ganar: nivel, tiempo, reliquias obtenidas, tipo de jefe, monstruos derrotados y salas completadas. Además se actualizan totales y mejor tiempo.
- Al perder todas las vidas: se aumenta el contador de muertes.
- En **Cuenta**: estadísticas y logros derivados de los totales.
- Al cerrar a mitad de un nivel: el laberinto actual y sus recursos no se guardan; se conserva el último nivel desbloqueado.

**Importante:** los logros se derivan de estadísticas guardadas, sin tabla separada de logros. Y las puntuaciones no son antifraude: un cliente web puede falsificar resultados. Para clasificaciones públicas hará falta validar los resultados en un servicio confiable.

## Solución de problemas

- `Could not find the function complete_arden_level_stats`: ejecuta el SQL de actualización y espera a que Supabase recargue su esquema; verifica los permisos de ejecución.
- `column total_relics does not exist`: ejecuta el SQL de actualización.
- Pantalla antigua: verifica que se publicó `sw.js` con caché `v3-rooms-bosses-stats`.
