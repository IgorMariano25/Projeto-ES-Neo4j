#!/usr/bin/env Rscript
# =============================================================================
# Análise Estatística Completa - Framework Neo4j
# =============================================================================
# Disciplina: Engenharia de Software - AP1
# Dataset: GitHub Bug Dataset v1.1 (Neo4j - versão mais recente)
# Autores: Igor Mariano, Felipe
# Data: Abril/2026
#
# Este script realiza a análise estatística completa dos datasets de métricas
# de código-fonte do framework Neo4j, contemplando:
#   1. Medidas de tendência central
#   2. Medidas de dispersão
#   3. Medidas de posição relativa (quartis, percentis, boxplots)
#   4. Construção de gráficos (histogramas, boxplots, dispersão, barras)
#   5. Avaliação de outliers
#   6. Testes de normalidade (Shapiro-Wilk, Kolmogorov-Smirnov)
#   7. Coeficientes de correlação (PerformanceAnalytics)
#   8. Modelagem estatística (Regressão Logística)
# =============================================================================

# --- Instalação e carregamento de pacotes ---
pacotes <- c("ggplot2", "dplyr", "tidyr", "corrplot",
             "PerformanceAnalytics", "gridExtra", "scales", "car")

for (p in pacotes) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  library(p, character.only = TRUE)
}

# --- Configuração de diretórios ---
dir_dataset <- "../dataset"
dir_figuras <- "../figuras"
if (!dir.exists(dir_figuras)) dir.create(dir_figuras, recursive = TRUE)

cat("=================================================================\n")
cat("ANÁLISE ESTATÍSTICA COMPLETA - FRAMEWORK NEO4J\n")
cat("=================================================================\n\n")

# =============================================================================
# 1. CARREGAMENTO E PREPARAÇÃO DOS DADOS
# =============================================================================
cat("--- 1. Carregamento dos datasets ---\n")

df_class <- read.csv(file.path(dir_dataset, "neo4j-Class.csv"),
                     stringsAsFactors = FALSE)
df_file  <- read.csv(file.path(dir_dataset, "neo4j-File.csv"),
                     stringsAsFactors = FALSE)

cat(sprintf("  Class-level: %d instâncias x %d atributos\n",
            nrow(df_class), ncol(df_class)))
cat(sprintf("  File-level:  %d instâncias x %d atributos\n\n",
            nrow(df_file), ncol(df_file)))

# Seleção de colunas relevantes (Class-level)
cols_class <- c("WMC", "CBO", "RFC", "LCOM5", "DIT", "NOC",
                "LOC", "LLOC", "NOS", "NM", "NL", "NLE",
                "CC", "CD", "CLOC", "NA.", "WarningInfo",
                "WarningMajor", "Number.of.bugs")

# Verificar nomes reais das colunas (R substitui espaços por pontos)
real_names <- names(df_class)
# NA é palavra reservada em R, verificar se é "NA." ou outro nome
cat("  Verificando nomes de colunas...\n")

# Ajustar nome de NA (pode ser NA. no R)
if ("NA." %in% real_names) {
  cols_class[which(cols_class == "NA.")] <- "NA."
} else if ("NA" %in% real_names) {
  cols_class[which(cols_class == "NA.")] <- "NA"
}

# Verificar disponibilidade
available_class <- cols_class[cols_class %in% real_names]
missing_cols <- cols_class[!cols_class %in% real_names]
if (length(missing_cols) > 0) {
  cat(sprintf("  AVISO: Colunas não encontradas: %s\n",
              paste(missing_cols, collapse = ", ")))
  # Tentar encontrar correspondência
  for (mc in missing_cols) {
    candidates <- grep(gsub("\\.", ".*", mc), real_names,
                       value = TRUE, ignore.case = TRUE)
    if (length(candidates) > 0) {
      cat(sprintf("    -> '%s' pode ser '%s'\n", mc, candidates[1]))
      available_class <- c(available_class, candidates[1])
    }
  }
}

dc <- df_class[, available_class, drop = FALSE]

# Criar variável Bug_class binária
dc$Bug_class <- ifelse(df_class$Number.of.bugs > 0, 1, 0)
dc$Bug_class <- as.factor(dc$Bug_class)

cat(sprintf("  Colunas selecionadas (Class): %d\n", ncol(dc)))
cat(sprintf("  Colunas: %s\n\n", paste(names(dc), collapse = ", ")))

# Seleção de colunas (File-level)
# CLOC é constante (tudo zero) no File-level, excluir
cols_file <- c("McCC", "LLOC",
               "Number.of.previous.modifications",
               "Number.of.previous.fixes",
               "Number.of.committers",
               "Number.of.developer.commits",
               "Number.of.bugs")

