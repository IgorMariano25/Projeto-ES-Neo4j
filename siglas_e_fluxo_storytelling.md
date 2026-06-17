# Siglas e Fluxo do Projeto em Formato de Storytelling

Este guia foi escrito para apoiar a apresentacao dos slides do artigo **"Analise Estatistica de Metricas de Codigo-Fonte do Framework Neo4j"**. A ideia nao e apenas decorar siglas: e entender quem entra na historia, qual papel cada conceito cumpre e por que o desfecho do trabalho e tao importante.

Fontes usadas no proprio repositorio: `README.md`, `prompt_slides.md`, `CLAUDE.md`, `artigo/main.tex`, `IEEE_artigo/IEEE-conference-template-062824/artigo_neo4j_ieee_claude.tex`, `scripts/analise_final.R`, `scripts/exploracao_inicial.py`, `api_r/api.R` e `api_r/apiR.md`.

---

## 1. A historia em uma frase

Este projeto comeca com uma pergunta aparentemente simples: **as metricas do codigo-fonte do Neo4j conseguem indicar onde ha defeitos?**

Ao longo da analise, as siglas entram como personagens de uma investigacao. Algumas medem tamanho, como `LOC` e `LLOC`. Outras medem complexidade, como `WMC`, `McCC`, `NL` e `NLE`. Outras observam acoplamento, coesao, heranca, documentacao, clones e warnings. Depois chegam as siglas estatisticas, como `IQR`, `VIF`, `EPV`, `ROC`, `AUC`, `AUC-PR`, `CV` e `MCC`, para testar se aquelas pistas realmente sustentam uma predicao confiavel.

O final e contraintuitivo: **as metricas descrevem muito bem a estrutura do Neo4j, mas o dataset nao tem bugs positivos suficientes para sustentar predicao confiavel**. O problema principal nao e a falta de boas metricas; e a falta de eventos positivos: apenas **8 classes com bug** e **6 arquivos com bug**.

> Ponto essencial para os slides: **Neo4j e o objeto de estudo, nao a ferramenta usada na analise**. O projeto nao usa banco de dados em grafo, Cypher, nos ou arestas. A analise e estatistica, feita principalmente em `R`.

---

## 2. O elenco principal: de onde as siglas aparecem

A historia tem quatro camadas:

| Camada | Papel na historia | Siglas principais |
|---|---|---|
| Contexto academico e artefatos | Identifica o trabalho e seus produtos | `IBMEC`, `ES`, `AP1`, `SBC`, `IEEE`, `OO`, `LaTeX`, `BibTeX`, `PDF`, `PNG`, `HTML` |
| Dados e ferramentas | Mostra de onde vieram os dados e como foram manipulados | `CSV`, `ARFF`, `SourceMeter`, `PMD`, `R`, `Python`, `Shiny`, `API`, `UI` |
| Metricas de software | Mede caracteristicas do codigo do Neo4j | `CK`, `WMC`, `CBO`, `RFC`, `LCOM5`, `DIT`, `NOC`, `LOC`, `LLOC`, `NOS`, `NM`, `NA`, `CC`, `McCC` |
| Estatistica e modelagem | Avalia distribuicoes, relacoes e predicao | `IQR`, `SW`, `K-S`, `VIF`, `EPV`, `ROC`, `AUC`, `AUC-PR`, `PR`, `CV`, `LOOCV`, `MCC`, `F1`, `RMSE`, `MAE`, `R2` |

Essas camadas se conectam assim:

```text
Neo4j (codigo Java)
  -> SourceMeter extrai metricas
  -> GitHub Bug Dataset v1.1 publica CSV/ARFF
  -> Python faz exploracao inicial
  -> R executa a analise estatistica completa
  -> PNGs alimentam o artigo e os slides
  -> LaTeX gera artigos SBC/IEEE
  -> Shiny transforma parte da analise em dashboard demonstrativo
```

---

## 3. A primeira cena: o que realmente esta sendo estudado

O personagem central e o **Neo4j**, um sistema real, grande, escrito majoritariamente em Java. Ele foi escolhido porque:

1. E um projeto real e amplamente usado.
2. E orientado a objetos, entao permite aplicar metricas `CK` e outras metricas estruturais.
3. Ja aparece no **GitHub Bug Dataset v1.1**, com metricas e historico de bugs extraidos.

Aqui nasce a primeira relacao importante:

| Termo | O que significa | Relacao no projeto |
|---|---|---|
| `Neo4j` | Software Java analisado | E o objeto da medicao, nao a ferramenta de analise |
| `GitHub Bug Dataset v1.1` | Base publica de metricas e defeitos | Fornece os dados de entrada |
| `SourceMeter` | Ferramenta de analise estatica | Gerou as metricas presentes no dataset |
| `PMD` | Programming Mistake Detector | Origem das categorias de warnings agregadas como `WarningInfo` e `WarningMajor` |
| `CSV` | Comma-Separated Values | Formato principal usado pelos scripts |
| `ARFF` | Attribute-Relation File Format | Formato alternativo do dataset, comum em ferramentas como Weka |

O projeto tem duas granularidades:

| Nivel | Arquivo | Significado | Papel |
|---|---|---|---|
| `Class-level` | `dataset/neo4j-Class.csv` | Uma linha representa uma classe Java | Principal fonte das metricas orientadas a objetos |
| `File-level` | `dataset/neo4j-File.csv` | Uma linha representa um arquivo Java | Fonte menor, com metricas de arquivo e historico |

---

## 4. A variavel-alvo: onde mora o conflito da historia

A variavel que o projeto tenta explicar e **`Number of bugs`**. Ela registra quantos defeitos historicos foram associados a uma classe ou arquivo.

Para modelagem, ela vira uma variavel binaria:

| Valor | Interpretacao |
|---:|---|
| `0` | Sem bug registrado |
| `1` | Com pelo menos um bug registrado |

O conflito aparece nos numeros:

| Dataset | Total de instancias | Positivos | Percentual positivo |
|---|---:|---:|---:|
| `Class-level` | 7.917 classes | 8 classes com bug | 0,10% |
| `File-level` | 4.261 arquivos | 6 arquivos com bug | 0,14% |

Aqui entra uma das siglas mais importantes do artigo:

| Sigla | Nome completo | Explicacao | Relacao com o projeto |
|---|---|---|---|
| `EPV` | Events Per Variable | Eventos por variavel; em geral, positivos divididos pelo numero de preditores | Ficou aproximadamente igual a 1, muito abaixo do minimo recomendado de 10 |

Em linguagem de apresentacao: **temos milhares de linhas no dataset, mas quase nenhum exemplo do fenomeno que queremos prever**. Essa e a raiz de todo o problema preditivo.

---

## 5. A familia CK: as metricas orientadas a objetos

`CK` significa **Chidamber e Kemerer**, autores de uma suite classica de metricas para projeto orientado a objetos. No artigo, as metricas `CK` funcionam como lentes para enxergar a estrutura das classes Java.

| Sigla | Nome completo | Traducao/ideia | Categoria | Relacao com outras siglas |
|---|---|---|---|---|
| `WMC` | Weighted Methods per Class | Metodos ponderados por classe | Complexidade | Cresce junto com `LOC` e `RFC`; foi mantida no modelo |
| `CBO` | Coupling Between Object classes | Acoplamento entre classes/objetos | Acoplamento | Se relaciona fortemente com `RFC`; foi mantida |
| `RFC` | Response For a Class | Conjunto de respostas de uma classe | Acoplamento/resposta | Teve `VIF` alto e foi removida do modelo final Class-level |
| `LCOM5` | Lack of Cohesion in Methods, versao 5 | Falta de coesao entre metodos | Coesao | Mede uma dimensao diferente de tamanho/complexidade |
| `DIT` | Depth of Inheritance Tree | Profundidade da arvore de heranca | Heranca | Teve pouca variabilidade; sugere heranca rasa |
| `NOC` | Number of Children | Numero de classes-filhas | Heranca | Tambem indicou pouca variabilidade no Neo4j |

Relacao narrativa:

```text
CK tenta responder:
  a classe e complexa?       -> WMC
  depende de muitas outras?  -> CBO
  responde a muitas chamadas?-> RFC
  seus metodos sao coesos?   -> LCOM5
  esta profunda na heranca?  -> DIT
  tem muitas subclasses?     -> NOC
```

No projeto, `WMC` e `CBO` sao especialmente importantes porque a literatura costuma trata-las como boas candidatas para predicao de defeitos. Mesmo assim, aqui elas nao conseguiram predizer bugs de modo confiavel, reforcando que o limite esta no dataset.

---

## 6. As metricas de tamanho: o corpo fisico do codigo

As metricas de tamanho contam linhas, comandos, metodos e atributos. Elas sao as siglas que mostram se uma classe e pequena, media ou grande.

