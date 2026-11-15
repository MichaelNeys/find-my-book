# 0003. Rust backend, router also compiled to WebAssembly

- Status: accepted
- Date: 2026-11-09

## Context

Routes must be computable on the server (API, validation on publish) and offline in the browser. Two implementations of the same router (e.g. Python on the server and TypeScript in the browser) mean double work, double tests and the risk that they return different routes.

## Decision

Write the backend in **Rust** with **Axum** and `sqlx`. The router is a separate `routing` crate without I/O, used by the server and compiled via `wasm-bindgen`/`wasm-pack` to WebAssembly for the PWA (in a Web Worker). `serde` and `ts-rs` share the data structures with the frontend.

## Alternatives considered

| Option | For | Against |
| --- | --- | --- |
| Django | Built-in admin, fast for management screens | Router implemented twice (Python + TypeScript) |
| Node.js/TypeScript | One language for everything | Less type safety against the database schema; weaker performance for graph work |
| Go | Simple, fast | No admin, less smooth WebAssembly support; gets neither advantage fully |

## Consequences

- One implementation and one test suite for the router.
- Admin screens must be built in SvelteKit (extra work in phase 7).
- `routing` and `core` may contain no database or network code; bundle size is checked on every build.
- Longer compile times; mitigated with cached Docker volumes (see [development](../development.md)).
