# =====================================================
# Dashboard de Qualidade de Software - Neo4j
# Aplicação Shiny para previsão de métricas e bugs
# Trabalho AP1 - Engenharia de Software (IBMEC)
# =====================================================
#
# COMO EXECUTAR LOCALMENTE:
#   - No RStudio: abra este arquivo e clique em "Run App".
#   - Via terminal R (a partir da raiz do projeto):
#       shiny::runApp("api.R")
#
# COMO PUBLICAR NA NUVEM (ShinyApps.io):
#   1. install.packages("rsconnect")
#   2. rsconnect::setAccountInfo(name=..., token=..., secret=...)
#   3. rsconnect::deployApp(appDir = ".",
#                           appPrimaryDoc = "api.R",
#                           appName = "neo4j-quality-dashboard")
#
# O caminho do dataset é RELATIVO ("dataset/neo4j-Class.csv"),
# o que permite a execução tanto local quanto na nuvem
# (ShinyApps.io empacota a pasta inteira do app).
# =====================================================

# -----------------------------------------------------
# 1. DEPENDÊNCIAS - instala automaticamente se faltarem
# -----------------------------------------------------
pacotes <- c("shiny", "bslib", "bsicons", "randomForest", "ggplot2",
             "dplyr", "DT", "corrplot", "scales", "pROC")

for (p in pacotes) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

library(shiny)
library(bslib)
library(bsicons)
library(randomForest)
library(ggplot2)
library(dplyr)
library(DT)
library(corrplot)
library(scales)
library(pROC)

# -----------------------------------------------------
# 2. CARREGAMENTO E LIMPEZA DOS DADOS
# -----------------------------------------------------
caminho_dataset <- file.path("dataset", "neo4j-Class.csv")

if (!file.exists(caminho_dataset)) {
  # fallback caso o app seja executado de outra pasta
  candidatos <- c(
    file.path("..", "dataset", "neo4j-Class.csv"),
    "neo4j-Class.csv"
  )
  for (c in candidatos) {
    if (file.exists(c)) { caminho_dataset <- c; break }
  }
}

dados_raw <- read.csv(caminho_dataset, stringsAsFactors = FALSE,
                      check.names = TRUE)

# Métricas numéricas usadas no estudo (alinhadas ao artigo)
metricas_preditoras <- c("CC", "LOC", "LLOC", "CBO", "RFC", "LCOM5",
                         "DIT", "NOC", "WMC", "NM", "NL", "NLE",
                         "CD", "CLOC", "WarningInfo", "WarningMajor")

col_bugs  <- "Number.of.bugs"
cols_disp <- intersect(c(metricas_preditoras, col_bugs),
                       names(dados_raw))

dados <- dados_raw[, cols_disp]
dados[] <- lapply(dados, function(x) as.numeric(as.character(x)))
dados <- na.omit(dados)

# Variável binária para classificação
dados$tem_bug <- factor(ifelse(dados[[col_bugs]] > 0, "Sim", "Nao"),
                        levels = c("Nao", "Sim"))

# -----------------------------------------------------
# 3. TREINO DOS MODELOS (uma vez ao iniciar o app)
# -----------------------------------------------------
set.seed(42)

# 3.1. Regressão: prever WMC
preditoras_reg <- intersect(
  c("CC", "LOC", "CBO", "RFC", "LCOM5", "NM", "NL"),
  names(dados)
)
formula_reg <- as.formula(
  paste("WMC ~", paste(preditoras_reg, collapse = " + "))
)

idx    <- sample(seq_len(nrow(dados)), size = 0.8 * nrow(dados))
treino <- dados[idx, ]
teste  <- dados[-idx, ]

modelo_reg <- randomForest(formula_reg, data = treino,
                           ntree = 300, importance = TRUE)

pred_teste <- predict(modelo_reg, teste)
rmse <- sqrt(mean((teste$WMC - pred_teste)^2))
mae  <- mean(abs(teste$WMC - pred_teste))
r2   <- 1 - sum((teste$WMC - pred_teste)^2) /
            sum((teste$WMC - mean(teste$WMC))^2)

importancia <- data.frame(
  Variavel    = rownames(importance(modelo_reg)),
  Importancia = importance(modelo_reg)[, 1]
)
importancia <- importancia[order(-importancia$Importancia), ]