| Sigla | Nome completo | Traducao/ideia | Relacao no projeto |
|---|---|---|---|
| `LOC` | Lines of Code | Linhas de codigo | Forte correlacao com `LLOC`, `NOS` e `WMC`; uma das metricas centrais |
| `LLOC` | Logical Lines of Code | Linhas logicas de codigo | Quase colada em `LOC`; `LOC x LLOC = 0,99` |
| `NOS` | Number of Statements | Numero de sentencas/comandos | Forte correlacao com `LOC`; mede tamanho funcional |
| `NM` | Number of Methods | Numero de metodos | Ajuda a explicar estrutura da classe |
| `NA` ou `NA.` | Number of Attributes | Numero de atributos | No R aparece como `NA.` para nao conflitar com `NA` de valor ausente |

Relacao narrativa:

```text
LOC e LLOC medem tamanho.
NOS mede quantidade de comandos.
NM e NA medem estrutura interna.
Quando essas medidas crescem juntas, aparece multicolinearidade.
```

Essa familia explica um dos achados centrais: **tamanho e complexidade se sobrepoem**. Classes maiores tendem a ter maior `WMC`, mais `NOS` e maior resposta (`RFC`).

---

## 7. Complexidade, aninhamento e clones

As siglas abaixo ajudam a mostrar que uma classe pode ser grande, mas tambem pode ser logicamente dificil de entender.

| Sigla | Nome completo | Traducao/ideia | Onde aparece | Relacao |
|---|---|---|---|---|
| `McCC` | McCabe's Cyclomatic Complexity | Complexidade ciclomatica de McCabe | `File-level` | Mede caminhos de decisao no codigo; correlacionou com `LLOC` |
| `NL` | Nesting Level | Nivel de aninhamento | `Class-level` | Mede profundidade de estruturas como `if`, `for`, `while` |
| `NLE` | Nesting Level Else-If | Nivel de aninhamento desconsiderando `else-if` | `Class-level` | Variante de `NL` para controle de fluxo |
| `CC` | Clone Coverage | Cobertura de codigo clonado | `Class-level` | No artigo significa clones, nao complexidade ciclomatica |

Ponto de cautela para sua fala:

> No artigo, `CC` e **Clone Coverage**. A complexidade ciclomatica aparece como `McCC`, no dataset File-level. Isso evita confundir `CC` com "Cyclomatic Complexity".

`CC` teve muitos outliers porque a maioria das classes tem valor zero: quando quase tudo e zero, qualquer valor positivo ja se destaca pelo metodo `IQR`.

---

## 8. Documentacao, warnings e qualidade

Essas siglas olham para comentarios e alertas de qualidade.

| Sigla | Nome completo | Traducao/ideia | Relacao |
|---|---|---|---|
| `CD` | Comment Density | Densidade de comentarios | Proporcao de comentario em relacao ao codigo |
| `CLOC` | Comment Lines of Code | Linhas de comentario | No File-level foi removida porque era constante igual a zero |
| `WarningInfo` | PMD warnings de severidade informativa | Alertas leves agregados | Mantida como indicador agregado de qualidade |
| `WarningMajor` | PMD warnings de severidade maior | Alertas mais relevantes agregados | Mantida como indicador agregado de qualidade |
| `PMD` | Programming Mistake Detector | Ferramenta/conjunto de regras de analise estatica | Origem das categorias de warnings do dataset |

Relacao narrativa:

```text
CD e CLOC perguntam: o codigo esta documentado?
WarningInfo e WarningMajor perguntam: o analisador estatico viu problemas?
PMD e a fonte dessas regras de alerta.
```

No projeto, as 37 categorias granulares de regras `PMD` foram resumidas em `WarningInfo` e `WarningMajor` para reduzir ruido e redundancia.

---

## 9. Siglas que aparecem no CSV, mas nao ficaram no conjunto principal

O dataset original tem muitas colunas alem das selecionadas. Elas foram removidas por tres motivos: eram identificadores, tinham pouca ou nenhuma variabilidade, ou eram redundantes com metricas mais centrais.

### 9.1 Identificadores e metadados

| Sigla/campo | Significado | Por que nao entra como metrica preditiva |
|---|---|---|
| `ID` | Identifier | Identifica a entidade, mas nao mede qualidade |
| `Name` | Nome simples | Texto identificador |
| `LongName` | Nome qualificado | Texto identificador |
| `Parent` | Entidade pai | Metadado estrutural |
| `Component` | Componente do projeto | Metadado |
| `Path` | Caminho do arquivo | Localizacao |
| `Line`, `Column`, `EndLine`, `EndColumn` | Posicoes no arquivo | Localizacao, nao qualidade |

