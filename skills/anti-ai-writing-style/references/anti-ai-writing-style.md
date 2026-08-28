# Anti AI Writing Style Reference

This file is the detailed audit sheet for removing AI-writing tells in English and Chinese. Use it before drafting important prose and after writing a first version.

## Boundary

These rules identify style signals, not authorship proof. Humans also write formulaic prose under deadline pressure, in a second language, or in corporate genres. Fix the text because the prose gets clearer, not because a flag proves anything about who wrote it.

Keep the writer's facts, claims, evidence, citations, domain terms, and intended tone. The goal is normal, specific prose, not performative humanity.

## Voice Calibration

Use the writer's own sample when one is available. Read it before rewriting and note:

- sentence and paragraph length;
- plain versus formal word choice;
- punctuation and parenthetical habits;
- paragraph openings and transitions;
- deliberate repetition, fragments, humor, or first-person phrasing.

Match those habits at roughly the same frequency. A writing sample overrides generic preferences about cadence, punctuation, formality, and em dashes. It does not override the user's requested format, factual fidelity, quotations, citations, or technical constraints.

Without a sample, preserve the source's strongest consistent habits. Do not manufacture personality, opinions, slang, uncertainty, or personal details to make the prose feel human.

## Claim Integrity

Treat style editing as a meaning-preserving transformation. Before rewriting, inventory details that must survive:

- names, numbers, dates, measurements, rankings, and comparisons;
- quotations, citations, attributions, and source boundaries;
- scope, negation, uncertainty, modality, causality, and stated limitations;
- technical terms, legal wording, requirements, and commitments.

After rewriting, compare the result against that inventory. An unsupported addition or a lost, strengthened, or weakened claim is an error. Do not turn vague praise into an invented metric, replace an unnamed source with a named one, add a product feature as an example, or supply a mechanism that the source never stated.

Preserve factual claims and writer-specific positions. Formulaic emphasis that only repeats the preceding sentence, such as a generic sendoff or an empty claim of importance, may be cut as style. When the distinction is unclear, flag the sentence instead of deleting it.

When a sentence needs missing detail, choose one of four actions: simplify it, preserve its uncertainty, flag the gap, or ask the user. Fact-checking is a separate task; change a factual claim only when the user requests that work and evidence supports the correction.

## Fast Routine

1. Read the text once for meaning and identify its genre.
2. Inventory claims and calibrate to any supplied writing sample.
3. Assign severity before editing.
4. Search for negative framing, inflated vocabulary, and generic future language.
5. Check structural tells: triads, false ranges, synonym cycling, copula avoidance, title-case headings, and uniform rhythm.
6. For Chinese, also check public-account voice, policy-document voice, slogan stacking, fake profundity, and over-explained conclusions.
7. Rewrite the paragraph around its main point instead of patching isolated words when the structure is the problem.
8. Run the claim-integrity comparison.
9. Check false positives, then run a style second pass.
10. Return the result in the mode required by the task.

## Severity Levels

Use severity to decide what to fix first. Do not treat every flag as equal.

- `P0 critical`: chatbot leakage, unfinished placeholders, citation leaks, copied UI artifacts, or text that openly reveals generation. Examples: `作为一个 AI 语言模型`, `当然可以，以下是`, `希望这能帮到你`, `[citation needed]`, `<insert example here>`.
- `P1 strong AI tell`: staged negative framing, fake contrast, slogan-heavy claims, generic future predictions, heavy synonym cycling, or high-risk vocabulary clusters.
- `P2 style drag`: formulaic transitions, triads, false ranges, excessive bullets, title-case headings, and same-length rhythm.
- `P3 context-dependent`: common words that are fine in technical prose but suspicious in clusters, such as `robust`, `ecosystem`, `闭环`, `生态`, `抓手`.

## High-Confidence Tell: Unnecessary Negative Framing

Do not build the argument by first inventing or invoking an unnecessary opposing claim. Directly state what the thing is, what it does, or why it matters.

Negative framing often looks like this:

```text
AI-ish: This is not X, but rather Y.
Cleaner: This is Y.
```

```text
AI 味: 这不是 X，而是 Y。
更自然: 这是 Y。
```

The problem is not every contrast. Real contrast is useful when it corrects a real misconception, separates two technical concepts, or marks an experimental boundary. The AI tell is a contrast that only creates drama before arriving at the claim.

Audit question: does the sentence advance the argument faster if the negative half is deleted? If yes, delete it.

### Negative parallelism patterns

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
- In academic or technical writing, use contrast only to separate concepts, assumptions, protocols, or failure modes.

Example:

```text
AI-ish: This productivity tool is not limited to task lists; it also tracks decisions and follow-up work.
Cleaner: This productivity tool tracks task lists, decisions, and follow-up work.
```

```text
AI 味: 这不只是一个待办工具，更是团队整理会后工作的方式。
更自然: 这个待办工具帮助团队整理会后工作。
```

Academic example:

```text
AI-ish: Our benchmark is not a collection of isolated attacks, but rather one framework for studying watermark robustness under direct scrubbing, stealing-based scrubbing, and spoofing.
Cleaner: Our benchmark studies watermark robustness under direct scrubbing, stealing-based scrubbing, and spoofing in one framework.
```

## Vocabulary Watchlist

Flag these words when they are generic, promotional, or clustered. Some are valid technical terms in specific contexts. Keep them when they carry precise meaning, such as `robust statistics`, `ecosystem service`, or `transformer architecture`.

### English high-risk words and phrases

Replace or justify these on sight:

`delve`, `delve into`, `unlock`, `leverage`, `utilize`, `harness`, `tapestry`, `realm`, `landscape`, `paradigm`, `cutting-edge`, `state-of-the-art`, `best-in-class`, `seamless`, `seamlessly`, `robust`, `comprehensive`, `holistic`, `meticulous`, `meticulously`, `pivotal`, `transformative`, `transformation`, `revolutionize`, `game-changing`, `game changer`, `empower`, `streamline`, `elevate`, `foster`, `facilitate`, `bolster`, `spearhead`, `unleash`, `navigate`, `underscore`, `showcase`, `showcasing`, `resonate`, `synergy`, `interplay`, `ecosystem`, `myriad`, `plethora`, `multifaceted`, `nuanced`, `crucial`, `paramount`, `cornerstone`, `overarching`, `burgeoning`, `nascent`, `poised`, `quintessential`, `instrumental`, `impactful`, `actionable`, `scalable`, `dynamic`, `compelling`, `remarkable`, `unprecedented`, `sophisticated`, `innovative`, `innovation`, `significant`, `effectively`, `lessons learned`, `learnings`, `thought leader`, `thought leadership`, `best practices`, `deep dive`, `dive into`, `unpack`, `at its core`, `in today's`, `in an era where`, `it is worth noting`, `notably`, `moreover`, `furthermore`, `additionally`, `when it comes to`, `at the end of the day`, `that being said`, `in conclusion`, `in summary`, `to summarize`, `moving forward`, `the future looks bright`, `only time will tell`, `watershed moment`, `marking a pivotal moment`, `a step forward`, `a testament to`, `designed to`, `serves as`, `features`, `boasts`, `presents`, `commence`, `ascertain`, `endeavor`, `keen`, `embrace`, `symphony`, `beacon`, `vibrant`, `thriving`, `bustling`, `nestled`, `intricate`, `complexities`, `ever-evolving`, `enduring`, `daunting`, `journey`, `unlock value`, `drive value`, `create value`, `long-term sustainability`, `user engagement`, `community-driven`, `the integration of`, `the intersection of`, `designed for long-term`, `could potentially`, `may eventually`, `might ultimately`.

Preferred replacements are plain and specific:

- `leverage`, `utilize`, `harness` -> `use`
- `robust` -> `reliable`, `strong`, or a source-stated failure case it handles
- `seamless` -> `smooth` or the source-stated friction removed
- `transformative`, `revolutionize` -> describe the source-stated change
- `comprehensive` -> list the included scope when the source provides it
- `significant` -> use a source-provided number, comparison, or example; otherwise remove or qualify the adjective
- `serves as` -> `is`
- `features`, `boasts` -> `has`, `includes`

