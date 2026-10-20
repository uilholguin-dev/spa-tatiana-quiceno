-- =====================================================================
-- Spa Tatiana Quiceno · Esquema de agenda (Supabase / PostgreSQL 17)
-- Estado actual de la base de datos. Ejecutar en un proyecto nuevo.
-- =====================================================================

-- ---------- Administradoras (quién puede entrar al panel) ----------
create table public.administradoras (
  email text primary key check (email = lower(email))
);
alter table public.administradoras enable row level security;
revoke all on public.administradoras from anon, authenticated;
-- Sin políticas: solo el servidor (service role / SQL editor) administra esta lista.

create or replace function public.es_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.administradoras a
    where a.email = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.es_admin() from public;
grant execute on function public.es_admin() to anon, authenticated; -- para anon siempre devuelve false

-- ---------- Catálogo de servicios ----------
create table public.servicios (
  nombre text primary key,
  grupo text not null,
  precio integer not null check (precio >= 0),
  precio_txt text not null,
  duracion_min integer not null check (duracion_min between 30 and 300 and duracion_min % 30 = 0),
  orden integer not null default 0,
  activo boolean not null default true
);
alter table public.servicios enable row level security;
revoke all on public.servicios from anon, authenticated;
grant select on public.servicios to anon, authenticated;
create policy "servicios visibles" on public.servicios for select to anon, authenticated using (activo);

insert into public.servicios (nombre, grupo, precio, precio_txt, duracion_min, orden) values
  ('Clásicas y efecto pestañina',  'Pestañas', 100000, '$100.000', 120, 1),
  ('Hawaiano 2D',                  'Pestañas', 120000, '$120.000', 150, 2),
  ('Tecnológicas 3D, 4D y 5D',     'Pestañas', 150000, '$150.000', 180, 3),
  ('Retoque de pestañas',          'Pestañas', 100000, '$100.000',  90, 4),
  ('Micropigmentación de cejas',   'Cejas y labios', 150000, '$150.000', 150, 5),
  ('Micropigmentación de labios',  'Cejas y labios', 250000, '$250.000', 150, 6),
  ('Limpieza facial',              'Facial',   100000, 'desde $100.000', 90, 7),
  ('Alisado orgánico',             'Cabello',  200000, '$200.000', 180, 8),
  ('Alisado orgánico largo',       'Cabello',  250000, '$250.000', 240, 9);

-- ---------- Reservas ----------
create table public.reservas (
  id uuid primary key default gen_random_uuid(),
  creada_en timestamptz not null default now(),
  canal text not null default 'web' check (canal in ('web','manual')),
  nombre text not null check (char_length(btrim(nombre)) between 2 and 80),
  celular text not null check (celular ~ '^3[0-9]{9}$'),
  servicio text not null references public.servicios(nombre) on update cascade,
  precio integer,
  inicio timestamptz not null,
  fin timestamptz not null,
  origen text check (char_length(origen) <= 120),
  utm_source text check (char_length(utm_source) <= 120),
  utm_campaign text check (char_length(utm_campaign) <= 120),
  utm_content text check (char_length(utm_content) <= 120),
  acepta_datos boolean not null default false,
  estado text not null default 'pendiente'
    check (estado in ('pendiente','confirmada','asistio','no_vino','cancelada')),
  valor_pagado integer check (valor_pagado >= 0),
  notas text check (char_length(notas) <= 500),
  actualizada_en timestamptz,
  check (fin > inicio),
  check (canal = 'manual' or acepta_datos),
  -- Dos reservas activas nunca se cruzan en el tiempo (garantizado por la base de datos)
  constraint reservas_sin_cruces exclude using gist (tstzrange(inicio, fin, '[)') with &&)
    where (estado in ('pendiente','confirmada','asistio'))
);
create index reservas_inicio_idx on public.reservas (inicio);
create index reservas_creada_idx on public.reservas (creada_en desc);

-- ---------- Reglas de horario ----------
create or replace function public.validar_reserva()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  s record;
  local_ini timestamp;
  local_fin timestamp;
  dia int;
  cierre time;
  activas int;
  admin boolean := public.es_admin();