df <- df_file[, cols_file, drop = FALSE]
df$Bug_class <- ifelse(df_file$Number.of.bugs > 0, 1, 0)
df$Bug_class <- as.factor(df$Bug_class)

cat(sprintf("  Colunas selecionadas (File): %d\n", ncol(df)))
cat(sprintf("  Colunas: %s\n\n", paste(names(df), collapse = ", ")))

# =============================================================================
# Variáveis numéricas para análise
# =============================================================================
num_cols_class <- names(dc)[sapply(dc, is.numeric)]
num_cols_file  <- names(df)[sapply(df, is.numeric)]

cat(sprintf("  Variáveis numéricas Class: %s\n", paste(num_cols_class, collapse=", ")))
cat(sprintf("  Variáveis numéricas File:  %s\n\n", paste(num_cols_file, collapse=", ")))

# =============================================================================
# 2. MEDIDAS DE TENDÊNCIA CENTRAL
# =============================================================================
cat("=================================================================\n")
cat("2. MEDIDAS DE TENDÊNCIA CENTRAL\n")
cat("=================================================================\n\n")

# Função para calcular moda
calc_moda <- function(x) {
  ux <- unique(x)
  tab <- tabulate(match(x, ux))
  modas <- ux[tab == max(tab)]
  if (length(modas) == length(ux)) return(NA)  # sem moda clara
  return(paste(modas, collapse = ", "))
}

cat("--- Dataset Class-level ---\n")
cat(sprintf("%-18s %12s %12s %15s\n", "Variável", "Média", "Mediana", "Moda"))
cat(paste(rep("-", 60), collapse = ""), "\n")
for (col in num_cols_class) {
  m <- mean(dc[[col]], na.rm = TRUE)
  med <- median(dc[[col]], na.rm = TRUE)
  mod <- calc_moda(dc[[col]])
  cat(sprintf("%-18s %12.4f %12.4f %15s\n", col, m, med,
              ifelse(is.na(mod), "N/A", mod)))
}

cat("\n--- Dataset File-level ---\n")
cat(sprintf("%-35s %12s %12s %15s\n", "Variável", "Média", "Mediana", "Moda"))
cat(paste(rep("-", 77), collapse = ""), "\n")
for (col in num_cols_file) {
  m <- mean(df[[col]], na.rm = TRUE)
  med <- median(df[[col]], na.rm = TRUE)
  mod <- calc_moda(df[[col]])
  cat(sprintf("%-35s %12.4f %12.4f %15s\n", col, m, med,
              ifelse(is.na(mod), "N/A", mod)))
}

# =============================================================================
# 3. MEDIDAS DE DISPERSÃO
# =============================================================================
cat("\n=================================================================\n")
cat("3. MEDIDAS DE DISPERSÃO\n")
cat("=================================================================\n\n")

cat("--- Dataset Class-level ---\n")
cat(sprintf("%-18s %12s %14s %14s\n",
            "Variável", "Amplitude", "Variância", "Desvio Padrão"))
cat(paste(rep("-", 62), collapse = ""), "\n")
for (col in num_cols_class) {
  amp <- max(dc[[col]], na.rm=TRUE) - min(dc[[col]], na.rm=TRUE)
  v <- var(dc[[col]], na.rm = TRUE)
  dp <- sd(dc[[col]], na.rm = TRUE)
  cat(sprintf("%-18s %12.4f %14.4f %14.4f\n", col, amp, v, dp))
}

cat("\n--- Dataset File-level ---\n")
cat(sprintf("%-35s %12s %14s %14s\n",
            "Variável", "Amplitude", "Variância", "Desvio Padrão"))
cat(paste(rep("-", 79), collapse = ""), "\n")
for (col in num_cols_file) {
  amp <- max(df[[col]], na.rm=TRUE) - min(df[[col]], na.rm=TRUE)
  v <- var(df[[col]], na.rm = TRUE)
  dp <- sd(df[[col]], na.rm = TRUE)
  cat(sprintf("%-35s %12.4f %14.4f %14.4f\n", col, amp, v, dp))
}

# =============================================================================
# 4. MEDIDAS DE POSIÇÃO RELATIVA
# =============================================================================
cat("\n=================================================================\n")
cat("4. MEDIDAS DE POSIÇÃO RELATIVA (Quartis e Percentis)\n")
cat("=================================================================\n\n")

cat("--- Dataset Class-level ---\n")
cat(sprintf("%-15s %8s %8s %8s %8s %8s %8s %8s %8s\n",
            "Variável", "P5", "P10", "Q1", "Q2", "Q3", "P90", "P95", "IQR"))