### Chinese high-risk words and phrases

Flag these when they are generic or stacked:

`赋能`, `助力`, `释放潜力`, `激发潜能`, `撬动`, `破局`, `引领`, `重塑`, `颠覆`, `颠覆式`, `变革性`, `革命性`, `里程碑`, `关键节点`, `重要抓手`, `核心引擎`, `关键引擎`, `底层逻辑`, `顶层设计`, `全链路`, `闭环`, `生态`, `生态化`, `新范式`, `新格局`, `新篇章`, `时代浪潮`, `时代命题`, `价值洼地`, `长期主义`, `可持续发展`, `高质量发展`, `降本增效`, `提质增效`, `精细化`, `多维度`, `立体化`, `系统性`, `体系化`, `场景化`, `智能化`, `数字化转型`, `深度融合`, `协同联动`, `无缝衔接`, `丝滑体验`, `极致体验`, `全面解析`, `深入探讨`, `深度剖析`, `值得关注`, `不容忽视`, `毋庸置疑`, `显而易见`, `可以说`, `从某种意义上说`, `本质上`, `归根结底`, `打造`, `构建`, `赋能业务`, `驱动增长`, `加速落地`, `持续迭代`, `面向未来`, `打开想象空间`, `想象力`, `护城河`, `飞轮`, `抓手`, `链路`, `赛道`, `红利`, `窗口期`, `蓄势待发`, `焕发活力`, `注入新动能`, `释放新动能`, `迈向新阶段`, `开启新征程`, `书写新篇章`, `从 0 到 1`, `从 1 到 N`, `小而美`, `大而全`, `既要又要还要`, `不是简单的 X，而是 Y`.

Preferred replacements:

- Replace slogans with a concrete action, metric, or mechanism already present in the source.
- Replace `赋能/助力` with the source's actual verb, such as `减少`, `加快`, `记录`, `同步`, `提醒`, or `检测`.
- Replace `生态/闭环/链路` only when the source names the participants, steps, or data flow.
- Replace `深度/全面/系统` with the source-stated scope; otherwise remove the modifier.

## Chinese-Specific Tells

Chinese AI prose often sounds less like machine-translated English and more like a compressed mix of public-account copy, policy documents, product launch language, and motivational slogans. Audit these separately from the English list.

### 1. Public-account opening

Flag openings that start from a broad social mood before naming the actual point:

- `在当下这个信息爆炸的时代...`
- `随着人工智能的快速发展...`
- `近年来，X 正在以前所未有的速度改变...`
- `在数字化浪潮席卷各行各业的今天...`
- `如果说过去 X，那么现在 Y...`

Fix: start with the concrete event, problem, user, or result.

```text
AI 味: 在信息爆炸的时代，会议纪要工具帮助团队记录会后任务。
更自然: 会议纪要工具帮助团队记录会后任务。
```

### 2. Policy-document voice

Flag official-sounding stacking when the genre is not policy writing:

- `持续推进 X 建设`
- `全面提升 X 能力`
- `构建 X 新格局`
- `形成 X 闭环`
- `推动 X 高质量发展`
- `夯实 X 基础`
- `强化 X 保障`
- `促进 X 协同联动`

Fix: name the actor, action, object, and any measurable change already present in the source.

### 3. Four-character slogan stacking

Flag dense strings of four-character phrases:

- `提质增效、降本增效、协同联动、闭环管理`
- `精准触达、快速响应、持续迭代、稳定交付`
- `可感可知、可管可控、可追可溯`

Fix: keep at most one slogan-like phrase if it is a known term. Convert the rest into normal sentences.

### 4. Fake profundity

Flag sentences that sound philosophical but do not add a claim:

- `本质上，这是一次关于效率与信任的重新思考。`
- `真正重要的不是工具本身，而是它背后的人与流程。`
- `这背后反映的是一种更深层的变化。`
- `它让我们重新理解 X 的边界。`
- `所有技术最终都要回到人的需求。`

Fix: replace with a mechanism stated in the source, or delete the empty conclusion.

### 5. Product-launch voice

Flag launch-copy claims when the task asks for normal explanation:

- `一站式解决方案`
- `轻量而强大`
- `开箱即用`
- `丝滑体验`
- `极致性能`
- `全流程覆盖`
- `让 X 变得前所未有地简单`

Fix: state source-supported features and the conditions where they help.

### 6. Resume/interview polish voice

Flag bullets that inflate ordinary work:

- `深度参与 X`
- `主导完成 X 全流程建设`
- `负责 X 能力沉淀`
- `推动 X 落地并取得显著成效`
- `具备扎实的 X 能力和丰富的 Y 经验`

Fix: use the project, action, artifact, metric, and constraint supplied by the writer. Do not fill missing fields with plausible details.

### 7. Soft-transition padding

Flag transitions that exist only to sound smooth:

- `值得一提的是`
- `更进一步`
- `与此同时`
- `在这个过程中`
- `从这个角度来看`
- `换句话说`
- `这也意味着`
- `可以看到`

Fix: keep the transition only if it changes the logical relation. Otherwise start the next claim directly.

### 8. Enumeration scaffolding

Flag rigid numbered framing:

- `首先...其次...最后...`
- `一方面...另一方面...`
- `从 X、Y、Z 三个维度来看...`
- `围绕 X，可以拆成三层...`

Fix: use this only for real step-by-step instruction or a real taxonomy. For prose, combine or reorder by importance.

### 9. English-term decoration

Flag English terms used for polish rather than precision:

- `打造一个 workflow`
- `形成完整 loop`
- `提升 prompt 质量`
- `沉淀 best practice`
- `构建 agentic 体验`

Fix: keep English only for fixed technical terms or when the Chinese translation would be less precise. Otherwise use Chinese verbs.

### 10. False empathy

Flag generic emotional alignment:

- `相信很多人都有这样的感受`
- `你一定遇到过这样的场景`
- `这可能是每个人都绕不开的问题`
- `说到底，我们都在寻找一种更好的方式`

Fix: describe an exact user pain only when the source supplies it. Otherwise cut the empathy claim or narrow the audience without inventing a scenario.

### 11. Chinese rhythm issues

AI Chinese often makes every sentence similar: `主语 + 是 + 抽象名词`, or `它可以 X，也可以 Y，还可以 Z`.

Fix:

- Mix short sentences with one longer explanatory sentence.
- Prefer verbs over abstract nouns.
- Use specific nouns from the user's context.
- Avoid every paragraph ending with a broad conclusion.

### 12. Chinese rewrite rule

For Chinese, do not "humanize" by adding internet slang, jokes, emoji, or deliberately casual particles. Good Chinese prose can be plain, dense, and clean. The target is closer to a sharp project note or an honest product explanation than a public-account article.

### 13. Over-explaining what readers can infer

Flag lines that explain the obvious, restate the metaphor, or wrap a claim in hand-holding:

- `这说明了 X 的重要性`
- `这也提醒我们，X 并不是孤立存在的`
- `换句话说，X 的意义在于...`
- `这背后其实反映了...`
- `这让我们看到...`

Fix: trust the reader. If the evidence already implies the conclusion, stop at the evidence. If a conclusion is needed, write the specific conclusion instead of a broad lesson.

```text
AI 味: 过去一个月，团队漏掉了 6 项会后 todo。这说明团队上个月存在会后任务遗漏。
更自然: 过去一个月，团队漏掉了 6 项会后 todo。
```

### 14. Quotable slogan endings

Flag sentence endings that sound like a post title, keynote punchline, or shareable quote:

- `真正的改变，往往发生在看不见的地方。`
- `技术的终点，还是回到人。`
- `好的工具，不是替代人，而是让人更像人。`
- `当 X 遇见 Y，一场新的变革已经开始。`

