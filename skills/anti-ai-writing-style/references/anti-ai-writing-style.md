# Anti AI Writing Style Reference

This file is the detailed audit sheet for removing AI-writing tells in English and Chinese. Use it before drafting important prose and after writing a first version.

## Boundary

These rules identify style signals, not authorship proof. Humans also write formulaic prose under deadline pressure, in a second language, or in corporate genres. Fix the text because the prose gets clearer, not because a flag proves anything about who wrote it.

Keep the writer's facts, claims, evidence, citations, domain terms, and intended tone. The goal is normal, specific prose, not performative humanity.

## Fast Routine

1. Read the text once for meaning.
2. Search for negative parallel structures.
3. Search for inflated vocabulary and generic future language.
4. Check structural tells: triads, false ranges, synonym cycling, copula avoidance, title-case headings, and same-length sentences.
5. Rewrite only the affected parts.
6. Run a second pass and remove survivors.

## The Biggest Tell: Negative Parallelism

The most visible AI pattern is a fake contrast that creates drama without adding information: "It's not X, it's Y." It often appears as a polished hinge sentence.

### English forms to flag

- `It's not X, it's Y.`
- `This isn't X. This is Y.`
- `This isn't about X. It's about Y.`
- `Not X. Y.`
- `No longer X, but Y.`
- `Not only X, but also Y.`
- `Less X, more Y.`
- `X is dead. Y is the future.`
- `Stop X. Start Y.`
- `Rather than X, Y.`
- `Instead of X, Y.`
- `Beyond X, Y.`
- `While X may seem ..., Y ...`
- `Sure, X works. But Y ...`
- `From X to Y, the shift is clear.`
- `What looks like X is actually Y.`

### Chinese forms to flag

- `这不是 X，而是 Y。`
- `不是 X，是 Y。`
- `不只是 X，更是 Y。`
- `与其 X，不如 Y。`
- `少一点 X，多一点 Y。`
- `X 已死，Y 才是未来。`
- `不要 X，要 Y。`
- `表面上是 X，本质上是 Y。`
- `看似 X，实则 Y。`
- `虽然 X 看起来 ...，但 Y ...`
- `当然 X 有用，但 Y ...`
- `从 X 到 Y，变化已经发生。`
- `不再是 X，而是 Y。`
- `真正的问题不是 X，而是 Y。`
- `它解决的不是 X，而是 Y。`

### Safer rewrites

- State the positive claim directly.
- If there is a real contrast, name the concrete difference.
- If X is a misconception, explain who holds it and why it is wrong.
- If Y is just emphasis, cut the contrast.

Example:

```text
AI-ish: This is not just a productivity tool. It is a new way to think about work.
Cleaner: The tool changes two work habits: it remembers decisions across meetings and turns them into follow-up tasks.
```

```text
AI 味: 这不是一个简单的待办工具，而是一种重新组织工作的方式。
更自然: 这个工具记录会议决策，并把它们转成后续任务。它解决的是会后遗忘的问题。
```

## Vocabulary Watchlist

Flag these words when they are generic, promotional, or clustered. Some are valid technical terms in specific contexts. Keep them when they carry precise meaning, such as `robust statistics`, `ecosystem service`, or `transformer architecture`.

### English high-risk words and phrases

Replace or justify these on sight:

