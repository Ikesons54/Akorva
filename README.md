# Akorva

**Every Item Accounted For. Every Decision Informed.**
Business · Inventory · Financial Clarity

Akorva is a private business-management platform for importing, stocking, selling and settling goods with agents. The first release serves one owner (UAE), one agent and one location (Ghana), with GHS as the reporting currency.

*Powered by FWXplus*

© Copyright 2026 FWXplus

## Status

Phase 0: requirements and setup. No application code has been written yet.

## Baseline

- Specification: consolidated spec v1.0 (formerly TradeLedger GH), approved with four changes.
- First release: one agent, one location, cash and mobile-money sales. Credit sales, multi-agent operations and public multi-business onboarding come later.
- Architecture: designed for multiple independent businesses from the start (every record belongs to a business).
- Business rules: owner owns 100% of stock; 60/40 split of eligible net profit; genuine losses carry forward first; weighted-average inventory costing.

## Brand

- Colors: forest green, warm gold, ivory
- Logo: built as SVG inside the app
- Splash: short animation with logo and slogan before the login page; logo also on the login page
- Footer/credit: "Powered by FWXplus" and "© Copyright 2026 FWXplus"
- Name availability (domain, social handles, app stores, trademark): still to verify before public launch

## Phases (each needs owner approval and a passed gate)

0. Requirements and setup
1. Secure foundation (accounts, roles, audit)
2. Products, suppliers, purchases, inventory
3. Sales, collections, expenses
4. Accounting and settlement
5. Reporting, deployment, verification, then one real pilot shipment

## Open decisions

- GHS approval, discount and refund limits
- Reserve policy before distributions
- Opening stock and balances
- Final stack choice (proposed: Next.js, TypeScript, Supabase/PostgreSQL, GitHub)
- Legal and accounting verification (see the spec)

## Working rules

See `AGENTS.md`. Never commit secrets. Use `.env.example` for variable names only.
