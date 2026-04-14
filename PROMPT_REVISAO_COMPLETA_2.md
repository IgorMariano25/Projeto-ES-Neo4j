# 🧠 PROMPT MESTRE — Revisão Completa do Artigo Científico
## Análise Estatística de Métricas de Código-Fonte (GitHub Bug Dataset)

> **Instrução de uso:** Forneça ao Claude todos os arquivos do repositório antes de executar este prompt — especialmente `analise_final.R`, `exploracao_inicial.py`, `V2_Completo.tex` e o dataset `.csv` utilizado. Este prompt deve ser executado de forma integral, cobrindo todas as seções obrigatórias do professor e todos os pontos de melhoria identificados.

---

## 🎯 CONTEXTO DO TRABALHO

Você é um revisor especialista em Engenharia de Software, Estatística, Ciência de Dados e escrita científica em LaTeX. Estou te fornecendo o repositório completo de um artigo científico desenvolvido como AP1 de Engenharia de Software, seguindo o template SBC (Sociedade Brasileira de Computação).

O trabalho analisa métricas de código-fonte (métricas CK de Chidamber & Kemerer) de um framework Java do **GitHub Bug Dataset (v1.1)**, aplicando estatística descritiva e inferencial para investigar a relação entre métricas OO e a presença de bugs.

**Arquivos do repositório que você deve analisar:**
- `analise_final.R` — script principal de análise estatística em R
- `exploracao_inicial.py` — script Python de pré-processamento e exclusão de variáveis
- `V2_Completo.tex` — artigo científico em LaTeX (template SBC)
- Dataset `.csv` — arquivo de dados do framework Java selecionado

---

## ✅ PARTE 1 — CHECKLIST DE REQUISITOS OBRIGATÓRIOS DO PROFESSOR

> Verifique se **cada item abaixo** está presente, correto e adequadamente documentado no artigo e nos scripts. Para cada item, indique: ✅ Completo | ⚠️ Incompleto | ❌ Ausente — e forneça sugestões de correção quando necessário.

### 1.1 Medidas de Tendência Central
- [ ] Média calculada para as principais variáveis numéricas (WMC, CBO, RFC, LCOM5, DIT, NOC, LOC, etc.)
- [ ] Mediana calculada para as mesmas variáveis
- [ ] Moda calculada quando aplicável
- [ ] Interpretação dos resultados no texto do artigo (não apenas tabelas)

### 1.2 Medidas de Dispersão
- [ ] Amplitude (range) calculada
- [ ] Variância calculada
- [ ] Desvio padrão calculado
- [ ] Interpretação da variabilidade das métricas no contexto de software

### 1.3 Medidas de Posição Relativa
- [ ] Quartis (Q1, Q2, Q3) calculados
- [ ] Percentis relevantes calculados
- [ ] Boxplots construídos para as principais métricas

### 1.4 Construção de Gráficos
- [ ] Histogramas para distribuição das métricas
- [ ] Boxplots com interpretação
- [ ] Gráficos de dispersão entre variáveis correlacionadas
- [ ] Gráficos de barras onde pertinente
- [ ] Cada gráfico acompanhado de interpretação no texto

### 1.5 Avaliação de Outliers
- [ ] Identificação de outliers via boxplot (regra do IQR)
- [ ] Interpretação técnica das causas dos outliers (classes muito grandes, acoplamento excessivo, etc.)

### 1.6 Testes de Normalidade
- [ ] Teste de Shapiro-Wilk aplicado
- [ ] Teste de Kolmogorov-Smirnov aplicado
- [ ] Interpretação clara dos p-valores e conclusões sobre normalidade

### 1.7 Coeficientes de Correlação
- [ ] Matriz de correlação calculada (preferencialmente com `chart.Correlation()` do pacote `PerformanceAnalytics`)
- [ ] Relações fortes (|r| > 0.7) identificadas e interpretadas
- [ ] Relações moderadas (0.4 < |r| < 0.7) discutidas
- [ ] Relações fracas contextualizadas

### 1.8 Modelagem Estatística
- [ ] Modelo estatístico ajustado (regressão logística ou linear)
- [ ] Coeficientes interpretados
- [ ] Desempenho do modelo avaliado
- [ ] Justificativa da escolha do tipo de modelo

