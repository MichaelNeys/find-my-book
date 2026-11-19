# Documentation

This is the design and implementation plan of Find My Book, split by topic. If you are new to the project, read in this order:

1. [Assignment](assignment.md): what is asked and where each requirement ends up in the design.
2. [Architecture](architecture.md): the big picture, the components and the technology choices.
3. [Data model](data-model.md): how a building, its racks and its walking graph are stored.
4. [Routing](routing.md): how a route is computed and described.
5. [Editor](editor.md): how administrators draw and publish floor plans.
6. [Changes and scaling](changes-and-scaling.md): how changes propagate and how the design scales.
7. [Development](development.md): the Docker environment and working agreements.
8. [Roadmap](roadmap.md): phases, decisions, open questions and risks.

Also:

- [adr/](adr/): Architecture Decision Records, each with context, decision and consequences.
- [glossary.md](glossary.md): terms and their name in the schema and code.
- [ai-usage.md](ai-usage.md): what AI was used for in this project, per phase.

## Conventions for this documentation

- Documentation, schema, code and UI are in English.
- A decision that materially changes the design gets a new ADR. Do not rewrite an existing ADR; mark it *superseded by* and link to the new one.
- Diagrams are written in [Mermaid](https://mermaid.js.org/), so they render directly on GitHub and live in version control.
