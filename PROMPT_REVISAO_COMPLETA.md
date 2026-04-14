# Prompt de Revisão Completa — Artigo Neo4j (Engenharia de Software AP1)

> **Instruções**: Cole este prompt inteiro em uma nova conversa com acesso a este repositório. Ele contém todas as análises e correções necessárias para aprimorar o artigo, os scripts, as figuras e as referências.

---

## Contexto do Projeto

Este repositório contém um artigo acadêmico em LaTeX (formato SBC) sobre análise estatística de métricas de código-fonte do framework Neo4j, usando o GitHub Bug Dataset v1.1. O artigo está em `artigo/V2_Completo.tex`, o script de análise principal em `scripts/analise_final.R`, a exploração inicial em `scripts/exploracao_inicial.py`, os dados em `dataset/`, as figuras em `figuras/`, e as referências em `artigo/sbc-template.bib`. Os requisitos do trabalho estão em `Requisitos.md`. Os PDFs contendo o materia utilizado pelo professor em sala de aula está na pasta `PDFsRefencia`

**Objetivo**: Realizar uma revisão crítica integrada e implementar todas as melhorias necessárias para elevar a qualidade do artigo, dos scripts e das figuras ao nível de um trabalho acadêmico rigoroso.

---

## TAREFA 1 — Correções Estatísticas no Script R (`scripts/analise_final.R`)

### 1.1 Teste de Kolmogorov-Smirnov com parâmetros estimados

O script atualmente usa:
```r
ks.test(x, "pnorm", mean(x), sd(x))
```
Isso viola a premissa do teste K-S, que exige parâmetros conhecidos *a priori* (não estimados da amostra). Com parâmetros estimados, os p-valores tornam-se **anticonservativos** (rejeitam demais). 

**Ação**: Substituir pelo teste de Lilliefors (`lillie.test()` do pacote `nortest`). Manter o K-S original comentado para referência. Atualizar o artigo LaTeX para mencionar o teste de Lilliefors em vez de K-S com parâmetros estimados.

### 1.2 Correlação de Pearson em dados não-normais

O script e o artigo usam correlação de Pearson exclusivamente, mas todos os testes de normalidade rejeitam a hipótese nula. Pearson assume linearidade e é sensível a outliers.

**Ação**: 
- Adicionar ao script R o cálculo de correlação de **Spearman** (rank-based, não-paramétrica) como análise complementar.
- Gerar uma segunda matriz de correlação com Spearman (heatmap e `chart.Correlation`).
- No artigo, reportar ambas as correlações (Pearson e Spearman), justificando que Spearman é mais adequada para dados não-normais, e discutir diferenças encontradas.

### 1.3 Threshold de 0.5 na regressão logística com desbalanceamento extremo

Com desbalanceamento de 99.9%/0.1%, o threshold de 0.5 faz o modelo classificar tudo como classe majoritária.

**Ação**:
- Adicionar ao script R: cálculo de **curva ROC** (pacote `pROC`), **AUC-ROC**, e determinação do **threshold ótimo** pelo Youden Index (`J = Sensitivity + Specificity - 1`).
- Calcular e reportar **precision, recall, F1-score** para ambas as classes.
- Adicionar cálculo de **AUC-PR** (Precision-Recall curve), que é mais informativa que AUC-ROC em dados desbalanceados.
- Gerar gráficos da curva ROC e da curva PR, salvá-los em `figuras/`.
- Atualizar o artigo com essas métricas e gráficos.

### 1.4 Pseudo-R² de McFadden — Interpretação

O valor 0.1194 é reportado sem contexto interpretativo.

**Ação**: No artigo, adicionar a seguinte contextualização: "Na escala de McFadden, valores entre 0.2 e 0.4 são considerados indicativos de ajuste excelente [referência: McFadden, 1974]. O valor obtido de 0.12 indica ajuste fraco, consistente com a incapacidade do modelo de discriminar classes com desbalanceamento extremo."

### 1.5 Validação do modelo (sem split treino/teste)

Atualmente o modelo é ajustado e avaliado no mesmo conjunto de dados — overfitting provável.

**Ação**:
- Adicionar ao script R: **k-fold cross-validation estratificado** (k=5 ou k=10) usando o pacote `caret` ou implementação manual.
- Alternativamente, dado o número extremamente pequeno de positivos (8 e 6), implementar **Leave-One-Out Cross-Validation (LOOCV)** que é mais adequado.
- Reportar métricas médias do CV no artigo.
- Adicionar nota explicativa no artigo sobre a importância da validação cruzada e por que foi implementada.

### 1.6 Análise de multicolinearidade com VIF

O artigo menciona multicolinearidade por inspeção visual das correlações, mas não usa método formal.

**Ação**:
- Adicionar ao script R: cálculo de **VIF (Variance Inflation Factor)** para os preditores da regressão logística usando `car::vif()`.
- Reportar os VIF no artigo. VIF > 10 indica multicolinearidade severa.
- Se LOC e LLOC têm VIF altíssimo (esperado dado r=0.99), remover uma delas do modelo e reajustar.

### 1.7 Shapiro-Wilk com amostragem

