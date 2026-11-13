-- ARDEN EL CABALLERO - actualización de estadísticas (no borra los datos existentes).
-- Ejecutar una sola vez, o repetir si se necesita. Conserve el script original de tablas.

alter table public.player_progress
  add column if not exists total_relics integer not null default 0,
  add column if not exists bosses_defeated integer not null default 0,
  add column if not exists total_deaths integer not null default 0,
  add column if not exists best_time_seconds integer,
  add column if not exists monsters_defeated integer not null default 0,
  add column if not exists rooms_cleared integer not null default 0;

alter table public.level_history
  add column if not exists boss_type text,
  add column if not exists monsters_defeated integer not null default 0,
  add column if not exists rooms_cleared integer not null default 0;

alter table public.player_progress enable row level security;
alter table public.level_history enable row level security;

-- Se mantienen las políticas RLS existentes creadas por ARDEN_SUPABASE_SETUP.sql.
-- Cada usuario sigue pudiendo consultar solo sus registros.

-- Idempotente: si el navegador reintenta una victoria ya registrada, devuelve
-- el nivel desbloqueado sin sumar dos veces los puntos.
create or replace function public.complete_arden_level_stats(
 p_level integer,
 p_seconds integer,
 p_relics integer,
 p_chests integer,
 p_boss text,
 p_monsters integer,
 p_rooms integer
) returns integer
language plpgsql
security invoker
set search_path = ''
as $$
declare
 v_user uuid := auth.uid();
 v_level integer;
begin
 if v_user is null then raise exception 'Debes iniciar sesión'; end if;
 if p_level not between 1 and 99999 or p_seconds not between 0 and 604800
    or p_relics not between 0 and 1000 or p_chests not between 0 and 1000
    or p_monsters not between 0 and 10000 or p_rooms not between 0 and 1000
    or p_boss not in ('golem','specter','mage') then
   raise exception 'Estadísticas inválidas';
 end if;

 select current_level into v_level
 from public.player_progress where user_id=v_user for update;
 if v_level is null then raise exception 'No existe el progreso del usuario'; end if;
 if p_level=v_level-1 and exists (
   select 1 from public.level_history where user_id=v_user and level_number=p_level
 ) then return v_level; end if;
 if p_level<>v_level then raise exception 'Nivel no corresponde al progreso'; end if;

 insert into public.level_history
 (user_id,level_number,elapsed_seconds,relics,chests_opened,boss_type,monsters_defeated,rooms_cleared)
 values(v_user,p_level,p_seconds,p_relics,p_chests,p_boss,p_monsters,p_rooms);

 update public.player_progress
 set current_level=p_level+1,
     completed_levels=p_level,
     total_relics=total_relics+p_relics,
     bosses_defeated=bosses_defeated+1,
     monsters_defeated=monsters_defeated+p_monsters,
     rooms_cleared=rooms_cleared+p_rooms,
     best_time_seconds=least(coalesce(best_time_seconds,p_seconds),p_seconds),
     updated_at=now()
 where user_id=v_user;
 return p_level+1;
end;
$$;

-- Registra una muerte cuando se agotan las vidas. La partida no avanza.
create or replace function public.record_arden_death(p_level integer)
returns integer
language plpgsql
security invoker
set search_path = ''
as $$
declare
 v_user uuid := auth.uid();
 v_deaths integer;
begin
 if v_user is null then raise exception 'Debes iniciar sesión'; end if;
 update public.player_progress
 set total_deaths=total_deaths+1, updated_at=now()
 where user_id=v_user and current_level=p_level
 returning total_deaths into v_deaths;
 if v_deaths is null then raise exception 'Nivel no válido'; end if;
 return v_deaths;
end;
$$;

revoke all on function public.complete_arden_level_stats(integer,integer,integer,integer,text,integer,integer) from public, anon;
grant execute on function public.complete_arden_level_stats(integer,integer,integer,integer,text,integer,integer) to authenticated;
revoke all on function public.record_arden_death(integer) from public, anon;
grant execute on function public.record_arden_death(integer) to authenticated;

-- Comprobación básica tras ejecutar:
select column_name from information_schema.columns
where table_schema='public' and table_name='player_progress'
and column_name in ('total_relics','bosses_defeated','total_deaths','best_time_seconds','monsters_defeated','rooms_cleared');

-- PROTOTIPO: al ejecutarse el juego en GitHub Pages, el navegador sigue siendo
-- no confiable y un usuario avanzado puede enviar resultados falsos al RPC.
-- Antes de rankings/competición: validar la partida en un servidor/Edge Function
-- confiable, y restringir escrituras directas a las tablas.
