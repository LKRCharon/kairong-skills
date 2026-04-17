---
name: paper-illustration
description: Use when you need polished architecture or method illustrations for papers, with prompt-driven generation and strict visual-review iterations.
version: 0.1.0
---

# Paper Illustration

Create high-quality architecture or conceptual method figures for papers.

## When to use
- Finalize hero figure, method overview, or system architecture figure.
- Upgrade a rough pipeline draft into publication-grade visual quality.
- Produce a consistent visual language across multiple conceptual figures.

## Inputs
- Figure purpose and audience (paper/rebuttal/slides).
- Mandatory component list and data flow direction.
- Any style references (existing figures, color direction, venue tone).

## Workflow
1. Start from structure, not style.
   Build a component-and-arrow specification first.
2. Produce a draft quickly.
   Use `$mermaid-diagram` for rapid first-pass structure when helpful.
3. Generate polished illustration.
   Use your preferred image/design workflow (AI image generation, Figma, or manual vector editing).
4. Run strict visual review.
   Verify arrow direction, text legibility, alignment, and hierarchy.
5. Iterate until publication bar.
   Keep each revision tied to concrete failure points from review.

## Quality bar
- Every module and arrow direction is logically correct.
- Typography remains readable in paper print size.
- Visual hierarchy highlights the main contribution path.
- Color usage is deliberate and consistent, not decorative.
- Diagram is interpretable in under 10 seconds.

## Recommended outputs
- `figures/illustration_<name>.svg` (editable)
- `figures/illustration_<name>.pdf` (paper insertion)
- `figures/illustration_<name>.png` (quick preview)
- `figures/illustration_<name>_prompt.md` (prompt + spec for reproducibility)

## References
- `references/prompt-template.md`
