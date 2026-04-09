# Resume Tailoring Rubric

Use this rubric when the user has several candidate projects and only a subset should appear.

## Default page budget

- Prefer one page for research internship resumes.
- Keep a second page only when the user explicitly wants a longer academic CV or the evidence cannot fit without losing signal.
- Optimize the resume for a 30-second scan: strongest direction first, strongest project first, strongest evidence first.

## Project ranking dimensions

Score each project on:

1. Domain match
   Does it align with the employer's problem space, such as LLM systems, recommendation, infra, backend, CV, or research?

2. Stack overlap
   Does it use the same tools, frameworks, models, or engineering patterns named in the job description?

3. Depth of ownership
   Did the user design, implement, evaluate, optimize, or lead a substantial part of the work?

4. Evidence strength
   Does the project include metrics, benchmark results, latency reductions, accuracy gains, scale, users, or publication outcomes?

5. Recency and maturity
   Is the project recent, complete enough to discuss, and technically credible for interview follow-up?

## Selection heuristics

- Keep 2-4 projects by default.
- Let one flagship project carry more weight if it best matches the role.
- Keep more only when the role is broad and the extra projects add distinct evidence.
- Drop projects that are redundant, weakly described, or off-target for the role.
- If one project is clearly the flagship, let it occupy more space than the others.

## Direction narrowing

Before selecting projects, choose one dominant direction:
- `LLM`
- `multimodal`
- `inference optimization`
- `AI4Science`

Then prefer projects that reinforce that direction.
Do not mix unrelated projects just to look comprehensive.

## Bullet rewriting heuristics

Prefer bullets that show:
- what problem was solved
- what the user actually did
- what methods or systems were used
- what outcome or evidence supports it

Prefer this pattern:

`Action + technical method + scope + result`

Example:

`Built a retrieval and reranking pipeline for a domain QA assistant using dense retrieval, BM25, and cross-encoder reranking, improving top-5 recall on internal evals by 14%.`

## Results are mandatory

Each selected project should include some form of outcome whenever evidence exists:
- metric gain
- latency reduction
- throughput improvement
- memory reduction
- benchmark score
- accuracy, AUC, BLEU, recall, or other task metric

Do not stop at "did X"; push the bullet toward "did X and improved Y".

## Research contribution rules

For papers, research projects, or competitions:
- do not only name the topic or paper
- state the real contribution

Common high-signal contribution types:
- data cleaning
- experiment reproduction
- ablation design
- evaluation pipeline construction
- model training or post-training
- failure case analysis

## Technical specificity

Prefer explicit technical nouns over broad claims.

Weak:
- participated in large model training
- familiar with large models
- good coding ability

Stronger:
- implemented `LoRA` fine-tuning in `PyTorch`
- served models with `vLLM`
- trained with `FSDP` or `DeepSpeed`
- optimized attention kernels with `FlashAttention`
- built evaluation and inference pipelines in `Python`
- used `CUDA` or `C++` where relevant

## Bilingual handling

- Chinese version can be denser and slightly more compact.
- English version should sound recruiter-ready rather than literally translated.
- Keep facts identical even if sentence shape changes.

## Red flags

Avoid:
- vague bullets with no action
- inflated ownership
- repeating the same technology list everywhere
- turning every project into a full paragraph
- keyword lists with no corresponding project evidence
- broad AI positioning with no primary track
