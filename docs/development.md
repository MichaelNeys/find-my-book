# Development

Development happens entirely in **Docker containers**. The host only needs Git, Docker and Docker Compose; Rust, Node.js and `wasm-pack` run in containers. The environment behaves the same everywhere, and a supervisor or jury can start the project with a single command.

## Requirements

- Docker Engine 24+ (or Docker Desktop) with Docker Compose v2
- Git

## Services

| Service | Base image | Task | Port |
| --- | --- | --- | --- |
| `backend` | [`docker/rust.Dockerfile`](../docker/rust.Dockerfile) (`rust`) | Axum server, rebuilt and restarted on changes (`cargo watch`) | 8080 |
| `wasm` | [`docker/rust.Dockerfile`](../docker/rust.Dockerfile) (`rust`) | Rebuilds `crates/wasm` with `wasm-pack` into `frontend/src/lib/wasm` when `wasm`, `routing` or `core` changes | — |
| `frontend` | [`docker/node.Dockerfile`](../docker/node.Dockerfile) (`node`) | SvelteKit dev server (Vite) with hot reload; proxies `/api` to `backend` | 5173 |

`backend` and `wasm` share one image (Rust with `rustfmt`, `clippy`, the `wasm32-unknown-unknown` target, `cargo-watch` and `wasm-pack`). The images contain only tools; the source code is bind-mounted.

SQLite needs no service of its own: the database files will live in `data/` (phase 1), used by the backend.

The first `docker compose up --build` takes a few minutes: the Rust image compiles `cargo-watch` and `wasm-pack`, and the backend compiles all dependencies. After that, the caches in the named volumes make restarts fast.

### Volumes

- Source code as a bind mount, so changes are visible immediately.
- Named volumes, separate for `backend` and `wasm`, for the Cargo registry and the build output (`CARGO_TARGET_DIR=/target`, outside the bind mount). They are separate because Cargo's locks do not work across containers, so two containers sharing them break on parallel builds. Also volumes for the `wasm-pack` cache and `node_modules`. Builds stay fast and do not clash with a build on the host.
- `docker compose down -v` removes these volumes; the next start rebuilds from scratch.

### File ownership

The containers run as a non-root user, so files they write into the bind mount (such as the generated wasm package) belong to you. The Rust image creates that user with UID/GID 1000 by default; if your host user has a different ID, build with `UID=$(id -u) GID=$(id -g) docker compose build`. The Node image uses its built-in `node` user (UID 1000).
- `data/` for the SQLite files; listed in `.gitignore`.

## Crate names

The workspace packages are `fmb-core`, `fmb-routing`, `fmb-server` and `fmb-wasm` (in `crates/`). In code, `fmb-core` is imported as `core_types`, because `core` is the name of Rust's built-in library. Dependencies between the crates are added as code needs them; the allowed direction is `routing -> core`, `server -> core, routing`, `wasm -> core, routing`.

## Common commands

```sh
# start everything
docker compose up --build

# follow the logs of one service
docker compose logs -f backend

# run the Rust workspace checks
docker compose run --rm backend cargo test --workspace
docker compose run --rm backend cargo clippy --workspace --all-targets -- -D warnings
docker compose run --rm backend cargo fmt --all

# build the WebAssembly package once (the `wasm` service does this on every change)
docker compose run --rm wasm wasm-pack build crates/wasm --target web --out-dir ../../frontend/src/lib/wasm

# from phase 1 on: run database migrations
docker compose run --rm backend sqlx migrate run

# load a test building into the database
docker compose run --rm backend cargo run --bin seed -- fixtures/test-building.json

# generate a large building and catalogue for scale tests
docker compose run --rm backend cargo run --release --bin generate -- \
    --aisles 40 --racks-per-side 20 --floors 4 --items 1000000 \
    > fixtures/generated/warehouse.json

# frontend checks
docker compose run --rm frontend npm run check
docker compose run --rm frontend npm run lint
docker compose run --rm frontend npm test
docker compose run --rm frontend npm run format   # fix formatting

# add a frontend package (installs into the node_modules volume)
docker compose run --rm frontend npm install <package>

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

- **Branches:** `main` always works. Work on a separate branch per phase or feature and merge through a pull request; CI must pass before merging.
- **Commits:** short, descriptive messages in the imperative mood, e.g. `routing: add wheelchair profile`.
- **Formatting and linting:** `cargo fmt`, `cargo clippy -- -D warnings`, Prettier and ESLint for the frontend.
- **Tests:** the router has unit tests on the test building; every router bug first gets a failing test.
- **WebAssembly bundle:** check its size on every build; `routing` must not gain database or network dependencies.
- **UI text:** never hard-coded in components; always through message keys (with an i18n library such as Paraglide), so tenant labels and extra languages need no code changes.
- **Documentation:** a material design change gets an [ADR](adr/).

## Continuous integration

GitHub Actions (`.github/workflows/ci.yml`) runs on every push to and pull request against `main`. It runs directly on the GitHub runner with caching instead of in the development containers, which is faster; the tool versions are the same.

| Job | Checks |
| --- | --- |
| `rust` | `cargo fmt --all --check`, `cargo clippy --workspace --all-targets -- -D warnings`, `cargo test --workspace`, `wasm-pack build crates/wasm` |
| `frontend` | `npm ci`, lint, type check, tests, build |

Notes:

- `sqlx` checks queries against the schema at compile time, but CI has no database. Run `cargo sqlx prepare` locally after changing a query or migration and commit the `.sqlx/` directory; CI builds with `SQLX_OFFLINE=true`.
- Once the frontend imports the WebAssembly package, the `frontend` job must build it first (or take it over as an artifact from the `rust` job).
- The workflow is added in phase 0, together with the Cargo workspace; before that every run would fail.