`delve`, `delve into`, `unlock`, `leverage`, `utilize`, `harness`, `tapestry`, `realm`, `landscape`, `paradigm`, `cutting-edge`, `state-of-the-art`, `best-in-class`, `seamless`, `seamlessly`, `robust`, `comprehensive`, `holistic`, `meticulous`, `meticulously`, `pivotal`, `transformative`, `transformation`, `revolutionize`, `game-changing`, `game changer`, `empower`, `streamline`, `elevate`, `foster`, `facilitate`, `bolster`, `spearhead`, `unleash`, `navigate`, `underscore`, `showcase`, `showcasing`, `resonate`, `synergy`, `interplay`, `ecosystem`, `myriad`, `plethora`, `multifaceted`, `nuanced`, `crucial`, `paramount`, `cornerstone`, `overarching`, `burgeoning`, `nascent`, `poised`, `quintessential`, `instrumental`, `impactful`, `actionable`, `scalable`, `dynamic`, `compelling`, `remarkable`, `unprecedented`, `sophisticated`, `innovative`, `innovation`, `significant`, `effectively`, `lessons learned`, `learnings`, `thought leader`, `thought leadership`, `best practices`, `deep dive`, `dive into`, `unpack`, `at its core`, `in today's`, `in an era where`, `it is worth noting`, `notably`, `moreover`, `furthermore`, `additionally`, `when it comes to`, `at the end of the day`, `that being said`, `in conclusion`, `in summary`, `to summarize`, `moving forward`, `the future looks bright`, `only time will tell`, `watershed moment`, `marking a pivotal moment`, `a step forward`, `a testament to`, `designed to`, `serves as`, `features`, `boasts`, `presents`, `commence`, `ascertain`, `endeavor`, `keen`, `embrace`, `symphony`, `beacon`, `vibrant`, `thriving`, `bustling`, `nestled`, `intricate`, `complexities`, `ever-evolving`, `enduring`, `daunting`, `journey`, `unlock value`, `drive value`, `create value`, `long-term sustainability`, `user engagement`, `community-driven`, `the integration of`, `the intersection of`, `designed for long-term`, `could potentially`, `may eventually`, `might ultimately`.

Preferred replacements are plain and specific:

- `leverage`, `utilize`, `harness` -> `use`
- `robust` -> `reliable`, `strong`, or the actual failure case it handles
- `seamless` -> `smooth`, `no manual step`, or the concrete friction removed
- `transformative`, `revolutionize` -> describe what changed
- `comprehensive` -> list the included scope
- `significant` -> give a number, comparison, or example
- `serves as` -> `is`
- `features`, `boasts` -> `has`, `includes`

### Chinese high-risk words and phrases

Flag these when they are generic or stacked:

`赋能`, `助力`, `释放潜力`, `激发潜能`, `撬动`, `破局`, `引领`, `重塑`, `颠覆`, `颠覆式`, `变革性`, `革命性`, `里程碑`, `关键节点`, `重要抓手`, `核心引擎`, `关键引擎`, `底层逻辑`, `顶层设计`, `全链路`, `闭环`, `生态`, `生态化`, `新范式`, `新格局`, `新篇章`, `时代浪潮`, `时代命题`, `价值洼地`, `长期主义`, `可持续发展`, `高质量发展`, `降本增效`, `提质增效`, `精细化`, `多维度`, `立体化`, `系统性`, `体系化`, `场景化`, `智能化`, `数字化转型`, `深度融合`, `协同联动`, `无缝衔接`, `丝滑体验`, `极致体验`, `全面解析`, `深入探讨`, `深度剖析`, `值得关注`, `不容忽视`, `毋庸置疑`, `显而易见`, `可以说`, `从某种意义上说`, `本质上`, `归根结底`, `打造`, `构建`, `赋能业务`, `驱动增长`, `加速落地`, `持续迭代`, `面向未来`, `打开想象空间`, `想象力`, `护城河`, `飞轮`, `抓手`, `链路`, `赛道`, `红利`, `窗口期`, `蓄势待发`, `焕发活力`, `注入新动能`, `释放新动能`, `迈向新阶段`, `开启新征程`, `书写新篇章`, `从 0 到 1`, `从 1 到 N`, `小而美`, `大而全`, `既要又要还要`, `不是简单的 X，而是 Y`.

Preferred replacements:

- Replace slogans with the concrete action, metric, or mechanism.
- Replace `赋能/助力` with the actual verb: `减少`, `加快`, `记录`, `同步`, `提醒`, `检测`.
- Replace `生态/闭环/链路` only when you can name the participants, steps, or data flow.
- Replace `深度/全面/系统` with the actual scope.

## Structural Tells

### 1. Rule of three

