-- Updates helper functions and RLS policies to prevent recursive evaluation
-- and ensure participants can view the full attendee list.

create or replace function public.user_is_appointment_creator(app_id uuid)
returns boolean
security definer
set search_path = public
set row_security = off
language sql
as $$
  select exists (
    select 1
    from appointments
    where appointment_id = app_id
      and creator_id = auth.uid()
  );
$$;

create or replace function public.user_is_appointment_participant(app_id uuid)
returns boolean
security definer
set search_path = public
set row_security = off
language sql
as $$
  select exists (
    select 1
    from appointment_participants
    where appointment_id = app_id
      and user_id = auth.uid()
  );
$$;

alter table public.appointments enable row level security;
alter table public.appointment_participants enable row level security;

-- Appointments SELECT policy
create policy if not exists "Appointments select accessible" on public.appointments
  for select to authenticated
  using (
    (creator_id = auth.uid())
    or public.user_is_appointment_participant(appointment_id)
    or public.user_is_appointment_creator(appointment_id)
  );

-- Participants policies
create policy if not exists "Participants select accessible" on public.appointment_participants
  for select to authenticated
  using (
    (user_id = auth.uid())
    or public.user_is_appointment_creator(appointment_id)
    or public.user_is_appointment_participant(appointment_id)
  );

create policy if not exists "Participants insert allowed" on public.appointment_participants
  for insert to authenticated
  with check (
    (user_id = auth.uid())
    or public.user_is_appointment_creator(appointment_id)
  );

create policy if not exists "Participants update allowed" on public.appointment_participants
  for update to authenticated
  using (
    (auth.uid() = user_id)
    or public.user_is_appointment_creator(appointment_id)
  )
  with check (
    (auth.uid() = user_id)
    or public.user_is_appointment_creator(appointment_id)
  );

create policy if not exists "Participants delete allowed" on public.appointment_participants
  for delete to authenticated
  using (
    (auth.uid() = user_id)
    or public.user_is_appointment_creator(appointment_id)
  );