# 3.2. Classificação: prever presença de bug
preditoras_clf <- intersect(
  c("CC", "LOC", "CBO", "RFC", "LCOM5", "WMC", "NM"),
  names(dados)
)
formula_clf <- as.formula(
  paste("tem_bug ~", paste(preditoras_clf, collapse = " + "))
)

modelo_clf <- randomForest(formula_clf, data = treino,
                           ntree = 300, importance = TRUE)

prob_teste <- predict(modelo_clf, teste, type = "prob")[, "Sim"]
roc_obj    <- pROC::roc(teste$tem_bug, prob_teste, quiet = TRUE)
auc_val    <- as.numeric(pROC::auc(roc_obj))

# =====================================================
# 4. INTERFACE (UI)
# =====================================================
ui <- page_navbar(
  title = "Neo4j • Dashboard de Qualidade de Software",
  theme = bs_theme(version = 5, bootswatch = "flatly",
                   primary = "#2C3E50"),
  fillable = FALSE,

  # ---------- Aba 1: Visão Geral ----------
  nav_panel(
    "Visão Geral",
    layout_columns(
      fill = FALSE,
      value_box(
        title = "Classes analisadas",
        value = format(nrow(dados), big.mark = "."),
        showcase = bs_icon("diagram-3")
      ),
      value_box(
        title = "Classes com bug",
        value = sum(dados$tem_bug == "Sim"),
        showcase = bs_icon("bug")
      ),
      value_box(
        title = "R² (modelo WMC)",
        value = sprintf("%.3f", r2),
        showcase = bs_icon("graph-up")
      ),
      value_box(
        title = "AUC (modelo bugs)",
        value = sprintf("%.3f", auc_val),
        showcase = bs_icon("bullseye")
      )
    ),
    card(
      card_header("Sobre esta aplicação"),
      card_body(
        p("Aplicação Shiny para previsão de métricas de qualidade ",
          "do framework ", strong("Neo4j"),
          ", a partir do GitHub Bug Dataset v1.1."),
        tags$ul(
          tags$li(strong("Previsão WMC"),
                  " — estima a complexidade ponderada (WMC) ",
                  "a partir de outras métricas via Random Forest."),
          tags$li(strong("Previsão de Bugs"),
                  " — classifica se uma classe é propensa a bugs."),
          tags$li(strong("Exploração"),
                  " — distribuição das métricas e correlações."),
          tags$li(strong("Modelo"),
                  " — importância das variáveis e métricas de erro."),
          tags$li(strong("Dados"),
                  " — tabela interativa com o dataset utilizado.")
        ),
        p(em("Atenção: o dataset apresenta forte desbalanceamento ",
             "(apenas 0,10% das classes contêm bug), conforme ",
             "discutido no artigo. As previsões de bugs devem ser ",
             "interpretadas como referência relativa."),
          class = "text-muted")
      )
    )
  ),

  # ---------- Aba 2: Previsão WMC ----------
  nav_panel(
    "Previsão WMC",
    layout_sidebar(
      sidebar = sidebar(
        title = "Entradas",
        numericInput("cc",   "CC (Complexidade Ciclomática)", 10, min = 0),
        numericInput("loc",  "LOC (Linhas de Código)", 200, min = 0),
        numericInput("cbo",  "CBO (Coupling Between Objects)", 5, min = 0),
        numericInput("rfc",  "RFC (Response For Class)", 10, min = 0),
        numericInput("lcom", "LCOM5 (Falta de Coesão)", 1, min = 0),
        numericInput("nm",   "NM (Número de Métodos)", 8, min = 0),
        numericInput("nl",   "NL (Aninhamento)", 2, min = 0),
        actionButton("btn_reg", "Prever WMC",
                     class = "btn-primary w-100")
      ),
      card(
        card_header("Resultado da previsão"),
        card_body(
          uiOutput("resultado_wmc"),
          hr(),
          plotOutput("plot_pred_vs_real", height = "320px")
        )
      )
    )
  ),

  # ---------- Aba 3: Previsão de Bugs ----------
  nav_panel(
    "Previsão de Bugs",
    layout_sidebar(
      sidebar = sidebar(
        title = "Entradas",
        numericInput("c_cc",   "CC", 10, min = 0),
        numericInput("c_loc",  "LOC", 200, min = 0),
        numericInput("c_cbo",  "CBO", 5, min = 0),
        numericInput("c_rfc",  "RFC", 10, min = 0),
        numericInput("c_lcom", "LCOM5", 1, min = 0),
        numericInput("c_wmc",  "WMC", 15, min = 0),
        numericInput("c_nm",   "NM", 8, min = 0),
        actionButton("btn_clf", "Prever Probabilidade",
                     class = "btn-danger w-100")
      ),
      card(
        card_header("Probabilidade da classe conter bug"),
        card_body(
          uiOutput("resultado_bug"),
          hr(),
          plotOutput("plot_roc", height = "320px")
        )
      )
    )
  ),

  # ---------- Aba 4: Exploração ----------
  nav_panel(
    "Exploração",
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Distribuição da métrica selecionada"),
        selectInput("var_dist", "Variável:",
                    choices  = setdiff(cols_disp, col_bugs),
                    selected = "WMC"),
        plotOutput("plot_dist", height = "320px")
      ),
      card(
        card_header("Dispersão entre duas métricas"),
        layout_columns(
          col_widths = c(6, 6),
          selectInput("var_x", "Eixo X:",
                      choices  = setdiff(cols_disp, col_bugs),
                      selected = "CC"),
          selectInput("var_y", "Eixo Y:",
                      choices  = setdiff(cols_disp, col_bugs),
                      selected = "WMC")
        ),
        plotOutput("plot_scatter", height = "320px")
      )
    ),
    card(
      card_header("Matriz de correlação (Spearman)"),
      plotOutput("plot_corr", height = "500px")
    )
  ),

  # ---------- Aba 5: Modelo ----------
  nav_panel(
    "Modelo",
    layout_columns(
      fill = FALSE,
      value_box(title = "RMSE (teste)",
                value = sprintf("%.2f", rmse),
                showcase = bs_icon("rulers")),
      value_box(title = "MAE (teste)",
                value = sprintf("%.2f", mae),
                showcase = bs_icon("activity")),
      value_box(title = "R² (teste)",
                value = sprintf("%.3f", r2),
                showcase = bs_icon("check2-circle"))
    ),
    card(
      card_header("Importância das variáveis - modelo WMC"),
      plotOutput("plot_importancia", height = "420px")
    )
  ),

  # ---------- Aba 6: Dados ----------
  nav_panel(
    "Dados",
    card(
      card_header("Dataset utilizado (após limpeza)"),
      DTOutput("tabela_dados")
    )
  )
)

