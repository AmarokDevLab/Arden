# Arden: El Laberinto Arcano — v7 · Menú y ranking

## Publicación en GitHub Pages

1. Descarga el ZIP y coloca **el contenido de la carpeta**, no la carpeta en sí, en la raíz del repositorio configurado para Pages.
2. Mantén `assets/`, `icons/`, `manifest.webmanifest` y `sw.js` con sus rutas.
3. Ejecuta `MENU_Y_RANKING_SUPABASE.sql` **en el SQL Editor de tu proyecto de Supabase**. Requiere los scripts de base y estadísticas de versiones previas.
4. Reemplaza `arden_el_caballero_pwa.html` y los demás archivos del ZIP. Después recarga GitHub Pages o cierra y reabre la PWA para actualizar la caché.

## Menú principal

- **Continuar:** comienza el último nivel desbloqueado guardado en Supabase; no restaura una partida abandonada a mitad del laberinto.
- **Nueva partida:** muestra una confirmación y, si aceptas, elimina los niveles desbloqueados, su historial y las estadísticas de esa cuenta. La cuenta de acceso y el alias de ranking permanecen.
- **Ranking de jugadores:** muestra hasta 100 aventureros, ordenados por niveles completados, jefes derrotados y reliquias. En empate se utiliza el mejor tiempo. No se muestran correos electrónicos.

## Privacidad del ranking

En la pantalla de ranking, cada jugador define un alias (3–18 caracteres) y activa voluntariamente **«Quiero aparecer públicamente en el ranking»**. La opción viene desactivada. Hasta que alguien se inscriba, la tabla puede aparecer vacía.

**Importante:** las estadísticas actuales proceden del navegador. Esta clasificación es recreativa/de desarrollo, no un ranking competitivo antifraude: una persona con conocimientos técnicos podría manipular sus resultados desde el cliente. Para una competición real hacen falta validaciones en un servidor confiable.

## Base de datos

Esta versión **sí requiere ejecutar un SQL nuevo**. No elimina ni cambia niveles al aplicar el SQL. La función de *Nueva partida* sí borra los datos de la aventura individual, previa confirmación en la interfaz.

Si los jugadores aún no ejecutaron la actualización de estadísticas `ACTUALIZACION_SUPABASE_ARDEN.sql`, aplícala antes de `MENU_Y_RANKING_SUPABASE.sql`.
