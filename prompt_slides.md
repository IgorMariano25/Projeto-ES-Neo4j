# Prompt para gerar os slides no Claude.ai

> **Como usar:** copie todo o conteúdo **abaixo da linha `=== INÍCIO DO PROMPT ===`**
> e cole no Claude.ai. O prompt é **autossuficiente** — todos os dados reais do
> artigo e do projeto já estão embutidos (tabelas, números, figuras, conclusões),
> então o Claude consegue montar a apresentação sem acessar o repositório.
> Ao final, ele entrega os slides como **artefato HTML navegável** + **notas do
> apresentador**.
>
> **Fontes da verdade usadas para montar este prompt** (não altere os números sem
> conferir nelas):
> - Artigo SBC: `artigo/main.tex`
> - Artigo IEEE (versão mais recente, com glossário): `IEEE_artigo/IEEE-conference-template-062824/artigo_neo4j_ieee_claude.tex`
> - Script de análise (R): `scripts/analise_final.R` → gera todas as figuras em `figuras/`
> - Dashboard Shiny: `api_r/api.R` (+ `api_r/apiR.md`)
> - `README.md` e `CLAUDE.md`
>
> **Aviso importante (leia antes de usar):** neste projeto, **Neo4j é o objeto de
> estudo** (o software Java cujo código-fonte foi medido), **não uma ferramenta
> usada**. **Não existe banco de dados em grafo, modelagem em grafo, nós,
> relacionamentos nem consultas Cypher neste trabalho.** A análise é 100%
> estatística, feita em **R**. Qualquer slide que fale em "modelar dados no Neo4j"
> ou "Cypher" estaria *inventando* e contradiz o artigo. O prompt abaixo já
> impede isso explicitamente.

---

=== INÍCIO DO PROMPT ===

Você é um **designer de apresentações acadêmicas** especializado em comunicar
trabalhos empíricos de Engenharia de Software para uma banca. Crie uma
**apresentação de slides** sobre o meu trabalho, **fiel ao artigo** cujos dados
estão integralmente embutidos abaixo.

## Regras inegociáveis (leia primeiro)

1. **Não invente nada.** Use **apenas** os números, tabelas, figuras e conclusões
   fornecidos neste prompt. Se um dado não estiver aqui, **não o crie** — trate a
   ausência como limitação ou ponto a confirmar, nunca preencha com suposição.
2. **Neo4j é o OBJETO de estudo, não uma ferramenta.** O trabalho **analisa
   estatisticamente** métricas do código-fonte do framework Neo4j. **NÃO há** banco
   de dados em grafo, modelagem em grafo, nós, arestas, propriedades ou consultas
   **Cypher**. Toda a análise foi feita em **R**. **Nunca** mencione Cypher ou
   modelagem em grafo — isso seria falso.
3. **A mensagem central do trabalho é contraintuitiva e deve ser respeitada:** as
   métricas revelam uma estrutura de código rica (tamanho, complexidade,
   assimetria, multicolinearidade), **mas o dataset é inadequado para predição
   confiável de defeitos** por causa do desbalanceamento extremo da variável-alvo.
   **Não** reposicione o resultado como "um classificador bem-sucedido". O herói da
   história é o diagnóstico honesto, não um modelo preditivo.
4. **Priorize dados concretos.** Sempre que houver número, tabela, percentual ou
   figura, ele deve aparecer no slide (em tabela enxuta, gráfico ou destaque
   numérico), não ser descrito vagamente em texto.

## Contexto da apresentação

- **Trabalho:** "Análise Estatística de Métricas de Código-Fonte do Framework
  Neo4j" — IBMEC, Engenharia de Software, **AP1**.
- **Autores:** Igor Mariano Lopes Rodrigues
- **Público:** coordenador e professores de Engenharia de Software — público
  técnico, mas nem todos especialistas em estatística. Explique termos ao
  introduzi-los.
