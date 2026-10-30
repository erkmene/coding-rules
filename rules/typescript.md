# TypeScript Guidelines

Apply to all TypeScript code, on top of the JavaScript guidelines and universal principles.

## Compiler configuration

- `strict: true` is non-negotiable in `tsconfig.json`. Also enable `noUncheckedIndexedAccess` (indexing returns `T | undefined`, which is the truth) and, for new projects, `exactOptionalPropertyTypes`.
- Never weaken compiler options to make an error go away; fix the code.

## Unknown values and assertions

- For values whose type is genuinely unknown at the boundary (JSON parses, external responses), use `unknown` and narrow with type guards before use.
- Avoid type assertions (`as T`) except at well-defined boundaries (deserialization, test fixtures); an assertion is a claim the compiler cannot check, so each one is a potential lie.

## Modeling types

- Model variants as discriminated unions with a literal discriminant field.
- Make illegal states unrepresentable: prefer `status: 'loading' | 'success' | 'error'` with per-state payloads over independent boolean flags that can contradict each other.
- Use `interface` for object shapes intended to be extended/implemented; use `type` aliases for unions, intersections, tuples, and mapped/conditional types.
- Domain types have a single source of truth. Never re-declare an existing domain shape locally in a component or module — import and extend it.
- Centralize a type only when two or more feature areas need it; until then, keep it next to its use.
- Use `readonly` and `Readonly<T>`/`ReadonlyArray<T>` for data that must not be mutated.
- Prefer union types of literals over `enum` for simple sets of values; if enums are used, use them consistently within the project.
- Generics earn their place: use them when a real relationship between input and output types exists, not to make a signature look flexible. Constrain them (`<T extends ...>`) as tightly as possible.