Fix: delete the line or replace it with a source-supported action, result, or limit. A sentence that sounds polished enough to be printed on a poster is usually too broad for normal prose.

### 15. Sterile prose with no stance

Some text passes the obvious pattern checks but still reads generated: every sentence is balanced, every claim is neutral, and nothing suggests a person made a judgment.

Flag:

- Same sentence structure repeated across a paragraph.
- Safe neutrality where the genre allows a judgment.
- No concrete discomfort, uncertainty, tradeoff, or point of view.
- Perfectly smooth paragraph endings that summarize instead of deciding.

Fix carefully. Preserve a stance found in the source or writing sample, but do not create one. Do not add fake warmth, forced jokes, slang, or casual particles. In technical writing, keep a supplied tradeoff such as `这个版本能跑通，但误报还偏高。`

## Cross-Language Pattern Extensions

These patterns complement the Chinese rules above. Apply them in both languages where relevant.

### 1. Passive voice and missing actors

Flag passive or subjectless sentences when they hide an actor already named in the source, create a row of fragments, or make responsibility unclear.

```text
AI-ish: The team approved the report. The findings were then presented by the team on Friday.
Cleaner: The team approved the report and presented the findings on Friday.
```

```text
AI 味: 报告于周五由团队完成并提交。
更自然: 团队周五完成并提交报告。
```

Keep passive voice when the actor is unknown, irrelevant, intentionally withheld, or required by the genre. Never invent an actor to make a sentence active.

### 2. Generic positive sendoffs

Flag endings such as `the future looks bright`, `exciting times lie ahead`, `未来可期`, `让我们拭目以待`, and `迈出了重要一步` when they add no plan, result, or limit.

```text
AI-ish: The team plans to open two more locations next year. The future looks bright as it continues its journey.
Cleaner: The team plans to open two more locations next year.
```

End on the last useful fact. Keep a future statement when the source names a real plan, date, owner, dependency, or uncertainty.

### 3. Too many hyphenated pairs in English

Watch clusters such as `cross-functional`, `client-facing`, `data-driven`, `decision-making`, `real-time`, `long-term`, and `end-to-end`. Keep a hyphen when grammar requires it before a noun: `a high-quality report`. Drop it in predicate position when the target style does not use it: `the report is high quality`.

Do not flatten established technical terms, quoted wording, or a writer's consistent house style.

### 4. Staged deeper-truth framing

Flag `the real question is`, `at its core`, `what really matters`, `fundamentally`, `真正的问题是`, `归根结底`, and `本质上` when they announce depth without adding a distinction.

```text
AI-ish: At its core, the migration is about reducing deploy time.
Cleaner: The migration reduces deploy time.
```

This overlaps with Chinese fake profundity. Keep the framing when it introduces a genuine conceptual distinction already developed in the text.

### 5. Announcing the next point and restating headings

Flag formal or casual announcements such as `let's dive in`, `here is what you need to know`, `quick note`, `先说结论`, and `下面展开`, when the next sentence can state the point directly. Also flag a heading followed by a sentence that merely repeats it.

```text
## Performance

Speed matters.

Pages over three seconds had a higher exit rate.
```

Remove `Speed matters.` and start with the evidence. Keep signposting when it helps readers navigate a long procedure, changes the logical relation, or matches the supplied writing sample.

### 6. Editorial scar tissue

Normal documentation should describe current behavior. Flag prose that narrates an earlier draft, implementation, or wording when the genre is not a changelog, release note, migration guide, decision record, or historical explanation.

```text
AI-ish: This function now uses a hash map, replacing the previous nested loop and reducing lookup cost from O(n²) to O(1).
Cleaner: The hash map provides O(1) lookups instead of the O(n²) cost of nested iteration.
```

Preserve past behavior when readers need it to migrate, reproduce a result, or understand a decision.

### 7. Forced dramatic fragments and formulaic sayings

