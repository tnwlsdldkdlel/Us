-- Adds location metadata columns to the appointments table.
-- Run with: supabase db push or supabase db remote commit

alter table if exists public.appointments
  add column if not exists address text,
  add column if not exists latitude double precision,
  add column if not exists longitude double precision;

-- Optionally ensure updated_at is refreshed when records change.
create or replace function public.handle_appointments_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger appointments_set_updated_at
  before update on public.appointments
  for each row
  execute function public.handle_appointments_updated_at();
