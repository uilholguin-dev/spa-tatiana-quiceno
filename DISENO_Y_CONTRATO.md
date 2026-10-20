# Spa Tatiana Quiceno · Reglas de diseño y contrato de la aplicación

Documento de referencia del sitio de reservas de **Tatiana Quiceno Estética Integral** (Cabañas, Bello, Antioquia). Si algo del código contradice este documento, este documento manda, y el código se corrige.

- **Negocio:** pestañas pelo a pelo, micropigmentación de cejas y labios, limpieza facial y alisados orgánicos.
- **Dirección:** Calle 24A # 58C-21, piso 3, Cabañas, Bello.
- **WhatsApp:** 311 363 6459 (`573113636459`).
- **Redes:** Instagram @tatianaqestetica · Facebook Tatiana Quiceno.
- **Lema:** "El cuidado de tu rostro en las mejores manos".

---

## 1. Embudo

```
Anuncio (Instagram/Facebook) ─► Página de reservas ─► Reserva con hora exacta ─► Aviso por WhatsApp
                                                                                        │
Retoque (2–4 semanas) ◄── Asistió ◄── Recordatorio (día anterior) ◄── Tatiana confirma ◄┘
```

La página aparta el horario. WhatsApp sirve para la relación con la clienta. El panel lleva la agenda y las cifras.

---

## 2. Reglas de diseño

### 2.1 Identidad
- La estética sale del logo real: un loto en acuarela rosa con mariposas en pastel (lila, menta, amarillo) y un rostro de línea fina.
- Debe sentirse cálida, femenina y cuidada, sin exceso. Nada de neón, degradados morados ni fondos oscuros.
- Siempre se usan fotos **reales** de trabajos de Tatiana. No se usan fotos de banco.

### 2.2 Paleta (tokens)
| Token | Hex | Uso |
|---|---|---|
| `--bg` | `#FFFBFC` | Fondo general |
| `--white` | `#FFFFFF` | Tarjetas, barra superior, formulario |
| `--petal` | `#FBEFF3` | Franjas, sección Agendar, talón del tiquete |
| `--line` | `#F1D6DF` | Bordes suaves y separadores |
| `--ink` | `#1E1A1C` | Texto principal, botón con borde |
| `--muted` | `#6B5A62` | Texto secundario (6,3:1 sobre `--bg`) |
| `--rose` | `#B03A62` | Acento: botón principal, palabra manuscrita, enlaces de acción (5,8:1 con blanco) |
| `--field` | `#A87485` | Bordes de campos y botones de hora (≥3:1) |
| `--wa` | `#0F7A3F` | Todo lo que abre WhatsApp, y nada más (5,4:1 con blanco) |
| `--lilac` / `--mint` / `--butter` | `#F1ECFA` / `#EAF7F2` / `#FBF5DC` | Fondo de las tarjetas Cejas y labios / Facial / Cabello (los colores de las mariposas) |
| Error | `#B3261E`, caja `#FBE3E1` + borde `#E6A49D` | Alertas y validación |
| Éxito | `#DDF3E6` + `--wa` | Ícono de confirmación |

Reglas:
- El rosa se reserva para **una** acción principal por pantalla. Los precios van en `--ink`.
- El verde significa siempre "abre WhatsApp".
- La página es de un solo tema (claro), y esto es una decisión de marca.

### 2.3 Tipografía
| Rol | Fuente | Uso |
|---|---|---|
| Manuscrita | **Allura** | Solo el nombre "Tatiana Quiceno" y, como mucho, 2 palabras de énfasis por página ("mejores manos", "cupo"). Va a 1,3 em del título. |
| Títulos | **Marcellus** | H1–H3, precios, etiquetas en mayúsculas espaciadas (0,2–0,34 em), como "ESTÉTICA INTEGRAL" en el logo. |
| Texto | **Figtree** | Párrafos, formularios y botones. Base de 16 px e interlineado de 1,6. |

- H1: `clamp(42px, 6vw, 76px)` · H2: `clamp(36px, 4.6vw, 56px)`.
- Los títulos llevan `text-wrap: balance` y los números `tabular-nums`.