### 1.9 Análise e Discussão dos Resultados
- [ ] Padrões encontrados discutidos
- [ ] Reflexão: métricas maiores estão associadas a mais defeitos?
- [ ] Reflexão: complexidade está relacionada ao número de bugs?
- [ ] Limitações da análise reconhecidas

### 1.10 Formato do Artigo
- [ ] Entre 8 e 12 páginas
- [ ] Template SBC respeitado
- [ ] Seções obrigatórias: Título, Autores, Resumo, Introdução, Metodologia, Resultados e Discussão, Conclusão, Referências
- [ ] Link do repositório GitHub citado no texto do artigo
- [ ] Código R completo no repositório
- [ ] Dataset no repositório
- [ ] Figuras geradas no repositório

---

## 🔬 PARTE 2 — REVISÃO ESTATÍSTICA E MATEMÁTICA (CRÍTICA PROFUNDA)

### 2.1 Problema Crítico: Teste K-S com Parâmetros Estimados

**Problema identificado:** O teste de Kolmogorov-Smirnov está sendo aplicado com `mean(x)` e `sd(x)` estimados da própria amostra como parâmetros da distribuição normal de referência.

**Por que isso é um erro grave:**
- O teste K-S padrão assume que os parâmetros da distribuição de referência são **conhecidos a priori**, não estimados dos dados
- Quando os parâmetros são estimados da amostra, a distribuição do estatístico de teste muda, tornando os p-valores **anticonservativos** (rejeitamos H₀ menos do que deveríamos)
- O p-valor reportado será inflado, levando a conclusões enganosas sobre normalidade

**Correção obrigatória:**
```r
# ❌ ERRADO — parâmetros estimados da amostra
ks.test(x, "pnorm", mean(x), sd(x))

# ✅ CORRETO — usar teste de Lilliefors (parâmetros estimados)
library(nortest)
lillie.test(x)
```

Corrija o script `analise_final.R` substituindo todas as chamadas de `ks.test(x, "pnorm", mean(x), sd(x))` por `lillie.test(x)` e atualize a discussão no artigo explicando a diferença metodológica.

### 2.2 Shapiro-Wilk com Amostragem

**Verificar no script:** A amostragem de 5.000 observações para o SW é metodologicamente aceitável (dado o limite de n ≤ 5000 da função `shapiro.test()` no R).

**O que o artigo deve explicar:**
- Justificar o tamanho da amostra (5.000) e o critério de seleção
- Mencionar que `set.seed(42)` garante reprodutibilidade
- Discutir se resultados são estáveis ao repetir com diferentes seeds (análise de sensibilidade)
- Adicionar a nota: "resultados do SW são válidos para a amostra analisada e podem diferir marginalmente em outras amostras aleatórias do mesmo dataset"

### 2.3 Correlação de Pearson em Dados Não-Normais

**Problema identificado:** O artigo aplica correlação de Pearson mesmo após demonstrar que nenhuma variável segue distribuição normal.

**Por que Pearson é inadequado aqui:**
- Pearson mede correlação **linear** e é sensível a outliers
- Para dados não-normais (especialmente com distribuições assimétricas como LOC, WMC), **Spearman** ou **Kendall** são mais robustos
- Spearman é baseado em ranks e não assume normalidade

**Correção recomendada:**
```r
# Substituir correlação de Pearson por Spearman
cor_matrix_spearman <- cor(dados_numericos, method = "spearman", use = "complete.obs")

# Para visualização, adaptar chart.Correlation com método Spearman
chart.Correlation(dados_numericos, method = "spearman", histogram = TRUE)
```

Atualize o artigo: mencione explicitamente que, dado o resultado dos testes de normalidade, optou-se pela correlação de Spearman (não-paramétrica), mais adequada para distribuições assimétricas típicas de métricas de software.

### 2.4 Pseudo-R² de McFadden — Interpretação Inadequada

**Problema:** O valor de McFadden R² = 0.1194 é reportado sem interpretação contextualizada.

**Contexto correto para o artigo:**
- R² de McFadden **não se interpreta como o R² de OLS** (não significa "11.94% da variância explicada")
- Escala de referência (Hosmer & Lemeshow):
  - 0.00 – 0.10: ajuste fraco
  - 0.10 – 0.20: ajuste razoável ← **o modelo está aqui**
  - 0.20 – 0.40: ajuste bom a excelente
  - > 0.40: pode indicar overfitting
