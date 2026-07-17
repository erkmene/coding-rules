# Security Guidelines

Apply to every file in every project. The universal principles already cover the foundations — parameterized queries and safe path handling, no user data in code-execution sinks, cryptographically secure randomness, and secrets hygiene ("Correctness and boundaries", "Secrets") — these rules extend them, they do not replace them.

## Never log sensitive data

- Secrets, tokens, passwords, session identifiers, and personal data (names tied to activity, emails, addresses, government IDs, card numbers) never appear in logs.
- When a sensitive value is needed for correlation, log a stable hash or a last-four fragment, never the value itself.
- This applies to every output channel: application logs, error reporters, crash dumps, analytics events, and error messages returned to clients.

## Authorization

- Every entry point (route, handler, resolver, job consumer) checks authorization server-side — being authenticated is not being allowed.
- Authorization is checked against the specific resource instance: "may this user act on *this* reservation", not merely "does this user have the reservations role". Object-level checks are the ones attackers probe first.
- Never trust client-supplied identity or role fields; identity comes from the verified session or token, nothing else.

## Fail closed

- When an authorization or validation check cannot complete — an exception, a timeout, a missing record — the answer is deny. Never default-allow on error.

## Least privilege

- Tokens, API scopes, database accounts, and service credentials get the narrowest access that works. A read path uses a read-only credential; a service touching one table does not hold rights to the schema.

## Passwords and data protection

- Passwords are stored only through an adaptive hashing algorithm (argon2 or bcrypt) — never reversible encryption, never a fast hash.
- TLS is assumed for every connection, internal ones included; plaintext transport is never "fine for now".
- Store only the sensitive data the feature actually needs. Data you never stored cannot leak.

## Dependencies

- Lockfiles are committed, always (extends the universal Dependencies rules).
- An automated vulnerability audit (`npm audit`, `pip-audit`, or a Dependabot-equivalent) runs in CI; new advisories are triaged, not ignored.
- Never install from an unpinned URL or a source outside the project's package manager.