O `set.seed(42)` garante reprodutibilidade, mas o artigo não discute isso.

**Ação**: Adicionar no artigo uma nota breve: "Para o teste de Shapiro-Wilk, que admite no máximo 5.000 observações, utilizou-se uma amostra aleatória com semente fixa (seed=42) para garantir reprodutibilidade."

---

## TAREFA 2 — Melhorias em Ciência de Dados

### 2.1 Desbalanceamento de classes

Com apenas 8/7917 (0.10%) e 6/4261 (0.14%) positivos, este é o ponto mais crítico.

**Ação no script R**:
- Implementar **cost-sensitive learning**: ajustar pesos na regressão logística com `weights` proporcional ao inverso da frequência da classe.
- Opcionalmente, aplicar **SMOTE** (pacote `DMwR2` ou `smotefamily`) e comparar resultados.
- Adicionar discussão no artigo sobre por que técnicas como SMOTE com tão poucos positivos podem gerar overfitting e ruído.

**Ação no artigo**: Expandir a seção de limitações para discutir que, com apenas 8 instâncias positivas, qualquer modelo preditivo é fundamentalmente limitado. Citar que a literatura recomenda no mínimo ~10 eventos por variável preditora (regra EPV — Events Per Variable) para regressão logística estável. Com 8 eventos e 8 preditores, EPV=1, muito abaixo do mínimo recomendado de 10.

### 2.2 Feature engineering e colinearidade

LOC×LLOC com r=0.99 é redundância quase total.

**Ação**:
- No script R, após calcular VIF, remover variáveis com VIF > 10 iterativamente.
- Considerar adicionar uma análise breve de **PCA** para mostrar quantos componentes principais explicam a variância total. Isso reforça o argumento de redundância.
- No artigo, justificar a remoção de variáveis redundantes para o modelo final.

### 2.3 Métricas de avaliação

**Ação**: 
- No script R, calcular e reportar: **Sensitivity (Recall), Specificity, Precision, F1-score, Balanced Accuracy, AUC-ROC, AUC-PR, Matthews Correlation Coefficient (MCC)**.
- No artigo, substituir a ênfase na acurácia (99.90%) pela discussão dessas métricas mais informativas. Explicar por que acurácia é enganosa com desbalanceamento extremo (um classificador que sempre prediz "sem bug" teria a mesma acurácia).

---

## TAREFA 3 — Revisão do Artigo LaTeX (`artigo/V2_Completo.tex`)

### 3.1 Erro de compilação

Verificar se existe um `a` extra na linha `\usepackage[utf8]{inputenc}a`. Se existir, remover. Verificar se **não há** outros erros de compilação.

### 3.2 Caminhos de figuras

As figuras são referenciadas com prefixo `Ap1/figuras/` (e.g., `Ap1/figuras/boxplots_class.png`) e com barras duplas em alguns casos (`Ap1//figuras/`). Verificar se esses caminhos estão corretos em relação à estrutura real do repositório. As figuras estão em `figuras/` na raiz. Corrigir os caminhos se necessário.

### 3.3 Formatação SBC

Revisar conformidade com o template SBC:
- Verificar se as margens, fontes e espaçamentos seguem o padrão.
- Verificar se as citações estão no formato correto.
- O `\address{}` deve incluir o nome da instituição (parece faltar "IBMEC" ou nome completo).

### 3.4 Abstract e Resumo — Melhorias

Reescrever abstract e resumo para:
- Ser mais concisos (máximo ~150 palavras cada).
- Incluir a **principal contribuição** e **principal achado** de forma mais impactante.
- Mencionar explicitamente a limitação do desbalanceamento no próprio abstract.

### 3.5 Ameaças à validade — Estruturação

Atualmente as limitações são listadas superficialmente. Reestruturar em três categorias formais:

**Ação**: Criar uma subseção "Ameaças à Validade" no artigo com:

- **Validade interna**: 
  - Desbalanceamento extremo da variável alvo (possível subreporte de bugs no dataset)
  - Teste K-S com parâmetros estimados (corrigido para Lilliefors)
  - Correlação de Pearson aplicada em dados não-normais
  - Ausência de validação cruzada (corrigida com CV)
  - Multicolinearidade entre preditores

- **Validade externa**:
  - Resultados específicos ao Neo4j; generalização para outros frameworks requer replicação
  - Dataset de uma única versão; evolução temporal não capturada
  - GitHub Bug Dataset pode ter viés de seleção (apenas bugs linkados a commits)

- **Validade de construto**:
  - Métricas CK como proxies imperfeitos de qualidade de software
  - "Number of bugs" como proxy de propensão a defeitos depende da qualidade do rastreamento
  - DIT e NOC com variância quase zero no Neo4j tornam essas métricas irrelevantes para este estudo específico

### 3.6 Discussão sobre métricas CK