cat(paste(rep("-", 85), collapse = ""), "\n")
for (col in num_cols_class) {
  q <- quantile(dc[[col]], probs = c(0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95),
                na.rm = TRUE)
  iqr_val <- q[5] - q[3]  # Q3 - Q1
  cat(sprintf("%-15s %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n",
              col, q[1], q[2], q[3], q[4], q[5], q[6], q[7], iqr_val))
}

cat("\n--- Dataset File-level ---\n")
cat(sprintf("%-35s %8s %8s %8s %8s %8s %8s %8s %8s\n",
            "Variável", "P5", "P10", "Q1", "Q2", "Q3", "P90", "P95", "IQR"))
cat(paste(rep("-", 105), collapse = ""), "\n")
for (col in num_cols_file) {
  q <- quantile(df[[col]], probs = c(0.05, 0.10, 0.25, 0.50, 0.75, 0.90, 0.95),
                na.rm = TRUE)
  iqr_val <- q[5] - q[3]
  cat(sprintf("%-35s %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n",
              col, q[1], q[2], q[3], q[4], q[5], q[6], q[7], iqr_val))
}

# =============================================================================
# 5. CONSTRUÇÃO DE GRÁFICOS
# =============================================================================
cat("\n=================================================================\n")
cat("5. CONSTRUÇÃO DE GRÁFICOS\n")
cat("=================================================================\n\n")

# --- 5.1 Histogramas (Class-level - métricas principais) ---
cat("  Gerando histogramas (Class-level)...\n")

metricas_hist <- c("WMC", "CBO", "RFC", "LOC", "LLOC", "NOS", "NM", "LCOM5")
metricas_hist <- metricas_hist[metricas_hist %in% names(dc)]

plots_hist <- list()
for (i in seq_along(metricas_hist)) {
  col <- metricas_hist[i]
  plots_hist[[i]] <- ggplot(dc, aes_string(x = col)) +
    geom_histogram(bins = 50, fill = "#2196F3", color = "white", alpha = 0.8) +
    labs(title = col, x = col, y = "Frequência") +
    theme_minimal(base_size = 10) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
}

png(file.path(dir_figuras, "histogramas_class.png"),
    width = 1600, height = 1200, res = 150)
do.call(grid.arrange, c(plots_hist, ncol = 3))
dev.off()
cat("  -> histogramas_class.png salvo\n")

# --- 5.2 Histogramas (File-level) ---
cat("  Gerando histogramas (File-level)...\n")

metricas_hist_file <- c("McCC", "LLOC",
                        "Number.of.previous.modifications",
                        "Number.of.committers",
                        "Number.of.developer.commits")
metricas_hist_file <- metricas_hist_file[metricas_hist_file %in% names(df)]

plots_hist_file <- list()
for (i in seq_along(metricas_hist_file)) {
  col <- metricas_hist_file[i]
  label <- gsub("\\.", " ", col)
  plots_hist_file[[i]] <- ggplot(df, aes_string(x = col)) +
    geom_histogram(bins = 50, fill = "#4CAF50", color = "white", alpha = 0.8) +
    labs(title = label, x = label, y = "Frequência") +
    theme_minimal(base_size = 10) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
}

png(file.path(dir_figuras, "histogramas_file.png"),
    width = 1600, height = 800, res = 150)
do.call(grid.arrange, c(plots_hist_file, ncol = 3))
dev.off()
cat("  -> histogramas_file.png salvo\n")

# --- 5.3 Boxplots (Class-level) ---
cat("  Gerando boxplots (Class-level)...\n")

metricas_box <- c("WMC", "CBO", "RFC", "LCOM5", "LOC", "LLOC",
                  "NOS", "NM", "DIT", "NL", "NLE", "CC")
metricas_box <- metricas_box[metricas_box %in% names(dc)]

plots_box <- list()
for (i in seq_along(metricas_box)) {
  col <- metricas_box[i]
  plots_box[[i]] <- ggplot(dc, aes_string(y = col)) +
    geom_boxplot(fill = "#FF9800", color = "#333333", alpha = 0.7,
                 outlier.color = "red", outlier.size = 0.5) +
    labs(title = col, y = col) +
    theme_minimal(base_size = 10) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          axis.text.x = element_blank())
}

png(file.path(dir_figuras, "boxplots_class.png"),
    width = 1600, height = 1200, res = 150)
do.call(grid.arrange, c(plots_box, ncol = 4))
dev.off()
cat("  -> boxplots_class.png salvo\n")

# --- 5.4 Boxplots (File-level) ---
cat("  Gerando boxplots (File-level)...\n")

