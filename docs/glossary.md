# Glossary

Terms as used in the documentation and the UI, and their name in the schema and code.

| Term | Schema/code | Meaning |
| --- | --- | --- |
| Organisation | `tenant` | Customer of the SaaS platform; sees only its own buildings |
| Building | `building` | Unit of publishing and of the offline snapshot |
| Floor, level | `level` | One plane with its own outline; also a mezzanine |
| Ordinal | `ordinal` | Decimal sort and uniqueness key of a level (e.g. 3.5) |
| Aisle | `aisle` | Walkway with racks on one or both sides, with a code ("K"); every rack along it is numbered K01, K02, … |
| Rack | `rack` | Anything items are stored on: rack, head rack, table, display case |
| Head rack | `rack` with `kind = head_rack` | Rack at the head of a block of racks, reached via the main aisle |
| Access point | `rack_access` | Spot in the aisle where you stand in front of a rack; points to a node |
| Item, book | `item` | What is being searched for: book, product, artwork |
| Placement | `placement` | Where an item is, possibly temporarily |
| Node | `node` | Point in the walking graph: junction, door, access point, stair or elevator stop |
| Edge | `edge` | Connection between two nodes with physical properties |
| Corridor, aisle | `edge` with `kind = corridor` | Ordinary walkable connection |
| Step | `edge` with `kind = step` | Small step(s) within one floor |
| Stairs | `edge` with `kind = stairs` | Stairs between levels |
| Ramp | `edge` with `kind = ramp` | Sloped connection, within or between levels |
| Elevator | `edge` with `kind = elevator` | Connection between the stops of one elevator |
| Vertical connector | `vertical_connector` | Groups the nodes of one stairwell, elevator or ramp across levels |
| Route profile | `route_profile` | Rules that exclude or weight edges (default, wheelchair, step-free) |
| Closure | `closure` | Temporarily unusable edges or zones (works, exhibition) |
| Draft, plan version | `plan_revision`, `plan_version` | Unpublished change to the floor plan, and the number of the published version |
| Snapshot | — | JSON export of graph + floor plan of a building, for offline use |
| Coarse navigation | — | Location as a hierarchy (Floor 2 › Aisle K › Rack K01), without the graph |
| 2.5D | — | Stack of 2D floors with vertical edges between them, instead of a full 3D model |
| PWA | — | Progressive Web App: a web app that can be installed and works offline |
| OPFS | — | Origin Private File System: persistent file storage in the browser |
| IMDF | — | Indoor Mapping Data Format, OGC Community Standard for indoor maps |