### 9.2 Clones e duplicacao

| Sigla | Nome completo/ideia | Relacao |
|---|---|---|
| `CCL` | Clone Classes | Redundante com a familia de clones |
| `CCO` | Clone Complexity | Complexidade associada a clones |
| `CI` | Clone Instances | Instancias de clones; cuidado: tambem pode significar Continuous Integration em outro contexto |
| `CLC` | Clone Line Coverage | Cobertura de linhas clonadas |
| `CLLC` | Clone Logical Line Coverage | Cobertura de linhas logicas clonadas |
| `LDC` | Lines of Duplicated Code | Linhas de codigo duplicado |
| `LLDC` | Logical Lines of Duplicated Code | Linhas logicas de codigo duplicado |

Essas metricas contam duplicacao em detalhes. O artigo preferiu reter `CC` como representacao mais enxuta de clones.

### 9.3 Acoplamento redundante

| Sigla | Nome completo/ideia | Relacao |
|---|---|---|
| `CBOI` | Coupling Between Object classes Inverse | Acoplamento inverso: classes que dependem desta |
| `NII` | Number of Incoming Invocations | Invocacoes recebidas |
| `NOI` | Number of Outgoing Invocations | Invocacoes feitas para fora |

Essas variaveis foram tratadas como proxies de acoplamento ja capturados por `CBO` e `RFC`.

### 9.4 Documentacao e API

| Sigla | Nome completo/ideia | Relacao |
|---|---|---|
| `AD` | API Documentation | Documentacao de API |
| `DLOC` | Documentation Lines of Code | Linhas de documentacao |
| `PDA` | Public Documented API | API publica documentada |
| `PUA` | Public Undocumented API | API publica nao documentada |
| `TCD` | Total Comment Density | Densidade total de comentarios |
| `TCLOC` | Total Comment Lines of Code | Total de linhas de comentario |

Essas siglas se relacionam com `CD` e `CLOC`. O projeto manteve a leitura mais simples por `CD` e `CLOC`, removendo redundancias.

### 9.5 Heranca

| Sigla | Nome completo/ideia | Relacao |
|---|---|---|
| `NOA` | Number of Ancestors | Numero de ancestrais |
| `NOD` | Number of Descendants | Numero de descendentes |
| `NOP` | Number of Parents | Numero de pais |

Elas complementam `DIT` e `NOC`, mas foram consideradas redundantes ou pouco uteis para o modelo final.

### 9.6 Tamanho granular

| Sigla | Nome completo/ideia | Relacao |
|---|---|---|
| `NG` | Number of Getters | Numero de getters |
| `NLA` | Number of Local Attributes | Atributos locais |
| `NLG` | Number of Local Getters | Getters locais |
| `NLM` | Number of Local Methods | Metodos locais |
| `NLPA` | Number of Local Public Attributes | Atributos publicos locais |
| `NLPM` | Number of Local Public Methods | Metodos publicos locais |
| `NLS` | Number of Local Setters | Setters locais |
| `NPA` | Number of Public Attributes | Atributos publicos |
| `NPM` | Number of Public Methods | Metodos publicos |
| `NS` | Number of Setters | Setters |

Essas metricas detalham a anatomia da classe. Foram removidas porque `LOC`, `LLOC`, `NOS`, `NM` e `NA` ja resumem bem tamanho e estrutura.

### 9.7 Prefixo `T`

No `Class-level`, varias metricas aparecem com prefixo `T`: `TLLOC`, `TLOC`, `TNA`, `TNG`, `TNLA`, `TNLG`, `TNLM`, `TNLPA`, `TNLPM`, `TNLS`, `TNM`, `TNOS`, `TNPA`, `TNPM` e `TNS`.

O `T` indica uma versao **total/agregada**, normalmente incluindo elementos associados a classes internas ou aninhadas. O artigo removeu essas metricas porque elas tinham correlacao acima de 0,99 com suas versoes sem `T`. Em termos de storytelling: elas contavam quase a mesma historia duas vezes.

### 9.8 Categorias PMD com siglas ou nomes tecnicos

O CSV tambem traz categorias granulares de regras `PMD`. A maioria nao virou variavel final porque foi agregada em `WarningInfo` e `WarningMajor`, mas algumas siglas podem aparecer se alguem abrir o dataset:

| Sigla/nome | Significado | Relacao |
|---|---|---|
| `J2EE` | Java 2 Enterprise Edition | Categoria de regras ligada a aplicacoes Java corporativas |
| `JUnit` | Framework de testes para Java | Categoria de regras ligada a testes |
| `JavaBean` | Convencao de componentes Java | Categoria de regras sobre padroes JavaBean |
| `PMD Rules` | Regras do analisador PMD | Fonte original dos warnings |

Em uma apresentacao, voce nao precisa explicar cada regra PMD. Basta dizer que o dataset tinha dezenas de categorias detalhadas de warnings, mas o estudo preferiu os agregados `WarningInfo` e `WarningMajor` para evitar excesso de dimensoes e redundancia.

---

## 10. Siglas estatisticas: os detetives da historia

Depois que as metricas entram, a estatistica decide se elas contam uma historia confiavel.

| Sigla | Nome completo | Ideia | Papel no projeto |
|---|---|---|---|
| `Q1`, `Q2`, `Q3` | Primeiro, segundo e terceiro quartis | Dividem a distribuicao em quatro partes | Mostram posicao relativa; `Q2` e a mediana |
| `P5`, `P10`, `P90`, `P95`, `Pk` | Percentis | Pontos de corte da distribuicao | Mostram caudas e extremos |
| `IQR` | Interquartile Range | Amplitude interquartil: `Q3 - Q1` | Detecta outliers |
| `SW` | Shapiro-Wilk | Teste de normalidade | Rejeitou normalidade para todas as variaveis |
| `K-S` | Kolmogorov-Smirnov | Teste classico de aderencia | Foi discutido como menos adequado quando media e desvio sao estimados |
| `VIF` | Variance Inflation Factor | Fator de inflacao da variancia | Detecta multicolinearidade entre preditores |
| `EPV` | Events Per Variable | Eventos positivos por variavel | Mostrou que ha positivos demais de menos para modelagem confiavel |

Relacao narrativa:

```text
Quartis e IQR mostram a forma dos dados.
SW e Lilliefors mostram que as distribuicoes nao sao normais.
Pearson e Spearman mostram relacoes entre metricas.
VIF mostra quando metricas diferentes contam quase a mesma coisa.
EPV mostra se existem bugs suficientes para treinar um modelo.
```

No artigo, o `IQR` mostrou muitos outliers superiores. Eles nao foram removidos, porque representam classes legitimamente complexas. O `VIF` mostrou problema em `RFC`, `WMC` e `LOC`; depois da remocao de `RFC`, os valores ficaram abaixo do limiar severo.

---

## 11. Correlacao e multicolinearidade: quando as pistas se repetem

As siglas de correlacao aparecem para responder: **duas metricas estao contando a mesma historia?**

| Termo | Significado | Papel |
|---|---|---|
| `Pearson` | Correlacao linear | Usada para medir associacao linear |
| `Spearman` | Correlacao por postos | Mais robusta para dados assimetricos e com outliers |
| `r` | Coeficiente de Pearson | Mede intensidade e direcao da associacao linear |
| `rho` | Coeficiente de Spearman | Mede associacao monotonica por ranking |

Principais relacoes encontradas:

| Relacao | Valor | Interpretacao |
|---|---:|---|
| `LOC x LLOC` | 0,99 | Linhas totais e linhas logicas contam quase a mesma coisa |
| `LOC x NOS` | 0,95 | Classes maiores tendem a ter mais comandos |
| `WMC x LOC` | 0,89 | Classes maiores tendem a ser mais complexas |
| `WMC x RFC` | 0,82 | Complexidade interna se relaciona com resposta da classe |
| `CBO x RFC` | 0,80 | Acoplamento se relaciona com numero de respostas/chamadas |

E aqui entra o `VIF`:

| Variavel | `VIF` antes | Decisao |
|---|---:|---|
| `RFC` | 20,18 | Removida |
| `WMC` | 15,17 | Mantida apos remover `RFC` |
| `LOC` | 10,98 | Mantida apos reduzir multicolinearidade |

Em linguagem de slide: **o projeto descobriu que varias metricas sao boas para descrever o codigo, mas algumas sao tao parecidas entre si que atrapalham o modelo se entrarem juntas**.

---

## 12. Modelagem e avaliacao: quando a historia encontra seu limite

Depois da estatistica descritiva, o projeto tenta modelar a presenca de bugs.

