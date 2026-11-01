# Svelte Guidelines

Apply only to Svelte code (components and `.svelte.{ts,js}` modules), on top of the JavaScript/TypeScript guidelines. In a project that has not moved to Svelte 5, follow the project.

## Runes

- Write Svelte 5 runes mode: `$state`, `$derived`, `$props`, `$effect`, event attributes (`onclick`), snippets and `{@render}`. Do not mix in legacy syntax (`export let`, `$:`, `on:click`, `<slot>`, `createEventDispatcher`) in a file that uses runes.
- Derive values with `$derived` (or `$derived.by`) instead of assigning state inside an `$effect`. `$effect` is for synchronizing with things outside Svelte: the DOM, timers, subscriptions, third-party libraries.
- Mutate `$state` in place; that is how its reactivity works. Do not mutate a prop the component does not own unless it is `$bindable`; call a callback prop instead.
- Shared reactive state lives in a `.svelte.{ts,js}` module that exports an object or functions, never a reassigned `$state` variable, which loses reactivity across modules.

## Snippets and components

- Use a snippet for markup local to one component, or for markup a parent passes in to fill a slot. Make it a component when it has its own state, is used from more than one file, or makes sense on its own.