metricas_box_file <- c("McCC", "LLOC",
                       "Number.of.previous.modifications",
                       "Number.of.committers",
                       "Number.of.developer.commits")
metricas_box_file <- metricas_box_file[metricas_box_file %in% names(df)]

plots_box_file <- list()
for (i in seq_along(metricas_box_file)) {
  col <- metricas_box_file[i]
  label <- gsub("\\.", " ", col)
  plots_box_file[[i]] <- ggplot(df, aes_string(y = col)) +
    geom_boxplot(fill = "#9C27B0", color = "#333333", alpha = 0.7,
                 outlier.color = "red", outlier.size = 0.5) +
    labs(title = label, y = label) +
    theme_minimal(base_size = 10) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          axis.text.x = element_blank())
}

png(file.path(dir_figuras, "boxplots_file.png"),
    width = 1400, height = 600, res = 150)
do.call(grid.arrange, c(plots_box_file, ncol = 3))
dev.off()
cat("  -> boxplots_file.png salvo\n")

# --- 5.5 Gráfico de dispersão: LOC vs WMC (Class-level) ---
cat("  Gerando gráfico de dispersão LOC vs WMC...\n")

if (all(c("LOC", "WMC") %in% names(dc))) {
  png(file.path(dir_figuras, "dispersao_loc_wmc.png"),
      width = 800, height = 600, res = 150)
  print(
    ggplot(dc, aes(x = LOC, y = WMC, color = Bug_class)) +
      geom_point(alpha = 0.3, size = 1) +
      scale_color_manual(values = c("0" = "#2196F3", "1" = "#F44336"),
                         labels = c("Sem bug", "Com bug")) +
      labs(title = "Dispersão: LOC vs WMC (Class-level)",
           x = "LOC (Linhas de Código)",
           y = "WMC (Complexidade Ponderada)",
           color = "Bug Class") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  )
  dev.off()
  cat("  -> dispersao_loc_wmc.png salvo\n")
}

# --- 5.6 Gráfico de dispersão: CBO vs RFC (Class-level) ---
cat("  Gerando gráfico de dispersão CBO vs RFC...\n")

if (all(c("CBO", "RFC") %in% names(dc))) {
  png(file.path(dir_figuras, "dispersao_cbo_rfc.png"),
      width = 800, height = 600, res = 150)
  print(
    ggplot(dc, aes(x = CBO, y = RFC, color = Bug_class)) +
      geom_point(alpha = 0.3, size = 1) +
      scale_color_manual(values = c("0" = "#2196F3", "1" = "#F44336"),
                         labels = c("Sem bug", "Com bug")) +
      labs(title = "Dispersão: CBO vs RFC (Class-level)",
           x = "CBO (Coupling Between Objects)",
           y = "RFC (Response For a Class)",
           color = "Bug Class") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  )
  dev.off()
  cat("  -> dispersao_cbo_rfc.png salvo\n")
}

# --- 5.7 Gráfico de dispersão (File-level): LLOC vs McCC ---
cat("  Gerando gráfico de dispersão LLOC vs McCC (File)...\n")

if (all(c("LLOC", "McCC") %in% names(df))) {
  png(file.path(dir_figuras, "dispersao_lloc_mccc_file.png"),
      width = 800, height = 600, res = 150)
  print(
    ggplot(df, aes(x = LLOC, y = McCC, color = Bug_class)) +
      geom_point(alpha = 0.3, size = 1) +
      scale_color_manual(values = c("0" = "#4CAF50", "1" = "#F44336"),
                         labels = c("Sem bug", "Com bug")) +
      labs(title = "Dispersão: LLOC vs McCC (File-level)",
           x = "LLOC (Linhas Lógicas de Código)",
           y = "McCC (Complexidade Ciclomática)",
           color = "Bug Class") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  )
  dev.off()
  cat("  -> dispersao_lloc_mccc_file.png salvo\n")
}

# --- 5.8 Gráfico de barras: distribuição de bugs ---
cat("  Gerando gráfico de barras (distribuição de bugs)...\n")

bugs_class_counts <- table(dc$Bug_class)
bugs_file_counts  <- table(df$Bug_class)

df_bars <- data.frame(
  Dataset = rep(c("Class-level", "File-level"), each = 2),
  Bug = rep(c("Sem Bug (0)", "Com Bug (1)"), 2),
  Contagem = c(as.numeric(bugs_class_counts), as.numeric(bugs_file_counts))
)

png(file.path(dir_figuras, "barras_distribuicao_bugs.png"),
    width = 800, height = 500, res = 150)
