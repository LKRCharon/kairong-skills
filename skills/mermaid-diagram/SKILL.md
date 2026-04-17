---
name: mermaid-diagram
description: Use when you need free, editable, source-controlled system or pipeline diagrams in Mermaid, with syntax checks and markdown preview output.
version: 0.1.0
---

# Mermaid Diagram

Create diagram source files that are easy to version, diff, and iterate.

## When to use
- Draw method pipeline or system flow quickly without image-generation APIs.
- Keep diagrams in text format for collaborative review and git tracking.
- Produce architecture placeholders before final polished illustration.

## Workflow
1. Select diagram family.
   Prefer `flowchart` for pipelines and `sequenceDiagram` for interactions.
2. Write `.mmd` source.
   Keep node labels concise and directional flow explicit.
3. Generate markdown preview.
   Mirror the exact Mermaid code in a `.md` file for easy rendering.
4. Validate syntax.
   Use `mmdc` or `npx @mermaid-js/mermaid-cli` when available.
5. Review clarity.
   Check arrow direction, node naming, and readability at paper scale.

## Recommended outputs
- `figures/<name>.mmd`
- `figures/<name>.md`
- `figures/<name>.png` (optional render output)

## Quality bar
- Arrows show unambiguous data flow direction.
- Diagram has one dominant reading path.
- Labels are concept names, not paragraph text.
- Diagram is understandable without oral explanation.

## Integration
- Use this skill for free drafts, then migrate high-value diagrams to `$paper-illustration` for final polish when needed.

## References
- `references/checklist.md`
