# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

Academic statistical analysis project (AP1 — Engenharia de Software, IBMEC). Empirical analysis of Neo4j source code metrics from the GitHub Bug Dataset v1.1, producing a scientific article in SBC LaTeX format. Due: April 14, 2026. Authors: Igor Mariano Lopes Rodrigues, Filipe Oliveira de Saldanha da Gama.

## Running the Analysis

```bash
# Main R analysis (generates all figures in figuras/)
Rscript scripts/analise_final.R

# Preliminary exploration (informational only, not required)
python3 scripts/exploracao_inicial.py

# Compile the article (run from artigo/ directory)
cd artigo && pdflatex V2_Completo.tex && bibtex main && pdflatex V2_Completo.tex && pdflatex V2_Completo.tex
```

There is no build system, test suite, or linter — this is a data analysis and academic writing project.

## R Package Dependencies

All must be installed via `install.packages()`:
```r
ggplot2, dplyr, tidyr, corrplot, PerformanceAnalytics,
gridExtra, scales, car, nortest, pROC, caret, PRROC
```

## Architecture & Data Flow

```
dataset/neo4j-Class.csv  (7,917 instances × 113 metrics)
dataset/neo4j-File.csv   (4,261 instances × 12 metrics)
        ↓
scripts/analise_final.R  (main analysis engine, ~1,259 lines)
        ↓
figuras/                 (20 PNG files at 150 dpi)
        ↓
artigo/V2_Completo.tex   (SBC LaTeX article, imports figures)
        ↓
artigo/V2_Completo.pdf
```

The R script hardcodes relative paths `dir_dataset <- "dataset"` and `dir_figuras <- "figuras"`, so it must be run from the project root.

The analysis pipeline in `analise_final.R` follows this order:
1. Data loading and column selection (19 variables chosen from 113)
2. Descriptive statistics (mean, median, mode, std dev, amplitude, quartiles, percentiles)
3. Graphics generation (histograms, boxplots, scatter plots, heatmaps, ROC/PR curves, VIF barplot)
4. Outlier detection (IQR method)
5. Normality tests (Shapiro-Wilk with `set.seed(42)` sampling; Lilliefors via `nortest::lillie.test()`)
6. Correlation analysis (Pearson and Spearman; `PerformanceAnalytics::chart.Correlation()`)
7. Multicollinearity analysis (VIF via `car::vif()`)
8. Logistic regression with cost-sensitive class weights, LOOCV, and threshold optimization via Youden Index

## Critical Finding (affects all interpretation)

Extreme class imbalance: only ~8 positive instances in Class dataset (0.1%) and ~6 in File dataset (0.14%). This makes the EPV (Events Per Variable) ≈ 1, far below the recommended minimum of 10. The main contribution of this work is demonstrating **dataset inadequacy for fault prediction**, not successful prediction. High accuracy (~99.9%) is misleading — metrics like AUC-ROC, AUC-PR, F1, MCC, and balanced accuracy are the relevant evaluation measures.

## Known Issues (from PROMPT_REVISAO_COMPLETA.md)

- Figure paths in LaTeX use `Ap1/figuras/` — may need correction to match actual directory structure
- Numeric values in article text must be verified against R script output for consistency
- Bibliography: Tóth et al. author name formatting, R Core Team year, missing McFadden 1974 / Lilliefors 1967 / Hosmer & Lemeshow 2013
- LaTeX compilation: check for stray `a` after `\usepackage[utf8]{inputenc}`
- Abstract (resumo) target: ~150 words max

## Article Structure

`artigo/V2_Completo.tex` is the single main LaTeX file. Supporting files:
- `sbc-template.sty` — SBC style (do not modify)
- `sbc-template.bib` — bibliography database (137 entries)
- All figures referenced from `figuras/` directory

The article is in Portuguese (Brazilian) with `\usepackage[brazil]{babel}`.