Flag rows of short dramatic sentences and slogan templates such as `X is the language of Y`, `X is the currency of Y`, `X becomes a trap`, `没有退路。没有例外。`, and `X 是 Y 的底色` when a normal sentence carries the same information.

```text
AI-ish: Requests waited up to 12 seconds. The queue was full. Latency became a trap.
Cleaner: With the queue full, requests waited up to 12 seconds.
```

One short sentence or a deliberate metaphor can be part of the writer's voice. Flag a repeated template, not the mere presence of emphasis.

### 8. Fake-candid openings

Flag staged hooks such as `Honestly?`, `Look,`, `Here's the thing`, `Real talk`, `说实话`, `讲真`, and `坦白说` when they precede an ordinary statement and do not match the writer's voice.

```text
AI-ish: Honestly? The migration took six weeks.
Cleaner: The migration took six weeks.
```

Keep genuine self-correction, uncertainty, or conversational phrasing supported by the source or sample.

### 9. Shadowboxing with unnamed objections

Flag defenses such as `I'm not saying`, `to be clear`, `don't get me wrong`, `有人可能会说`, and `这并不是说` when no person, source, or earlier passage raises the objection.

Rewrite every retained claim directly:

```text
AI-ish: To be clear, I am not saying documentation does not matter. The parser must also validate the schema at runtime.
Cleaner: Documentation matters, and the parser must validate the schema at runtime.
```

Keep named objections, FAQ answers, safety limits, scope statements, and distinctions that the argument actually resolves.

### 10. Rejecting imaginary alternatives

Flag `a tempting approach would be`, `one might think`, `it would be easy to`, `一种显而易见的做法是`, and similar setup when the option is never considered elsewhere and contributes no decision-relevant information.

If the rejected option carries a real constraint, state the constraint directly:

```text
AI-ish: One might be tempted to restart the service to rotate tokens, but that would drop active sessions. Tokens rotate in place.
Cleaner: Restarting the service would drop active sessions, so tokens rotate in place.
```

In a style-only rewrite, flag an apparently abandoned drafting idea instead of deleting factual content. Keep real alternatives in design documents, tutorials, arguments, and decision records.

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

Also watch several sentences that begin with the same subject and follow the same grammar. Merge them, begin with the action, or change the subject only when doing so improves the paragraph. Keep deliberate repetition used for rhythm or emphasis.

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
- Vary paragraph endings. Do not end every paragraph with a neat thesis sentence or slogan.
- Two items often sound more natural than a forced three-item list. Four items can also be fine when the categories are real.

## False-Positive Safeguards

One pattern is weak evidence. Look for clusters, repetition, and a mismatch with the genre or writer's sample.

Do not flag these by themselves:

- perfect grammar, consistent style, or professionally edited prose;
- dry or neutral prose without a specific AI-writing tell;
- one formal term or transition used precisely;
- one em dash, curly quotation marks, or a correctly hyphenated modifier;
- one short sentence or a deliberate repeated opening;
- passive voice when the actor is unknown or unimportant;
- real caveats, limits, corrections, named objections, or decision alternatives;
- headings, lists, or complex formatting that genuinely organize the material;
- watched phrases inside quotations, titles, proper names, code, or examples that discuss the phrase itself.

Preserve source-supported details that carry the writer's voice:

- specific or unusual details;
- mixed feelings, unresolved tension, and honest uncertainty;
- deliberate first-person wording;
- era-specific references, slang, or in-jokes that fit the audience;
- genuine asides, parentheticals, and self-corrections;
- uneven but readable sentence and paragraph rhythm.

Remove formulaic choices while retaining source-supported signs of the writer's voice.

## Audit Checklist

Use this checklist after drafting:

- Is there any negative framing, especially `not X, but Y` / `不是 X，而是 Y`?
- Are two or more high-risk words clustered in one paragraph?
- Does every paragraph add a new claim, evidence point, example, or transition?
- Are there triads that exist only for rhythm?
- Are there fake ranges that imply broad coverage without naming scope?
- Is the same thing renamed several times?
- Are simple `is/has/includes` verbs replaced with inflated verbs?
- Are headings title-cased or slogan-like without reason?
- Do sentence and paragraph lengths vary naturally?
- Does the text trust the reader, or does it explain every implication?
- Are there polished punchlines that should be deleted?
- Is the prose technically clean but too sterile for the genre?
- Did the revision preserve every name, number, date, quotation, citation, comparison, limitation, and technical term?
- Did any claim become stronger, weaker, more certain, or more causal?
- Did the rewrite add an example, mechanism, feature, opinion, or personal detail that the source did not provide?
- Are flagged phrases inside quotations, titles, proper names, code, or source examples?
- Does the result match a supplied writing sample without imitating its topic-specific facts?

## Rewriting Tactics

- Replace generic praise with a source-provided number, example, mechanism, or named constraint. If the source has none, simplify or flag the claim.
- Replace broad openings with the actual point.
- Cut meta-guidance like `let's explore`, `值得注意的是`, `下面我们来`.
- Convert negative framing and fake contrast into direct claims.
- Keep the plain term. Do not cycle synonyms for variety.
- Prefer verbs that describe work: `records`, `compares`, `blocks`, `retrieves`, `summarizes`; `记录`, `比较`, `阻止`, `检索`, `总结`.
- Delete slogan endings unless they contain a concrete claim.
- Replace hand-holding conclusions with source-supported evidence, action, or a specific tradeoff.
- If a local word swap leaves the sentence awkward, rebuild the paragraph around its main claim and then repeat the integrity check.

## Optional Quality Score

Use this only when the user asks whether a rewrite improved, when comparing variants, or when collecting evaluation data. It is an editorial rubric, not an authorship probability. Score each item from 1 to 10. Total: 50.

| Dimension | 10 means | 1 means |
| --- | --- | --- |
| Directness | States the claim without detours | Starts with setup, caveats, and fake contrast |
| Rhythm | Sentence and paragraph lengths vary naturally | Every line has the same length and cadence |
| Reader trust | Lets evidence do work | Explains every implication and metaphor |
| Voice match | Preserves the source or supplied sample's habits | Replaces the writer's voice with a generic persona |
| Concision | Little can be deleted | Filled with transitions, slogans, and padding |

Claim integrity is pass/fail and sits outside the score. Any unsupported addition or changed claim invalidates the rewrite regardless of its total.

Interpretation:

- `45-50`: clean enough for publication.
- `35-44`: usable, but still has visible style drag.
- `<35`: rewrite again from the concrete claim and evidence.

## Reusable Audit Prompts

English:

```text
Audit your text using the anti-ai-writing-style.md file from your folder. Match any supplied writing sample. Flag unnecessary negative framing, inflated vocabulary, formulaic rhythm, false ranges, term cycling, staged depth, shadowboxing, and abandoned drafting ideas. Rewrite only what needs fixing. Then compare the source and rewrite for names, numbers, dates, quotations, citations, scope, uncertainty, and technical meaning; treat any unsupported addition or changed claim as an error.
```

Chinese:

```text
请按 anti-ai-writing-style.md 自查一遍；如有作者样本，优先匹配其语气。重点检查无必要的“先否定再立论”、浮夸词、三联排比、假范围、同义词轮换、假装揭示本质、回应不存在的异议和残留的旧草稿思路。改写后逐项核对姓名、数字、日期、引文、引用、范围、不确定性和技术含义；任何无依据的新增或主张变化都视为错误。
```

## Sources

- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), maintained by WikiProject AI Cleanup.
- [blader/humanizer](https://github.com/blader/humanizer) v2.11.2 (MIT), consulted for voice calibration, claim-integrity safeguards, false-positive guidance, return modes, and recent pattern categories. The Chinese-specific rules in this reference remain locally maintained.

## Maintenance

Refresh this file every three months or after a noticeable style drift. Add new tells only if they appear repeatedly across real drafts. Remove or narrow rules that cause too many false positives in technical writing. Recheck adapted upstream guidance against its current license and behavior before importing later changes.
