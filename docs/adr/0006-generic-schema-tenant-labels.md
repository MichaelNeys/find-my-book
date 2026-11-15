# 0006. Generic schema, library terms only in the UI

- Status: accepted
- Date: 2026-11-09

## Context

The assignment asks for a solution that works not only for a library but also for museums, hospitals, warehouses and airports. The library is the demonstration.

## Decision

- The schema uses generic names: `item` (not `book`), `rack` (not `bookshelf`), `level`, `node`, `edge`. Enum values are English as well (`corridor`, `stairs`, `head_rack`, …).
- `item.type` and `item.meta` (JSON) carry domain-specific fields (author, ISBN, item number).
- Each tenant picks the labels the UI shows ("rack", "shelving unit", "display case").
- Multi-tenant from the start: `tenant`, with one SQLite file per tenant.
- To demonstrate genericity: a second demo environment (a large warehouse with generated data) and optionally an IMDF export.

## Consequences

- No schema change is needed to support a new kind of organisation.
- Searching and displaying domain-specific fields takes a little more work (JSON fields, FTS index per type).
- The documentation uses library terms for readability; the [glossary](../glossary.md) maps them to schema names.
