# Development

> There is no code yet. This document describes the planned development environment; update it once `compose.yaml` and the Dockerfiles exist.

Development happens entirely in **Docker containers**. The host only needs Git, Docker and Docker Compose; Rust, Node.js and `wasm-pack` run in containers. The environment behaves the same everywhere, and a supervisor or jury can start the project with a single command.

## Requirements

- Docker Engine 24+ (or Docker Desktop) with Docker Compose v2
- Git

## Services (planned)

| Service | Base image | Task | Port |
| --- | --- | --- | --- |
| `backend` | `rust` | Axum server, restarted automatically on changes (`cargo watch`) | 8080 |
| `frontend` | `node` | SvelteKit dev server (Vite) with hot reload | 5173 |
| `wasm` | `rust` + `wasm-pack` | Builds `crates/wasm` into `frontend/src/lib/wasm` when `routing` changes | — |

SQLite needs no service of its own: the database files live in a volume (`./data` or a named volume) used by the backend.

### Volumes

- Source code as a bind mount, so changes are visible immediately.
- Named volumes for `target/` (Cargo build), the Cargo registry and `node_modules`, so builds stay fast and do not clash with the host.
- `data/` for the SQLite files; listed in `.gitignore`.

## Common commands (planned)

```sh
# start everything
docker compose up --build

# follow the logs of one service
docker compose logs -f backend

# run the Rust workspace tests
docker compose run --rm backend cargo test --workspace

# run database migrations
docker compose run --rm backend sqlx migrate run

# load a test building into the database
docker compose run --rm backend cargo run --bin seed -- fixtures/test-building.json

# generate a large building and catalogue for scale tests
docker compose run --rm backend cargo run --release --bin generate -- \
    --aisles 40 --racks-per-side 20 --floors 4 --items 1000000 \
    > fixtures/generated/warehouse.json

# frontend tests and lint
docker compose run --rm frontend npm test
docker compose run --rm frontend npm run lint

# stop everything and wipe the database
docker compose down -v
```

## Test data

The admin forms only arrive in phase 7, but test data is needed from phase 1 on. It comes from **fixtures**: test buildings stored as JSON in the same format as the [offline snapshot](architecture.md#offline-operation).

| Source | What | Used for |
| --- | --- | --- |
| `fixtures/test-building.json` | Small hand-made building: 3 floors, a 3.5 mezzanine, stairs, an elevator, a ramp, a step in a corridor, a few aisles, a head rack and a table, plus a handful of books | Router unit tests, seeding the development database, demo |
| `fixtures/*.json` (further) | Small buildings for one specific case each (e.g. mezzanine reachable only by stairs) | Targeted router tests |
| `generate` binary | Large building and catalogue, generated from parameters | Scale tests, the warehouse demo (phase 8) |
| SQL in the migrations | Fixed reference data: a demo tenant, default route profiles | Every fresh database |

Why JSON fixtures instead of hand-written `.sql` files:

- **One file, three uses.** The `routing` tests read the fixture directly, without a database; `seed` loads the same file into SQLite; and the snapshot format gets tested along the way.
- **Fewer mistakes.** In SQL every edge has to reference two node IDs by hand. In the fixture, nodes have readable IDs (`"K-entrance"`) that `seed` resolves.
- **Shared logic.** `generate` uses the same numbering and layout rules as the aisle generator in the editor, so the scale tests exercise realistic buildings.

Generated files go into `fixtures/generated/`, which is in `.gitignore`; only the command that produces them is versioned.

### Inspecting the database

SQLite is a single file in `data/`, so no database container is needed. Open it on the host with DB Browser for SQLite, a SQLite extension in VS Code, or `sqlite3`. A web viewer such as `sqlite-web` can be added later under a separate Compose profile (`docker compose --profile tools up`) if that turns out to be useful.

**Careful with manual edits.** The server keeps the graph in memory and only reloads it on publish. After editing nodes or edges directly in the database, restart the backend; otherwise routes are still computed on the old graph. Items and placements are read per request and are not affected.

## Production image

Besides the development environment there will be a multi-stage production image:

1. Build WebAssembly with `wasm-pack`.
2. Build the frontend statically (SvelteKit `adapter-static` or `adapter-node`).
3. Build the backend in release mode.
4. Final image: only the server binary and the built frontend, on a small base (e.g. `debian-slim` or `distroless`).

## Working agreements

- **Branches:** `main` always works. Work on a separate branch per phase or feature and merge through a merge request.
- **Commits:** short, descriptive messages in the imperative mood, e.g. `routing: add wheelchair profile`.
- **Formatting and linting:** `cargo fmt`, `cargo clippy -- -D warnings`, Prettier and ESLint for the frontend.
- **Tests:** the router has unit tests on the test building; every router bug first gets a failing test.
- **WebAssembly bundle:** check its size on every build; `routing` must not gain database or network dependencies.
- **UI text:** never hard-coded in components; always through message keys (with an i18n library such as Paraglide), so tenant labels and extra languages need no code changes.
- **Documentation:** a material design change gets an [ADR](adr/).

## Continuous integration

A pipeline that runs `cargo fmt --check`, `cargo clippy`, `cargo test`, the frontend tests and a `wasm-pack build` on every push, in the same containers as locally.
