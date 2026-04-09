---
name: cs-resume-builder
description: use when tasks involve turning existing markdown profile notes, experience summaries, and project descriptions into a polished computer science resume using a tailwindcss-based html template. supports chinese and english resumes, optional pdf-ready output, and job-targeted tailoring such as selecting the most relevant 2-4 projects from a larger pool based on a job description.
---

# CS Resume Builder

Turn existing resume source material into a polished, tailored resume with minimal friction.

## Default behavior

Assume the user already has raw content and wants a usable resume draft quickly.

Unless the user explicitly asks for another format:
- use HTML as the primary output
- use Tailwind utility classes for styling
- keep the HTML print-safe so it can be exported to PDF later
- prefer a one-page layout for research internship resumes
- optimize for a 30-second recruiter scan
- prefer separate Chinese and English resume outputs over one mixed bilingual page

Never fabricate facts, metrics, dates, titles, or technologies.
If the input is incomplete, compress and reorganize what exists rather than inventing missing achievements.

## Accepted inputs

This skill works best when the user provides some or all of:
- a markdown self-introduction or profile summary
- one or more markdown files describing projects, internships, research, or publications
- an optional target job description
- an optional preference for Chinese, English, or both

When input shape is unclear, read `references/input-format.md`.

## Workflow

### 1. Determine the mode

Choose one primary mode:

- **General resume draft**
  Use when the user wants a baseline resume without a specific job target.

- **Job-targeted resume**
  Use when a job description is provided and the resume should be tailored toward it.

- **Bilingual resume generation**
  Use when the user wants both Chinese and English versions.
  Prefer generating two parallel outputs rather than compressing both languages into one page.

- **Project selection and trimming**
  Use when the user has several projects and only the most relevant subset should appear.

### 2. Normalize the content

Before writing, extract and normalize:
- identity and contact information
- education
- work, research, internship, or competition experience
- project pool
- skills and tool stack
- publications, awards, or links if present

Rewrite bullets to be:
- concise
- evidence-based
- verb-led
- focused on outcome, method, and relevance

Prefer quantified impact when the user already provided evidence.
If no metrics are available, state the technical contribution clearly instead of inventing numbers.

### 3. Choose one primary narrative

Do not present the user as a generic "all-round AI candidate" unless the user explicitly wants that framing.

Pick one main direction and let the resume orbit around it:
- LLM
- multimodal
- inference optimization / systems
- AI4Science

Everything else should support that main direction rather than compete with it.

### 4. Tailor toward the job

When a job description exists:
- extract the must-have skills, domain keywords, and seniority signals
- score each project for relevance
- keep the strongest 2-4 projects unless the user requests otherwise
- reorder sections and bullets so the most relevant evidence appears earlier

When choosing between several projects, prioritize:
1. direct domain match
2. technical stack overlap
3. evidence of ownership or depth
4. measurable outcome or research relevance

Use `references/tailoring-rubric.md` when deeper matching logic is needed.
Use `references/role-emphasis.md` when the job track should reshape the whole resume narrative.

### 5. Choose the structure

Use a structure that is easy to scan in both ATS and human review:
- header
- summary
- education
- experience or research
- selected projects
- skills
- optional publications, awards, or links

For student or research resumes, projects and research experience usually deserve more space than generic coursework.
For engineering resumes, avoid long self-description paragraphs if project bullets already carry the signal.
For research internships, compress aggressively toward one page unless the user explicitly prefers a longer academic CV.

### 6. Generate the output

Default output:
1. one production-oriented HTML file
2. optional second HTML file in the other language if bilingual output is requested
3. a short note listing what was emphasized, cut, or reordered

Use `assets/resume-template.html` as the starting point when a print-friendly layout is needed.
If the user asks for the clean blue systems style derived from the reference resume, use `assets/resume-template-kairong-clean.html` and `references/theme-kairong-clean-blue.md`.

If PDF is explicitly requested:
- generate the HTML first
- ensure print CSS is stable
- then export or prepare it for PDF rendering

### 7. Enforce typography and page constraints

Default print layout assumptions:
- target A4 page size
- keep the resume inside printable page bounds
- use body text around 12-14 pt equivalent
- make section titles 1-2 pt larger than body text
- never let section titles fall below 12 pt equivalent

For English resumes:
- prefer uppercase section headers such as `EDUCATION`, `PROJECTS`, and `SKILLS`

Avoid oversized typography that makes content look thin.
Avoid undersized typography that harms scanability just to force more content onto one page.

## Language rules

### Chinese output
- keep wording compact and high-signal
- avoid translated jargon when the English term is standard in recruiting
- do not make the tone too literary or too academic unless the role is research-heavy

### English output
- use recruiter-friendly engineering phrasing
- prefer strong action verbs
- keep grammar consistent and avoid literal translation from Chinese sentence order
- preserve proper nouns, paper names, model names, and stack names accurately

For bilingual requests, keep the facts aligned across languages even if wording differs.

## Resume writing rules

Always:
- preserve factual truth
- remove redundant or weak bullets
- highlight scope, depth, and concrete contribution
- surface the most relevant stack and problem domain early
- keep technical wording concrete and interviewable
- make each selected bullet defensible for at least a few minutes of follow-up

Project bullets should usually make clear:
- what was built or studied
- what methods, models, systems, or tools were used
- what changed as a result

For research items:
- do not only list paper or topic names
- state the user's real contribution such as data cleaning, reproduction, ablation, evaluation pipeline, or method design

For skills sections:
- list actual tools the user can discuss in detail
- prefer concrete items like `LoRA`, `QLoRA`, `vLLM`, `FSDP`, `DeepSpeed`, `FlashAttention`, `PyTorch`, `CUDA`, `C++`
- avoid vague claims like "familiar with large models" or "good coding ability"

Avoid:
- generic self-evaluation
- long narrative paragraphs
- repeating the same skill in multiple sections
- listing every project equally when only a few are relevant
- broad AI branding without a clear direction
- project bullets that describe work but show no result
- keyword stuffing without evidence

## Output quality bar

A good output should:
- look polished as HTML
- remain readable when printed to PDF
- fit on one page by default for internship-style resumes
- use body copy and section headings that remain comfortable in print
- feel targeted to the role instead of generic
- make project selection decisions explicit and defensible
- work in Chinese, English, or both without awkward translation artifacts

## References

Read these files as needed:
- `references/input-format.md` for expected markdown input structure
- `references/tailoring-rubric.md` for project ranking and job-targeting heuristics
- `references/role-emphasis.md` for role-specific keyword and emphasis shifts
- `references/theme-kairong-clean-blue.md` for the extracted clean blue resume theme
- `assets/resume-template.html` for the base Tailwind HTML layout
- `assets/resume-template-kairong-clean.html` for the clean blue systems resume theme
