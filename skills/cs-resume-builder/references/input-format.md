# Resume Input Format

This skill expects source material in Markdown, but it should still work when the input is rough.

## Minimum viable input

At minimum, try to extract:
- name
- current role or status
- education
- at least one project or experience item

## Recommended markdown sections

Any of the following headings are acceptable:

- `# Profile`
- `# Summary`
- `# Education`
- `# Experience`
- `# Research`
- `# Projects`
- `# Skills`
- `# Publications`
- `# Awards`

The exact heading names do not need to match.

## Good project entry shape

Each project entry should ideally include:
- project name
- role
- time range
- problem or goal
- methods, models, system design, or stack
- results or evidence

If some fields are missing, preserve the facts that do exist and avoid inventing the rest.

## Job description input

When a job description is provided, extract:
- role title
- must-have skills
- preferred skills
- domain signals
- seniority expectations
- language expectations

Then use those signals to choose projects and rewrite emphasis.

## Output choice guidance

- If the user is still iterating on content, HTML is the best default output.
- If the user needs final delivery, make the HTML print-safe and optionally prepare PDF output.
- If the user asks for both Chinese and English, prefer two files over one mixed-language file.