- **Conclusão honesta:** o modelo com R² = 0.1194 tem **ajuste fraco a razoável** e poder preditivo limitado

Adicione ao artigo: "O pseudo-R² de McFadden de 0,1194 indica ajuste razoável, porém abaixo do limiar de 0,20 geralmente associado a modelos com boa capacidade preditiva (HOSMER; LEMESHOW, 2000). Este resultado, em conjunto com o severo desbalanceamento de classes, sugere cautela na interpretação do modelo como ferramenta preditiva."

### 2.5 Threshold de 0.5 na Regressão Logística — Crítico com Desbalanceamento

**Problema grave:** Com apenas ~0.1% de instâncias positivas (buggy), usar threshold = 0.5 faz com que o modelo **nunca prediga a classe positiva**, atingindo 99.9% de acurácia simplesmente ao prever "sem bug" para tudo.

**Correções no script R:**
```r
library(pROC)

# 1. Curva ROC
roc_curve <- roc(dados$bug, predict(modelo, type = "response"))
plot(roc_curve, main = "Curva ROC — Regressão Logística")
auc_valor <- auc(roc_curve)
cat("AUC-ROC:", auc_valor, "\n")

# 2. Threshold ótimo pelo Índice de Youden
youden_threshold <- coords(roc_curve, "best", ret = "threshold", best.method = "youden")
cat("Threshold ótimo (Youden):", youden_threshold, "\n")

# 3. Predições com threshold ótimo
pred_otimo <- ifelse(predict(modelo, type = "response") >= youden_threshold, 1, 0)

# 4. Matriz de confusão com métricas adequadas
library(caret)
confusionMatrix(factor(pred_otimo), factor(dados$bug), positive = "1")
```

Adicione ao artigo: tabela com precision, recall, F1-score e AUC-ROC. Explique que acurácia é uma métrica inadequada para datasets desbalanceados.

---

## 📊 PARTE 3 — REVISÃO DE CIÊNCIA DE DADOS

### 3.1 Desbalanceamento de Classes — O Problema Central

**Situação:** Apenas ~8 instâncias buggy em 7917 (nível de classe) e ~6 em 4261 (nível de arquivo). Isso representa aproximadamente **0.1% de positivos**.

**Implicações que o artigo DEVE discutir:**

1. **O modelo logístico com esses dados tem utilidade preditiva mínima** — qualquer classificador que sempre prediga "sem bug" terá 99.9% de acurácia

2. **Opções metodológicas (incluir ao menos como limitação ou trabalho futuro):**
   - **SMOTE** (Synthetic Minority Over-sampling): gera amostras sintéticas da classe minoritária
   - **Cost-sensitive learning**: penalizar mais erros na classe positiva
   - **Ajuste de threshold**: como discutido na seção 2.5
   - **Reconhecer limitação**: com tão poucos positivos, o dataset pode ser inadequado para modelagem preditiva supervisionada

```r
# Verificar desbalanceamento no script
table(dados$bug)
prop.table(table(dados$bug)) * 100
```

Adicione seção de "Ameaças à Validade" que mencione explicitamente: *"O severo desbalanceamento de classes (< 0,1% de instâncias com defeitos) representa uma ameaça à validade interna, limitando a capacidade do modelo logístico de identificar padrões preditivos confiáveis. Técnicas como SMOTE ou cost-sensitive learning poderiam ser exploradas em trabalhos futuros."*

### 3.2 Ausência de Validação do Modelo

**Problema:** O modelo é ajustado e avaliado no **mesmo conjunto de dados**, sem split treino/teste nem cross-validation. Isso gera overfitting e estimativas otimistas de desempenho.

**Correção mínima aceitável:**
```r
library(caret)
set.seed(42)

# k-fold cross-validation estratificada (k=5 ou k=10)
ctrl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  sampling = "smote"  # opcional, para desbalanceamento
)

modelo_cv <- train(
  bug ~ WMC + CBO + RFC + LCOM5,
  data = dados,
  method = "glm",
  family = "binomial",
  trControl = ctrl,
  metric = "ROC"
)
print(modelo_cv)
```