# =====================================================
# 5. SERVER
# =====================================================
server <- function(input, output, session) {

  # ----- Previsão WMC -----
  pred_wmc <- eventReactive(input$btn_reg, {
    novo <- data.frame(
      CC = input$cc, LOC = input$loc, CBO = input$cbo,
      RFC = input$rfc, LCOM5 = input$lcom,
      NM = input$nm, NL = input$nl
    )
    novo <- novo[, preditoras_reg, drop = FALSE]
    as.numeric(predict(modelo_reg, novo))
  }, ignoreNULL = FALSE)

  output$resultado_wmc <- renderUI({
    val <- pred_wmc()
    tagList(
      h2(sprintf("WMC estimado: %.2f", val),
         style = "color:#2C3E50;"),
      p(sprintf("Média do WMC no dataset: %.2f | Mediana: %.2f",
                mean(dados$WMC), median(dados$WMC)),
        class = "text-muted")
    )
  })

  output$plot_pred_vs_real <- renderPlot({
    df <- data.frame(real = teste$WMC, pred = pred_teste)
    ggplot(df, aes(real, pred)) +
      geom_point(alpha = 0.4, color = "#2C3E50") +
      geom_abline(slope = 1, intercept = 0,
                  color = "red", linetype = "dashed") +
      labs(title = "Predito vs. Real (conjunto de teste)",
           x = "WMC real", y = "WMC predito") +
      theme_minimal(base_size = 13)
  })

  # ----- Previsão Bugs -----
  pred_bug <- eventReactive(input$btn_clf, {
    novo <- data.frame(
      CC = input$c_cc, LOC = input$c_loc, CBO = input$c_cbo,
      RFC = input$c_rfc, LCOM5 = input$c_lcom,
      WMC = input$c_wmc, NM = input$c_nm
    )
    novo <- novo[, preditoras_clf, drop = FALSE]
    as.numeric(predict(modelo_clf, novo, type = "prob")[, "Sim"])
  }, ignoreNULL = FALSE)

  output$resultado_bug <- renderUI({
    p_val <- pred_bug()
    cor   <- if (p_val > 0.5) "#C0392B" else "#27AE60"
    rotulo <- if (p_val > 0.5) "ALTO RISCO" else "BAIXO RISCO"
    tagList(
      h2(sprintf("Probabilidade: %.1f%%", p_val * 100),
         style = paste0("color:", cor, ";")),
      h4(rotulo, style = paste0("color:", cor, ";")),
      p("Limiar de decisão: 50%.", class = "text-muted"),
      p(em("Dataset desbalanceado: use as probabilidades como ",
           "referência relativa, não como diagnóstico definitivo."),
        class = "text-muted small")
    )
  })

  output$plot_roc <- renderPlot({
    df <- data.frame(fpr = 1 - roc_obj$specificities,
                     tpr = roc_obj$sensitivities)
    ggplot(df, aes(fpr, tpr)) +
      geom_line(color = "#C0392B", linewidth = 1) +
      geom_abline(slope = 1, intercept = 0,
                  linetype = "dashed", color = "grey50") +
      labs(title = sprintf("Curva ROC - AUC = %.3f", auc_val),
           x = "Taxa de Falso Positivo",
           y = "Taxa de Verdadeiro Positivo") +
      theme_minimal(base_size = 13)
  })

  # ----- Exploração -----
  output$plot_dist <- renderPlot({
    req(input$var_dist)
    ggplot(dados, aes(x = .data[[input$var_dist]])) +
      geom_histogram(fill = "#2C3E50", bins = 40, color = "white") +
      labs(title = paste("Distribuição de", input$var_dist),
           x = input$var_dist, y = "Frequência") +
      scale_y_continuous(labels = scales::comma) +
      theme_minimal(base_size = 13)
  })

  output$plot_scatter <- renderPlot({
    req(input$var_x, input$var_y)
    ggplot(dados, aes(x = .data[[input$var_x]],
                      y = .data[[input$var_y]],
                      color = tem_bug)) +
      geom_point(alpha = 0.5) +
      geom_smooth(method = "lm", se = FALSE,
                  inherit.aes = FALSE,
                  aes(x = .data[[input$var_x]],
                      y = .data[[input$var_y]]),
                  color = "#2C3E50") +
      scale_color_manual(values = c("Nao" = "#7F8C8D",
                                    "Sim" = "#C0392B"),
                         name = "Tem bug?") +
      labs(title = paste(input$var_y, "vs.", input$var_x),
           x = input$var_x, y = input$var_y) +
      theme_minimal(base_size = 13)
  })

  output$plot_corr <- renderPlot({
    num_cols <- setdiff(cols_disp, col_bugs)
    m <- cor(dados[, num_cols], method = "spearman",
             use = "pairwise.complete.obs")
    corrplot(m, method = "color", type = "upper",
             tl.col = "black", tl.cex = 0.8,
             addCoef.col = "black", number.cex = 0.6,
             col = colorRampPalette(c("#2C3E50", "white",
                                      "#C0392B"))(200))
  })

  # ----- Modelo -----
  output$plot_importancia <- renderPlot({
    ggplot(importancia,
           aes(x = reorder(Variavel, Importancia),
               y = Importancia)) +
      geom_col(fill = "#2C3E50") +
      coord_flip() +
      labs(title = "Importância das variáveis (Random Forest)",
           x = NULL, y = "%IncMSE") +
      theme_minimal(base_size = 13)
  })

  # ----- Dados -----
  output$tabela_dados <- renderDT({
    datatable(dados,
              options  = list(pageLength = 15, scrollX = TRUE),
              rownames = FALSE) %>%
      formatRound(columns = which(sapply(dados, is.numeric)),
                  digits  = 2)
  })
}

# =====================================================
# 6. EXECUTAR APLICAÇÃO
# =====================================================
shinyApp(ui = ui, server = server)