print(
  ggplot(df_bars, aes(x = Dataset, y = Contagem, fill = Bug)) +
    geom_bar(stat = "identity", position = "dodge", alpha = 0.85) +
    geom_text(aes(label = Contagem), position = position_dodge(0.9),
              vjust = -0.3, size = 3.5) +
    scale_fill_manual(values = c("Sem Bug (0)" = "#2196F3",
                                 "Com Bug (1)" = "#F44336")) +
    labs(title = "Distribuição de Classes de Bug nos Datasets",
         x = "Dataset", y = "Número de Instâncias", fill = "Classe") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
)
dev.off()
cat("  -> barras_distribuicao_bugs.png salvo\n")

# =============================================================================
# 6. AVALIAÇÃO DE OUTLIERS (método IQR)
# =============================================================================
cat("\n=================================================================\n")
cat("6. AVALIAÇÃO DE OUTLIERS (Método IQR)\n")
cat("=================================================================\n\n")

cat("--- Dataset Class-level ---\n")
cat(sprintf("%-18s %10s %10s %10s\n",
            "Variável", "Outliers", "% do total", "Limite Sup"))
cat(paste(rep("-", 52), collapse = ""), "\n")

for (col in num_cols_class) {
  x <- dc[[col]]
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  lower <- Q1 - 1.5 * IQR_val
  upper <- Q3 + 1.5 * IQR_val
  n_outliers <- sum(x < lower | x > upper, na.rm = TRUE)
  pct <- n_outliers / length(x) * 100
  cat(sprintf("%-18s %10d %10.2f%% %10.2f\n", col, n_outliers, pct, upper))
}

cat("\n--- Dataset File-level ---\n")
cat(sprintf("%-35s %10s %10s %10s\n",
            "Variável", "Outliers", "% do total", "Limite Sup"))
cat(paste(rep("-", 69), collapse = ""), "\n")

for (col in num_cols_file) {
  x <- df[[col]]
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  lower <- Q1 - 1.5 * IQR_val
  upper <- Q3 + 1.5 * IQR_val
  n_outliers <- sum(x < lower | x > upper, na.rm = TRUE)
  pct <- n_outliers / length(x) * 100
  cat(sprintf("%-35s %10d %10.2f%% %10.2f\n", col, n_outliers, pct, upper))
}

# =============================================================================
# 7. TESTES DE NORMALIDADE
# =============================================================================
cat("\n=================================================================\n")
cat("7. TESTES DE NORMALIDADE\n")
cat("=================================================================\n\n")

# Shapiro-Wilk (máximo 5000 amostras)
# Kolmogorov-Smirnov (sem limite)

cat("--- Dataset Class-level ---\n")
cat(sprintf("%-18s %12s %12s %12s %12s %10s\n",
            "Variável", "SW Stat", "SW p-valor", "KS Stat", "KS p-valor", "Normal?"))
cat(paste(rep("-", 80), collapse = ""), "\n")

for (col in num_cols_class) {
  x <- dc[[col]]
  # Shapiro-Wilk (amostra de 5000 se necessário)
  n <- length(x)
  if (n > 5000) {
    set.seed(42)
    x_sample <- sample(x, 5000)
  } else {
    x_sample <- x
  }

  sw <- tryCatch(shapiro.test(x_sample), error = function(e) NULL)
  ks <- tryCatch(ks.test(x, "pnorm", mean(x), sd(x)), error = function(e) NULL)

  sw_stat <- ifelse(!is.null(sw), sprintf("%.6f", sw$statistic), "N/A")
  sw_p    <- ifelse(!is.null(sw), sprintf("%.2e", sw$p.value), "N/A")
  ks_stat <- ifelse(!is.null(ks), sprintf("%.6f", ks$statistic), "N/A")
  ks_p    <- ifelse(!is.null(ks), sprintf("%.2e", ks$p.value), "N/A")

  normal <- "Não"
  if (!is.null(sw) && sw$p.value > 0.05) normal <- "Sim"

  cat(sprintf("%-18s %12s %12s %12s %12s %10s\n",
              col, sw_stat, sw_p, ks_stat, ks_p, normal))
}

cat("\n--- Dataset File-level ---\n")
cat(sprintf("%-35s %12s %12s %12s %12s %10s\n",
            "Variável", "SW Stat", "SW p-valor", "KS Stat", "KS p-valor", "Normal?"))
cat(paste(rep("-", 97), collapse = ""), "\n")