- **Objetivo:** contar, do problema à conclusão, **o que foi analisado, como, e o
  que se descobriu**, com ênfase em (a) estatística descritiva, (b) normalidade e
  correlação, (c) multicolinearidade, e (d) por que a predição de defeitos falha
  neste dataset.
- **Tom:** acadêmico, didático e visual. Pouco texto por slide (tópicos curtos,
  não parágrafos); o detalhe fica na minha fala.
- **Idioma:** Português do Brasil.
- **Duração:** 10 minutos (≈ 12 a 16 slides).
- **Narrativa (importante):** os slides devem formar **uma história contínua**, não
  uma lista solta de tópicos. Plante o conflito cedo — "milhares de classes, mas só
  8 com bug" — e faça esse fio reaparecer no clímax (modelagem que não converge) e
  no desfecho (o limite está nos dados, não nas métricas).

## Formato de saída

1. Entregue a apresentação como **artefato em HTML** (slides navegáveis por
   teclado/clique, **um conceito por slide**, visual limpo e moderno).
2. **Design:** paleta sóbria (azuis + cinzas + um tom de destaque, p.ex. vermelho
   só para alertar sobre o desbalanceamento). Tipografia legível; **corpo de texto
   com no mínimo 24px**, títulos bem maiores. Margens generosas, no máximo ~6
   bullets curtos por slide. Use ícones, caixas, divisórias e **tabelas resumidas**
   em vez de blocos de texto.
3. Para **cada slide**, gere **notas do apresentador** (campo separado, fora do
   slide visível) com um **roteiro de fala de 3 a 5 frases** em 1ª pessoa.
4. **Figuras:** o repositório tem PNGs reais em `figuras/` (lista no fim deste
   prompt). Como você não tem acesso a esses arquivos, para cada visual escolha
   uma das duas opções, **sem nunca inventar dados**:
   - **(a) Reconstruir o gráfico** a partir dos números reais embutidos aqui
     (ex.: barras das tabelas descritivas, barra do desbalanceamento, barras das
     correlações fortes, barras do VIF, tabela de métricas). Isso é preferível
     quando os números estão neste prompt.
   - **(b) Inserir um *placeholder* rotulado** (uma caixa com moldura) com o **nome
     exato do arquivo** (ex.: `figuras/curva_roc.png`) e uma legenda, para eu
     encaixar a imagem real depois. Use isto para gráficos cujos dados ponto-a-ponto
     **não** estão no prompt (dispersões com milhares de pontos, heatmaps,
     densidades, curvas ROC/PR).
   - Nunca gere um gráfico "decorativo" com dados fictícios.
5. Use diagramas/caixas/ASCII para o **fluxo do pipeline de análise** (em R) e para
   o **esquema de validação cruzada** (10-fold estratificada).

---

## DADOS REAIS DO PROJETO (única fonte permitida — não extrapole)

### Identificação
- **Título:** Análise Estatística de Métricas de Código-Fonte do Framework Neo4j
- **Instituição/disciplina:** IBMEC — Engenharia de Software — AP1
- **Dataset:** GitHub Bug Dataset v1.1 (Tóth, Gyimési e Ferenc, 2016); métricas
  extraídas pela ferramenta de análise estática **SourceMeter**.
- **Repositório:** https://github.com/IgorMariano25/Projeto-ES-Neo4j
- **Dashboard interativo (Shiny):** https://igormariano.shinyapps.io/Projeto-ES-Neo4j/
- **Linguagem do sistema analisado:** Java.
- **Ferramenta de análise estatística do trabalho:** **R** (não Python/Neo4j).

### Objeto de estudo: Neo4j
- Neo4j é um sistema de **banco de dados em grafo de código aberto**, escrito
  predominantemente em **Java**. *(Aqui ele entra apenas como o software cujo
  código foi medido — não usamos o Neo4j para nada na análise.)*
- Por que foi escolhido: (i) é um projeto real e amplamente usado (não um exemplo
  artificial); (ii) código Java orientado a objetos, que permite aplicar métricas
  CK; (iii) já está presente no GitHub Bug Dataset v1.1, com métricas e histórico
  de bugs extraídos.