| Sigla/termo | Nome completo | Papel |
|---|---|---|
| `GLM` | Generalized Linear Model | Base da regressao logistica usada em R |
| `AIC` | Akaike Information Criterion | Indicador de ajuste/parcimonia do modelo |
| `R2` ou `R²` | Coeficiente de determinacao | Mede ajuste em regressao; no artigo aparece tambem como pseudo `R2` de McFadden |
| `OR` | Odds Ratio | Razao de chances; interpretacao de coeficientes logisticos |
| `TP` | True Positive | Positivo verdadeiro |
| `TN` | True Negative | Negativo verdadeiro |
| `FP` | False Positive | Falso positivo |
| `FN` | False Negative | Falso negativo |
| `ROC` | Receiver Operating Characteristic | Curva de sensibilidade versus falso positivo |
| `PR` | Precision-Recall | Curva precisao-revocacao |
| `AUC` | Area Under the Curve | Area sob uma curva de avaliacao |
| `AUC-ROC` | Area sob a curva ROC | Avalia separacao geral entre classes |
| `AUC-PR` | Area sob a curva Precision-Recall | Mais informativa quando positivos sao raros |
| `CV` | Cross-Validation | Validacao cruzada |
| `LOOCV` | Leave-One-Out Cross-Validation | Validacao deixando uma instancia fora por vez; o script comenta esse conceito, mas usa 10-fold estratificada como aproximacao viavel |
| `MCC` | Matthews Correlation Coefficient | Metrica robusta para classificacao desbalanceada |
| `F1` ou `F1-score` | Media harmonica entre precisao e revocacao | Resume equilibrio entre encontrar positivos e ser preciso |
| `Bal. Acc.` | Balanced Accuracy | Media entre sensibilidade e especificidade |

Relacao narrativa:

```text
EPV baixo -> regressao instavel
Regressao instavel -> nao convergencia
Nao convergencia -> metricas de treino ficam suspeitas
CV entra para testar generalizacao
MCC e AUC-PR revelam o problema real
```

O resultado principal:

| Nivel | Sinal observado |
|---|---|
| `Class-level` | Modelo nao convergiu; coeficientes enormes; pseudo `R2` de McFadden = -10,76 |
| `File-level` | Pseudo `R2` de McFadden = 0,59, mas tambem sem convergencia confiavel |
| `CV` | `MCC` proximo de zero: 0,023 no Class-level e 0,068 no File-level |
| `AUC-PR` | Muito baixa: 0,007 e 0,020 |

Em fala de apresentacao: **a acuracia alta engana, porque quase tudo e "sem bug". Um modelo que sempre diz "sem bug" ja parece acertar muito. Por isso o artigo confia mais em `MCC`, `AUC-PR`, precisao, `F1` e validacao cruzada.**

---

## 13. Dashboard Shiny: uma demonstracao, nao a conclusao cientifica

O projeto tambem tem um dashboard em `api_r/api.R`.

| Sigla | Nome completo/ideia | Papel no dashboard |
|---|---|---|
| `API` | Application Programming Interface | Nome da pasta/arquivo do app, embora aqui seja uma aplicacao Shiny interativa |
| `UI` | User Interface | Parte visual do Shiny |
| `KPI` | Key Performance Indicator | Cartoes de indicadores na aba Visao Geral |
| `RF` | Random Forest | Modelo usado no dashboard para previsoes demonstrativas |
| `RMSE` | Root Mean Squared Error | Erro quadratico medio raiz para previsao de `WMC` |
| `MAE` | Mean Absolute Error | Erro absoluto medio |
| `R2` | Coeficiente de determinacao | Indicador de ajuste do modelo de regressao de `WMC` |
| `%IncMSE` | Percent Increase in Mean Squared Error | Importancia de variaveis no Random Forest |
| `DT` | DataTables | Tabela interativa usada no Shiny |
| `AUC` | Area Under the Curve | Indicador exibido para classificacao de bugs |

O dashboard executa este fluxo:

```text
CSV Class-level
  -> limpeza numerica
  -> split 80/20 com seed=42
  -> Random Forest para prever WMC
  -> Random Forest para prever presenca de bug
  -> abas interativas com graficos, ROC, importancia e tabela
```

Mas a leitura correta e esta: **o dashboard e exploratorio e demonstrativo**. Ele nao invalida a conclusao do artigo. Como o proprio projeto alerta, as probabilidades de bug devem ser vistas como referencia relativa, nao como diagnostico confiavel.

