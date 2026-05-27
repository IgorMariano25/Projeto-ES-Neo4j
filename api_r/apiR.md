# 📊 Dashboard de Qualidade de Software - Neo4j

Aplicação web em **R + Shiny** que prevê métricas de código-fonte e a
probabilidade de bugs em classes do framework **Neo4j**, a partir do
*GitHub Bug Dataset v1.1*.

Trabalho **AP1 — Engenharia de Software (IBMEC)**.

---

## 1. Visão geral

A aplicação ([api.R](api.R)) é um dashboard interativo com 6 abas:

| Aba | O que faz |
|-----|-----------|
| **Visão Geral** | KPIs do dataset e resumo do projeto. |
| **Previsão WMC** | Estima o *Weighted Methods per Class* via Random Forest a partir de outras métricas (CC, LOC, CBO, RFC, LCOM5, NM, NL). |
| **Previsão de Bugs** | Classifica se a classe é propensa a bugs e mostra a curva ROC com AUC. |
| **Exploração** | Histograma dinâmico, dispersão entre duas métricas (colorida por bug) e matriz de correlação Spearman. |
| **Modelo** | Métricas de erro (RMSE, MAE, R²) e gráfico de importância das variáveis. |
| **Dados** | Tabela `DT` interativa com o dataset usado (após limpeza). |

> ⚠️ O dataset é fortemente **desbalanceado** (apenas ~0,10% das classes
> têm bug). As probabilidades de bug devem ser interpretadas como
> referência relativa, não diagnóstico definitivo — coerente com a
> conclusão do artigo.

---

## 2. Pré-requisitos

- **R ≥ 4.1** (recomendado 4.3+)
- **RStudio** (opcional, mas facilita)
- Acesso a internet **apenas na primeira execução** para baixar os
  pacotes. Depois disso roda totalmente offline.

### Pacotes utilizados

O script instala automaticamente o que faltar:

```
shiny, bslib, bsicons, randomForest, ggplot2,
dplyr, DT, corrplot, scales, pROC
```

Se preferir instalar manualmente antes:

```r
install.packages(c("shiny", "bslib", "bsicons", "randomForest",
                   "ggplot2", "dplyr", "DT", "corrplot",
                   "scales", "pROC"))
```

---

## 3. Estrutura esperada de pastas

A aplicação procura o CSV em três caminhos (nesta ordem):

1. `dataset/neo4j-Class.csv` (raiz do projeto — caso preferido)
2. `../dataset/neo4j-Class.csv` (quando rodado de uma subpasta)
3. `neo4j-Class.csv` (ao lado do `api.R`)

Estrutura atual do projeto:

```
Projeto-ES-Neo4j/
├── api_r/
│   ├── api.R          ← aplicação Shiny
│   └── apiR.md        ← este documento
├── dataset/
│   └── neo4j-Class.csv
├── artigo/
├── figuras/
└── scripts/
```

Como o `api.R` está em `api_r/`, ele encontra o CSV via o **fallback
`../dataset/`** automaticamente.

---

## 4. Como executar localmente

### Opção A — RStudio

1. Abra o arquivo [api.R](api.R) no RStudio.
2. Clique no botão **▶ Run App** (canto superior direito do editor).
3. A primeira execução instala os pacotes (pode demorar alguns minutos).
4. O navegador abrirá em `http://127.0.0.1:XXXX`.

### Opção B — Terminal R / PowerShell

A partir da **raiz do projeto** (`E:\Projeto-ES-Neo4j`):

```powershell
Rscript -e "shiny::runApp('api_r/api.R', launch.browser = TRUE)"
```

Ou de dentro da pasta `api_r/`:

```powershell
cd api_r
Rscript -e "shiny::runApp('api.R', launch.browser = TRUE)"
```

### Opção C — Console R interativo

```r
setwd("E:/Projeto-ES-Neo4j")
shiny::runApp("api_r/api.R")
```

> 💡 Para parar a aplicação, basta pressionar `Esc` no console R ou
> fechar a aba do navegador e clicar em **Stop** no RStudio.

---

## 5. Como usar cada aba

### 5.1 Visão Geral
Mostra 4 KPIs: total de classes, classes com bug, R² do modelo de
regressão e AUC do modelo de classificação. Use como ponto de partida.

### 5.2 Previsão WMC
1. Ajuste os campos numéricos na barra lateral (CC, LOC, CBO, RFC,
   LCOM5, NM, NL).
2. Clique em **Prever WMC**.
3. O resultado aparece em destaque, com a média e a mediana do WMC do
   dataset para referência.
4. Abaixo, o gráfico *Predito × Real* mostra o desempenho do modelo no
   conjunto de teste.

### 5.3 Previsão de Bugs
1. Preencha as métricas da classe.
2. Clique em **Prever Probabilidade**.
3. O cartão mostra a probabilidade (%) e o rótulo:
   - 🟢 **BAIXO RISCO** quando p ≤ 50%
   - 🔴 **ALTO RISCO** quando p > 50%
