# Changes and scaling

## Three kinds of change

Each changes something different at a different pace, so each is processed differently.

| Change | Example | Affects the graph? | How processed |
| --- | --- | --- | --- |
| **Floor plan** | move a rack, add a floor, redraw an aisle | Yes | In a **draft** (`plan_revision` = draft); on **Publish**: validate, `plan_version + 1`, server reloads the graph into memory |
| **Closure** | works in aisle L, exhibition in the hall | Only as a filter | Active immediately within its time window; no new version |
| **Content** | book moved to another rack | No | Plain update on `placement`; synchronised via `updated_at` |

### Why a draft/publish step

An administrator dragging a rack halfway must not send visitors into a broken graph. The draft also makes undo and a change log straightforward. See [ADR 0004](adr/0004-offline-snapshot.md).

### Effect on clients

- The app requests `GET /buildings/{id}/snapshot` with the last known version (ETag).
- If there is a new version, it downloads graph + floor plan again.
- Closures and moved items arrive as small deltas.
- A route already on screen stays valid until the next scan.

This meets the requirement that changes are processed automatically: every new route uses the latest published floor plan, the active closures and the current placement.

## Scaling

The design scales because the two things that grow, grow separately: the **catalogue** (millions of items) and the **floor plan** (thousands of racks).

| What grows | Problem | Approach |
| --- | --- | --- |
| Number of items | Fast search; carrying it offline | Server: SQLite with an FTS5 index on title, author and item number. Offline: catalogue separate from the floor-plan snapshot, as SQLite-WASM in OPFS with FTS5; full download first, then deltas via `updated_at`. Configurable per tenant: fully, partially or not offline. |
| Number of racks and nodes | Route computation time | Graph per building in memory; A\* stays fast even for a large warehouse. Only if measurements demand it: hierarchical routing (first between floors, then within the floor). |
| Size of the floor plan | Rendering in the browser | Render only what is in view; zoomed out, show a block of racks as one shape. Snapshot per floor instead of per building. |
| Number of tenants and buildings | Isolation, backups, concurrent writes | One SQLite file per tenant. With many concurrent writers, `sqlx` can also use PostgreSQL. |
| Item entry | Entering thousands of items one by one | Manual entry is the baseline; a CSV import with the same validation is a small extension. |

**Test scale early** with generated data: a large building with many floors and a catalogue of millions of items. Measure route time, snapshot size, search time and rendering speed.
