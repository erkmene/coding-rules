# API Design Guidelines

Apply when designing or implementing HTTP (REST) APIs; skip for projects with no API surface. Universal principles apply first, and an existing API's established conventions win over these defaults.

## Published contracts are promises

- An API consumed outside the codebase is the one place where backward compatibility is mandatory — the counterpart to the universal "no backward-compatibility shims" rule, which applies only to code whose callers you can update yourself.
- Evolve additively: add optional fields and new endpoints freely; never rename, remove, or retype a field, and never change the meaning of an error code consumers branch on.
- A breaking change requires a versioned migration path and a deprecation window, not a coordinated big-bang release.

## Versioning

- Avoid versioning as long as possible: design additively and iterate within the current version.
- When a breaking change is genuinely unavoidable, version in the URL path (`/v2/`). Pick one mechanism and never mix it with header- or parameter-based versioning in the same API.
- Introducing a new API version is always a human decision. An agent or developer who believes a break is needed proposes it; they do not ship it unilaterally.

## Resources and naming

- Collections are plural nouns (`/reservations`), members are addressed by id (`/reservations/{id}`).
- Verbs appear only for genuine actions that do not map to CRUD (`/reservations/{id}/cancel`).
- Pick one casing convention (camelCase or snake_case) and apply it everywhere — paths, query parameters, and body fields.

## Status codes

- Status codes carry the semantics RFC 9110 gives them: `400` malformed request, `401` unauthenticated, `403` unauthorized, `404` not found, `409` state conflict, `422` semantically invalid, `5xx` server fault only.
- Never return `200` with an error in the body. The status line is the first thing every client, proxy, and monitor reads; it must tell the truth.

## Errors: one envelope

- The entire API uses one error envelope. Default to the RFC 9457 Problem Details shape unless the project already has an established one.
- Every error carries stable, machine-mappable identifiers consumers can branch on — e.g. `errorCode` (unique and stable), `errorName`, `errorCategory` — plus a human-readable message. The message is for people and is never a contract: it may change freely and must never be parsed.
- Validation failures include per-field details (field path, violated rule) so clients can render errors in place.
- Internal details never leak into a response: no stack traces, raw exception text, SQL, or internal identifiers.

## Pagination

- Every collection endpoint paginates from day one — retrofitting pagination is a breaking change.
- Prefer cursor-based pagination for anything that grows; include the paging metadata (next cursor / total where feasible) in a consistent shape across all endpoints.

## Idempotency

- Honor HTTP method semantics: `GET`/`HEAD` are safe, `PUT`/`DELETE` are idempotent by design — a retry must not change the outcome.
- A `POST` with consequential side effects (payment, booking, message send) accepts an idempotency key so client retries cannot duplicate the effect.

## Boundary validation and the contract

- Validate every request at the boundary with schema-driven validation (zod, Pydantic, or the project's equivalent), per the universal boundary-validation rule.
- The API contract (OpenAPI) is generated from — or verified against — those same schemas. One source of truth; no hand-maintained parallel documentation to drift.
- Response shapes are designed for consumers, not mirrors of database rows. Expose what the use case needs, nothing more.

## Data formats

- Timestamps, calendar dates, money, and localizable text follow the universal rules: ISO 8601 UTC timestamps, date-only values kept date-only, money in minor units with its currency, display formatting left to the client's locale layer.