4. A curva ROC abaixo indica o desempenho geral do classificador.

### 5.4 Exploração
- **Distribuição**: escolha uma variável no `selectInput` para ver seu
  histograma.
- **Dispersão**: escolha eixos X e Y; os pontos são coloridos pela
  presença de bug.
- **Correlação**: matriz Spearman entre todas as métricas numéricas.

### 5.5 Modelo
KPIs de desempenho (RMSE, MAE, R²) + gráfico de importância das
variáveis (`%IncMSE` do Random Forest).

### 5.6 Dados
Tabela paginada e pesquisável com o dataset usado (sortable, com busca
por coluna e exportação básica).

---

## 6. Como funciona internamente

Pipeline executado uma única vez ao iniciar o app:

```
CSV → limpeza (numérico + NA) → split 80/20 (seed=42)
      → Random Forest regressão (WMC)
      → Random Forest classificação (tem_bug)
      → cálculo de RMSE, MAE, R², AUC
      → renderização das abas
```

- **Seed fixa** (`set.seed(42)`) garante reprodutibilidade.
- Os modelos não são re-treinados a cada interação — apenas as
  *previsões pontuais* são recalculadas, mantendo o app responsivo.
- O carregamento inicial pode levar ~10–30 s (treino dos dois modelos).

---

## 7. Publicação na nuvem (ShinyApps.io)

O `api.R` já está preparado para deploy: usa **caminho relativo** e
**auto-instala dependências**.

### Passos

1. Crie uma conta gratuita em <https://www.shinyapps.io/>.
2. Em *Account → Tokens*, copie o comando `setAccountInfo(...)`.
3. No R, instale e configure o `rsconnect`:

   ```r
   install.packages("rsconnect")
   rsconnect::setAccountInfo(name   = "seu-usuario",
                             token  = "XXXX",
                             secret = "YYYY")
   ```

4. **Importante**: o ShinyApps.io só envia a pasta do app. Para que o
   CSV vá junto, copie o dataset para dentro de `api_r/` antes do
   deploy:

   ```powershell
   Copy-Item ..\dataset\neo4j-Class.csv .\neo4j-Class.csv
   ```

   (O fallback do script já procura `neo4j-Class.csv` ao lado do `api.R`.)

5. Faça o deploy:

   ```r
   setwd("E:/Projeto-ES-Neo4j/api_r")
   rsconnect::deployApp(appDir        = ".",
                        appPrimaryDoc = "api.R",
                        appName       = "neo4j-quality-dashboard")
   ```

6. Ao final, o `rsconnect` mostra a URL pública
   (`https://seu-usuario.shinyapps.io/neo4j-quality-dashboard/`).

### Limites do plano gratuito
- 5 aplicações ativas
- 25 horas/mês de uso
- Sleep automático após inatividade (o app "acorda" no primeiro acesso,
  com ~30 s de delay)

---

## 8. Alternativa: publicar via GitHub (sem ShinyApps.io)

Caso a publicação em nuvem não seja possível (rede controlada), o
enunciado aceita o link do **repositório GitHub** com o código:

```powershell
git add api_r/api.R api_r/apiR.md
git commit -m "feat: dashboard Shiny de qualidade de software"
git push origin main
```

Documente no `README.md` da raiz como executar localmente
(seção 4 deste documento).

---

## 9. Solução de problemas

| Sintoma | Causa provável | Como resolver |
|---|---|---|
| `Error in read.csv: cannot open file` | CSV não encontrado em nenhum dos 3 caminhos. | Verifique se `dataset/neo4j-Class.csv` existe na raiz do projeto, ou copie-o para dentro de `api_r/`. |
| Travamento na primeira execução | Instalação dos pacotes em andamento. | Aguarde; observe o console R. |
| `there is no package called 'bsicons'` | R muito antigo. | Atualize para R ≥ 4.1 e rode `install.packages("bsicons")`. |
| App abre mas gráficos não renderizam | Pacote `ggplot2` ou `corrplot` faltando. | `install.packages(c("ggplot2","corrplot"))`. |
| Deploy ShinyApps.io falha por timeout | Treino dos modelos demora > 5 min. | Reduza `ntree = 300` para `ntree = 150` no `randomForest()`. |
| Acentuação aparece quebrada | Encoding do console no Windows. | Salve o arquivo como UTF-8 (já está); no PowerShell rode `chcp 65001`. |

---

## 10. Créditos

- **Dataset**: GitHub Bug Dataset v1.1 — métricas do framework
  [Neo4j](https://neo4j.com/).
- **Artigo associado**: [artigo/main.tex](../artigo/main.tex).
- **Análise estatística completa**: [scripts/analise_final.R](../scripts/analise_final.R).