### 2.4 Composición
- Columna máxima de 1240 px, márgenes laterales de `max(20px, safe-area)` y secciones con 80 px de aire vertical (56 px en el celular).
- **Arco** (`border-radius: 150–220px 150–220px 18–24px 18–24px`): es el sello visual. Se usa en la foto principal y alterna con esquinas rectas en la galería.
- Esquinas: 18 px para fotos y 24 px para tarjetas. Los botones son tipo píldora.
- Orden de la página: Hero → Franja de servicios → **Trabajos reales** → Servicios y precios → Agendar → Visítanos + preguntas → Pie.
- En el celular (≤760 px) la foto del hero va **antes** que el texto. En la barra superior quedan solo el logo y WhatsApp (≤640 px), y aparece el botón flotante de WhatsApp.

### 2.5 Componentes
- **Tiquete de oferta:** una parte principal con servicio y precio, y un talón punteado con información secundaria.
- **Carta de precios:** nombre, puntos guía y precio en la misma línea; debajo, el detalle y "Agendar →". Las líneas se separan con un borde de 1 px.
- **Botones de hora:** píldoras con borde `--field`. La seleccionada tiene fondo `--rose`, texto blanco y `aria-pressed="true"`.
- **Alerta** (`role="alert"`): caja roja suave con texto claro que dice qué pasó y qué hacer.
- **Confirmación** (`role="status"`): ícono de chulo verde, "¡Listo, {nombre}! Tu cita quedó reservada", el resumen, un botón verde de WhatsApp y "Hacer otra reserva".
- **Burbuja de WhatsApp:** muestra en vivo el mensaje que se va a enviar.

### 2.6 Voz y textos
- Se habla de tú, en español de Colombia, con frases cortas.
- Los botones dicen exactamente lo que pasa: "Reservar mi cita", "Avisarle a Tatiana por WhatsApp" y "Ver trabajos".
- Los errores dicen qué falló y cómo arreglarlo, sin pedir disculpas.
- Formatos: `$100.000`, `9:00 a. m.`, `lunes, 26 de octubre`.
- No se inventan reseñas, cifras ni urgencias falsas.

### 2.7 Accesibilidad (mínimos)
- Contraste del texto ≥4,5:1 y de bordes de controles ≥3:1.
- Áreas táctiles ≥44 px.
- Todo campo tiene su `<label>` y toda foto su `alt` descriptivo (las decorativas, `alt=""`).
- El foco es visible (`outline 3px --rose`) y se respeta `prefers-reduced-motion`.

---

## 3. Contrato de la aplicación

### 3.1 Arquitectura
```
web/index.html        Página pública (HTML + CSS + JS sin dependencias)
web/panel/index.html  Panel de Tatiana (supabase-js 2.49.4 desde jsDelivr)
web/privacidad.html   Política de datos (Ley 1581)
supabase/migrations/  Esquema de la base de datos
        │
        ▼
Supabase (PostgreSQL 17, us-east-1) · proyecto tatiana-quiceno-citas
Hosting: Vercel (sitio estático, carpeta raíz: web)
```

### 3.2 Reglas de negocio
Las reglas se validan **en la base de datos**. La página las repite solo para mostrar opciones válidas, y no se pueden saltar desde el navegador.

| # | Regla | Dónde se aplica |
|---|---|---|
| R1 | Lunes a viernes de 8:00 a 18:00; sábados de 8:00 a 14:00; domingos cerrado | Trigger `validar_reserva` + página |
| R2 | El servicio debe **terminar** a más tardar a la hora de cierre | Trigger + página |
| R3 | Las citas empiezan en punto o y media (bloques de 30 min) | Trigger + página |
| R4 | La duración la define la tabla `servicios`. La hora de fin la calcula el servidor | Trigger |
| R5 | **Dos reservas activas nunca se cruzan** (pendiente, confirmada o asistió) | Restricción `reservas_sin_cruces` (EXCLUDE con gist) |
| R6 | Las reservas web se piden con mínimo 1 h de anticipación y máximo 60 días adelante | Trigger + página |
| R7 | Máximo 2 citas activas futuras por celular desde la web | Trigger |
| R8 | Una cita cancelada o marcada como "no vino" libera su horario | Condición `where` de R5 |
| R9 | Las reservas web entran siempre como `pendiente` y canal `web` | Trigger + política RLS |
| R10 | Las administradoras pueden agregar citas manuales (WhatsApp, Instagram, en persona) y mover citas. Se respetan R1–R5 | Trigger + panel |

**Duraciones** (supuestas, **por confirmar con Tatiana**; se cambian en la tabla `servicios`):

