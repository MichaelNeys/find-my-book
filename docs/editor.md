# Editor and floor plan

A floor is drawn fully dynamically as **SVG** from the database. Svelte components build the SVG in the browser from the same JSON the router uses; the server stores no images.

## Storing shapes

- **Outline and walls** as a list of vertices with a `bulge` value per segment: 0 is a straight wall, any other value an arc (as in DXF polylines). This maps directly onto the SVG path commands `L` (line) and `A` (arc). A round or slanted wing is not a special case.
- **Input per wall, stored as coordinates.** The administrator draws "12 m, turn 90°, 8 m, arc with radius 3 m"; the editor converts that into absolute points. Storage does not depend on the input method.
- **Racks** as centre (x, y), width, depth and rotation. In SVG: a `rect` with `transform="rotate(…)"`. Height is informational only.
- **Zones** (main aisle, stairwell) as polygons. They help with drawing and with proposing nodes automatically.
- **The graph as a separate layer** that can be toggled: nodes as circles, edges as lines, inaccessible edges dashed.

Zoom and pan are a single `viewBox` in metres. See [ADR 0005](adr/0005-svg-floor-plan.md) for SVG versus canvas.

## Features

1. **Create a floor:** draw the outline or enter walls by length and angle, snapping to a grid (e.g. 10 cm). A new floor is drawn on top of the floor below, so the origin stays the same.
2. **Aisle generator:** "aisles K to N, 13 racks of 1 m wide per side, aisle width 1.2 m, wall racks along the first aisle" creates every aisle with its racks on both sides, numbered U-shaped per aisle (K01–K13 up the left, K14–K26 back down the right), groups the back-to-back halves (K26 + L01), and adds the access points and aisle edges in one go. This covers most of a library with few clicks.
3. **Standalone racks, head racks, tables and display cases:** place, drag and rotate; access points are proposed automatically.
4. **Nodes and edges** edited by hand: main aisle, door, step, ramp; link stairs and elevators through a vertical connector.
5. **Validation layer:** unreachable racks in red, per route profile; warnings for aisles that are too narrow.
6. **Draft and publish:** all changes happen in a draft; publishing validates and creates a new version.
7. **Print QR sheets** per floor, with the code and a small map of that spot.

## Managing content and closures

Besides the floor-plan editor, the admin interface offers simple forms for non-technical users:

| Action (from the assignment) | How |
| --- | --- |
| Move books to another rack | Search the item, pick the new rack; plain update on `placement`, no new plan version |
| Add, remove or move racks | Floor-plan editor, through draft and publish |
| Add a temporary exhibition | Table/display or polygon with a time window; the editor shows which aisles it narrows or blocks |
| Close a route because of works | Click edges or draw an area, with a reason and time window; active immediately |
| New floors or rooms | Add a floor with a proposed ordinal, draw outline and walls |

## Usability for non-technical users

- Library terms in the UI (rack, head rack, table), never "node" or "edge".
- The graph is generated as much as possible (aisle generator, automatic access points); drawing nodes by hand is the exception.
- Validation says what is wrong and where: *"Rack K07 is not reachable with the wheelchair profile: the aisle between K06 and K07 is 0.8 m wide"*.
- Undo within a draft; a draft can be discarded.
