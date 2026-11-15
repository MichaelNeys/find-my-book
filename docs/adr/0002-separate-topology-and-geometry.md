# 0002. Separate topology and geometry, 2.5D model

- Status: accepted
- Date: 2026-11-09

## Context

The system must handle multiple floors, stairs, elevators, aisles and racks of all kinds of shapes. The editor draws shapes; the router only needs connections and costs. A full 3D model is hard for non-technical users to draw and edit.

## Decision

1. **Topology and geometry are separate.** The graph (nodes, edges, weights) is for the router; the floor plan (walls, zones, rack shapes) is for the editor. They only share a coordinate system in meters, with one origin per building.
2. **2.5D.** Every node has (level, x, y). A level has a decimal `ordinal` and an `elevation_m`. Stairs, elevators and ramps are ordinary edges between nodes on different levels.
3. **Book → rack → access points.** Only `rack_access` and `qr_code` refer to nodes.

## Alternatives considered

- **Full 3D model:** more realistic, but hard to draw and with no benefit for the router.
- **Deriving the graph from geometry** (e.g. a navigation mesh): elegant, but complex and hard to correct when the derivation is wrong. The editor does *propose* nodes automatically (aisle generator, access points), but the graph stays explicitly stored.

## Consequences

- Every floor can be drawn in 2D; A\* works unchanged across floors.
- Moving a book does not touch the graph; redrawing an aisle does not touch the catalogue.
- The editor must guarantee that all floors use the same origin (drawing on top of the floor below).
- The model aligns with IMDF (levels with ordinal, openings) and IndoorGML (connectivity network), which makes a later export possible.

## Sources

- [Indoor Map Data Standards: IMDF, GeoJSON, IndoorGML](https://www.ariadne.inc/resources/blogs/indoor-map-data-standards/)
- [Indoor Mapping Data Format, OGC Community Standard](https://docs.ogc.org/cs/20-094/)