begin
  select * into s from public.servicios where nombre = new.servicio;
  if not found then
    raise exception 'SERVICIO_INVALIDO: el servicio no existe' using errcode = 'P0001';
  end if;

  if tg_op = 'INSERT' or new.inicio is distinct from old.inicio or new.servicio is distinct from old.servicio then
    new.fin := new.inicio + make_interval(mins => s.duracion_min);
    local_ini := new.inicio at time zone 'America/Bogota';
    local_fin := new.fin at time zone 'America/Bogota';
    dia := extract(isodow from local_ini);
    cierre := case when dia = 6 then time '14:00' else time '18:00' end;

    if dia = 7 then
      raise exception 'FUERA_DE_HORARIO: los domingos no se atiende' using errcode = 'P0001';
    end if;
    if extract(minute from local_ini)::int % 30 <> 0 or extract(second from local_ini) <> 0 then
      raise exception 'FUERA_DE_HORARIO: las citas empiezan en punto o y media' using errcode = 'P0001';
    end if;
    if local_ini::time < time '08:00' or local_fin::date <> local_ini::date or local_fin::time > cierre then
      raise exception 'FUERA_DE_HORARIO: el servicio debe empezar desde las 8:00 a. m. y terminar a más tardar a las %', to_char(cierre, 'HH24:MI') using errcode = 'P0001';
    end if;
  end if;

  if tg_op = 'INSERT' then
    if new.precio is null then new.precio := s.precio; end if;
    if not admin then
      new.canal := 'web';
      new.estado := 'pendiente';
      if new.inicio < now() + interval '1 hour' then
        raise exception 'FUERA_DE_HORARIO: la cita debe pedirse con al menos 1 hora de anticipación' using errcode = 'P0001';
      end if;
      if new.inicio > now() + interval '60 days' then
        raise exception 'FUERA_DE_HORARIO: solo se agenda hasta 60 días adelante' using errcode = 'P0001';
      end if;
      select count(*) into activas from public.reservas
        where celular = new.celular and estado in ('pendiente','confirmada') and inicio > now();
      if activas >= 2 then
        raise exception 'LIMITE_CITAS: este celular ya tiene 2 citas activas' using errcode = 'P0001';
      end if;
    end if;
  else
    new.actualizada_en := now();
  end if;
  return new;
end;
$$;
revoke all on function public.validar_reserva() from public, anon, authenticated;

create trigger reservas_validar
  before insert or update on public.reservas
  for each row execute function public.validar_reserva();

-- ---------- Permisos ----------
alter table public.reservas enable row level security;
revoke all on public.reservas from anon, authenticated;

-- Página pública: solo agrega, solo estas columnas, nunca lee
grant insert (nombre, celular, servicio, inicio, origen, utm_source, utm_campaign, utm_content, acepta_datos)
  on public.reservas to anon;
create policy "pagina publica reserva" on public.reservas for insert to anon
  with check (estado = 'pendiente' and canal = 'web');

-- Administradoras: todo
grant select, insert, update, delete on public.reservas to authenticated;
create policy "admin lee reservas" on public.reservas for select to authenticated using ((select public.es_admin()));
create policy "admin agrega reservas" on public.reservas for insert to authenticated with check ((select public.es_admin()));
create policy "admin actualiza reservas" on public.reservas for update to authenticated
  using ((select public.es_admin())) with check ((select public.es_admin()));
create policy "admin borra reservas" on public.reservas for delete to authenticated using ((select public.es_admin()));

-- ---------- Horarios ocupados (sin datos personales) ----------
create or replace function public.horarios_ocupados(desde timestamptz, hasta timestamptz)
returns table (inicio timestamptz, fin timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select r.inicio, r.fin
  from public.reservas r
  where r.estado in ('pendiente','confirmada','asistio')
    and r.fin > desde
    and r.inicio < least(hasta, desde + interval '62 days')
  order by r.inicio;
$$;
revoke all on function public.horarios_ocupados(timestamptz, timestamptz) from public;
grant execute on function public.horarios_ocupados(timestamptz, timestamptz) to anon, authenticated;

-- ---------- Alta de una administradora ----------
-- 1) Supabase > Authentication > Users > Add user (correo + contraseña, "Auto confirm").
-- 2) insert into public.administradoras (email) values ('correo@ejemplo.com');