| Servicio | Precio | Duración |
|---|---|---|
| Clásicas y efecto pestañina | $100.000 | 2 h |
| Hawaiano 2D | $120.000 | 2 h 30 |
| Tecnológicas 3D, 4D y 5D | $150.000 | 3 h |
| Retoque de pestañas | $100.000 | 1 h 30 |
| Micropigmentación de cejas (retoque $100.000) | $150.000 | 2 h 30 |
| Micropigmentación de labios (retoque $200.000) | $250.000 | 2 h 30 |
| Limpieza facial | desde $100.000 | 1 h 30 |
| Alisado orgánico (hasta media espalda) | $200.000 | 3 h |
| Alisado orgánico largo | $250.000 | 4 h |

### 3.3 Estados de una reserva
```
pendiente ──Confirmar──► confirmada ──Asistió──► asistio ──(14–30 días)──► "Retoques por ofrecer"
    │                        │
    └──Cancelar──► cancelada ◄┘──No vino──► no_vino
          └──────── Volver a pendiente ────────┘
```
`pendiente`, `confirmada` y `asistio` ocupan horario. `cancelada` y `no_vino` lo liberan.

### 3.4 Modelo de datos
**`servicios`**: `nombre` (PK), `grupo`, `precio` (int, COP), `precio_txt`, `duracion_min` (30–300, múltiplo de 30), `orden`, `activo`.

**`reservas`**
| Columna | Tipo | Notas |
|---|---|---|
| `id` | uuid | PK |
| `creada_en` | timestamptz | `now()` |
| `canal` | `web` \| `manual` | |
| `nombre` | text | 2–80 caracteres |
| `celular` | text | `^3[0-9]{9}$` (10 dígitos, sin +57) |
| `servicio` | text | FK → `servicios.nombre` |
| `precio` | int | Lo copia el servidor desde `servicios` |
| `inicio` / `fin` | timestamptz | `fin` lo calcula el servidor |
| `origen`, `utm_source`, `utm_campaign`, `utm_content` | text | ≤120 caracteres |
| `acepta_datos` | bool | Obligatorio `true` en canal web |
| `estado` | text | Ver 3.3 |
| `valor_pagado` | int | Lo que realmente pagó |
| `notas` | text | ≤500 caracteres |
| `actualizada_en` | timestamptz | Lo pone el trigger |

**`administradoras`**: `email` (PK, en minúsculas). Quien esté aquí y tenga usuario en Supabase Auth entra al panel.

### 3.5 Permisos
| Acción | Página pública (`anon`) | Administradora (`authenticated` + en la lista) | Otro usuario autenticado |
|---|---|---|---|
| Ver servicios | ✅ | ✅ | ✅ |
| Ver horarios ocupados (solo inicio/fin) | ✅ `rpc/horarios_ocupados` | ✅ | ✅ |
| Crear reserva | ✅ solo columnas permitidas, estado pendiente | ✅ cualquier estado | ❌ |
| Leer, editar o borrar reservas | ❌ | ✅ | ❌ |
| Leer la lista de administradoras | ❌ | ❌ | ❌ |

La llave publicable (`sb_publishable_…`) va en el código y es pública por diseño. La seguridad depende de RLS y de los permisos de cada columna. **La llave de servicio (service role) nunca va en el código.**

### 3.6 API que usa la página
Base: `https://qhdgdjfatrizsztrpntl.supabase.co`. Encabezados: `apikey: <llave publicable>`, `Content-Type: application/json`.

| Llamada | Para qué | Respuesta |
|---|---|---|
| `GET /rest/v1/servicios?select=nombre,duracion_min` | Duración real de cada servicio | `[{nombre, duracion_min}]` |
| `POST /rest/v1/rpc/horarios_ocupados` `{desde, hasta}` (ISO con `-05:00`, máximo 62 días) | Pintar solo las horas libres | `[{inicio, fin}]` |
| `POST /rest/v1/reservas` + `Prefer: return=minimal` | Reservar | `201` sin cuerpo |

**Errores y mensajes en pantalla:**
| Respuesta | Significa | Mensaje |
|---|---|---|
| `409`, `code: 23P01` | Otra persona tomó esa hora | "Esa hora ya fue reservada por otra persona hace un momento. Te mostramos las horas que siguen libres: elige otra." La página recarga las horas libres. |
| `P0001`, mensaje `FUERA_DE_HORARIO: …` | Rompe R1, R2, R3 o R6 | "Esa hora está fuera del horario de atención: {detalle}." |
| `P0001`, mensaje `LIMITE_CITAS: …` | Rompe R7 | "Este celular ya tiene 2 citas activas. Escríbele a Tatiana por WhatsApp si quieres cambiarlas." |
| Error de red u otro | — | "No pudimos guardar tu reserva. Revisa tu conexión y vuelve a intentar, o escríbenos por WhatsApp." |
| `201` | Reserva creada | Tarjeta de confirmación + botón de WhatsApp con el resumen |