for (col in num_cols_file) {
  x <- df[[col]]
  n <- length(x)
  if (n > 5000) {
    set.seed(42)
    x_sample <- sample(x, 5000)
  } else {
    x_sample <- x
  }

  sw <- tryCatch(shapiro.test(x_sample), error = function(e) NULL)
  ks <- tryCatch(ks.test(x, "pnorm", mean(x), sd(x)), error = function(e) NULL)

  sw_stat <- ifelse(!is.null(sw), sprintf("%.6f", sw$statistic), "N/A")
  sw_p    <- ifelse(!is.null(sw), sprintf("%.2e", sw$p.value), "N/A")
  ks_stat <- ifelse(!is.null(ks), sprintf("%.6f", ks$statistic), "N/A")
  ks_p    <- ifelse(!is.null(ks), sprintf("%.2e", ks$p.value), "N/A")

  normal <- "Não"
  if (!is.null(sw) && sw$p.value > 0.05) normal <- "Sim"

  cat(sprintf("%-35s %12s %12s %12s %12s %10s\n",
              col, sw_stat, sw_p, ks_stat, ks_p, normal))
}

# =============================================================================
# 8. COEFICIENTES DE CORRELAÇÃO (chart.Correlation)
# =============================================================================
cat("\n=================================================================\n")
cat("8. COEFICIENTES DE CORRELAÇÃO\n")
cat("=================================================================\n\n")

# --- 8.1 Matriz de correlação (Class-level) ---
cat("  Gerando matriz de correlação (Class-level)...\n")

# Selecionar subconjunto para visualização legível
corr_cols_class <- c("WMC", "CBO", "RFC", "LCOM5", "LOC", "LLOC",
                     "NOS", "NM", "DIT", "NL", "CC", "CD")
corr_cols_class <- corr_cols_class[corr_cols_class %in% names(dc)]

cor_matrix_class <- cor(dc[, corr_cols_class], use = "complete.obs")

# Heatmap com corrplot
png(file.path(dir_figuras, "correlacao_heatmap_class.png"),
    width = 1000, height = 900, res = 150)
corrplot(cor_matrix_class, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45, addCoef.col = "black",
         number.cex = 0.7, cl.cex = 0.8,
         title = "Matriz de Correlação - Class-level",
         mar = c(0, 0, 2, 0))
dev.off()
cat("  -> correlacao_heatmap_class.png salvo\n")

# --- 8.2 chart.Correlation (PerformanceAnalytics) - Class-level ---
cat("  Gerando chart.Correlation (Class-level)...\n")

# Selecionar 6 métricas principais para legibilidade
perf_cols <- c("WMC", "CBO", "RFC", "LOC", "LCOM5", "NOS")
perf_cols <- perf_cols[perf_cols %in% names(dc)]

png(file.path(dir_figuras, "chart_correlation_class.png"),
    width = 1200, height = 1200, res = 150)
chart.Correlation(dc[, perf_cols], histogram = TRUE, pch = 19,
                  method = "pearson")
dev.off()
cat("  -> chart_correlation_class.png salvo\n")

# --- 8.3 Matriz de correlação (File-level) ---
cat("  Gerando matriz de correlação (File-level)...\n")

corr_cols_file <- num_cols_file[num_cols_file != "Number.of.bugs"]
cor_matrix_file <- cor(df[, corr_cols_file], use = "complete.obs")

png(file.path(dir_figuras, "correlacao_heatmap_file.png"),
    width = 900, height = 800, res = 150)
corrplot(cor_matrix_file, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45, addCoef.col = "black",
         number.cex = 0.7, cl.cex = 0.8,
         title = "Matriz de Correlação - File-level",
         mar = c(0, 0, 2, 0))
dev.off()
cat("  -> correlacao_heatmap_file.png salvo\n")

# --- 8.4 chart.Correlation (File-level) ---
cat("  Gerando chart.Correlation (File-level)...\n")

perf_cols_file <- c("McCC", "LLOC", "Number.of.previous.modifications",
                    "Number.of.committers")
perf_cols_file <- perf_cols_file[perf_cols_file %in% names(df)]

png(file.path(dir_figuras, "chart_correlation_file.png"),
    width = 1000, height = 1000, res = 150)
chart.Correlation(df[, perf_cols_file], histogram = TRUE, pch = 19,
                  method = "pearson")
dev.off()
cat("  -> chart_correlation_file.png salvo\n")

# --- 8.5 Interpretação das correlações ---
cat("\n  Interpretação das correlações (Class-level):\n")
for (i in 1:(ncol(cor_matrix_class) - 1)) {
  for (j in (i + 1):ncol(cor_matrix_class)) {
    r <- cor_matrix_class[i, j]
    strength <- if (abs(r) >= 0.7) "FORTE"
                else if (abs(r) >= 0.4) "MODERADA"
                else "FRACA"
    if (abs(r) >= 0.4) {
      cat(sprintf("    %s x %s: r = %.4f [%s]\n",
                  rownames(cor_matrix_class)[i],
                  colnames(cor_matrix_class)[j], r, strength))
    }
  }
}

