# 0005. Floor plan and editor in SVG

- Status: accepted
- Date: 2026-11-09

## Context

The floor plan is shown to visitors (with the route on it) and edited by administrators (dragging racks, drawing walls). Racks have different shapes and orientations; walls can be curved.

## Decision

Draw every floor dynamically as **SVG** with Svelte components, from the same JSON the router uses. Walls as vertices with a `bulge` per segment (line or arc), racks as centre + width + depth + rotation, zones as polygons. Zoom and pan via a single `viewBox` in metres.

## Alternatives considered

- **HTML5 canvas:** faster with tens of thousands of objects, but every object needs its own hit testing and accessibility. Not worth it at the scale of a floor.
- **Drawing library (e.g. Konva, Fabric.js):** an extra dependency with no clear gain over SVG + Svelte.
- **Rendering images on the server:** not interactive, not editable offline.

## Consequences

- Every rack is a DOM element with its own click and drag behaviour, Tailwind classes and accessibility.
- No extra drawing library needed.
- For very large floor plans: render only what is in view, show a block of racks as one shape when zoomed out.
