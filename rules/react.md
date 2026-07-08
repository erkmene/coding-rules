# React Guidelines

Apply only to React UI code (`.jsx`, `.tsx` components, hooks, and their support modules), on top of the JavaScript/TypeScript guidelines. Do not apply React patterns to non-React code.

## Rules of React (non-negotiable)

These are the official invariants from react.dev; the compiler and runtime assume them.

- Components and hooks must be pure: same props/state/context in, same output out, and no side effects during render. Side effects run in event handlers or effects, never in the render body.
- Props and state are immutable snapshots — never mutate them, nor values already passed to JSX or hooks.
- Only call hooks at the top level of a component or custom hook — never in loops, conditions, nested functions, or after early returns.
- Never call a component function directly and never pass hooks around as values; components are used via JSX, hooks are called.
- Keep `eslint-plugin-react-hooks` on and never silence `react-hooks/exhaustive-deps` with a disable comment — fix the root cause: stabilize callbacks with `useCallback`, memoize objects with `useMemo`, or lift the value out of render scope.

## Component structure

- Components render; they do not orchestrate. A component receives display-ready values and callbacks (from props or a colocated hook) and returns JSX.
- Compose small components; a component approaching the 50-line function cap should have sub-components or helpers extracted.
- One component (plus its types, styles, tests, and sub-components) per folder or file group, following the project's established layout. Public surface goes through an index; internals stay private.
- Data transformation (domain shape to display props) lives in pure, named mapper functions outside the component — typed input, typed output, no hooks, no side effects — so it can be unit tested in isolation.

## Custom hooks

- Extract a custom hook when a component would otherwise contain two or more store/context selections, non-trivial derived state, or async side effects. A single `useState` or trivial `useMemo` inline is fine.
- Also extract when logic is shared across components or would have meaningful unit tests of its own.
- Keep hooks small and composed: an orchestrator hook composes focused hooks rather than growing past the function-size cap itself.
- Group related selections in one hook (`useSearchParams()`), not many granular ones stitched together in the component.

## State

- Put state at the lowest level that needs it. Ephemeral UI state (modal open, active tab, input focus) lives in local `useState` — never in a global store.
- Shared client state goes in one store per domain; never duplicate the same state in two places, deriving instead.
- Server data is server state: fetch and cache it through a data-fetching layer (React Query or the framework's loader/RSC mechanism), do not copy it into client stores. Store raw domain shapes and transform at the display layer.
- Stores hold data; they do not fetch. Data fetching happens in the page/component layer or the framework's data layer.
- Derive values during render instead of mirroring them into extra state with effects. `useEffect` is for synchronizing with external systems, not for computing state from other state.

## Server-first (frameworks with React Server Components)

Only when the project uses an RSC-capable framework (Next.js App Router, React Router/TanStack Start in RSC mode):

- Components are Server Components by default; add `"use client"` only at the leaves that genuinely need interactivity, hooks, or browser APIs.
- Fetch data on the server, as high as practical; pass results down. Use Server Actions for mutations rather than hand-rolled API routes.
- Compose server content into client shells by passing Server Components as `children` (the composition/donut pattern) instead of importing server modules into client files.
- Never pass non-serializable values (functions, class instances) across the server/client boundary, and never let server-only secrets reach a client module.

## Performance

- Code-split routes and heavy, single-path components with `lazy()` + `Suspense`; don't import heavy libraries at module top level when only one path uses them.
- Heavy computation belongs in `useMemo` (or on the server), not inline in JSX; don't parse large blobs during render.
- Images: explicit `width`/`height` to prevent layout shift; `loading="lazy"` below the fold; prioritize above-the-fold hero images.
- Reserve space for late-arriving content (fixed-dimension skeletons) so the layout doesn't shift.
- Measure before memoizing: `React.memo`/`useMemo`/`useCallback` are for demonstrated re-render costs and referential-stability requirements, not decoration.

## Accessibility

- Every interactive element has an accessible name: icon-only buttons and links get `aria-label`; meaningful images get `alt`; decorative images get `alt=""`.
- Never use positive `tabIndex`. `0` makes an element focusable, `-1` removes it from tab order; anything higher breaks assistive-tech order.
- Every input is associated with a `<label htmlFor>` (placeholder is not a label); error messages connect via `aria-describedby`.
- One `<h1>` per page; heading levels descend without skipping.
- Use semantic elements (`button`, `nav`, `main`, `ul`) before reaching for ARIA roles on `div`s.
- `target="_blank"` always pairs with `rel="noopener noreferrer"`.
- Wrap significant animation in `@media (prefers-reduced-motion: no-preference)`.

## Events and async in the UI

- Event handlers return void; wrap async work so rejections are handled (`onClick={() => { void save(); }}`).
- Surface async errors and confirmations through the project's user-facing notification mechanism (toast, banner) — never `alert`, console output, or silence.
