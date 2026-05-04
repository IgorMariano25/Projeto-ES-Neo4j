# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project context

Academic project (IBMEC, Engenharia de Software — AP1) producing an SBC-format scientific article from a statistical analysis of source-code metrics extracted from the Neo4j framework via the GitHub Bug Dataset v1.1. The deliverable is the article in `artigo/main.tex`; the R script and figures exist to support its claims. Language for prose, comments, and console output is Portuguese (pt-BR).

## Commands

Run from the **repository root** (the R script uses relative paths `dataset/` and `figuras/`):

```bash
Rscript scripts/analise_final.R          # full analysis pipeline; regenerates all PNGs in figuras/
python3 scripts/exploracao_inicial.py    # preliminary inspection only (run from scripts/ — uses ../dataset paths)
```

Compile the article (must run all four passes for SBC bibliography to resolve):

```bash
cd artigo && pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex
```

R packages required: `ggplot2 dplyr tidyr corrplot PerformanceAnalytics gridExtra scales car nortest pROC caret PRROC`. The script auto-installs missing ones on first run.

There are no tests, linters, or CI — this is a one-shot analysis project.

## Architecture

Linear pipeline, no modules:

```
dataset/*.csv  →  scripts/analise_final.R  →  figuras/*.png  →  artigo/main.tex
```

`scripts/analise_final.R` (~1259 lines) is monolithic and ordered by analysis section (1. load → 2-4. descriptive stats → 5. plots → 6. outliers → 7. normality → 8. correlation → 9. VIF → 10. logistic regression → 11. CV/metrics). Section markers are `# === N. TITLE ===` headers. Edit it in place; do not split into files unless the user asks.

Two datasets at different granularities feed the pipeline:

| File | Rows | Cols | Notes |
|------|------|------|-------|
| `dataset/neo4j-Class.csv` | 7917 | 113 | Class-level CK + size + warnings metrics. Column `NA.` (with dot) is real — R coerces the original `NA` header. |
| `dataset/neo4j-File.csv` | 4261 | 12 | File-level metrics, narrower set. |

The class-level subset actually analyzed is selected in `cols_class` (around line 62): WMC, CBO, RFC, LCOM5, DIT, NOC, LOC, LLOC, NOS, NM, NL, NLE, CC, CD, CLOC, NA., WarningInfo, WarningMajor, Number.of.bugs.

## Key analytical caveats (load-bearing for the article)

- **Severe class imbalance**: only 8 buggy classes (0.10%) and 6 buggy files (0.14%). EPV ≈ 1, far below the rule-of-thumb 10. The article's headline conclusion is that the *dataset* is inadequate for defect prediction — not the metrics. Don't accidentally reframe results as a successful predictor.
- High accuracy (97–99%) is the trivial-majority baseline. Trust **MCC** and CV AUC over accuracy when discussing model quality.
- Logistic regression is **cost-sensitive** with 10-fold CV and Youden-index threshold selection; do not replace with vanilla `glm()` defaults without preserving these.
- Normality is rejected for 100% of variables (Shapiro-Wilk on seed=42 sample, plus Lilliefors). Spearman is the primary correlation; Pearson is reported for comparison.
- Multicollinearity is real (LOC × LLOC r = 0.99; max VIF = 20.18 for RFC pre-removal). The VIF reduction step in section 9 is required before regression.

## Figures

All 19 PNGs in `figuras/` are produced by `analise_final.R` at 150 dpi and referenced by name from `artigo/main.tex`. Renaming a figure file requires updating both the R `ggsave()` call and the LaTeX `\includegraphics`. Re-running the script overwrites them in place.

## Article

`artigo/main.tex` uses `sbc-template.sty` (do not modify the template) and `sbc-template.bib` (137 references). Target length 8–12 pages; current version is ~12. Sections: Abstract (EN) + Resumo (PT) + Introdução, Metodologia, Resultados/Discussão, Conclusão, Referências.