Adicionar ao artigo uma discussão mais crítica sobre:
- **Limitações de LCOM5**: Existem múltiplas definições de LCOM (LCOM1 a LCOM5); LCOM5 pode dar valores negativos ou zero para classes coesas, e seu significado prático é debatido na literatura.
- **DIT e NOC com variância quase zero**: No Neo4j, DIT tem amplitude=6 e σ=0.99, indicando hierarquias rasas. Discutir que isso torna DIT/NOC pouco discriminativas para fault prediction neste contexto, mas que isso é uma característica do projeto (design "flat"), não uma falha das métricas em si.

### 3.7 Consistência numérica

Verificar se TODOS os valores numéricos no artigo (tabelas, texto) correspondem exatamente aos gerados pelo script R. Especificamente:
- Tabela de tendência central (Tabela 2)
- Tabela de dispersão (Tabela 3)
- Tabela de outliers (Tabela 4)
- Tabela de normalidade (Tabela 5)
- Tabela de regressão logística (Tabelas 6 e 7)
- Valores de correlação citados no texto
- Valores de AIC, Pseudo R², acurácia

### 3.8 Referências bibliográficas

Revisar as citações no arquivo `artigo/sbc-template.bib`:

- **Basili (1996)**: Verificar se está sendo usado no contexto correto. Basili et al. validam métricas CK como indicadores de qualidade — o artigo cita na introdução, o que é correto.
- **Gyimothy (2005)**: Validação empírica de métricas OO para fault prediction em OSS — uso correto na introdução.
- **Radjenovic (2013)**: SLR sobre métricas de fault prediction — verificar se as citações no corpo do texto refletem corretamente as conclusões do SLR.
- **Tóth (2016)**: Nome do segundo autor parece estar com erro no .bib (`Pter` → deveria ser `Péter`). Corrigir.
- **R Core Team (2024)**: O campo `year` diz 2025 mas a citação é `rcoreteam2024`. Corrigir para consistência.
- Adicionar referência para **McFadden (1974)** se for citar a escala de interpretação do pseudo-R².
- Considerar adicionar referência para **Hosmer & Lemeshow** (regressão logística) e **Lilliefors** (se o teste for adotado).

---

## TAREFA 4 — Melhorias nas Figuras

### 4.1 Qualidade geral

Revisar todas as figuras em `figuras/` para:
- Resolução adequada (mínimo 150 dpi, preferencialmente 300 dpi para publicação).
- Labels legíveis (verificar se texto não está cortado).
- Consistência de cores entre os gráficos.
- Nomes de variáveis legíveis (substituir `Number.of.previous.modifications` por nomes mais curtos nos eixos).

### 4.2 Novas figuras a gerar

Adicionar ao script R e ao artigo:
1. **Curva ROC** para ambos os modelos (Class e File).
2. **Curva Precision-Recall** para ambos os modelos.
3. **Heatmap de correlação de Spearman** (complementar ao de Pearson).
4. **Gráfico de VIF** (barplot dos valores de VIF por variável).

### 4.3 Inclusão no artigo

Para cada nova figura, adicionar o `\begin{figure}...\end{figure}` correspondente no artigo com caption descritivo e referência no texto.

---

## TAREFA 5 — Melhorias na Seção de Conclusão

Reescrever a conclusão para:
- Ser mais assertiva sobre o que foi efetivamente demonstrado.
- Enfatizar que o principal achado é a **inadequação do dataset para predição de defeitos** (não a inadequação das métricas em si).
- Discutir mais concretamente os trabalhos futuros: mencionar que versões anteriores do Neo4j no dataset poderiam ser combinadas para aumentar o número de instâncias positivas.
- Mencionar a regra EPV como justificativa formal para a limitação da modelagem.

---

## TAREFA 6 — Checklist Final de Execução

Após implementar todas as mudanças acima, executar este checklist:

1. [ ] Rodar o script R atualizado (`scripts/analise_final.R`) e verificar que todas as figuras são geradas sem erro.
2. [ ] Verificar que os novos valores numéricos no artigo correspondem à saída do script.
3. [ ] Compilar o artigo LaTeX e verificar que não há erros de compilação.
4. [ ] Verificar que todas as figuras referenciadas no artigo existem nos caminhos corretos.
5. [ ] Verificar que todas as referências citadas no texto existem no .bib e vice-versa.
6. [ ] Verificar que o abstract/resumo não excede ~150 palavras cada.
7. [ ] Verificar formatação de tabelas (decimais consistentes, alinhamento).
8. [ ] Rodar git diff para revisar todas as mudanças antes de commit.

---

## Resumo de Pacotes R Necessários (adicionar ao script)

```r
# Novos pacotes necessários:
# nortest    — teste de Lilliefors
# pROC       — curva ROC e AUC
# caret      — cross-validation e métricas
# PRROC      — curva Precision-Recall
# smotefamily — SMOTE (opcional)
```

---

## Ordem de Execução Sugerida

1. **Script R** (Tarefa 1 + partes da Tarefa 2) — correções estatísticas e novas análises
2. **Figuras** (Tarefa 4) — gerar novas figuras e melhorar existentes
3. **Artigo LaTeX** (Tarefa 3) — correções de texto, tabelas, referências
4. **Conclusão e Abstract** (Tarefa 5 + 3.4) — reescrita
5. **Checklist** (Tarefa 6) — verificação final
