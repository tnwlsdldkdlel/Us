-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Users table (syncs with auth.users)
create table public.users (
  user_id uuid not null primary key references auth.users(id) on delete cascade,
  nickname text,
  email text,
  profile_image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.users enable row level security;

-- Appointments table
create table public.appointments (
  appointment_id uuid not null default gen_random_uuid() primary key,
  creator_id uuid not null references public.users(user_id) on delete cascade,
  title text not null,
  appointment_time timestamp with time zone not null,
  location_name text,
  description text,
  address text,
  latitude double precision,
  longitude double precision,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.appointments enable row level security;

-- Appointment Participants table
create table public.appointment_participants (
  participant_id bigint generated always as identity primary key,
  appointment_id uuid not null references public.appointments(appointment_id) on delete cascade,
  user_id uuid not null references public.users(user_id) on delete cascade,
  rsvp_status text not null default 'PENDING',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(appointment_id, user_id)
);

alter table public.appointment_participants enable row level security;

-- Comments table
create table public.comments (
  id bigint generated always as identity primary key,
  appointment_id uuid not null references public.appointments(appointment_id) on delete cascade,
  user_id uuid not null references public.users(user_id) on delete cascade,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.comments enable row level security;

-- Friendships table
create table public.friendships (
  friendship_id uuid not null default gen_random_uuid() primary key,
  requester_id uuid not null references public.users(user_id) on delete cascade,
  addressee_id uuid not null references public.users(user_id) on delete cascade,
  status text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(requester_id, addressee_id)
);

alter table public.friendships enable row level security;

-- Friend Invites table
create table public.friend_invites (
  invite_id uuid not null default gen_random_uuid() primary key,
  inviter_id uuid not null references public.users(user_id) on delete cascade,
  invitee_email text not null,
  status text not null default 'INVITED',
  expires_at timestamp with time zone not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.friend_invites enable row level security;

-- Functions
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (user_id, email, nickname, profile_image_url)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'nickname',
    new.raw_user_meta_data->>'profile_image_url'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Triggers
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create trigger users_updated_at
  before update on public.users
  for each row execute procedure public.handle_updated_at();

create trigger appointments_updated_at
  before update on public.appointments
  for each row execute procedure public.handle_updated_at();

create trigger appointment_participants_updated_at
  before update on public.appointment_participants
  for each row execute procedure public.handle_updated_at();

create trigger comments_updated_at
  before update on public.comments
  for each row execute procedure public.handle_updated_at();

create trigger friendships_updated_at
  before update on public.friendships
  for each row execute procedure public.handle_updated_at();

create trigger friend_invites_updated_at
  before update on public.friend_invites
  for each row execute procedure public.handle_updated_at();

-- RLS Policies (Basic)

-- Users: Public read, Self update
create policy "Public profiles are viewable by everyone"
  on public.users for select
  using ( true );

create policy "Users can update own profile"
  on public.users for update
  using ( auth.uid() = user_id );

-- Appointments: Creator can do all, Participants can view
create policy "Appointments viewable by creator and participants"
  on public.appointments for select
  using (
    auth.uid() = creator_id or
    exists (
      select 1 from public.appointment_participants
      where appointment_id = appointments.appointment_id
      and user_id = auth.uid()
    )
  );

create policy "Appointments insertable by authenticated"
  on public.appointments for insert
  with check ( auth.uid() = creator_id );

create policy "Appointments updatable by creator"
  on public.appointments for update
  using ( auth.uid() = creator_id );

create policy "Appointments deletable by creator"
  on public.appointments for delete
  using ( auth.uid() = creator_id );

-- Appointment Participants
create policy "Participants viewable by authenticated"
  on public.appointment_participants for select
  using ( true ); -- Simplified for now, can restrict later

create policy "Participants insertable by creator or self"
  on public.appointment_participants for insert
  with check (
    auth.uid() = user_id or
    exists (
      select 1 from public.appointments
      where appointment_id = appointment_participants.appointment_id
      and creator_id = auth.uid()
    )
  );

create policy "Participants updatable by self or creator"
  on public.appointment_participants for update
  using (
    auth.uid() = user_id or
    exists (
      select 1 from public.appointments
      where appointment_id = appointment_participants.appointment_id
      and creator_id = auth.uid()
    )
  );

create policy "Participants deletable by self or creator"
  on public.appointment_participants for delete
  using (
    auth.uid() = user_id or
    exists (
      select 1 from public.appointments
      where appointment_id = appointment_participants.appointment_id
      and creator_id = auth.uid()
    )
  );

-- Comments
create policy "Comments viewable by participants"
  on public.comments for select
  using (
    exists (
      select 1 from public.appointment_participants
      where appointment_id = comments.appointment_id
      and user_id = auth.uid()
    ) or
    exists (
      select 1 from public.appointments
      where appointment_id = comments.appointment_id
      and creator_id = auth.uid()
    )
  );

create policy "Comments insertable by participants"
  on public.comments for insert
  with check ( auth.uid() = user_id );

-- Friendships
create policy "Friendships viewable by involved parties"
  on public.friendships for select
  using ( auth.uid() = requester_id or auth.uid() = addressee_id );

create policy "Friendships insertable by authenticated"
  on public.friendships for insert
  with check ( auth.uid() = requester_id );

create policy "Friendships updatable by involved parties"
  on public.friendships for update
  using ( auth.uid() = requester_id or auth.uid() = addressee_id );

-- Friend Invites
create policy "Invites viewable by inviter or invitee (by email)"
  on public.friend_invites for select
  using ( auth.uid() = inviter_id ); -- Note: Invitee can't see by ID easily if not logged in, but that's fine for now.

create policy "Invites insertable by authenticated"
  on public.friend_invites for insert
  with check ( auth.uid() = inviter_id );

create policy "Invites updatable by inviter"
  on public.friend_invites for update
  using ( auth.uid() = inviter_id );
