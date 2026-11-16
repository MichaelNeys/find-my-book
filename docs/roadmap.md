# Roadmap

Build the router on test data first, then the editor: that shows early whether the data model holds up, and the editor is the largest piece of work.

## Phases

### Phase 0: Development environment

- [x] Cargo workspace with `core`, `routing`, `server`, `wasm`
- [x] SvelteKit project with Tailwind
- [x] `compose.yaml` and Dockerfiles for backend, frontend and wasm build
- [x] GitHub Actions CI workflow (see [development](development.md#continuous-integration))

*Done when:* `docker compose up` starts an empty API and an empty frontend.

### Phase 1: Data model and test building

- [ ] Schema and migrations
- [ ] Small hand-made test building as a fixture (`fixtures/test-building.json`): 3 floors, a 3.5 mezzanine, stairs and an elevator
- [ ] `seed` binary that loads a fixture into the database

*Done when:* the schema enforces the constraints (unique ordinal, stairs never wheelchair accessible).

### Phase 2: Router as a standalone library

- [ ] A\* with route profiles and multiple goals
- [ ] Closures and temporary placements
- [ ] Directions
- [ ] Unit tests on the test building

*Done when:* a wheelchair route to 3.5 fails without an elevator stop or ramp and succeeds with either, and a step in a corridor blocks the wheelchair profile.

### Phase 3: API and snapshot

- [ ] Endpoints for building, levels, item search, route and versioned snapshot

*Done when:* a QR URL + item ID, and a floor + rack code + item ID, both yield a complete route.

### Phase 4: Visitor app (PWA)

- [ ] Open QR link, search item, route on the SVG map, step by step
- [ ] Manual start position: pick a floor and enter a rack code
- [ ] Offline with snapshot and `routing.wasm`

*Done when:* the route works in airplane mode.

### Phase 5: Editor, part 1

- [ ] Create floors, outline and walls (including arcs)
- [ ] Place and rotate racks, head racks and tables
- [ ] Aisle generator and automatic access points

### Phase 6: Editor, part 2

- [ ] Nodes and edges, linking stairs and elevators
- [ ] Validation layer per profile
- [ ] Draft/publish
- [ ] Print QR sheets

### Phase 7: Management for non-technical users

- [ ] Enter items manually (title, author, optional ISBN, rack) and move them
- [ ] Closures and exhibitions with a time window
- [ ] Roles per tenant

### Phase 8: Make it generic and demonstrate

- [ ] Tenant labels (rack/shelving unit/display case)
- [ ] Second demo environment: large warehouse generated with the `generate` binary
- [ ] Optional: IMDF export
- [ ] Optional: multilingual UI (e.g. English + Dutch), with a language switcher and translated route directions

## Decisions made

| Question | Decision |
| --- | --- |
| Where does the catalogue come from? | Manual entry through a form in the admin interface (title, author, optional ISBN, rack). No integration with an external library system. |
| How big is the catalogue? | Very large libraries and warehouses with many items must also work. See [scaling](changes-and-scaling.md#scaling). |
| Positioning? | QR code scan, or manual entry of floor + rack code as a fallback. Bluetooth and Wi-Fi positioning are out of scope. |
| Shelf within a rack? | Not modelled. A book is located down to the rack. |
| Backend language? | Rust. See [ADR 0003](adr/0003-rust-backend-wasm-router.md). |
| Development environment? | Docker containers. See [development](development.md). |
| Language? | English for documentation, code and UI. Multiple UI languages are an optional extension (phase 8). |

## Open questions

- [ ] **Authentication.** Own user management with sessions, or an external identity provider? To decide before phase 7.
- [ ] **Demo hosting.** Where does the demo run for the defence (own server, university infrastructure, cloud)?

## Risks

| Risk | Consequence | Mitigation |
| --- | --- | --- |
| The editor is the largest work package | Phases 5–6 overrun | Start with the aisle generator; it covers most of a library with few clicks. Phase 4 also works with a seeded building. |
| A floor drawn with a different origin | Heuristic breaks, elevator appears in two places | The editor draws every new floor on top of the floor below |
| Browser storage is evicted | No map offline | The PWA detects an empty or stale snapshot and fetches it again |
| WebAssembly bundle grows large | Slow first load | Keep `routing` free of I/O dependencies; check bundle size on every build |
| Limited time | Not all phases finished | Phases 1–4 form a working minimum; 5–8 are incremental and each can be demonstrated on its own |
