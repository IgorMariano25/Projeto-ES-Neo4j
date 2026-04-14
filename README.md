# Análise Estatística de Métricas de Código-Fonte do Framework Neo4j

**Trabalho AP1 — Engenharia de Software | IBMEC**
Análise empírica quantitativa de métricas de código-fonte Java com produção de artigo científico no formato SBC.

---

## Autores

| Nome | Matrícula |
|------|-----------|
| Igor Mariano Lopes Rodrigues | 202407095992 |
| Filipe Oliveira de Saldanha da Gama | 202303161085 |

**Instituição:** IBMEC — Curso de Graduação em Engenharia de Software
**Disciplina:** Engenharia de Software — AP1
**Entrega:** 14 de abril de 2026

---

## O que é o Neo4j?

[Neo4j](https://neo4j.com/) é o sistema de banco de dados em grafo de código aberto mais utilizado no mundo. Diferente dos bancos relacionais tradicionais (SQL), o Neo4j armazena dados como **nós** (entidades) e **arestas** (relacionamentos), tornando-o ideal para modelar domínios altamente conectados — como redes sociais, sistemas de recomendação, detecção de fraudes e grafos de conhecimento.

Escrito predominantemente em **Java**, o Neo4j possui um ecossistema robusto de código aberto com centenas de milhares de linhas de código distribuídas em classes de complexidade variada, o que o torna um caso de estudo representativo para análise de métricas de software orientado a objetos.

---

## Sobre o Trabalho

Este projeto aplica **estatística descritiva e inferencial** sobre datasets de métricas de código-fonte do framework Neo4j, extraídos do [GitHub Bug Dataset v1.1](https://www.inf.u-szeged.hu/~ferenc/papers/GitHubBugDataSet/), com o objetivo de compreender padrões de qualidade, complexidade e propensão a defeitos.

### Datasets analisados

| Dataset | Instâncias | Atributos | Granularidade |
|---------|-----------|-----------|---------------|
| `neo4j-Class.csv` | 7.917 | 113 | Nível de classe |
| `neo4j-File.csv` | 4.261 | 12 | Nível de arquivo |

As métricas incluem as propostas por **Chidamber e Kemerer** (WMC, CBO, RFC, LCOM5, DIT, NOC), além de métricas de tamanho (LOC, LLOC, NOS, NM), cobertura de clones (CC), documentação (CD, CLOC), warnings de análise estática e histórico de modificações.

### Análises realizadas

1. **Medidas de tendência central** — média, mediana, moda
2. **Medidas de dispersão** — amplitude, variância, desvio padrão
3. **Medidas de posição relativa** — quartis (Q1, Q2, Q3), percentis (P90, P95), IQR
4. **Visualizações gráficas** — histogramas, boxplots, gráficos de dispersão, gráficos de densidade, heatmaps de correlação
5. **Avaliação de outliers** — método IQR
6. **Testes de normalidade** — Shapiro-Wilk (amostra seed=42) e Lilliefors
7. **Análise de correlação** — Pearson e Spearman via `PerformanceAnalytics::chart.Correlation()`
8. **Análise de multicolinearidade** — VIF (*Variance Inflation Factor*)
9. **Modelagem estatística** — Regressão logística binária *cost-sensitive* com 10-fold cross-validation e Youden Index

### Principal achado

O dataset possui **desbalanceamento extremo**: apenas **8 classes (0,10%)** e **6 arquivos (0,14%)** apresentam bugs registrados. Com EPV ≈ 1 (muito abaixo do mínimo recomendado de 10), nenhum modelo de predição é confiável neste contexto — a "acurácia" de 97–99% é enganosa, e o MCC próximo de zero na validação cruzada confirma poder preditivo nulo. O achado principal é a **inadequação do dataset para predição de defeitos**, não a inadequação das métricas em si.

---

## Estrutura do Projeto

```
Projeto-ES-Neo4j/
├── artigo/
│   ├── main.tex                  # Artigo científico final (LaTeX, formato SBC)
│   ├── sbc-template.bib          # Base bibliográfica (137 referências)
│   └── sbc-template.sty          # Template oficial SBC (não modificar)
│
├── dataset/
│   ├── neo4j-Class.csv           # Dataset class-level  (7.917 × 113)
│   ├── neo4j-Class.csv.arff      # Mesmo dataset em formato ARFF (Weka)
│   ├── neo4j-File.csv            # Dataset file-level   (4.261 × 12)
│   └── neo4j-File.csv.arff       # Mesmo dataset em formato ARFF
│
├── figuras/                      # Gráficos gerados pelo script R (PNG, 150 dpi)
│   ├── boxplots_class.png
│   ├── boxplots_file.png
│   ├── histogramas_class.png
│   ├── histogramas_file.png
│   ├── densidade_metricas_class.png
│   ├── dispersao_loc_wmc.png
│   ├── dispersao_cbo_rfc.png
│   ├── dispersao_lloc_mccc_file.png
│   ├── barras_distribuicao_bugs.png
│   ├── boxplot_comparativo_bugs.png
│   ├── correlacao_heatmap_class.png
│   ├── correlacao_heatmap_file.png
│   ├── correlacao_spearman_class.png
│   ├── correlacao_spearman_file.png
│   ├── chart_correlation_class.png
│   ├── chart_correlation_file.png
│   ├── vif_barplot.png
│   ├── curva_roc.png
│   └── curva_pr.png
│
├── scripts/
│   ├── analise_final.R           # Script principal de análise (~1.259 linhas)
│
├── PDFsRefencia/                 # Apostilas de R utilizadas como referência
│   ├── apostila-r-cap-1.pdf
│   ├── apostila-r-cap-2.pdf
│   ├── apostila-r-cap-3.pdf
│   ├── apostila-r-cap-4.pdf
│   └── apostila-r-cap-5.pdf
│
├── README.md
├── Requisitos.md                 # Enunciado oficial do trabalho
```

---

## Como executar

### Pré-requisitos

- **R** (≥ 4.0) com os pacotes:

```r
install.packages(c(
  "ggplot2", "dplyr", "tidyr", "corrplot",
  "PerformanceAnalytics", "gridExtra", "scales",
  "car", "nortest", "pROC", "caret", "PRROC"
))
```

### Executar a análise completa

O script deve ser executado a partir da **raiz do projeto** (os caminhos são relativos):

```
Rscript scripts/analise_final.R
```

Todos os gráficos serão gerados automaticamente na pasta `figuras/`.

### Compilar o artigo LaTeX

```bash
cd artigo
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

## Fluxo de dados

```
dataset/neo4j-Class.csv  (7.917 instâncias × 113 métricas)
dataset/neo4j-File.csv   (4.261 instâncias × 12 métricas)
         │
         ▼
scripts/analise_final.R  (pipeline de análise estatística)
         │
         ▼
figuras/                 (20 gráficos PNG em 150 dpi)
         │
         ▼
artigo/main.tex          (artigo SBC, ~12 páginas)
```

## Tecnologias utilizadas

| Ferramenta | Uso |
|------------|-----|
| **R / RStudio** | Análise estatística e geração de gráficos |
| **ggplot2** | Histogramas, boxplots, heatmaps, dispersão |
| **PerformanceAnalytics** | `chart.Correlation()` — painel integrado de correlações |
| **car** | Cálculo do VIF para análise de multicolinearidade |
| **nortest** | Teste de Lilliefors |
| **pROC / PRROC** | Curvas ROC e Precision-Recall |
| **caret** | Validação cruzada estratificada (10-fold) |
| **LaTeX / Overleaf** | Redação do artigo científico (template SBC) |
| **GitHub** | Controle de versão e entrega do repositório |


## Resultados em destaque

| Métrica | Class-level | File-level |
|---------|-------------|------------|
| Instâncias com bug | 8 (0,10%) | 6 (0,14%) |
| Correlação LOC × LLOC | r = 0,99 | — |
| VIF máximo antes da remoção | RFC = 20,18 | — |
| AUC-ROC (treino / CV) | 0,674 / 0,660 | 0,968 / 0,805 |
| MCC na validação cruzada | 0,023 | 0,068 |
| Normalidade (Shapiro-Wilk) | Rejeitada em 100% das variáveis | Rejeitada em 100% das variáveis |


## Artigo

O artigo científico está em `artigo/main.tex` e segue o **template oficial da SBC (Sociedade Brasileira de Computação)**, com 8–12 páginas, escrito em português (pt-BR), contendo:

- Abstract (inglês) e Resumo (português)
- Introdução com contextualização e referências à literatura
- Metodologia (fonte de dados e seleção de variáveis)
- Resultados e Discussão (todas as análises e gráficos)
- Conclusão e trabalhos futuros
- Referências bibliográficas


*Repositório disponível em: https://github.com/IgorMariano25/Projeto-ES-Neo4j*