# API Design Guidelines

Apply when designing or implementing HTTP (REST) APIs; skip for projects with no API surface. Universal principles apply first, and an existing API's established conventions win over these defaults.

## Published contracts are promises

- An API consumed outside the codebase must stay backward compatible; the universal "no backward-compatibility shims" rule covers only code whose callers you update yourself.
- Evolve additively: add optional fields and new endpoints freely; never rename, remove, or retype a field, and never change the meaning of an error code consumers branch on.
- A breaking change requires a versioned migration path and a deprecation window, not a coordinated big-bang release.

## Versioning

- Avoid versioning as long as possible: design additively and iterate within the current version.
- When a breaking change is genuinely unavoidable, version in the URL path (`/v2/`). Pick one mechanism and never mix it with header- or parameter-based versioning in the same API.
- Introducing a new API version is always a human decision. An agent or developer who believes a break is needed proposes it; they do not ship it unilaterally.

## Resources and naming

- Verbs appear only for genuine actions that do not map to CRUD (`/reservations/{id}/cancel`).
- Pick one casing convention (camelCase or snake_case) and apply it everywhere — paths, query parameters, and body fields.

## Status codes

- `401` means unauthenticated and `403` means authenticated but not permitted. When even the existence of a resource is secret, deny with `404`.

## Errors: one envelope

- The entire API uses one error envelope. Default to the RFC 9457 Problem Details shape unless the project already has an established one.
- Every error carries stable, machine-mappable identifiers consumers can branch on: the Problem Details `type` URI, plus extension members such as `errorCode` when needed. It also carries a human-readable message. The message is for people and is never a contract: it may change freely and must never be parsed.
- Validation failures include per-field details (field path, violated rule) so clients can render errors in place.

## Pagination

- Every collection that can grow paginates from day one — retrofitting pagination is a breaking change.
- Prefer cursor-based pagination for anything that grows; include the paging metadata (next cursor / total where feasible) in a consistent shape across all endpoints.

## Idempotency

- A `POST` with consequential side effects (payment, booking, message send) accepts an idempotency key so client retries cannot duplicate the effect.

## Boundary validation and the contract

- Validate every request at the boundary with schema-driven validation (zod, Pydantic, or the project's equivalent).
- The API contract (OpenAPI) is generated from — or verified against — those same schemas. One source of truth; no hand-maintained parallel documentation to drift.
