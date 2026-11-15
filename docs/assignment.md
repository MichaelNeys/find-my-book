# Assignment

**Title:** Find My Book web service

**Supervisor and co-supervisor:** Prof. dr. Bart Moelans and dr. Juno Steegmans

**Context:** individual project

## Summary of the assignment

Finding a specific location in a large building (library, museum, hospital, warehouse, airport) is often hard. The project delivers a **Software-as-a-Service platform** that lets organisations model their building, manage locations and guide visitors to their destination.

The concrete use case is a library: a visitor knows their current location and wants to reach a particular book as quickly as possible.

### Step 1: Modelling the environment

A data structure that represents the physical environment and handles complex situations:

- multiple floors;
- stairs and elevators;
- aisles and passages;
- racks with different shapes and orientations;
- temporary obstacles or exhibitions.

It must be possible to link books to a specific rack=.

### Step 2: Route planning

An algorithm that, given a start location and a destination (a book location), determines the optimal route and guides visitors efficiently through the building, taking the building structure into account.

### Step 3: Managing the environment

Non-technical users update the building information through a web interface:

- moving books to another rack;
- adding, removing or moving racks;
- adding temporary exhibitions;
- closing routes because of works;
- configuring new floors or rooms.

Changes are processed automatically, so future routes are computed with the most recent information.

### Challenge

The solution is fully web-based and generic enough for other complex indoor environments. The library serves as a realistic demonstration.

## From requirement to design

| Requirement | Where in the design |
| --- | --- |
| Multiple floors | `level` with a decimal `ordinal` and `elevation_m`; shared (x, y) origin per building. See [data model](data-model.md#floors-and-mezzanines). |
| Stairs and elevators | `stairs`, `elevator`, `ramp` edges between nodes on different floors, grouped in a `vertical_connector`. See [data model](data-model.md#vertical-connections). |
| Aisles and passages | Nodes and edges with width, door type and status. See [data model](data-model.md#graph). |
| Racks with shapes and orientations | `rack` with centre, width, depth, rotation and kind (rack, head rack, table, display case). See [data model](data-model.md#racks-head-racks-and-tables). |
| Temporary obstacles and exhibitions | `closure` and temporary `rack`/`placement` with a time window. See [routing](routing.md#closures-and-temporary-obstacles). |
| Link a book to a rack and location | `item` → `placement` → `rack` → `rack_access` → `node`. A book is located down to the rack. |
| Optimal route to a book | A\* with multiple goals, cost in seconds, route profiles. See [routing](routing.md). |
| Management by non-technical users | SVG editor with aisle generator, forms for books and closures. See [editor](editor.md). |
| Process changes automatically | Draft/publish with a version number, closures as a filter, content as a plain update. See [changes](changes-and-scaling.md). |
| Fully web-based | SvelteKit PWA, offline via snapshot and WebAssembly. See [architecture](architecture.md). |
| Generic, not library-only | Generic table names, per-tenant labels, second demo (warehouse), optional IMDF export. See [ADR 0006](adr/0006-generic-schema-tenant-labels.md). |
| SaaS | Multi-tenant with `tenant`, one SQLite file per tenant. See [architecture](architecture.md#multi-tenancy). |

## Scope

Decided and out of scope:

- **Positioning** is done by scanning a QR code, or manually by entering the floor and the code of the rack the visitor is standing at (e.g. when the phone camera does not work). Bluetooth and Wi-Fi positioning are out of scope, although the model could support them (a position is a node or a point on a floor).
- **Shelf level** is not modelled: a book is located down to the rack, which is enough to guide the visitor there.
- **Catalogue** is entered manually through a form (title, author, optional ISBN, rack). There is no integration with an existing library system; a CSV import is a possible extension.
- **Scale**: the design must also work for very large libraries and warehouses with millions of items.