AI prose often uses three parallel adjectives or nouns because it sounds complete: `clear, scalable, and robust`; `高效、智能、可持续`. Use two items, four items, or a sentence with evidence. Keep triads only when the three items are real categories.

### 2. Significance inflation

Flag phrases that turn ordinary updates into historic moments: `pivotal moment`, `watershed`, `redefines the future`, `开启新篇章`, `重塑格局`. State what happened and let the reader judge its importance.

### 3. Superficial participle analysis

English AI prose piles on `-ing` clauses: `highlighting`, `underscoring`, `showcasing`, `reflecting`, `symbolizing`. Chinese equivalents include `体现了`, `彰显了`, `凸显了`, `展现了`. Ask whether the clause adds evidence. If not, cut it.

### 4. False range

Flag fake breadth: `from ancient X to modern Y`, `from startups to enterprises`, `from strategy to execution`, `从底层逻辑到顶层设计`, `从技术到商业`. Replace with the actual scope.

### 5. Synonym cycling

Do not rename the same thing four ways: `Claude`, `the assistant`, `the model`, `the system`; `用户`, `使用者`, `参与者`, `个体`. Pick the clearest term and repeat it.

### 6. Copula avoidance

AI prose dodges `is` / `是` with inflated verbs: `serves as`, `functions as`, `acts as`, `constitutes`, `成为了一个`. Use `is`, `has`, `includes`, `是`, `有`, `包括`.

### 7. Title case headings

For normal docs and notes, avoid title case like `Strategic Negotiations And Partnerships`. Prefer sentence case: `Strategic negotiations and partnerships`. In Chinese, avoid slogan headings unless the genre needs them.

### 8. Metronome rhythm

If every sentence has the same length and every paragraph has the same shape, rewrite. Good prose mixes short sentences with longer ones. Use 1-2 sentence paragraphs when the point benefits from space, but do not make the whole piece choppy.

## Rhythm Rules

- Mix short and long sentences.
- Use 1-2 sentence paragraphs for strong turns or important claims.
- Do not use em dashes as the default hinge.
- Do not force humor, slang, typos, or fragments just to look human.
- Keep enough polish for the genre. A paper abstract, a README, and a WeChat post should not sound the same.

## Audit Checklist

Use this checklist after drafting:

- Is there any `not X, but Y` / `不是 X，而是 Y` pattern?
- Are two or more high-risk words clustered in one paragraph?
- Does every paragraph add a new claim, evidence point, example, or transition?
- Are there triads that exist only for rhythm?
- Are there fake ranges that imply broad coverage without naming scope?
- Is the same thing renamed several times?
- Are simple `is/has/includes` verbs replaced with inflated verbs?
- Are headings title-cased or slogan-like without reason?
- Do sentence and paragraph lengths vary naturally?
- Did the revision preserve facts, claims, citations, and technical meaning?

## Rewriting Tactics

- Replace generic praise with a number, example, mechanism, or named constraint.
- Replace broad openings with the actual point.
- Cut meta-guidance like `let's explore`, `值得注意的是`, `下面我们来`.
- Convert fake contrast into a direct claim.
- Keep the plain term. Do not cycle synonyms for variety.
- Prefer verbs that describe work: `records`, `compares`, `blocks`, `retrieves`, `summarizes`; `记录`, `比较`, `阻止`, `检索`, `总结`.

## Reusable Audit Prompts

English:

```text
Audit your text using the anti-ai-writing-style.md file from your folder. Flag negative parallelism, inflated vocabulary, formulaic rhythm, false ranges, synonym cycling, and copula avoidance. Rewrite only what needs fixing and preserve facts, claims, citations, and technical meaning.
```

Chinese:

```text
请按 anti-ai-writing-style.md 自查一遍，重点检查“不是 X，而是 Y”、浮夸词、三联排比、假范围、同义词轮换、系动词回避和句长过齐。只改机器味，不改事实、主张、证据和技术含义。
```

## Maintenance

Refresh this file every three months or after a noticeable style drift. Add new tells only if they appear repeatedly across real drafts. Remove rules that cause too many false positives in technical writing.