Se a cross-validation não for implementada por limitações do trabalho, mencione explicitamente como limitação metodológica.

### 3.3 Colinearidade Extrema — Feature Engineering

**Problema:** Variáveis como LOC e LLOC apresentam r = 0.99, indicando colinearidade quase perfeita.

**Verificação e tratamento:**
```r
# Calcular VIF (Variance Inflation Factor)
library(car)
vif(modelo_logistico)
# VIF > 10 indica multicolinearidade severa; VIF > 5 é preocupante

# Alternativa: remover variável redundante
# Se LOC e LLOC têm r=0.99, manter apenas LOC (mais interpretável)
```

Documente no artigo quais variáveis foram excluídas por colinearidade e **por que** (usando VIF como critério objetivo, não apenas inspeção visual).

### 3.4 Métricas de Avaliação — Substituir Acurácia

**O artigo deve reportar:**

| Métrica | Código R | Relevância com desbalanceamento |
|---------|----------|--------------------------------|
| AUC-ROC | `auc(roc_curve)` | Alta — independe do threshold |
| AUC-PR | `pr.curve()` (pacote PRROC) | Alta — foco na classe positiva |
| F1-Score | `confusionMatrix()$byClass["F1"]` | Alta — equilíbrio precision/recall |
| Precision | `confusionMatrix()$byClass["Precision"]` | Complementar |
| Recall | `confusionMatrix()$byClass["Recall"]` | Complementar |
| Acurácia | — | **Irrelevante** — não reportar como métrica principal |

---

## 🏗️ PARTE 4 — REVISÃO DE ENGENHARIA DE SOFTWARE

### 4.1 Validade das Métricas CK Escolhidas

**O artigo deve abordar criticamente:**

- **WMC (Weighted Methods per Class):** mérito alto — forte preditor de fault-proneness na literatura (Gyimothy 2005, Basili 1996)
- **CBO (Coupling Between Objects):** mérito alto — acoplamento é forte preditor de manutenibilidade e defeitos
- **RFC (Response for a Class):** mérito alto — relacionado à complexidade de teste
- **LCOM5:** **mérito questionável** — várias versões do LCOM existem, com definições inconsistentes na literatura. O artigo deve identificar qual versão está sendo usada e citar limitações conhecidas
- **DIT (Depth of Inheritance Tree):** **relevância limitada** — se a variância é quase zero no dataset (maioria das classes com DIT=1 ou 2), a métrica não discrimina entre classes buggy e não-buggy. Mencionar explicitamente.
- **NOC (Number of Children):** idem DIT — baixa variância implica baixo poder discriminatório

**Adicionar ao artigo:** "As métricas DIT e NOC apresentaram variância próxima de zero ([inserir valores], dp=[inserir]), indicando que o framework analisado faz uso limitado de herança profunda. Consequentemente, essas métricas possuem baixo poder discriminatório no contexto deste estudo, corroborando os achados de Radjenovic et al. (2013), que indicam WMC e CBO como os preditores mais consistentes de fault-proneness."

### 4.2 Justificativa de Exclusão de Variáveis

**Verificar no `exploracao_inicial.py`:** as exclusões estão documentadas no script, mas o **artigo** deve apresentar justificativa estatisticamente rigorosa:

```python
# Adicionar ao exploracao_inicial.py: cálculo de VIF
from statsmodels.stats.outliers_influence import variance_inflation_factor
import pandas as pd

X = dados[colunas_numericas].dropna()
vif_data = pd.DataFrame()
vif_data["feature"] = X.columns
vif_data["VIF"] = [variance_inflation_factor(X.values, i) for i in range(len(X.columns))]
print(vif_data.sort_values("VIF", ascending=False))
# Excluir variáveis com VIF > 10
```

Adicione uma tabela no artigo com os valores de VIF das variáveis excluídas e o critério de corte utilizado.

### 4.3 Ameaças à Validade — Estruturar Formalmente

Adicione (ou expanda) uma seção "Ameaças à Validade" com a seguinte estrutura:

**Ameaças à Validade Interna:**
- Desbalanceamento severo de classes (~0.1% buggy) compromete a capacidade preditiva do modelo
- Ausência de validação cruzada pode resultar em estimativas de desempenho otimistas
- Sub-reporte de bugs: o dataset é baseado em issue trackers do GitHub; defeitos não reportados formalmente não são capturados

