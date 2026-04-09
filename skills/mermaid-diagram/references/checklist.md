# Mermaid Diagram Checklist

- Diagram type matches problem type (flowchart/sequence/state/etc.).
- Every arrow has correct direction.
- No crossing arrows unless unavoidable.
- Node labels are short and specific.
- `.mmd` and `.md` contain the same Mermaid source.
- Rendering verification command passes:
  - `mmdc -i figures/name.mmd -o figures/name.png`
  - or `npx -y @mermaid-js/mermaid-cli -i figures/name.mmd -o figures/name.png`
