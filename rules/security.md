# Security Guidelines

Apply to every file in every project.

## Test credentials

- When a test needs a credential-shaped string, use an obvious dummy (`EXAMPLE_API_KEY`, `test-token`), never a realistic-looking value.

## Never log sensitive data

- Secrets, tokens, passwords, session identifiers, and personal data (names tied to activity, emails, addresses, government IDs, card numbers) never appear in logs.
- When a sensitive value is needed for correlation, log a stable hash or a last-four fragment, never the value itself.
- This applies to every output channel: application logs, error reporters, crash dumps, analytics events, and error messages returned to clients.

## Authorization

- Every entry point (route, handler, resolver, job consumer) checks authorization server-side — being authenticated is not being allowed.
- Authorization is checked against the specific resource instance: "may this user act on *this* reservation", not merely "does this user have the reservations role". Object-level checks are the ones attackers probe first.

## Fail closed

- When an authorization or validation check cannot complete — an exception, a timeout, a missing record — the answer is deny. Never default-allow on error.

## Least privilege

- Tokens, API scopes, database accounts, and service credentials get the narrowest access that works in deployed environments. A service touching one table does not hold rights to the schema.

## Data protection

- Deployed connections use TLS, internal ones included; TLS terminated by a service mesh counts. Local development may use plaintext.
- Store only the sensitive data the feature actually needs. Data you never stored cannot leak.

## Dependencies

- Never install from an unpinned URL or a source outside the project's package manager.
