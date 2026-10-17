# Akorva: First Release Spec (v1.0-R1)

Status: draft for owner approval. Nothing is built until approved.
Powered by FWXplus · © Copyright 2026 FWXplus

## 1. Scope
One owner (UAE), one agent, one location (Ghana). GHS is the reporting currency. Sales are cash and mobile money only. Goods: perfumes, laptops and other approved items.

**Not in this release:** credit sales, customer debts, multiple agents or regions, stock transfers, public onboarding, subscriptions, offline mode, automatic purchasing, automatic payments.

## 2. Roles
- **Owner:** creates products, purchases and shipments; sets prices, limits and agreements; approves restricted actions; closes months.
- **Agent:** confirms receipts; records sales, payments, expenses, returns and stock counts. Cannot approve own restricted actions, edit costs or delete anything.

Everything restricted needs owner approval: exceptional expenses, below-minimum prices, refunds above limit, stock write-offs, period close, settlements.

## 3. Core flows
1. **Buy and ship:** owner records purchase, shipment, charges and evidence. Costs are allocated once (landed cost).
2. **Receive:** agent confirms quantities and condition. Only verified stock becomes available.
3. **Sell:** agent records sale at the actual price. Below minimum price needs approval. Payment is a separate record with proof.
4. **Expense:** agent submits with evidence. Unapproved expenses are not counted.
5. **Return/refund:** linked to the original sale. Original is never deleted.
6. **Close month:** both review stock, sales, payments, expenses and discrepancies, then approve.

## 4. Settlement rule (agreement v1)
Net profit = net sales − cost of goods sold (weighted average) − approved expenses. Recover genuine carried-forward losses first, then split 60% owner / 40% agent. Pay only from available cash after obligations and the agreed reserve. Unpaid entitlement stays recorded, never treated as a loss.

## 5. Screens
Splash (logo, slogan, animation) → Login (logo) → Dashboard → Products → Purchases and Shipments → Receipts → Inventory → Sales → Payments → Expenses → Approvals → Monthly Close and Settlement → Reports → Audit Log. Footer on every screen: "Powered by FWXplus" and "© Copyright 2026 FWXplus".

## 6. Data and security
- Every record carries a business_id (ready for multiple businesses later). Row-level security enforces access in the database.
- Append-only ledger: corrections are reversals or adjustments. Closed months are locked.
- Decimal-safe money, explicit currency, duplicate-submission protection, private file storage for evidence, full audit log.

## 7. Acceptance tests (must pass before real money)
Receipt counts stock once · costs allocated once · sale reduces stock and records cost · unsold stock stays inventory · below-minimum price blocked or approved · unapproved expense excluded · duplicate submit creates one record · return preserves original sale · closed month cannot be edited · unauthorized access rejected · 60/40 and carry-forward correct, no double deduction · backup restores and reconciles.

## 8. Open before real-money use
GHS approval, discount and refund limits · reserve policy · opening stock · written agent agreement · accountant and legal verification · name checks (domain, handles, app stores, trademark).
