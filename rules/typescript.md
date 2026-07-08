# TypeScript Guidelines

Apply to all TypeScript code (`.ts`, `.tsx`), on top of the JavaScript guidelines and universal principles.

## Compiler configuration

- `strict: true` is non-negotiable in `tsconfig.json`. Also enable `noUncheckedIndexedAccess` (indexing returns `T | undefined`, which is the truth) and, for new projects, `exactOptionalPropertyTypes`.
- Never weaken compiler options to make an error go away; fix the code.

## No `any`

- `any` disables all downstream type checking and is forbidden in production code.
- For values whose type is genuinely unknown at the boundary (JSON parses, external responses), use `unknown` and narrow with type guards before use.
- No `as any`, and no `@ts-ignore` / `@ts-expect-error` without a justification comment explaining why the suppression is unavoidable.

## Assertions and narrowing

- Avoid non-null assertions (`!`). Handle the `null`/`undefined` case explicitly, or restructure so the compiler can see the value is present.
- Avoid type assertions (`as T`) except at well-defined boundaries (deserialization, test fixtures); an assertion is a claim the compiler cannot check, so each one is a potential lie.
- Prefer narrowing (via `typeof`, `instanceof`, `in`, discriminant checks, or custom type-guard functions) over casting.

## Modeling types

- Model variants as discriminated unions with a literal discriminant field, and use exhaustive `switch` statements with a `never` check so the compiler flags unhandled cases.
- Use `interface` for object shapes intended to be extended/implemented; use `type` aliases for unions, intersections, tuples, and mapped/conditional types.
- Make illegal states unrepresentable: prefer `status: 'loading' | 'success' | 'error'` with per-state payloads over independent boolean flags that can contradict each other.
- Domain types have a single source of truth. Never re-declare an existing domain shape locally in a component or module — import and extend it.
- Centralize a type only when two or more feature areas need it; until then, keep it next to its use.
- Use `readonly` and `Readonly<T>`/`ReadonlyArray<T>` for data that must not be mutated.
- Prefer union types of literals over `enum` for simple sets of values; if enums are used, use them consistently within the project.

## Explicitness at boundaries

- Exported functions declare explicit parameter and return types; inside function bodies, let inference do the work.
- Always use `import type` (or inline `type` modifiers) for type-only imports so they are erased at build time.
- Generics earn their place: use them when a real relationship between input and output types exists, not to make a signature look flexible. Constrain them (`<T extends ...>`) as tightly as possible.

## Async typing

- Functions returning promises are typed `Promise<T>`; never leave an async boundary implicitly `any`.
- Type caught errors as `unknown` (the default under `useUnknownInCatchVariables`) and narrow before touching properties.

## Linting

- Use typescript-eslint with the type-checked rule sets (`strictTypeChecked`, `stylisticTypeChecked`) when the project allows; at minimum enforce `no-explicit-any`, `no-floating-promises`, `no-misused-promises`, and `consistent-type-imports`.
