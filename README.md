# Spa Tatiana Quiceno

Sitio de reservas para **Tatiana Quiceno Estética Integral** (Cabañas, Bello, Antioquia): pestañas pelo a pelo, micropigmentación de cejas y labios, limpieza facial y alisados orgánicos.

La clienta elige el servicio, el día y una **hora libre real**, y reserva. El horario queda apartado y le avisa a Tatiana por WhatsApp con un toque. Tatiana maneja la agenda, los recordatorios y los retoques desde un panel privado.

## Qué hace
- **Agenda con horarios reales:**
  - Respeta el horario de atención: lunes a viernes de 8:00 a 18:00 y sábados de 8:00 a 14:00.
  - Usa la duración de cada servicio.
  - **Impide que dos personas reserven la misma hora.** Esto lo garantiza PostgreSQL con una restricción `EXCLUDE`, no el navegador.
- **Alerta o confirmación:** si la hora acaba de ser tomada, avisa y muestra las que siguen libres. Si se guardó, confirma y abre WhatsApp con el resumen.
- **Panel para la dueña:**
  - Ver, confirmar, mover, cancelar y marcar si asistió o no vino.
  - Agregar citas que llegan por otros canales.
  - Ofrecer retoques.
  - Ver ventas, costo por clienta y qué anuncio trae más clientas.
- **Medición de campañas:** Meta Pixel (`Lead`, `Contact`, `ViewContent`) y UTM guardados en cada reserva.
- **Datos personales según la Ley 1581:** autorización, política publicada y lectura restringida con RLS.

## Stack
- HTML, CSS y JavaScript sin framework en la página pública.
- [Supabase](https://supabase.com): PostgreSQL 17, Row Level Security, Auth y RPC.
- `supabase-js` 2.49.4 en el panel.
- Vercel como hosting estático.

## Estructura
```
web/
  index.html          Página pública y reservas
  panel/index.html    Panel de citas (con inicio de sesión)
  privacidad.html     Política de tratamiento de datos
  img/                Fotos de trabajos reales y logo
supabase/migrations/
  001_agenda.sql      Tablas, reglas de horario, permisos y funciones
DISENO_Y_CONTRATO.md  Reglas de diseño + contrato de la aplicación
```

## Correr en local
```bash
npx serve web
# abre http://localhost:3000 y http://localhost:3000/panel
```

## Desplegar
1. **Supabase:** crear un proyecto y ejecutar `supabase/migrations/001_agenda.sql`. Luego cambiar `SB_URL` y `SB_KEY` (llave publicable) en `web/index.html` y `web/panel/index.html`.
2. **Administradora:** crear su usuario en *Authentication → Users* y ejecutar `insert into public.administradoras (email) values ('correo');`.
3. **Vercel:** importar el repo con carpeta raíz `web`, sin comando de build.
4. **Meta Pixel:** pegar el ID en `PIXEL_ID` dentro de `web/index.html`.

Todos los detalles (reglas, API, errores, permisos y diseño) están en [`DISENO_Y_CONTRATO.md`](./DISENO_Y_CONTRATO.md).

## Créditos
Desarrollado por **uil-dev** · [uilholguin.dev](https://www.instagram.com/uilholguin.dev/).
Fotos y marca © Tatiana Quiceno Estética Integral, usadas con su autorización.
