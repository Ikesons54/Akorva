-- Akorva Phase 1: secure foundation
-- Powered by FWXplus · © Copyright 2026 FWXplus
-- DRAFT: not yet tested. Run only in the DEVELOPMENT project with fictional data.
-- Path in repo: supabase/migrations/20261017000001_foundation.sql

-- ---------- types ----------
create type public.member_role as enum ('owner', 'agent');
create type public.member_status as enum ('invited', 'active', 'suspended');
create type public.approval_status as enum ('pending', 'approved', 'rejected');

-- ---------- tables ----------
create table public.businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  base_currency text not null default 'GHS',
  timezone text not null default 'Africa/Accra',
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users (id),
  full_name text not null,
  phone text,
  created_at timestamptz not null default now()
);

create table public.business_members (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id),
  user_id uuid not null references auth.users (id),
  role public.member_role not null,
  status public.member_status not null default 'invited',
  invited_by uuid references auth.users (id),
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  unique (business_id, user_id)
);

create table public.approval_limits (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id),
  action_type text not null
    check (action_type in ('expense', 'discount', 'refund', 'write_off', 'credit')),
  limit_amount_ghs numeric(18, 2) not null check (limit_amount_ghs >= 0),
  set_by uuid not null references auth.users (id),
  effective_from timestamptz not null default now()
);

create table public.approvals (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id),
  action_type text not null,
  target_type text not null,
  target_id uuid,
  requested_by uuid not null references auth.users (id),
  status public.approval_status not null default 'pending',
  decided_by uuid references auth.users (id),
  decided_at timestamptz,
  reason text,
  created_at timestamptz not null default now(),
  check (decided_by is null or decided_by <> requested_by),
  check (status = 'pending' or (decided_by is not null and decided_at is not null))
);

create table public.files (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id),
  storage_key text not null,
  original_filename text not null,
  content_type text not null,
  uploaded_by uuid not null references auth.users (id),
  uploaded_at timestamptz not null default now()
);

create table public.audit_events (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id),
  actor_user_id uuid references auth.users (id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  reason text,
  before_snapshot jsonb,
  after_snapshot jsonb,
  created_at timestamptz not null default now()
);

create table public.reference_counters (
  business_id uuid not null references public.businesses (id),
  ref_type text not null,
  next_number bigint not null default 1,
  primary key (business_id, ref_type)
);

-- ---------- helper functions ----------
create or replace function public.is_active_member(b uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.business_members m
    where m.business_id = b and m.user_id = auth.uid() and m.status = 'active'
  );
$$;

create or replace function public.is_owner(b uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.business_members m
    where m.business_id = b and m.user_id = auth.uid()
      and m.status = 'active' and m.role = 'owner'
  );
$$;

create or replace function public.shares_business_with(p uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1
    from public.business_members a
    join public.business_members c on c.business_id = a.business_id
    where a.user_id = auth.uid() and a.status = 'active' and c.user_id = p
  );
$$;

-- Permanent, never-reused reference numbers, e.g. SALE-000001
create or replace function public.next_reference(b uuid, t text)
returns text
language plpgsql security definer set search_path = public
as $$
declare n bigint;
begin
  if not public.is_active_member(b) then
    raise exception 'Not allowed';
  end if;
  insert into public.reference_counters (business_id, ref_type, next_number)
  values (b, upper(t), 2)
  on conflict (business_id, ref_type)
  do update set next_number = public.reference_counters.next_number + 1
  returning next_number - 1 into n;
  return upper(t) || '-' || lpad(n::text, 6, '0');
end;
$$;

revoke all on function public.next_reference(uuid, text) from public, anon;
grant execute on function public.next_reference(uuid, text) to authenticated;

-- ---------- audit log is append-only ----------
create or replace function public.block_change()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Audit records cannot be changed or deleted';
end;
$$;

create trigger audit_no_update_delete
  before update or delete on public.audit_events
  for each row execute function public.block_change();

create trigger audit_no_truncate
  before truncate on public.audit_events
  for each statement execute function public.block_change();

-- Every membership change is written to the audit log automatically
create or replace function public.audit_member_change()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  insert into public.audit_events
    (business_id, actor_user_id, action, entity_type, entity_id, before_snapshot, after_snapshot)
  values
    (new.business_id, auth.uid(), tg_op || '_MEMBER', 'business_member', new.id,
     case when tg_op = 'UPDATE' then to_jsonb(old) end, to_jsonb(new));
  return new;
end;
$$;

create trigger trg_audit_members
  after insert or update on public.business_members
  for each row execute function public.audit_member_change();

-- ---------- row-level security ----------
alter table public.businesses enable row level security;
alter table public.profiles enable row level security;
alter table public.business_members enable row level security;
alter table public.approval_limits enable row level security;
alter table public.approvals enable row level security;
alter table public.files enable row level security;
alter table public.audit_events enable row level security;
alter table public.reference_counters enable row level security;

revoke all on all tables in schema public from anon;
revoke all on public.reference_counters from authenticated;

-- businesses: members can read. Creation is done by the owner setup script only.
create policy businesses_select on public.businesses
  for select to authenticated using (public.is_active_member(id));

-- profiles
create policy profiles_select on public.profiles
  for select to authenticated
  using (id = auth.uid() or public.shares_business_with(id));
create policy profiles_insert on public.profiles
  for insert to authenticated with check (id = auth.uid());
create policy profiles_update on public.profiles
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- business_members: only the owner invites or changes members
create policy members_select on public.business_members
  for select to authenticated
  using (user_id = auth.uid() or public.is_active_member(business_id));
create policy members_insert on public.business_members
  for insert to authenticated
  with check (public.is_owner(business_id) and invited_by = auth.uid());
create policy members_update on public.business_members
  for update to authenticated
  using (public.is_owner(business_id)) with check (public.is_owner(business_id));

-- approval_limits: members read, owner adds new rows (history is kept, no edits)
create policy limits_select on public.approval_limits
  for select to authenticated using (public.is_active_member(business_id));
create policy limits_insert on public.approval_limits
  for insert to authenticated
  with check (public.is_owner(business_id) and set_by = auth.uid());

-- approvals: any member requests; only the owner decides, never on own request
create policy approvals_select on public.approvals
  for select to authenticated using (public.is_active_member(business_id));
create policy approvals_insert on public.approvals
  for insert to authenticated
  with check (
    public.is_active_member(business_id)
    and requested_by = auth.uid() and status = 'pending'
  );
create policy approvals_update on public.approvals
  for update to authenticated
  using (
    public.is_owner(business_id) and status = 'pending' and requested_by <> auth.uid()
  )
  with check (
    public.is_owner(business_id)
    and status in ('approved', 'rejected') and decided_by = auth.uid()
  );

-- files: members read and add, nobody edits or deletes
create policy files_select on public.files
  for select to authenticated using (public.is_active_member(business_id));
create policy files_insert on public.files
  for insert to authenticated
  with check (public.is_active_member(business_id) and uploaded_by = auth.uid());

-- audit_events: members read and add, nobody edits or deletes (also blocked by trigger)
create policy audit_select on public.audit_events
  for select to authenticated using (public.is_active_member(business_id));
create policy audit_insert on public.audit_events
  for insert to authenticated
  with check (public.is_active_member(business_id) and actor_user_id = auth.uid());

-- reference_counters: no direct access; use next_reference()
