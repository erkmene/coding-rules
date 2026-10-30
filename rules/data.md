# Data & Persistence Guidelines

Apply to projects with a database or other durable store — schema design, migrations, and queries. Skip for projects with no persistence. The project's migration tooling and existing conventions win over these defaults.

## The schema is a published contract

- During every deploy, old code runs against the new schema (and sometimes new code against the old). The schema therefore carries the same compatibility discipline as a published API: evolve additively, break deliberately.

## Expand → migrate → contract

- Never rename or drop a column or table in the same release as the code change that stops using it.
- Expand: add the new column/table alongside the old. Migrate: dual-write and backfill, then switch readers. Contract: remove the old one in a later release, once nothing running references it.

## Migrations

- Every migration is reversible in mechanism: a tested down-path, or a documented reason why one is impossible (data-destroying operations often are — say so).
- Destructive operations (dropping tables or columns, mass deletes) get their own explicitly reviewed migration — never bundled into a feature change where they hide.

## Transactions

- Keep transactions short, and never hold one open across a network call — locks held during someone else's latency are how systems seize up.

## Modeling defaults

- Every mutable entity table gets `created_at` and `updated_at`.
- Soft-delete versus hard-delete is decided once per project and applied consistently, not re-decided per table.

## Queries

- Columns used in filters and joins are indexed; a query on a hot path has had its plan checked, and the measurement is kept.
