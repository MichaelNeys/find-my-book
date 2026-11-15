# Architecture Decision Records (ADRs)

Each ADR records one decision: the context, the decision, the alternatives considered and the consequences. That way it stays clear later (and at the defence) *why* the design is the way it is.

| No. | Decision | Status |
| --- | --- | --- |
| [0001](0001-sqlite-graph-storage.md) | Store the graph in SQLite as node and edge tables, route in application code | Accepted |
| [0002](0002-separate-topology-and-geometry.md) | Separate topology and geometry, 2.5D model | Accepted |
| [0003](0003-rust-backend-wasm-router.md) | Rust backend, router also compiled to WebAssembly | Accepted |
| [0004](0004-offline-snapshot.md) | Offline via a versioned snapshot, with draft/publish | Accepted |
| [0005](0005-svg-floor-plan.md) | Floor plan and editor in SVG | Accepted |
| [0006](0006-generic-schema-tenant-labels.md) | Generic schema, library terms only in the UI | Accepted |

## Template

```markdown
# NNNN. Title

- Status: proposed | accepted | superseded by NNNN
- Date: YYYY-MM-DD

## Context
## Decision
## Alternatives considered
## Consequences
```