**Ameaças à Validade Externa:**
- Os resultados foram obtidos para um único framework Java ([nome do framework]); a generalização para outros frameworks, linguagens ou paradigmas não é garantida
- O dataset refere-se a uma versão específica ([inserir versão]) — o comportamento pode diferir em versões anteriores ou posteriores

**Ameaças à Validade de Construto:**
- As métricas CK são proxies de características estruturais do código e não capturam aspectos semânticos, como lógica de negócio defeituosa
- A variável `bug` é binária (0/1), ignorando a severidade e quantidade de defeitos

### 4.4 Revisão das Referências Bibliográficas

Verifique se as seguintes citações estão sendo usadas corretamente no contexto:

- **Chidamber & Kemerer (1994):** usar ao introduzir as métricas CK — citar como origem da suite de métricas ✅
- **Basili et al. (1996):** usar ao justificar que métricas CK têm correlação com fault-proneness — verificar se o estudo citado usa o mesmo framework (smalltalk vs Java)
- **Gyimothy et al. (2005):** usar ao discutir evidências empíricas de WMC e CBO como preditores de bugs em Java — adequado ✅
- **Radjenovic et al. (2013):** usar na revisão sistemática de literatura — verificar se a citação está no contexto correto (meta-análise de fault prediction)

**Adicionar referências que podem estar faltando:**
- Hosmer & Lemeshow (2000) — para interpretação do pseudo-R² de McFadden
- Lilliefors (1967) — se o teste de Lilliefors for implementado
- Ferenc et al. (2020) — para referenciar o próprio GitHub Bug Dataset

---

## 📝 PARTE 5 — REVISÃO DO LaTeX (V2_Completo.tex)

### 5.1 Correções de Compilação

**Erro confirmado — corrigir imediatamente:**
```latex
% ❌ ERRADO (linha 4 do arquivo)
\usepackage[utf8]{inputenc}a

% ✅ CORRETO
\usepackage[utf8]{inputenc}
```

**Verificar também:**
- Todos os `\begin{...}` têm `\end{...}` correspondentes
- Todas as figuras referenciadas com `\includegraphics{...}` existem no repositório
- Todas as citações `\cite{...}` têm entrada correspondente no `.bib`
- Não há caracteres especiais (ã, ç, etc.) sem encoding correto

### 5.2 Conformidade com Template SBC

**Verificar:**
- [ ] Arquivo `.sty` da SBC está presente e correto (`sbc-template.sty`)
- [ ] Título em português E inglês
- [ ] Abstract em inglês (obrigatório pelo template SBC)
- [ ] Resumo em português
- [ ] Palavras-chave em ambos os idiomas
- [ ] Cabeçalho com nome(s) do(s) autor(es) conforme template
- [ ] Referências no formato SBC (ABNT adaptado) — verificar se `\bibliographystyle{sbc}` está presente
- [ ] Figuras com `\caption` abaixo da imagem (não acima)
- [ ] Tabelas com `\caption` acima da tabela
- [ ] Numeração de figuras e tabelas automática (não manual)

### 5.3 Abstract e Resumo — Melhorias

O abstract/resumo deve responder em ordem:
1. **Contexto:** qual framework foi analisado e por quê
2. **Objetivo:** o que foi investigado
3. **Método:** quais técnicas estatísticas foram aplicadas
4. **Resultado principal:** o que foi encontrado (com números)
5. **Conclusão:** qual é a implicação prática

**Template sugerido:**
```
Este trabalho apresenta uma análise estatística das métricas de código-fonte 
do framework Java [NOME], utilizando o GitHub Bug Dataset v1.1. 
Foram aplicadas técnicas de estatística descritiva, testes de normalidade 
(Shapiro-Wilk e Lilliefors), análise de correlação de Spearman e regressão 
logística para investigar a relação entre as métricas CK (WMC, CBO, RFC, 
LCOM5, DIT e NOC) e a ocorrência de defeitos. Os resultados indicam que 
[INSERIR RESULTADO PRINCIPAL COM NÚMERO]. O modelo logístico ajustado 
obteve AUC-ROC de [VALOR], com limitações associadas ao severo 
desbalanceamento de classes (≈0,1% de instâncias defeituosas). 
Os achados sugerem que [CONCLUSÃO PRÁTICA].
```