---

## 14. Siglas de ferramentas, formatos e publicacao

| Sigla/termo | Significado | Papel no projeto |
|---|---|---|
| `IBMEC` | Instituicao do trabalho | Contexto academico |
| `ES` | Engenharia de Software | Curso/area do projeto |
| `AP1` | Primeira avaliacao/entrega academica | Contexto da apresentacao |
| `OO` | Orientado a Objetos / Object-Oriented | Paradigma das metricas `CK` aplicadas ao codigo Java |
| `SBC` | Sociedade Brasileira de Computacao | Template anterior do artigo em `artigo/main.tex` |
| `IEEE` | Institute of Electrical and Electronics Engineers | Template mais recente do artigo |
| `IEEEtran` | Classe LaTeX da IEEE | Arquivo `IEEEtran.cls` usado no artigo IEEE |
| `LaTeX` | Sistema de preparacao de documentos | Gera os artigos cientificos |
| `BibTeX` | Sistema de bibliografia para LaTeX | Resolve referencias do artigo SBC |
| `PDF` | Portable Document Format | Saida compilada dos artigos |
| `PNG` | Portable Network Graphics | Formato das figuras geradas em `figuras/` |
| `HTML` | HyperText Markup Language | Formato pedido no prompt de slides |
| `URL` | Uniform Resource Locator | Links do repositorio e dashboard |
| `UTF-8` | Unicode Transformation Format 8-bit | Codificacao dos arquivos com acentos |
| `DCF` | Debian Control File / formato de metadados usado pelo `rsconnect` | Aparece em metadados de deploy do Shiny |
| `CI` | Continuous Integration | Em `CLAUDE.md`, aparece no sentido de pipeline automatizado; o projeto nao tem CI |
| `PT`, `EN`, `pt-BR` | Portugues, English e Portugues do Brasil | Idiomas/locale mencionados nos documentos do projeto |

### 14.1 Siglas de referencias e eventos academicos

Algumas siglas aparecem nas referencias bibliograficas ou no contexto dos artigos citados:

| Sigla | Significado | Onde entra na historia |
|---|---|---|
| `ICCSA` | International Conference on Computational Science and Applications | Evento em que o GitHub Bug Dataset foi publicado/citado |
| `ICSE` | International Conference on Software Engineering | Evento citado em trabalhos sobre predicao de falhas |
| `TSE` | IEEE Transactions on Software Engineering | Periodico classico de Engenharia de Software citado no artigo |
| `JASA` | Journal of the American Statistical Association | Periodico associado ao teste de Lilliefors |
| `SCAM` | Source Code Analysis and Manipulation | Conferencia ligada a ferramentas de analise de codigo, citada em contexto de SourceMeter/SonarQube |

---

## 15. O fluxo completo do projeto

Esta e a linha do tempo que voce pode narrar nos slides:

```text
1. Escolha do objeto
   Neo4j, um projeto Java real e grande.

2. Fonte dos dados
   GitHub Bug Dataset v1.1, com metricas extraidas por SourceMeter.

3. Entrada no repositorio
   dataset/neo4j-Class.csv
   dataset/neo4j-File.csv
   dataset/*.arff

4. Exploracao inicial
   scripts/exploracao_inicial.py
   Verifica colunas, tipos, ausentes, variancia, distribuicao de bugs.

5. Analise estatistica principal
   scripts/analise_final.R
   Carrega CSVs, seleciona variaveis e executa estatistica completa.

6. Selecao de variaveis
   Remove identificadores, constantes e redundancias.
   Mantem 19 variaveis Class-level e 7 File-level.

7. Estatistica descritiva
   Media, mediana, moda, amplitude, variancia, desvio padrao, quartis e percentis.

8. Visualizacoes
   Histogramas, boxplots, dispersoes, densidades, heatmaps, curvas ROC/PR.

9. Outliers
   Metodo IQR identifica caudas longas; outliers nao sao removidos.

10. Normalidade
    Shapiro-Wilk e Lilliefors rejeitam normalidade em todas as variaveis.

11. Correlacao
    Pearson e Spearman mostram relacoes fortes entre tamanho e complexidade.

12. Multicolinearidade
    VIF detecta redundancia; RFC e removida do modelo Class-level.

13. Modelagem
    Regressao logistica cost-sensitive tenta lidar com o desbalanceamento.

14. Validacao
    10-fold CV estratificada testa generalizacao.

15. Interpretacao
    MCC perto de zero, AUC-PR baixa e nao convergencia indicam predicao nao confiavel.

16. Saidas
    figuras/*.png
    artigo/main.tex
    IEEE_artigo/.../artigo_neo4j_ieee_claude.tex
    README.md
    prompt_slides.md
    api_r/api.R
```