### Problema de pesquisa
> **As métricas de código-fonte do Neo4j, no GitHub Bug Dataset v1.1, permitem uma
> análise estatística robusta E uma predição confiável de defeitos?**

Resposta dupla encontrada:
1. **Sim** para análise estatística (tamanho, complexidade, assimetria, outliers,
   correlação, multicolinearidade).
2. **Não** para predição confiável de defeitos neste dataset — há pouquíssimos
   exemplos positivos de bug.

### Objetivos
- **Geral:** caracterizar estatisticamente as métricas de código do Neo4j e avaliar
  se sustentam um modelo de predição de defeitos.
- **Específicos:** (i) descrever tendência central, dispersão e posição; (ii)
  detectar outliers (IQR); (iii) testar normalidade (Shapiro-Wilk e Lilliefors);
  (iv) medir correlação (Pearson e Spearman); (v) diagnosticar multicolinearidade
  (VIF); (vi) ajustar regressão logística *cost-sensitive*; (vii) validar com
  10-fold CV e interpretar criticamente as métricas de avaliação.

### Base de dados (duas granularidades; nenhum valor ausente)
| Dataset | Instâncias | Atributos originais | Variáveis após seleção |
|---|---:|---:|---:|
| Class-level (`neo4j-Class.csv`) | 7.917 | 113 | 19 numéricas |
| File-level (`neo4j-File.csv`) | 4.261 | 12 | 7 |

- **Variável-alvo:** *Number of bugs*, binarizada (0 = sem bug; 1 = ≥1 bug).
- **Desbalanceamento (o coração do trabalho):**
  - Class-level: **8 classes com bug = 0,10%**
  - File-level: **6 arquivos com bug = 0,14%**
  - **EPV (Events Per Variable) ≈ 1**, muito abaixo do mínimo recomendado de **10**.

### Seleção de variáveis (3 critérios objetivos)
1. **Natureza métrica:** removidos identificadores/metadados posicionais (ID, Name,
   LongName, Parent, Component, Path, Line, Column, EndLine, EndColumn).
2. **Variabilidade não-nula:** removidas constantes; no File-level isso eliminou
   **CLOC** (todas as 4.261 instâncias = 0).
3. **Não-redundância:** no Class-level, removidos totais com prefixo `T` (r > 0,99
   vs. contrapartes), variantes locais (`NL`), proxies de acoplamento (CBOI, NII,
   NOI) e as 37 regras PMD granulares (colapsadas em `WarningInfo` e `WarningMajor`).

**19 variáveis Class-level:** Complexidade — WMC, NL, NLE · Acoplamento — CBO, RFC ·
Coesão — LCOM5 · Herança — DIT, NOC · Tamanho — LOC, LLOC, NOS, NM, NA · Clones — CC
· Documentação — CD, CLOC · Qualidade — WarningInfo, WarningMajor · Alvo — Number of
bugs.
**7 variáveis File-level:** McCC, LLOC, N. previous modifications, N. previous fixes,
N. committers, N. developer commits, Number of bugs.

### Metodologia — pipeline linear em R (`analise_final.R`)
```
CSV (Class + File)
  → limpeza e seleção de variáveis
  → estatística descritiva (tendência central, dispersão, posição)
  → visualizações (histogramas, boxplots, dispersão, densidade, heatmaps)
  → detecção de outliers (método IQR)
  → testes de normalidade (Shapiro-Wilk + Lilliefors)
  → correlação (Pearson + Spearman)
  → multicolinearidade (VIF)
  → regressão logística cost-sensitive
  → validação cruzada estratificada 10-fold + limiar por Youden Index
  → interpretação crítica
```

