# kairong-skills

Personal skill collection for aesthetic-heavy workflows in research and engineering.

这个仓库用来沉淀我自己会长期复用的 Codex skills，重点服务于这几类场景：

- Python 科研绘图与论文图表润色
- 科研汇报/PPT 视觉化表达
- 具有明确审美方向的网页前端设计
- LaTeX 论文表格排版与美化

这些任务都带有较强的主观审美判断，适合做成面向个人偏好的 skill，而不是直接照搬通用开源模板。

## Design Principles

- Aesthetic first: 输出不仅要能用，还要有明确风格和版式判断。
- Reproducible: 能脚本化的流程尽量脚本化，减少反复手写。
- Progressive disclosure: `SKILL.md` 保持精炼，把细节放到 `references/`、`scripts/`、`assets/`。
- Personal taste matters: 默认服务于我的科研与工程工作流，不追求“适合所有人”。

## Repository Layout

```text
kairong-skills/
├── README.md
├── .gitignore
├── scripts/
│   └── new_skill.sh
├── templates/
│   └── SKILL.template.md
└── skills/
    ├── python-research-plot/
    │   └── SKILL.md
    ├── research-ppt-figure/
    │   └── SKILL.md
    ├── web-frontend-aesthetic/
    │   └── SKILL.md
    └── latex-academic-table/
        └── SKILL.md
```

## Initial Skills

### `python-research-plot`

面向论文级、汇报级 Python 绘图。强调信息表达、风格统一、可发表质量与导出规范。

### `research-ppt-figure`

面向科研汇报中的图示、结构图、概念图和封面视觉。强调“讲清楚一个观点”，而不是堆砌元素。

### `web-frontend-aesthetic`

面向具有明显视觉方向的前端页面与交互原型。重点避免模板化和“AI 味”。

### `latex-academic-table`

面向论文表格、实验结果表、消融表。强调 `booktabs`、数字对齐、信息层级和版面紧凑度。

## Authoring Notes

- 每个 skill 必须包含 `SKILL.md`
- 可选目录只在需要时创建：`scripts/`、`references/`、`assets/`
- 尽量让 frontmatter 的 `description` 清楚说明 “何时触发”
- 把稳定流程写进 skill，把个人判断写成明确偏好，而不是模糊口号

## Create A New Skill

可以直接手工创建，也可以用脚手架：

```bash
./scripts/new_skill.sh skill-name "Describe when this skill should be used."
```

脚本会生成一个带 frontmatter 的 `SKILL.md` 初稿，后续再按具体领域补充流程与参考资料。

## Next Steps

- 为每个 skill 补充真实项目中的 `references/` 与 `assets/`
- 增加科研海报、论文配色、答辩动画、网页落地页等方向的 skills
- 逐步把高频操作沉淀成可执行脚本
