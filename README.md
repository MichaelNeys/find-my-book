# Find My Book

**Find My Book** is a web-based SaaS platform that lets organisations model their building, manage locations and guide visitors to their destination. The concrete use case is a library: a visitor scans a QR code (or enters the floor and rack they are standing at), picks a book and gets the fastest (or a wheelchair-accessible) route to the right rack, across multiple floors and even offline.

The system is deliberately generic: `rack`, `item` and `level` cover a warehouse shelving unit, a museum display case or a hospital wing just as well. The library is the demonstration.

> Individual project, Bachelor of Computer Science, Hasselt University (UHasselt).  
> Supervisor: Prof. dr. Bart Moelans  
> co-supervisor: dr. Juno Steegmans.

## Status

**Design phase.** The design and implementation plan lives in [`docs/`](docs/). There is no code yet; implementation follows the [phases in the roadmap](docs/roadmap.md).

## What the system does (goal)

| Requirement | How Find My Book addresses it |
| --- | --- |
| **Model the environment**: floors, stairs, elevators, aisles, racks of different shapes and orientations, temporary obstacles | Floor plan (geometry) and walking graph (topology) kept separate; 2.5D model with floors as a decimal ordinal; stairs/elevators/ramps as edges; closures and displays with a time window |
| **Route planning** from a start location to a book location | A\* over an in-memory graph, with multiple goals (every rack holding a copy), cost in seconds and route profiles (default, wheelchair, step-free) |
| **Management** by non-technical users | In-browser SVG editor with a aisle generator, draft/publish step and validation; forms for books, closures and exhibitions |
| **Fully web-based and generic** | PWA with offline snapshot; multi-tenant; generic names in the schema, library terms only in the UI |

See [docs/assignment.md](docs/assignment.md) for the full assignment and how each requirement maps onto the design.

## Key decisions

1. **Topology and geometry are separate.** The graph is what the router uses; the floor plan is what the editor draws. They only share a coordinate system.
2. **2.5D instead of 3D.** Every node has (floor, x, y) in metres; stairs and elevators are ordinary edges between floors.
3. **Book → rack → access points.** A book only knows its rack; a rack has one or more access points on the graph.
4. **Edges carry attributes** (kind, width, steps, slope, status). Route profiles filter and weight them; accessibility is derived, not a checkbox.
5. **Offline via snapshot.** The server publishes a versioned graph + floor plan per building; the PWA computes the route itself with the same Rust code, compiled to WebAssembly.

The rationale for each decision is in [docs/adr/](docs/adr/).

## Technology

| Layer | Choice |
| --- | --- |
| Backend | Rust, [Axum](https://github.com/tokio-rs/axum), `sqlx` |
| Router | Own Rust crate `routing`, also compiled to WebAssembly for the PWA |
| Database | SQLite (WAL mode), one file per tenant |
| Frontend | SvelteKit + Tailwind CSS, PWA with service worker |
| Map and editor | SVG via Svelte components |
| Offline | JSON snapshot in IndexedDB; catalogue optionally as SQLite-WASM in OPFS |
| Development | Docker and Docker Compose |

## Repository layout (planned)

```text
find-my-book/
├── crates/
│   ├── core/       # domain types: building, level, rack, node, edge, profile
│   ├── routing/    # A*, profiles, closures, directions (no I/O)
│   ├── server/     # Axum API, sqlx, migrations, snapshots, validation,
│   │               # seed and generate binaries
│   └── wasm/       # wasm-bindgen layer around routing for the PWA
├── frontend/       # SvelteKit app: visitor PWA and admin interface
├── fixtures/       # test buildings as JSON (snapshot format)
├── docker/         # Dockerfiles per service
├── docs/           # design, architecture, ADRs, roadmap
├── compose.yaml    # development environment
└── Cargo.toml      # Cargo workspace
```

## Getting started

Development happens entirely in Docker containers. Once the first code is in place:

```sh
docker compose up --build
```

- Frontend: <http://localhost:5173>
- API: <http://localhost:8080>

Services, volumes and common commands are described in [docs/development.md](docs/development.md).

## Documentation

| Document | Contents |
| --- | --- |
| [Assignment](docs/assignment.md) | The assignment and how each requirement is met |
| [Architecture](docs/architecture.md) | Components, data flow, technology choices, offline operation |
| [Data model](docs/data-model.md) | Tables, floors, racks and access points, accessibility |
| [Routing](docs/routing.md) | A\*, cost function, heuristic, profiles, directions |
| [Editor](docs/editor.md) | Drawing floor plans in SVG, aisle generator, publishing |
| [Changes and scaling](docs/changes-and-scaling.md) | Draft/publish, synchronisation, large buildings and catalogues |
| [Development](docs/development.md) | Docker environment, conventions, testing |
| [Roadmap](docs/roadmap.md) | Phases, decisions, open questions and risks |
| [ADRs](docs/adr/) | Architecture decision records |
| [Glossary](docs/glossary.md) | Terms and their schema names |