### Resultado 1 — Tendência central (Class-level): média > mediana > moda (assimetria positiva)
| Variável | Média | Mediana | Moda |
|---|---:|---:|---:|
| WMC | 7,39 | 3,00 | 1 |
| CBO | 5,64 | 3,00 | 2 |
| RFC | 9,84 | 5,00 | 1 |
| LCOM5 | 1,58 | 1,00 | 1 |
| LOC | 59,70 | 25,00 | 7 |
| LLOC | 49,18 | 21,00 | 8 |
| NOS | 18,77 | 5,00 | 1 |
| NM | 8,61 | 4,00 | 1 |
| DIT | 0,98 | 1,00 | 1 |
| CC | 0,12 | 0,00 | 0 |

File-level: McCC média 6,06 / mediana 2,00 (moda 1); LLOC média 102,74 / mediana 55,00.

### Resultado 2 — Dispersão (Class-level)
| Variável | Amplitude | Variância | Desvio-padrão |
|---|---:|---:|---:|
| WMC | 325 | 193,25 | 13,90 |
| CBO | 161 | 55,57 | 7,45 |
| RFC | 293 | 256,19 | 16,01 |
| LCOM5 | 71 | 12,33 | 3,51 |
| LOC | 3.207 | 13.360,81 | 115,59 |
| LLOC | 2.588 | 8.473,03 | 92,05 |
| NOS | 1.411 | 2.218,10 | 47,10 |
| NM | 161 | 183,94 | 13,56 |
| DIT | 6 | 0,99 | 0,99 |
| CC | 1 | 0,08 | 0,29 |

- **LOC tem coeficiente de variação = 1,94** (o maior), desvio-padrão quase o dobro
  da média → tamanho altamente heterogêneo.
- **DIT** tem variância ≈ 0,99 → pouco discriminante (herança rasa no Neo4j).
- File-level: *Number of developer commits* tem variância 4.106.050,59 (desvio 2.026,34).

### Resultado 3 — Posição relativa (quartis)
- WMC: Q1=1, Q2=3, Q3=8, IQR=7, P95=27, máx=325 (75% das classes têm WMC ≤ 8).
- LOC: Q1=7, Q2=25, Q3=60, IQR=53, máx=3.207.
- File-level: McCC Q1=1, Q3=6, P90=18; LLOC Q1=20, Q3=112.

### Resultado 4 — Outliers (método IQR, Class-level); não removidos (classes legitimamente complexas)
| Variável | Outliers | % do total | Limite superior |
|---|---:|---:|---:|
| WMC | 706 | 8,92% | 18,50 |
| CBO | 644 | 8,13% | 14,50 |
| RFC | 759 | 9,59% | 24,50 |
| LOC | 799 | 10,09% | 140,00 |
| LLOC | 787 | 9,94% | 112,50 |
| NOS | 840 | 10,61% | 42,00 |
| NM | 866 | 10,94% | 19,50 |
| CC | 1.780 | 22,48% | 0,00 |

- Faixa de outliers: **5,86% (NA) a 22,48% (CC)**. CC explode porque a maioria é 0 e
  qualquer valor positivo já vira outlier. ~10% nas métricas de tamanho — consistente
  com a regra de Pareto (poucos componentes concentram a complexidade).

### Resultado 5 — Normalidade: rejeitada para 100% das variáveis (p < 10⁻⁵⁰)
| Variável | Shapiro-Wilk W | Lilliefors D |
|---|---:|---:|
| WMC | 0,4214 | 0,3081 |
| CBO | 0,5874 | 0,2246 |
| RFC | 0,5158 | 0,2786 |
| LOC | 0,4244 | 0,3113 |
| DIT | 0,8267 | 0,2520 |
| CC | 0,4754 | 0,4410 |

- W variou de **0,013 (Number of bugs) a 0,827 (DIT)** — sempre longe de 1.
- Shapiro-Wilk em amostra de 5.000 obs. (limite do R), `seed=42`; Lilliefors sobre
  toda a base. **Por que Lilliefors e não K-S clássico:** o K-S fica conservador
  demais quando μ e σ são estimados da própria amostra; Lilliefors recalcula os
  valores críticos e corrige isso. A convergência dos dois sela o diagnóstico.