---

## 16. Como contar isso nos slides

Uma forma natural de apresentar:

> "Eu comecei analisando um sistema real, o Neo4j. Mas aqui o Neo4j nao e uma ferramenta usada; ele e o codigo que eu medi. Essas medicoes vieram do GitHub Bug Dataset, geradas pelo SourceMeter. A partir dai, eu organizei as metricas em familias: tamanho, complexidade, acoplamento, coesao, heranca, documentacao, clones e warnings."

Depois:

> "A primeira descoberta foi que as metricas contam uma historia bem tipica de software real: muitas classes pequenas e poucas muito grandes. Isso aparece em `LOC`, `LLOC`, `NOS`, `WMC` e `RFC`, com medias maiores que medianas, muitos outliers e distribuicoes nao normais."

Em seguida:

> "Quando eu analisei correlacao, percebi que tamanho e complexidade caminham juntos: `LOC x LLOC = 0,99`, `LOC x NOS = 0,95` e `WMC x LOC = 0,89`. O `VIF` confirmou que algumas variaveis eram redundantes, especialmente `RFC`, que precisou sair do modelo Class-level."

O climax:

> "So que a variavel mais importante, `Number of bugs`, quase nao aparece. Sao apenas 8 classes com bug entre 7.917, e 6 arquivos com bug entre 4.261. Isso gera `EPV` perto de 1, quando a recomendacao minima e 10. O modelo tenta compensar com pesos cost-sensitive, mas nao consegue criar evidencia onde quase nao existe exemplo positivo."

O fechamento:

> "Por isso a conclusao nao e que as metricas sao ruins. Pelo contrario: elas descrevem muito bem o codigo. A conclusao e que este recorte do dataset do Neo4j e inadequado para predicao confiavel de defeitos. O limite esta nos dados, nao nas metricas."

---

## 17. Mapa de relacoes entre as siglas mais importantes

```text
CK
  -> WMC, CBO, RFC, LCOM5, DIT, NOC
  -> mede projeto orientado a objetos

Tamanho
  -> LOC, LLOC, NOS, NM, NA
  -> se relaciona fortemente com WMC e RFC

Complexidade
  -> WMC, McCC, NL, NLE
  -> cresce junto com tamanho

Acoplamento
  -> CBO, RFC, CBOI, NII, NOI
  -> CBO e RFC sao fortemente correlacionadas

Documentacao e qualidade
  -> CD, CLOC, WarningInfo, WarningMajor, PMD
  -> ajudam a caracterizar codigo, mas nao salvaram a predicao

Forma das distribuicoes
  -> Q1, Q2, Q3, P95, IQR, SW, K-S, Lilliefors
  -> mostram assimetria, outliers e nao-normalidade

Redundancia estatistica
  -> Pearson, Spearman, VIF
  -> justifica remover RFC no Class-level

Predicao
  -> GLM, ROC, AUC, AUC-PR, CV, MCC, F1
  -> revela que o desempenho real e fraco

Problema central
  -> EPV
  -> poucos bugs positivos por variavel
  -> modelo nao converge
  -> MCC proximo de zero
```

---

## 18. Resumo final para memorizar

Se voce precisar resumir todas as siglas em uma unica narrativa:

> `CK`, `LOC`, `LLOC`, `WMC`, `CBO`, `RFC`, `LCOM5`, `DIT`, `NOC`, `McCC`, `NL`, `NLE`, `CD`, `CLOC`, `CC` e `PMD` medem o codigo. `IQR`, `SW`, `K-S`, Pearson, Spearman e `VIF` testam a forma e as relacoes dessas medidas. `EPV` mostra se ha bugs suficientes para modelar. `ROC`, `AUC`, `AUC-PR`, `CV`, `MCC` e `F1` avaliam a predicao. No projeto, as primeiras siglas revelam uma estrutura de codigo rica; as ultimas mostram que a predicao falha porque a classe positiva quase nao existe.

Essa e a mensagem que deve guiar seus slides: **o trabalho nao vende um modelo milagroso; ele demonstra maturidade estatistica ao reconhecer quando os dados nao sustentam a conclusao que gostariamos de tirar.**
