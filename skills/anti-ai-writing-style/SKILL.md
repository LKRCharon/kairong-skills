---
name: anti-ai-writing-style
description: Use when writing, rewriting, or auditing Chinese or English prose to avoid AI writing tells, including negative parallel structures, inflated vocabulary, formulaic rhythm, title-case headings, and generic polish. Supports draft guard, rewrite, and detect-only modes.
version: 0.1.0
---

# Anti AI Writing Style

Edit prose so it sounds written, not generated. Preserve the user's facts, claims, audience, and level of formality while removing formulaic AI patterns.

## When to use

- The user asks to remove AI flavor, machine tone, "AI 味", "机器味", "不像人写的", or similar.
- The user asks for an `anti-ai-writing-style.md` audit, "按这个文件审一遍", or a self-check before publishing.
- You are drafting or polishing prose-heavy English or Chinese content: blog posts, README text, emails, essays, resumes, paper prose, speeches, social posts, product copy, or interview answers.
- You see obvious AI-writing tells: negative parallelism, inflated vocabulary, false breadth, over-neat triads, repeated sentence length, title-case headings, or synonym cycling.

## Modes

- `draft guard`: Before writing, load the reference and avoid known tells during drafting.
- `rewrite`: Default mode. Audit, rewrite, and run a second pass on the rewrite.
- `detect`: Flag only. Use when the user says "audit only", "只标出来", "scan", "detect", or wants to decide edits themselves.
- `bilingual`: For Chinese text, use Chinese pattern rules first. For English text, use English pattern rules first. For mixed text, preserve language boundaries and audit both.

## Workflow

1. Identify genre, audience, and source constraints.
   Keep technical terms, citations, numbers, legal wording, and the user's own voice unless they are the problem.
2. Load `references/anti-ai-writing-style.md` when the text is more than a short reply or the user asks for an audit.
3. Find high-confidence tells first.
   Prioritize negative parallel structures, inflated vocabulary clusters, fake contrast, triads, false ranges, synonym cycling, copula avoidance, and uniform rhythm.
4. Rewrite for specificity.
   Replace template shapes with direct claims, concrete nouns, evidence, examples, or shorter transitions.
5. Second-pass audit.
   Re-read the revised text against the same file. Do not stop after vocabulary cleanup; rhythm and structure matter more.

## Hard Rules

- This is a writing-quality check, not proof that a human or AI wrote the text.
- Do not overfit by adding forced slang, jokes, fragments, or all-short sentences.
- Do not change facts, claims, citations, or technical meaning to make prose sound casual.
- Avoid em dashes in normal prose unless the target style explicitly wants them.
- Prefer stable terms over synonym cycling. Repeating the right word is better than rotating names to sound varied.
- Use contrast only when the contrast carries real information. Do not use "not X, but Y" as a default emphasis machine.

## Output Contract

For `rewrite` mode, return:

1. `Issues found`: concise bullets with quoted evidence.
2. `Rewritten version`: the cleaned text.
3. `What changed`: short explanation of the main edit types.
4. `Second-pass audit`: remaining risks or "clean enough".

For `detect` mode, return:

1. `Issues found`: grouped by severity.
2. `Assessment`: which flags are definite problems and which are context-dependent.

If the user asks for only the final text, provide only the revised text plus one short note that it passed the style audit.

## Quick Self-Audit Prompts

English:

```text
Audit your text using the anti-ai-writing-style.md file from your folder. Fix AI-writing tells without changing facts, claims, or technical meaning.
```

Chinese:

```text
请按 anti-ai-writing-style.md 自查一遍，只删机器味，不改事实、主张、证据和技术含义。
```

## References

- `references/anti-ai-writing-style.md`