cat("\n  Interpretação das correlações (File-level):\n")
for (i in 1:(ncol(cor_matrix_file) - 1)) {
  for (j in (i + 1):ncol(cor_matrix_file)) {
    r <- cor_matrix_file[i, j]
    strength <- if (abs(r) >= 0.7) "FORTE"
                else if (abs(r) >= 0.4) "MODERADA"
                else "FRACA"
    if (abs(r) >= 0.3) {
      cat(sprintf("    %s x %s: r = %.4f [%s]\n",
                  rownames(cor_matrix_file)[i],
                  colnames(cor_matrix_file)[j], r, strength))
    }
  }
}

# =============================================================================
# 9. MODELAGEM ESTATÍSTICA - REGRESSÃO LOGÍSTICA
# =============================================================================
cat("\n=================================================================\n")
cat("9. MODELAGEM ESTATÍSTICA - REGRESSÃO LOGÍSTICA\n")
cat("=================================================================\n\n")

# --- 9.1 Regressão Logística (Class-level) ---
cat("--- 9.1 Regressão Logística - Class-level ---\n")
cat("  Variável resposta: Bug_class (0/1)\n")
cat("  Nota: Desbalanceamento severo (99.9% sem bug)\n\n")

# Selecionar preditores
pred_class <- c("WMC", "CBO", "RFC", "LOC", "LCOM5", "NL", "DIT", "CC")
pred_class <- pred_class[pred_class %in% names(dc)]

formula_class <- as.formula(paste("Bug_class ~",
                                  paste(pred_class, collapse = " + ")))

model_class <- glm(formula_class, data = dc, family = binomial(link = "logit"))

cat("  Sumário do modelo:\n")
print(summary(model_class))

cat("\n  Coeficientes (odds ratio):\n")
coefs <- coef(model_class)
or <- exp(coefs)
ci <- tryCatch(exp(confint(model_class)), error = function(e) NULL)
p_vals <- summary(model_class)$coefficients[, "Pr(>|z|)"]

cat(sprintf("  %-15s %12s %12s %12s\n",
            "Variável", "Odds Ratio", "p-valor", "Significância"))
cat(paste(rep("-", 55), collapse = ""), "\n")
for (i in seq_along(coefs)) {
  sig <- if (p_vals[i] < 0.001) "***"
         else if (p_vals[i] < 0.01) "**"
         else if (p_vals[i] < 0.05) "*"
         else if (p_vals[i] < 0.1) "."
         else ""
  cat(sprintf("  %-15s %12.4f %12.4e %12s\n",
              names(coefs)[i], or[i], p_vals[i], sig))
}

# AIC
cat(sprintf("\n  AIC: %.2f\n", AIC(model_class)))

# Pseudo R-squared (McFadden)
null_model <- glm(Bug_class ~ 1, data = dc, family = binomial)
mcfadden <- 1 - (logLik(model_class) / logLik(null_model))
cat(sprintf("  Pseudo R² (McFadden): %.4f\n", mcfadden))

# Predições
prob_class <- predict(model_class, type = "response")
pred_labels <- ifelse(prob_class > 0.5, 1, 0)
conf_matrix_class <- table(Observado = dc$Bug_class, Predito = pred_labels)
cat("\n  Matriz de Confusão:\n")
print(conf_matrix_class)

accuracy <- sum(diag(conf_matrix_class)) / sum(conf_matrix_class)
cat(sprintf("\n  Acurácia: %.4f (%.2f%%)\n", accuracy, accuracy * 100))

# --- 9.2 Regressão Logística (File-level) ---
cat("\n--- 9.2 Regressão Logística - File-level ---\n")
cat("  Variável resposta: Bug_class (0/1)\n\n")

pred_file <- c("McCC", "LLOC",
               "Number.of.previous.modifications",
               "Number.of.previous.fixes",
               "Number.of.committers",
               "Number.of.developer.commits")
pred_file <- pred_file[pred_file %in% names(df)]

formula_file <- as.formula(paste("Bug_class ~",
                                 paste(pred_file, collapse = " + ")))

model_file <- glm(formula_file, data = df, family = binomial(link = "logit"))

cat("  Sumário do modelo:\n")
print(summary(model_file))

cat("\n  Coeficientes (odds ratio):\n")
coefs_f <- coef(model_file)
or_f <- exp(coefs_f)
p_vals_f <- summary(model_file)$coefficients[, "Pr(>|z|)"]