### Resultado 6 — Correlação (Class-level)
- **Fortes (|r| ≥ 0,7, Pearson):** LOC×LLOC = **0,99**; LOC×NOS = 0,95; WMC×LOC =
  0,89; WMC×RFC = 0,82; CBO×RFC = 0,80.
- **Moderadas:** WMC×CBO = 0,51; WMC×NM = 0,53; CBO×LOC = 0,59.
- **Spearman** segue o mesmo padrão, magnitudes geralmente maiores (LOC×LLOC ρ=0,99;
  NOS×NL ρ=0,72).
- File-level: McCC×LLOC = 0,72; N. prev. modifications × N. committers = 0,77
  (Spearman ρ=0,90).
- **Correlação máxima entre QUALQUER métrica e bug = r = 0,06** (praticamente nula).

### Resultado 7 — Multicolinearidade (VIF; >10 = severa)
| Variável | VIF antes | VIF após remover RFC |
|---|---:|---:|
| RFC | 20,18 | (removida) |
| WMC | 15,17 | 8,75 |
| LOC | 10,98 | 9,16 |
| Demais | — | ≤ 5 |

- RFC removida por redundância com WMC (r=0,82) e CBO (r=0,80). File-level: todos os
  VIF ≤ 5,58 (sem multicolinearidade severa).

### Resultado 8 — Regressão logística *cost-sensitive*
- Pesos inversos à frequência: w₊ = N/(2·N₊); w₋ = N/(2·N₋) — evita classificar tudo
  como "sem bug".
- **Class-level** (preditores pós-VIF: WMC, CBO, LOC, LCOM5, NL, DIT, CC):
  **NÃO convergiu** — coeficientes em ordem 10¹²–10¹⁵ (sinal de **separação
  completa**, sintoma de EPV≈1). Pseudo R² de McFadden = **−10,76** (pior que o
  modelo nulo).
- **File-level** (McCC, LLOC, N. prev. modifications, N. prev. fixes, N. committers,
  N. developer commits): Pseudo R² McFadden = **0,59** (alto na escala), mas também
  **não convergiu**; só LLOC não foi significativo (p=0,30). Interpretar com cautela
  (apenas 6 arquivos com bug).

### Resultado 9 — Validação cruzada (10-fold estratificada) e métricas
| Métrica | Class (treino) | File (treino) | Class (10-fold CV) | File (10-fold CV) |
|---|---:|---:|---:|---:|
| AUC-ROC | 0,674 | 0,968 | 0,660 | 0,805 |
| AUC-PR | 0,007 | 0,020 | — | — |
| Sensibilidade | 0,375 | 1,000 | 0,625 | 0,833 |
| Precisão | 0,014 | 0,024 | 0,002 | 0,007 |
| F1-score | 0,027 | 0,047 | 0,004 | 0,014 |
| Bal. Acc. | 0,674 | 0,972 | 0,664 | 0,836 |
| **MCC** | 0,069 | 0,151 | **0,023** | **0,068** |

- Limiar definido pelo **Youden Index** (J = Sensibilidade + Especificidade − 1).
- A degradação treino→CV confirma **overfitting** (File: AUC 0,97 → 0,81).
- **MCC ≈ 0 na CV → poder preditivo praticamente nulo.**
- **Por que a acurácia (97–99%) engana:** com 0,10–0,14% de positivos, prever sempre
  "sem bug" já acerta ~99%. AUC-PR ≈ 0,007/0,020 confirma a inadequação (a base
  aleatória teria AUC-PR ≈ prevalência ≈ 0,001).

### Principais achados (discussão)
1. **Métricas de software são assimétricas à direita** (muitas classes simples,
   poucas muito complexas) — incompatíveis com normalidade.
2. **Tamanho e complexidade se sobrepõem** (LOC, LLOC, NOS, WMC, RFC fortemente
   correlacionados; confirmado pelo VIF).
3. **Arquitetura "flat" do Neo4j** — DIT e NOC com variância quase nula (herança
   rasa).
