# AGENTS.md: Akorva project rules

These rules apply to every AI coding agent and contributor.

## 1. Approval first
- The owner approves every stage, feature and migration before it is built.
- Work only on the approved phase. Do not build ahead.
- Each phase ends with its gate tests passing and the owner's explicit approval.
- When a business rule is unclear, ask. Do not assume financial rules.

## 2. Workflow
- The owner works from a phone through GitHub. Keep changes small, reviewable and well described in pull requests.
- Never commit secrets, keys or real business data. Document variable names only in `.env.example`.
- The stack is proposed, not final: Next.js, TypeScript, Supabase/PostgreSQL, GitHub. Confirm before adopting anything else.

## 3. Accounting invariants (never break)
- Records are append-only. Corrections are reversals or adjustments, never deletions or silent edits.
- Money uses decimal-safe values with explicit currency codes. Never use floating point for money.
- Landed costs are allocated once. A purchase, a supplier invoice and a payment are separate events and are never counted twice.
- Only sold stock enters cost of goods sold. Unsold stock stays inventory.
- A sale and its payment are separate records. Collecting a payment never creates revenue twice.
- Profit and cash are different. Reserves are not expenses. Unpaid entitlement is not a loss.
- Stock counts and discrepancies are investigated, not automatically classed as theft or loss.
- Closed periods cannot be edited. Changes need an authorized, audited adjustment.
- Settlements keep the agreement version and figures used at the time.
- Weighted-average costing at variant level for interchangeable goods.

## 4. Security
- Enforce authorization on the server and in database policies, not only in the interface.
- Every record belongs to a business. No user may read or write another business's data.
- Protect against duplicate submissions (idempotency) and concurrent stock allocation.
- Private file storage with controlled access for receipts and evidence.
- Audit every material action: actor, action, time, reason, before/after.

## 5. Scope of the first release
One agent, one location, cash and mobile-money sales. Not yet: credit sales, multi-agent regions, transfers between agents, public onboarding, subscriptions, offline mode.

## 6. Branding
- Colors: forest green, warm gold, ivory.
- SVG logo inline in the app (no image dependency).
- Splash animation (logo and slogan) before the login page; logo on the login page.
- Show "Powered by FWXplus" and "© Copyright 2026 FWXplus" across the app (footer of every page, login page and splash).
- Slogan: "Every Item Accounted For. Every Decision Informed."

## 7. Required tests
Before real money is involved, the acceptance tests in the spec must pass, including: single-count receipts and costs, COGS on sale, below-minimum price approval, unapproved expenses excluded, duplicate-submission protection, closed-period protection, unauthorized access rejected, and a restorable backup.

## 8. Do not
- Hard-code tax rates or claim legal or tax compliance.
- Auto-purchase, auto-pay, auto-write-off or auto-blame.
- Hide original transactions or rewrite history.