### 3.7 Página pública: comportamiento
1. Al elegir servicio y día, consulta los horarios ocupados y pinta solo los inicios posibles: cada 30 min, que no se crucen, que terminen antes del cierre y que estén al menos 1 h en el futuro.
2. Campos obligatorios: nombre, celular colombiano, servicio, día, hora y autorización de datos.
3. Al tocar "Reservar mi cita" guarda la reserva. Solo si se guardó, muestra la confirmación y el botón de WhatsApp.
4. El mensaje de WhatsApp incluye servicio, día, hora, nombre, celular y `(Vengo de: {utm_content | utm_campaign | Anuncio de Facebook/Instagram | la página web})`.

### 3.8 Panel (`/panel`)
- Ingreso con correo y contraseña (Supabase Auth). La página no se indexa en buscadores.
- **Pestañas:** Por confirmar · Hoy · Próximas · Asistieron · Todas.
- **Acciones por tarjeta:**
  - Confirmar, con mensaje de confirmación por WhatsApp.
  - Asistió, registrando el valor pagado.
  - No vino.
  - Cancelar.
  - Cambiar día u hora.
  - Recordatorio, reseña y retoque por WhatsApp.
- **Agregar cita manual:** para clientas que escriben por otro canal, así su horario queda bloqueado en la página.
- **Resultados por periodo:**
  - Reservas, confirmadas, asistieron, ventas y costo por clienta (inversión ÷ asistieron).
  - Tabla por origen.
  - La inversión se guarda solo en ese navegador.
- **Retoques por ofrecer:** clientas que vinieron hace entre 14 y 30 días.

### 3.9 Medición
- **Meta Pixel:** se pega el ID en `PIXEL_ID` (en el `<head>` de `web/index.html`). Si está vacío, no carga nada.
- **Eventos:**
  - `PageView` al cargar.
  - `ViewContent` al tocar "Agendar" en un servicio.
  - `Lead` cuando la reserva se guarda.
  - `Contact` al abrir WhatsApp.
- **Convención de enlaces en los anuncios:** `?utm_source=meta&utm_campaign=pestanas-oct&utm_content=anuncio-a` (a, b o c según el creativo). El panel agrupa por `utm_content`.

### 3.10 Datos personales (Ley 1581 de 2012)
- La casilla de autorización es obligatoria en la web y enlaza a `privacidad.html`.
- Solo las administradoras leen los datos. La función pública de horarios no devuelve nombres ni celulares.
- Si una clienta pide borrar sus datos, se borra su fila desde el panel o con SQL.

### 3.11 Puesta en marcha
1. Crear el usuario de Tatiana en Supabase: *Authentication → Users → Add user*, con "Auto confirm".
2. Darle acceso: `insert into public.administradoras (email) values ('correo-de-tatiana');`
3. Recomendado: en *Authentication → Sign In / Providers*, desactivar "Allow new users to sign up".
4. Vercel: importar el repositorio con carpeta raíz `web` y sin comando de build.
5. Pegar el `PIXEL_ID` y ajustar `og:image` al dominio final.
6. Confirmar con Tatiana las duraciones de cada servicio y actualizarlas en `servicios`.

### 3.12 Pendientes y riesgos conocidos
- **Duraciones supuestas:** hay que confirmarlas.
- **Reservas falsas:** alguien podría apartar horarios en masa. Hoy esto se mitiga con R7 y con la cancelación desde el panel. Si pasa, se puede agregar un captcha (Cloudflare Turnstile) o un límite por IP con una Edge Function.
- **Tabla vieja `citas`:** existe en la base de datos, vacía y sin permisos. Se puede borrar cuando se quiera.
- **Recordatorios:** hoy son manuales (con un botón). Se podrían automatizar con la API de WhatsApp Business.
- **Bloqueos de agenda** (vacaciones, almuerzo): hoy se hacen agregando una cita manual. Más adelante convendría una tabla `bloqueos`.

---

*Desarrollado por uil-dev (uilholguin.dev).*
