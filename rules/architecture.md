# Architecture Guidelines

Language-agnostic rules for how modules, features, and layers relate to each other, on top of the universal principles: "code is a story" governs layout; these rules govern dependencies. They prescribe relationships, not folder names — any layout that satisfies them is fine.

## Dependency direction

- Dependencies point from volatile to stable: feature code depends on shared code, shared code depends on core/domain code — never the reverse.
- Domain logic never imports from delivery mechanisms (HTTP handlers, UI components, CLI parsing) or from infrastructure (database clients, queue consumers). Those outer layers depend on the domain and adapt it to the outside world.
- Shared/common modules never import from feature modules. When a shared module needs something that lives in a feature, move that something up to the shared layer (the universal DRY "move it up" rule).
- No circular imports, at any level — between files, between features, between packages. A cycle means a boundary is drawn wrong; redraw the boundary (extract the shared piece, invert the dependency) rather than suppressing the cycle or hiding it behind a lazy import.

## Features are boxes with one door

- A feature exposes a deliberate public surface: explicit public exports from a single entry file (`index.ts`, `__init__.py`). Everything else is internal.
- Other features import only from that surface, never from another feature's internals.
- When a feature appears to need another feature's internals, do not reach in — promote those internals to a public surface: either the owning feature's own door, or a common module both features can depend on.

## Functional core, imperative shell

- Keep decision logic pure: transforms, calculations, and business rules take values in and return values out, with no I/O.
- Push side effects (network, filesystem, database, clock, randomness) to the edges, and pass their results into the pure core. A function that both decides and performs is harder to test than the two functions it should be.
- Inject sources of nondeterminism (current time, random values, environment) rather than reading them deep inside logic, so tests control them without patching.

## External systems behind ports

- Access each third-party service or SDK through one thin adapter module the project owns; feature code talks to the adapter, never to the vendor client directly.
- The adapter gives one place to mock in tests, one place to absorb vendor changes, and one place to swap the provider. Vendor types stay inside it; the rest of the codebase sees the project's own types.

## Configuration

- Configuration is read once, validated at the entry point, and passed down explicitly (or exposed through a single typed config module). No `process.env` / `os.environ` reads scattered through the codebase.
- This keeps the full configuration surface visible and typed in one place, makes code testable without environment patching, and prevents arbitrary configuration from creeping in.
- Secrets come from the environment, never from source (universal Secrets rules).

## When to split — and when not to

- Extracting a module, package, or service is justified by a boundary — different consumers, different rates of change, different deployment needs — not by line count alone (size caps are handled by the universal rules).
- Never split speculatively. A second package, a plugin system, or a service boundary for a hypothetical future consumer is YAGNI (universal Abstraction discipline).

## Decisions

- Significant architectural decisions and their reasoning are recorded per the universal Documentation rules (an ADR or dated note) — future readers need the why, not just the what.
