# 0004. Offline via a versioned snapshot, with draft/publish

- Status: accepted
- Date: 2026-11-09

## Context

Mobile reception is often poor inside large buildings. Visitors must still get a route. At the same time administrators edit the floor plan, and a half-finished change must not send visitors into a broken graph.

## Decision

- Per building, the server publishes a **snapshot** (graph + floor plan as JSON) with a version number (`building.plan_version`), retrievable with an ETag.
- The PWA stores the snapshot in IndexedDB and computes routes locally with `routing.wasm`.
- Floor-plan changes happen in a **draft** (`plan_revision`) and are published only after validation.
- Closures and moved items bypass the version, as small deltas.
- A large catalogue is synced separately, as SQLite-WASM with FTS5 in OPFS.

## Alternatives considered

- **Always compute online:** simpler, but unusable without a connection.
- **Replicating the server database itself to the browser:** ties offline operation to the choice of server database; heavier than needed.
- **Changes go live immediately:** visitors may see an intermediate state.

## Consequences

- Offline operation is independent of the server database.
- Validation on publish guarantees that every published version is usable.
- Browser storage can be evicted; the PWA must detect an empty or stale snapshot and fetch it again.

## Sources

- [SQLite in the browser with OPFS (OpenReplay)](https://blog.openreplay.com/sqlite-browser-opfs/)
