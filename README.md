# Arden: El Laberinto Arcano — v4

Publica todos los archivos de esta carpeta en la raíz de GitHub Pages y abre `arden_el_caballero_pwa.html`. Para entrada directa a la raíz del sitio, renombra este HTML como `index.html` **y cambia `start_url`, rutas y rutas del service worker de ser necesario**.

**Incluye:** icono de Arden y portada, botón DASH renovado, estela de esquiva, escudo único gestionable (Q/🛡), flor vital que cura una vida o entrega un escudo cuando tienes 3 vidas, acertijos de cuatro runas con orden variable, vista previa de memoria y 23 segundos para resolver, y combos de espada de hasta tres golpes (el tercero da +1 daño). Los enemigos alcanzados quedan aturdidos brevemente.

**Puzles:** al entrar se muestra la secuencia 5.5 s; luego tienes 23 s para pisar en orden las cuatro placas numeradas. Si fallas, la secuencia vuelve a aparecer; el error no provoca un bloqueo permanente.

**Combate:** impactar consecutivamente antes de 2.4 s mejora el combo; la última estocada añade daño. Los golpes generan destellos y una onda visual.

**Supabase:** conserva la URL y la clave pública incluidas. No se añade ninguna contraseña. Necesitas haber ejecutado `ACTUALIZACION_SUPABASE_ARDEN.sql` una sola vez en tu proyecto si aún no lo hiciste. Las partidas siguen guardándose cuando completas un nivel, no a mitad de él. No necesitas migrar las tablas para estos cambios visuales y jugables.

**PWA:** `manifest.webmanifest`, `sw.js`, iconos y banner se sirven en HTTPS a través de GitHub Pages. Recarga tras publicar; si una instalación antigua sigue en caché, cierra la PWA y vuelve a abrirla. La instalación y orientación horizontal dependen del navegador.

Controles PC: WASD/flechas, Enter espada, Shift DASH, Q escudo, M mapa, Esc pausa. En móviles usa joystick, DASH, 🛡, espada y mapa.


## Versión 6: reintento de jefe y salto

Si Arden pierde todas las vidas en la cámara del jefe, el botón «REINTENTAR JEFE» reinicia únicamente ese combate. Se conservan el nivel, llaves, reliquias y estadísticas reunidas durante el laberinto. Las vidas, los escudos guardados y las cargas de espada se restauran al estado con que entraste a la arena. El contador de tiempo continúa para no dar ventajas artificiales en las estadísticas.

La esquiva (Shift o botón SALTO en móvil) ahora incluye elevación en arco, partículas y estela.

No es necesario cambiar el esquema ni las funciones de Supabase.
