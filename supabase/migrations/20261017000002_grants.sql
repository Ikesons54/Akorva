-- Akorva Phase 1: explicit privileges for signed-in users
-- Powered by FWXplus · © Copyright 2026 FWXplus
-- Path in repo: supabase/migrations/20261017000002_grants.sql
--
-- New Supabase projects do not give signed-in users access to new tables automatically.
-- These grants are deliberately minimal and match the row-level security policies.
-- There is no DELETE anywhere (records are never deleted) and no UPDATE on the audit log.

grant select on public.businesses to authenticated;

grant select, insert, update on public.profiles to authenticated;

grant select, insert, update on public.business_members to authenticated;

grant select, insert on public.approval_limits to authenticated;

grant select, insert, update on public.approvals to authenticated;

grant select, insert on public.files to authenticated;

grant select, insert on public.audit_events to authenticated;

-- reference_counters: no direct access. Use public.next_reference() only.