cat(sprintf("  %-40s %12s %12s %12s\n",
            "Variável", "Odds Ratio", "p-valor", "Significância"))
cat(paste(rep("-", 80), collapse = ""), "\n")
for (i in seq_along(coefs_f)) {
  sig <- if (p_vals_f[i] < 0.001) "***"
         else if (p_vals_f[i] < 0.01) "**"
         else if (p_vals_f[i] < 0.05) "*"
         else if (p_vals_f[i] < 0.1) "."
         else ""
  cat(sprintf("  %-40s %12.4f %12.4e %12s\n",
              names(coefs_f)[i], or_f[i], p_vals_f[i], sig))
}

cat(sprintf("\n  AIC: %.2f\n", AIC(model_file)))

null_model_f <- glm(Bug_class ~ 1, data = df, family = binomial)
mcfadden_f <- 1 - (logLik(model_file) / logLik(null_model_f))
cat(sprintf("  Pseudo R² (McFadden): %.4f\n", mcfadden_f))

prob_file_pred <- predict(model_file, type = "response")
pred_labels_f <- ifelse(prob_file_pred > 0.5, 1, 0)
conf_matrix_file <- table(Observado = df$Bug_class, Predito = pred_labels_f)
cat("\n  Matriz de Confusão:\n")
print(conf_matrix_file)

accuracy_f <- sum(diag(conf_matrix_file)) / sum(conf_matrix_file)
cat(sprintf("\n  Acurácia: %.4f (%.2f%%)\n", accuracy_f, accuracy_f * 100))

# =============================================================================
# 10. GRÁFICOS ADICIONAIS
# =============================================================================
cat("\n=================================================================\n")
cat("10. GRÁFICOS ADICIONAIS\n")
cat("=================================================================\n\n")

# --- 10.1 Densidade de WMC e LOC ---
cat("  Gerando gráfico de densidade...\n")

if (all(c("WMC", "LOC") %in% names(dc))) {
  p1 <- ggplot(dc, aes(x = WMC)) +
    geom_density(fill = "#2196F3", alpha = 0.5) +
    labs(title = "Densidade: WMC", x = "WMC", y = "Densidade") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))

  p2 <- ggplot(dc, aes(x = LOC)) +
    geom_density(fill = "#4CAF50", alpha = 0.5) +
    labs(title = "Densidade: LOC", x = "LOC", y = "Densidade") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))

  p3 <- ggplot(dc, aes(x = CBO)) +
    geom_density(fill = "#FF9800", alpha = 0.5) +
    labs(title = "Densidade: CBO", x = "CBO", y = "Densidade") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))

  p4 <- ggplot(dc, aes(x = RFC)) +
    geom_density(fill = "#9C27B0", alpha = 0.5) +
    labs(title = "Densidade: RFC", x = "RFC", y = "Densidade") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))

  png(file.path(dir_figuras, "densidade_metricas_class.png"),
      width = 1200, height = 800, res = 150)
  grid.arrange(p1, p2, p3, p4, ncol = 2)
  dev.off()
  cat("  -> densidade_metricas_class.png salvo\n")
}

# --- 10.2 Boxplot comparativo por Bug_class ---
cat("  Gerando boxplots comparativos por Bug_class...\n")

comp_cols <- c("WMC", "CBO", "RFC", "LOC")
comp_cols <- comp_cols[comp_cols %in% names(dc)]

plots_comp <- list()
for (i in seq_along(comp_cols)) {
  col <- comp_cols[i]
  plots_comp[[i]] <- ggplot(dc, aes_string(x = "Bug_class", y = col,
                                            fill = "Bug_class")) +
    geom_boxplot(alpha = 0.7, outlier.size = 0.5) +
    scale_fill_manual(values = c("0" = "#2196F3", "1" = "#F44336")) +
    labs(title = paste(col, "por Bug_class"), x = "Bug Class", y = col) +
    theme_minimal(base_size = 10) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"),
          legend.position = "none")
}

png(file.path(dir_figuras, "boxplot_comparativo_bugs.png"),
    width = 1200, height = 600, res = 150)
do.call(grid.arrange, c(plots_comp, ncol = 4))
dev.off()
cat("  -> boxplot_comparativo_bugs.png salvo\n")

# =============================================================================
# FIM DA ANÁLISE
# =============================================================================
cat("\n=================================================================\n")
cat("ANÁLISE COMPLETA FINALIZADA\n")
cat(sprintf("Figuras salvas em: %s\n", normalizePath(dir_figuras)))
cat("=================================================================\n")
