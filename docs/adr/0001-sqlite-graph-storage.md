# 0001. Store the graph in SQLite, route in application code

- Status: accepted
- Date: 2026-11-09

## Context

To the router, the building is a graph. It must be stored, edited and searched quickly, and also be usable offline in the browser. A library has at most a few thousand nodes; the graph is read far more often than it is changed.

## Decision

Store the graph in SQLite as `node` and `edge` tables, with ordinary foreign keys to `level` and `rack`. Load the graph per building into memory and find routes with A\* in the Rust crate `routing`.

## Alternatives considered

| Option | Why not |
| --- | --- |
| Neighbours per rack (left/right columns) | Cannot represent junctions, main aisles, doors or floors; it is a special case of nodes + edges. Still useful as *input* to the aisle generator. |
| Neo4j (graph database server) | Extra service to operate, no offline use, no benefit at a few thousand nodes |
| Kuzu (embedded graph database) | Archived on 10 October 2025 after its acquisition by Apple; continued only through forks such as RyuGraph. Too risky for a new project. |
| SpatiaLite / PostGIS + pgRouting | Useful for spatial queries, but extra complexity; GIS is 2D and SpatiaLite does not run in the browser. Optional later. |
| DuckDB | Columnar (OLAP), not built for the many small writes of an editor |

## Consequences

- One database, with transactions and foreign keys between catalogue, racks and graph.
- The shortest path must be written by hand (A\* is ~100 lines) or taken from `petgraph`.
- The graph is easy to export as a JSON snapshot (see [0004](0004-offline-snapshot.md)).
- Moving to PostgreSQL (+ PostGIS) remains possible through `sqlx`.

## Sources

- [Kuzu: what happened (PuppyGraph)](https://www.puppygraph.com/blog/what-is-kuzudb)
- [RyuGraph, a fork of Kuzu](https://github.com/gmh5225/ryugraph)
- [Persistent Databases in the Browser with DuckDB-Wasm and OPFS](https://duckdb.org/2026/09/18/opfs-wasm.html)
