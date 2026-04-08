# AP1-Projeto-ES-Neo4j
Análise Estatística de Dados de Código-Fonte do Framework neo4j ao utilizar dataset mais recente do Neo4j para analisar projetos de engenharia de software com dados estatístico no R

## Descrição do Projeto

Este repositório foi criado para armazenar todo o material desenvolvido para a AP1 da disciplina de Engenharia de Software, cujo tema é a **análise estatística de dados de código-fonte de frameworks Java**.

O framework escolhido para este trabalho foi o **neo4j**, e a proposta consiste em realizar uma análise estatística completa utilizando o **dataset mais recente disponível** do projeto, com o objetivo de investigar características estruturais do software, identificar padrões, avaliar relações entre métricas e discutir possíveis associações com defeitos e complexidade do código.

## Objetivo do Trabalho

Este trabalho busca aplicar conceitos de **estatística descritiva e inferencial** sobre métricas extraídas do framework **neo4j**, integrando conhecimentos de **Engenharia de Software** e **Estatística**.

A análise tem como foco:
- compreender o comportamento das métricas numéricas do projeto;
- identificar padrões de distribuição dos dados;
- verificar relações entre variáveis;
- detectar outliers;
- aplicar testes de normalidade;
- ajustar um modelo estatístico para interpretação dos resultados.

## Dataset Utilizado

O dataset utilizado neste trabalho foi obtido a partir do **GitHub Bug Dataset - versão 1.1**.

### Critério de escolha
- framework selecionado: **neo4j**;
- utilização do **dataset mais recente disponível**;
- análise baseada nas métricas de código-fonte presentes no conjunto de dados.

## Atividades Desenvolvidas

A análise estatística realizada neste repositório contempla os seguintes pontos:

### 1. Medidas de Tendência Central
- média;
- mediana;
- moda, quando aplicável.

### 2. Medidas de Dispersão
- amplitude;
- variância;
- desvio padrão.

### 3. Medidas de Posição Relativa
- quartis;
- percentis;
- construção de boxplots para interpretação da distribuição dos dados.

### 4. Visualização Gráfica
Foram produzidos gráficos para apoiar a análise, como:
- histogramas;
- boxplots;
- gráficos de dispersão;
- gráficos de barras;
- outros gráficos relevantes para as variáveis estudadas.

### 5. Identificação de Outliers
- detecção de valores discrepantes com apoio de boxplots;
- discussão sobre possíveis causas técnicas para esses valores.

### 6. Testes de Normalidade
Aplicação de testes estatísticos para verificar se as variáveis seguem distribuição normal, como:
- Shapiro-Wilk;
- Kolmogorov-Smirnov.

### 7. Análise de Correlação
- cálculo de correlação entre variáveis numéricas;
- interpretação de relações fortes, moderadas e fracas;
- uso de recursos gráficos para facilitar a análise.

### 8. Modelagem Estatística
- ajuste de um modelo estatístico;
- interpretação dos coeficientes;
- avaliação do desempenho do modelo.

### 9. Discussão dos Resultados
Nesta etapa são discutidos:
- padrões encontrados nos dados;
- relações entre métricas de software;
- possíveis explicações técnicas;
- limitações da análise realizada.

## Tecnologias e Ferramentas

Este projeto utiliza:
- **R**
- **RStudio**
- **Overleaf**
- **LaTeX**
- **GitHub**

## Estrutura do Repositório

A organização do repositório inclui:

- `dataset/` → dataset selecionado do framework neo4j;
- `scripts/` → scripts em R utilizados nas análises;
- `figuras/` → gráficos e visualizações geradas;
- `artigo/` → arquivos do artigo em LaTeX no padrão SBC;
- `README.md` → descrição geral do projeto.

## Artigo Científico

Como parte da entrega da disciplina, os resultados deste repositório serão organizados em um **artigo científico** com:
- título;
- autores;
- resumo;
- introdução;
- metodologia;
- resultados e discussão;
- conclusão;
- referências.

O artigo foi produzido em **LaTeX**, utilizando o **template oficial da SBC**, com extensão entre **8 e 12 páginas**.

## Autor(es)

- Igor Mariano
- Felipe