4. **Correlação métrica×bug ≈ 0** (máx. r=0,06), contrastando com a literatura
   clássica (Basili et al.; Gyimóthy et al.) — explicado pelo desbalanceamento e
   provável subreporte de defeitos.
5. **O problema é o dataset, não as métricas:** WMC e CBO, apontadas como dos
   melhores preditores na literatura, também não tiveram poder aqui → a limitação
   está nos dados (poucos positivos), não nas métricas.

### Conclusão
- O Neo4j exibe padrões estatísticos típicos de software real (assimetria, caudas
  longas, multicolinearidade, forte relação tamanho↔complexidade).
- **Achado principal:** o GitHub Bug Dataset v1.1 para o Neo4j, nesta granularidade,
  **não tem positivos suficientes para sustentar predição confiável de defeitos**
  (EPV≈1; modelos instáveis, não convergem; MCC≈0 na CV).

### Limitações / ameaças à validade
- **Interna:** desbalanceamento extremo → separação completa e não-convergência;
  multicolinearidade severa (corrigida por VIF); avaliação no próprio treino
  (corrigida por CV); amostragem do Shapiro-Wilk (mitigada por `seed=42` +
  Lilliefors).
- **Externa:** um único projeto e versão; domínio (banco em grafo) com arquitetura
  plana (baixa variância de DIT/NOC é idiossincrasia); viés de captura do dataset
  (só bugs ligados a commits de correção).
- **Construto:** métricas CK são *proxies* imperfeitos; "Number of bugs" é bug
  registrado, não defeito real; LCOM5 tem múltiplas definições; PMD agregado perde
  resolução.
- **Conclusão:** baixíssimo poder estatístico; ~170 correlações sem correção para
  comparações múltiplas; p-valores minúsculos refletem também o n grande.

### Trabalhos futuros
1. Combinar **múltiplas versões** do Neo4j para elevar positivos e atingir EPV ≥ 10.
2. Aplicar **Random Forest / gradient boosting**, que tratam desbalanceamento
   nativamente.
3. Explorar **cross-project defect prediction**.

### Tecnologias e ferramentas
- **R** + pacotes: ggplot2, dplyr, tidyr, corrplot, PerformanceAnalytics, gridExtra,
  scales, car, nortest, pROC, caret, PRROC.
- **Python** (`exploracao_inicial.py`) para inspeção preliminar.
- **SourceMeter** (externo) gerou as métricas do dataset.
- **LaTeX** (artigo em formato SBC e versão IEEE).
- **Dashboard web em R + Shiny** (`api.R`): pacotes shiny, bslib, bsicons,
  randomForest, DT, ggplot2, corrplot, pROC. **6 abas** — Visão Geral (KPIs),
  Previsão WMC (Random Forest, regressão), Previsão de Bugs (Random Forest,
  classificação + curva ROC/AUC), Exploração (histograma, dispersão colorida por
  bug, correlação Spearman), Modelo (RMSE/MAE/R² + importância de variáveis) e Dados
  (tabela interativa). Treino único com split 80/20, `seed=42`. **Aviso do próprio
  dashboard:** por causa do desbalanceamento, as probabilidades de bug são
  referência relativa, não diagnóstico — coerente com a conclusão do artigo.

### Contribuições do trabalho
- Para **Engenharia de Software empírica:** evidência de que validade de um estudo de
  predição de defeitos depende criticamente de **balanceamento de classes e poder
  estatístico (EPV)**, não só da escolha das métricas.
- Para **Ciência de Dados / análise de repositórios:** um pipeline reprodutível
  (R + `seed=42`) de descritiva → normalidade → correlação → VIF → modelagem
  *cost-sensitive* → CV, com leitura honesta de métricas em cenário de classe rara
  (priorizar MCC e AUC-PR sobre acurácia).

---

## Estrutura de slides recomendada (≈ 16–20 slides — pode fundir slides afins)

Para **cada slide**, produza os 5 elementos: **(T) Título** · **(C) Conteúdo**
(bullets curtos / tabela / destaque numérico) · **(V) Visual recomendado** · **(N)
Nota do apresentador** (3–5 frases) · **(L) Vínculo** com a seção/tabela/figura do
artigo.