### 5.4 Consistência Numérica — Verificação Cruzada

Confirme que os seguintes valores no texto do artigo **correspondem exatamente** aos gerados pelo script R:

| Valor | Localização no artigo | Localização no script R |
|-------|----------------------|------------------------|
| n total de classes | Seção de Metodologia | `nrow(dados_class)` |
| n total de arquivos | Seção de Metodologia | `nrow(dados_file)` |
| % de classes buggy | Seção de Resultados | `prop.table(table(bug))` |
| Média de WMC | Tabela de estatísticas descritivas | `mean(WMC)` |
| p-valor Shapiro-Wilk (WMC) | Seção de Normalidade | `shapiro.test(amostra$WMC)$p.value` |
| McFadden R² | Seção de Modelagem | `1 - (modelo$deviance / modelo$null.deviance)` |
| AUC-ROC | Seção de Modelagem | `auc(roc_curve)` |

---

## 📋 PARTE 6 — ENTREGÁVEIS ESPERADOS DESTA REVISÃO

Após analisar todos os arquivos do repositório com base neste prompt, gere os seguintes entregáveis:

### 6.1 Relatório de Revisão
Um documento estruturado com:
- Status de cada item do checklist da Parte 1 (✅/⚠️/❌)
- Lista priorizada de correções críticas (P1) vs. melhorias recomendadas (P2)
- Inconsistências encontradas entre o script R e o texto do artigo

### 6.2 Script R Corrigido (`analise_final_v2.R`)
Versão atualizada do script com:
- Substituição de `ks.test` por `lillie.test` (nortest)
- Correlação de Spearman no lugar de Pearson
- Curva ROC, AUC e threshold ótimo por Youden Index
- VIF para diagnóstico de multicolinearidade
- Tabela de precision, recall e F1-score
- Comentários explicando cada correção

### 6.3 Trechos LaTeX para Inserir no Artigo
Blocos de código LaTeX prontos para:
- Seção de Ameaças à Validade
- Tabela de métricas de avaliação do modelo (F1, AUC-ROC, Precision, Recall)
- Parágrafo corrigido sobre teste de normalidade (Lilliefors)
- Parágrafo corrigido sobre correlação de Spearman
- Interpretação correta do McFadden R²
- Abstract melhorado

### 6.4 Checklist Final de Entrega
Uma lista de verificação final para garantir que todos os requisitos do professor estão atendidos antes da submissão em **14/04/2026**.

---

## ⚠️ PRIORIDADE DE CORREÇÕES

| Prioridade | Item | Impacto na Nota |
|-----------|------|-----------------|
| 🔴 P1 — Crítico | Erro de compilação LaTeX (`inputenc}a`) | Artigo não compila |
| 🔴 P1 — Crítico | Threshold 0.5 com desbalanceamento extremo | Modelagem estatística (1.5 pts) |
| 🔴 P1 — Crítico | Ausência de métricas adequadas (F1, AUC) | Modelagem estatística (1.5 pts) |
| 🟠 P2 — Importante | KS test → Lilliefors | Testes de normalidade (1.0 pt) |
| 🟠 P2 — Importante | Pearson → Spearman | Análise de correlação (1.5 pts) |
| 🟠 P2 — Importante | Interpretação do McFadden R² | Interpretação dos resultados (1.5 pts) |
| 🟡 P3 — Recomendado | VIF para multicolinearidade | Eng. de Software — rigor metodológico |
| 🟡 P3 — Recomendado | Seção de Ameaças à Validade | Interpretação dos resultados (1.5 pts) |
| 🟡 P3 — Recomendado | Conformidade SBC (figuras, tabelas, captions) | Organização do artigo (0.5 pts) |
| 🟢 P4 — Opcional | Curva ROC no artigo (figura) | Gráficos e visualizações (1.5 pts) |
| 🟢 P4 — Opcional | Cross-validation como limitação | Interpretação dos resultados (1.5 pts) |

---

*Prompt elaborado com base nos requisitos da AP1 de Engenharia de Software (Ibmec, 2026) e nas diretrizes metodológicas identificadas na análise crítica do repositório.*