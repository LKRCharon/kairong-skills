---
name: anti-ai-writing-style
description: Use when writing, rewriting, or auditing Chinese or English prose to reduce AI-writing tells while preserving the writer's claims and voice. Supports draft guard, rewrite, detect-only, file, and embedded modes.
metadata:
  version: "0.2.0"
---

# Anti AI Writing Style

Edit prose so it sounds written, not generated. Preserve the writer's facts, claims, voice, audience, and level of formality while removing formulaic AI patterns.

## When to use

- The user asks to remove AI flavor, machine tone, "AI 味", "机器味", "不像人写的", or similar.
- The user asks for an `anti-ai-writing-style.md` audit, "按这个文件审一遍", or a self-check before publishing.
- You are drafting or polishing prose-heavy English or Chinese content: blog posts, README text, emails, essays, resumes, paper prose, speeches, social posts, product copy, or interview answers.
- You see obvious AI-writing tells: negative framing, negative parallelism, inflated vocabulary, false breadth, over-neat triads, repeated sentence length, title-case headings, or synonym cycling.

## Modes

- `draft guard`: Before writing, load the reference and avoid known tells during drafting.
- `rewrite`: Default mode. Audit, rewrite, and run a second pass on the rewrite.
- `detect`: Flag only. Use when the user says "audit only", "只标出来", "scan", "detect", or wants to decide edits themselves.
- `bilingual`: For Chinese text, use Chinese rules first. For English text, use English rules first. For mixed text, preserve language boundaries and audit both.

## Workflow

1. Identify genre, audience, source constraints, and target voice.
   Keep technical terms, citations, numbers, legal wording, and deliberate formatting unless the user asks to change them.
2. Calibrate to the writer before applying generic rules.
   If the user supplies their own writing sample, match its sentence length, diction, punctuation, paragraph shape, repeated phrases, and transitions. The sample overrides generic style preferences, but never fact-preservation or format constraints.
3. Load `references/anti-ai-writing-style.md` when the text is more than a short reply or the user asks for an audit.
4. Find high-confidence tells first.
   Prioritize negative framing, negative parallel structures, inflated vocabulary clusters, fake contrast, triads, false ranges, synonym cycling, copula avoidance, and uniform rhythm.
5. Rewrite for directness and source-supported specificity.
   Trust the reader. Replace template shapes with direct claims, concrete nouns, source-provided evidence or examples, and shorter transitions. Delete quotable slogan lines unless they carry a concrete claim.
6. Run a claim-integrity pass.
   Compare the source and rewrite for names, numbers, dates, quotations, citations, rankings, constraints, uncertainty, and every other factual claim. Restore anything lost and remove anything added without support.
7. Run a style second pass.
   Re-read the revised text against the same file. Do not stop after vocabulary cleanup; rhythm and structure matter more.

## Hard Rules

- This is a writing-quality check, not proof that a human or AI wrote the text.
- Do not overfit by adding forced slang, jokes, fragments, or all-short sentences.
- Do not invent a fact, name, number, date, quotation, citation, example, mechanism, result, opinion, or personal detail. If specificity is missing, simplify the sentence, preserve the uncertainty, flag the gap, or ask the user.
- Do not delete, strengthen, or weaken substantive claims, writer-specific positions, citations, constraints, modality, or technical meaning merely to make prose smoother.
- Do not rewrite text inside quotations, titles, proper names, code, data, or link targets unless the user explicitly puts it in scope.
- Match punctuation from a supplied writing sample. Without one, avoid using em dashes as the default hinge.
- Prefer stable terms over synonym cycling. Repeating the right word is better than rotating names to sound varied.
- Use contrast only when the contrast carries real information. Do not use "not X, but Y" or "不是 X，而是 Y" to create an unnecessary opposing view before stating the actual claim.
- Do not make the text "human" by forcing jokes, slang, typos, or fake personality. A clean project note can sound human if it is direct, specific, and uneven in a natural way.

## Output Contract

Choose the return shape from the task context:

- `pasted rewrite` (default): return `Issues found`, `Rewritten version`, `What changed`, and `Verification`. In `Verification`, report whether claims were preserved and list any remaining style risks.
- `detect`: return `Issues found`, grouped by severity, followed by `Assessment`, separating definite problems from context-dependent flags. Do not rewrite.
- `file`: edit only the prose in the named file. Keep code blocks, frontmatter, data, and link targets unchanged unless they are explicitly in scope. Write no audit commentary into the file; summarize the edit after saving.
- `embedded`: when another task or skill invokes this one for a commit message, document passage, pull request, resume bullet, or similar artifact, return only the final text in the format requested by the parent task.
- `draft guard`: produce the requested artifact normally. Do not expose the internal audit unless the user asks for it.

If the user asks for only the final text, provide only the final text with no audit note.

## Quick Self-Audit Prompts

English:

```text
Audit your text using the anti-ai-writing-style.md file from your folder. Match any supplied writing sample. Fix AI-writing tells without adding, removing, strengthening, or weakening claims.
```

Chinese:

```text
请按 anti-ai-writing-style.md 自查一遍；如有作者样本，优先匹配其语气。只删机器味，不新增、删减、强化或弱化事实、主张、证据和技术含义。
```

## References

- Read `references/anti-ai-writing-style.md` for detailed bilingual patterns, false-positive safeguards, and the claim-integrity checklist.