1. **Capa / Identificação** — (C) título, subtítulo "Análise estatística de
   métricas de código com R · GitHub Bug Dataset v1.1", autores, IBMEC ES / AP1,
   links do repositório e do dashboard. (V) capa limpa. (L) cabeçalho do artigo.
2. **Contexto e motivação** — (C) métricas de código estimam qualidade,
   complexidade e propensão a defeitos; suíte CK; a relação métricas↔falhas depende
   da qualidade estatística do dataset. (V) ícones das categorias de métrica. (L)
   Introdução.
3. **Objeto de estudo: Neo4j** — (C) banco em grafo open-source em Java; **deixe
   explícito que ele é o software analisado, não uma ferramenta usada**; 3 motivos
   da escolha. (V) caixa "Neo4j = código-fonte sob análise". (L) Introdução.
4. **Problema de pesquisa** — (C) a pergunta central + a resposta dupla (sim para
   análise; não para predição). (V) destaque da pergunta. (L) Introdução.
5. **Objetivos** — (C) geral + 7 específicos. (V) lista em duas colunas. (L)
   Introdução/Metodologia.
6. **Base de dados** — (C) tabela Class (7.917×113) e File (4.261×12); alvo = Number
   of bugs; **plante o conflito:** 8 classes (0,10%) e 6 arquivos (0,14%) com bug;
   EPV≈1 vs. mínimo 10. (V) **reconstruir** barra do desbalanceamento OU placeholder
   `figuras/barras_distribuicao_bugs.png`. (L) Metodologia §Fonte de Dados.
7. **Seleção de variáveis** — (C) 3 critérios → 19 (Class) e 7 (File); tabela das
   19 por categoria. (V) tabela enxuta por categoria. (L) Tabela "Variáveis
   selecionadas".
8. **Metodologia / pipeline (R)** — (C) o fluxo de 10 etapas. (V) **diagrama de
   fluxo** (caixas encadeadas). (N) frise que tudo é em R, reprodutível com
   `seed=42`. (L) Metodologia.
9. **Tendência central** — (C) tabela média/mediana/moda; relação média>mediana>moda
   = assimetria positiva. (V) **reconstruir** barras agrupadas média vs. mediana
   (WMC, LOC, LLOC, NOS) OU `figuras/histogramas_class.png`. (L) Tabela tendência
   central.
10. **Dispersão e posição** — (C) destaques: LOC CV=1,94 (máx heterogeneidade); DIT
    variância≈0,99 (pouco discriminante); quartis de WMC/LOC. (V) tabela enxuta de
    dispersão. (L) Tabelas de dispersão/posição.
11. **Outliers (IQR)** — (C) 5,86%–22,48%; ~10% nas métricas de tamanho; não
    removidos. (V) `figuras/boxplots_class.png` (placeholder) **ou** reconstruir
    barras de % de outliers por métrica. (L) Tabela de outliers + Fig. boxplots.
12. **Distribuições / histogramas** — (C) assimetria à direita em todas; pico em
    zero + cauda pesada ≈ log-normal/lei de potência; incompatível com normalidade.
    (V) `figuras/histogramas_class.png` (placeholder) ou `figuras/densidade_metricas_class.png`.
    (L) Fig. histogramas.
13. **Normalidade** — (C) tabela SW W + Lilliefors D; todos p<10⁻⁵⁰; por que
    Lilliefors em vez de K-S. (V) tabela. (N) explique o "porquê" do Lilliefors em
    linguagem simples. (L) §Testes de Normalidade.
14. **Correlação** — (C) lista das fortes (LOC×LLOC 0,99…); Spearman concorda;
    métrica×bug máx 0,06. (V) `figuras/correlacao_heatmap_class.png` (placeholder)
    + **reconstruir** barras das correlações fortes; opcional
    `figuras/correlacao_spearman_class.png`. (L) §Análise de Correlação.
