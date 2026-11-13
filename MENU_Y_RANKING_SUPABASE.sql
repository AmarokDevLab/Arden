-- ARDEN: EL LABERINTO ARCANO — v7
-- Ejecutar en el SQL Editor del proyecto de desarrollo de Supabase.
-- Requiere haber ejecutado los scripts base y de estadísticas anteriores.
-- Mantiene cuentas, progreso y estadísticas existentes sin modificarlos.

-- Perfil opcional: nunca se exponen direcciones de correo ni identificadores en el ranking.
create table if not exists public.arden_ranking_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null check (
    char_length(nickname) between 3 and 18
    and nickname ~ '^[[:alnum:]_ -]+$'
  ),
  visible boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.arden_ranking_profiles enable row level security;
revoke all on table public.arden_ranking_profiles from anon, authenticated;
grant select, insert, update on public.arden_ranking_profiles to authenticated;

drop policy if exists arden_ranking_profile_read_own on public.arden_ranking_profiles;
drop policy if exists arden_ranking_profile_insert_own on public.arden_ranking_profiles;
drop policy if exists arden_ranking_profile_update_own on public.arden_ranking_profiles;

create policy arden_ranking_profile_read_own on public.arden_ranking_profiles
 for select to authenticated using ((select auth.uid())=user_id);
create policy arden_ranking_profile_insert_own on public.arden_ranking_profiles
 for insert to authenticated with check ((select auth.uid())=user_id);
create policy arden_ranking_profile_update_own on public.arden_ranking_profiles
 for update to authenticated using ((select auth.uid())=user_id)
 with check ((select auth.uid())=user_id);

-- Consulta controlada: solamente muestra alias y estadísticas de participantes voluntarios.
-- Función con privilegios elevados restringida a SELECT fijo, sin SQL dinámico,
-- sin datos de autenticación y sin permitir alterar las cuentas de otros usuarios.
create or replace function public.get_arden_ranking()
returns table (
 nickname text,
 completed_levels integer,
 bosses_defeated integer,
 total_relics integer,
 best_time_seconds integer,
 is_me boolean
)
language plpgsql stable security definer set search_path = ''
as $$
begin
 if (select auth.uid()) is null then
  raise exception 'Inicia sesión para consultar la clasificación';
 end if;
 return query
 select p.nickname, g.completed_levels, g.bosses_defeated,
        g.total_relics, g.best_time_seconds,
        p.user_id = (select auth.uid()) as is_me
 from public.arden_ranking_profiles p
 join public.player_progress g on g.user_id = p.user_id
 where p.visible = true
 order by g.completed_levels desc, g.bosses_defeated desc,
          g.total_relics desc, g.best_time_seconds asc nulls last, p.nickname asc
 limit 100;
end;
$$;
revoke all on function public.get_arden_ranking() from public, anon;
grant execute on function public.get_arden_ranking() to authenticated;

-- Nueva partida: elimina SOLAMENTE los datos de aventura de la cuenta activa.
-- Conserva la cuenta Supabase y el alias elegido para el ranking.
-- El juego solicita confirmación antes de invocar esta función.
create or replace function public.reset_arden_adventure()
returns boolean
language plpgsql security invoker set search_path = ''
as $$
declare v_uid uuid := auth.uid();
begin
 if v_uid is null then raise exception 'Debes iniciar sesión'; end if;
 delete from public.level_history where user_id = v_uid;
 update public.player_progress
 set current_level=1,
     completed_levels=0,
     total_relics=0,
     bosses_defeated=0,
     total_deaths=0,
     best_time_seconds=null,
     monsters_defeated=0,
     rooms_cleared=0,
     updated_at=now()
 where user_id=v_uid;
 if not found then raise exception 'No existe progreso para esta cuenta'; end if;
 return true;
end;
$$;

-- Solo el propietario puede borrar su historial; la función usa SECURITY INVOKER.
-- IMPORTANTE: este permiso también permite borrar el propio historial desde la API
-- de Supabase. Para un ranking competitivo, mover esta operación a una capa
-- de servidor confiable y retirar el permiso directo de DELETE.
grant delete on public.level_history to authenticated;
drop policy if exists arden_history_delete_own on public.level_history;
create policy arden_history_delete_own on public.level_history
 for delete to authenticated using ((select auth.uid())=user_id);
revoke all on function public.reset_arden_adventure() from public, anon;
grant execute on function public.reset_arden_adventure() to authenticated;

-- Verificación básica del esquema (no toca datos de jugadores):
select routine_name from information_schema.routines
where routine_schema='public' and routine_name in ('get_arden_ranking','reset_arden_adventure');