15. **Multicolinearidade (VIF)** — (C) RFC 20,18 / WMC 15,17 / LOC 10,98 → remove
    RFC → todos <10. (V) **reconstruir** barras de VIF (antes) com linha de corte
    em 10, ou `figuras/vif_barplot.png` (placeholder). (L) §VIF.
16. **Modelagem: regressão logística *cost-sensitive*** — (C) pesos por frequência;
    Class **não converge** (coef. 10¹²–10¹⁵, separação completa, McFadden −10,76);
    File McFadden 0,59 mas também não converge. (V) caixa de alerta + fórmula dos
    pesos. (L) §Modelagem Estatística.
17. **Validação cruzada e métricas** — (C) tabela treino vs CV; **MCC≈0**; por que a
    acurácia engana. (V) tabela de métricas + `figuras/curva_roc.png` e/ou
    `figuras/curva_pr.png` (placeholders). (N) ancore na ideia "99% de acurácia é o
    baseline trivial". (L) Tabela de métricas + Fig. ROC.
18. **Principais insights** — (C) os 5 achados, em uma linha cada. (V) cinco cartões.
    (L) §Discussão.
19. **Conclusão** — (C) padrões estruturais ricos **+** dataset inadequado para
    predição (EPV≈1, MCC≈0); o limite está nos dados, não nas métricas. (V) frase de
    impacto centralizada. (L) §Conclusão.
20. **Limitações & Trabalhos futuros** — (C) ameaças à validade (4 tipos, 1 linha
    cada) + 3 trabalhos futuros. (V) duas colunas. (L) §Ameaças à Validade + Conclusão.
21. **(Opcional) Tecnologias & Dashboard** — (C) ecossistema R, LaTeX, e o dashboard
    Shiny de 6 abas + link. (V) ícones + screenshot/placeholder do dashboard. (L)
    `api_r/apiR.md`.
22. **Encerramento** — (C) "Obrigado / Perguntas", link do repo e do dashboard. (V)
    slide final limpo.

> Slides 6, 16, 17 e 19 são o **clímax narrativo** (o desbalanceamento e suas
> consequências) — dê a eles o maior peso visual.

## Mapa figura → slide (arquivos reais em `figuras/`)
- `barras_distribuicao_bugs.png` → slide 6 (desbalanceamento)
- `histogramas_class.png` / `densidade_metricas_class.png` → slides 9, 12
- `boxplots_class.png` → slide 11 (outliers); `boxplots_file.png` (apoio)
- `boxplot_comparativo_bugs.png` → apoio nos slides 17/18 (métricas por presença de bug)
- `dispersao_loc_wmc.png` → apoio no slide 14 (tamanho×complexidade);
  `dispersao_cbo_rfc.png` (acoplamento)
- `correlacao_heatmap_class.png` (Pearson) e `correlacao_spearman_class.png` → slide 14;
  `chart_correlation_class.png` (versão integrada PerformanceAnalytics) como alternativa
- `correlacao_heatmap_file.png`, `correlacao_spearman_file.png`,
  `dispersao_lloc_mccc_file.png`, `histogramas_file.png` → apoio para o nível arquivo
- `vif_barplot.png` → slide 15
- `curva_roc.png` e `curva_pr.png` → slide 17

## O que NÃO fazer
- ❌ Não mencione Neo4j como banco de dados em uso, nem Cypher, nós ou modelagem em
  grafo. (O Neo4j é só o código analisado.)
- ❌ Não apresente o modelo como "predição de bugs bem-sucedida". O resultado honesto
  é que o **dataset** não sustenta predição confiável.
- ❌ Não destaque a acurácia como prova de qualidade do modelo (use MCC e AUC-PR).
- ❌ Não invente números, gráficos com dados fictícios, nem conclusões fora desta
  lista. Na dúvida, marque como limitação ou "a confirmar".

Comece **confirmando em 2–3 linhas a estrutura** que vai seguir; em seguida gere o
**artefato HTML dos slides** + as **notas do apresentador** de cada slide.

=== FIM DO PROMPT ===
