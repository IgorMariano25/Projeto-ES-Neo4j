#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Exploração Inicial dos Datasets Neo4j
======================================
Script de inspeção preliminar dos datasets de métricas de código-fonte
do framework Neo4j (GitHub Bug Dataset v1.1).

Objetivos:
- Verificar estrutura e tipos de dados
- Identificar valores ausentes e anomalias
- Estatísticas descritivas preliminares
- Distribuições preliminares das variáveis
- Justificativa de seleção/exclusão de colunas

Autor: Igor Mariano, Felipe
Data: Abril/2026
"""

import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')

# =============================================================================
# 1. CARREGAMENTO DOS DATASETS
# =============================================================================
print("=" * 80)
print("EXPLORAÇÃO INICIAL DOS DATASETS NEO4J")
print("=" * 80)

# Caminhos dos datasets
path_class = "../dataset/neo4j-Class.csv"
path_file = "../dataset/neo4j-File.csv"

# Carregar datasets
df_class = pd.read_csv(path_class)
df_file = pd.read_csv(path_file)

print(f"\n[Dataset Class-level]")
print(f"  Dimensões: {df_class.shape[0]} instâncias x {df_class.shape[1]} atributos")
print(f"\n[Dataset File-level]")
print(f"  Dimensões: {df_file.shape[0]} instâncias x {df_file.shape[1]} atributos")

# =============================================================================
# 2. ESTRUTURA E TIPOS DE DADOS
# =============================================================================
print("\n" + "=" * 80)
print("2. ESTRUTURA DOS DATASETS")
print("=" * 80)

print("\n--- Dataset Class-level: colunas e tipos ---")
print(df_class.dtypes.to_string())

print("\n--- Dataset File-level: colunas e tipos ---")
print(df_file.dtypes.to_string())

# =============================================================================
# 3. VALORES AUSENTES
# =============================================================================
print("\n" + "=" * 80)
print("3. VALORES AUSENTES")
print("=" * 80)

missing_class = df_class.isnull().sum()
missing_class_pct = (df_class.isnull().sum() / len(df_class) * 100)
if missing_class.sum() > 0:
    print("\n--- Class-level: colunas com valores ausentes ---")
    mask = missing_class > 0
    for col in missing_class[mask].index:
        print(f"  {col}: {missing_class[col]} ({missing_class_pct[col]:.2f}%)")
else:
    print("\n  Dataset Class-level: SEM valores ausentes")

missing_file = df_file.isnull().sum()
missing_file_pct = (df_file.isnull().sum() / len(df_file) * 100)
if missing_file.sum() > 0:
    print("\n--- File-level: colunas com valores ausentes ---")
    mask = missing_file > 0
    for col in missing_file[mask].index:
        print(f"  {col}: {missing_file[col]} ({missing_file_pct[col]:.2f}%)")
else:
    print("\n  Dataset File-level: SEM valores ausentes")

# =============================================================================
# 4. IDENTIFICAÇÃO DE COLUNAS CATEGÓRICAS E IDENTIFICADORES
# =============================================================================
print("\n" + "=" * 80)
print("4. COLUNAS IDENTIFICADORAS (NÃO-NUMÉRICAS)")
print("=" * 80)

id_cols_class = df_class.select_dtypes(include=['object']).columns.tolist()
id_cols_file = df_file.select_dtypes(include=['object']).columns.tolist()

print(f"\n  Class-level identificadores: {id_cols_class}")
print(f"  File-level identificadores:  {id_cols_file}")

# =============================================================================
# 5. VARIÁVEIS NUMÉRICAS - ESTATÍSTICAS DESCRITIVAS PRELIMINARES
# =============================================================================
print("\n" + "=" * 80)
print("5. ESTATÍSTICAS DESCRITIVAS - DATASET CLASS-LEVEL")
print("=" * 80)

num_cols_class = df_class.select_dtypes(include=[np.number]).columns.tolist()
print(f"\n  Total de variáveis numéricas: {len(num_cols_class)}")

desc_class = df_class[num_cols_class].describe().T
desc_class['cv'] = desc_class['std'] / desc_class['mean']  # coeficiente de variação
desc_class['iqr'] = desc_class['75%'] - desc_class['25%']
print("\n  Resumo (primeiras 30 variáveis):")
print(desc_class[['count', 'mean', 'std', 'min', '25%', '50%', '75%', 'max', 'cv', 'iqr']].head(30).to_string())

print("\n" + "=" * 80)
print("5b. ESTATÍSTICAS DESCRITIVAS - DATASET FILE-LEVEL")
print("=" * 80)

num_cols_file = df_file.select_dtypes(include=[np.number]).columns.tolist()
print(f"\n  Total de variáveis numéricas: {len(num_cols_file)}")

desc_file = df_file[num_cols_file].describe().T
desc_file['cv'] = desc_file['std'] / desc_file['mean']
desc_file['iqr'] = desc_file['75%'] - desc_file['25%']
print("\n  Resumo completo:")
print(desc_file[['count', 'mean', 'std', 'min', '25%', '50%', '75%', 'max', 'cv', 'iqr']].to_string())

# =============================================================================
# 6. DETECÇÃO DE COLUNAS COM VARIÂNCIA ZERO OU QUASE ZERO
# =============================================================================
print("\n" + "=" * 80)
print("6. COLUNAS COM VARIÂNCIA ZERO OU QUASE ZERO (Class-level)")
print("=" * 80)

for col in num_cols_class:
    var = df_class[col].var()
    unique_ratio = df_class[col].nunique() / len(df_class)
    zero_pct = (df_class[col] == 0).sum() / len(df_class) * 100
    if var == 0 or unique_ratio < 0.01 or zero_pct > 95:
        print(f"  {col}: var={var:.4f}, valores_unicos={df_class[col].nunique()}, "
              f"zeros={zero_pct:.1f}%")

# =============================================================================
# 7. DISTRIBUIÇÃO DA VARIÁVEL ALVO (Number of bugs / Bug class)
# =============================================================================
print("\n" + "=" * 80)
print("7. DISTRIBUIÇÃO DA VARIÁVEL ALVO")
print("=" * 80)

if 'Number of bugs' in df_class.columns:
    bugs_class = df_class['Number of bugs']
    print(f"\n  Class-level - 'Number of bugs':")
    print(f"    min={bugs_class.min()}, max={bugs_class.max()}, "
          f"mean={bugs_class.mean():.3f}, median={bugs_class.median()}")
    print(f"    Distribuição de valores:")
    vc = bugs_class.value_counts().sort_index()
    for val, cnt in vc.items():
        pct = cnt / len(bugs_class) * 100
        print(f"      bugs={val}: {cnt} ({pct:.2f}%)")
    # Criar variável binária Bug_class
    df_class['Bug_class'] = (df_class['Number of bugs'] > 0).astype(int)
    print(f"\n    Bug_class derivada (0=sem bug, 1=com bug):")
    print(f"      0 (sem bug): {(df_class['Bug_class']==0).sum()} "
          f"({(df_class['Bug_class']==0).mean()*100:.2f}%)")
    print(f"      1 (com bug): {(df_class['Bug_class']==1).sum()} "
          f"({(df_class['Bug_class']==1).mean()*100:.2f}%)")

if 'Number of bugs' in df_file.columns:
    bugs_file = df_file['Number of bugs']
    print(f"\n  File-level - 'Number of bugs':")
    print(f"    min={bugs_file.min()}, max={bugs_file.max()}, "
          f"mean={bugs_file.mean():.3f}, median={bugs_file.median()}")
    print(f"    Distribuição de valores:")
    vc = bugs_file.value_counts().sort_index()
    for val, cnt in vc.items():
        pct = cnt / len(bugs_file) * 100
        print(f"      bugs={val}: {cnt} ({pct:.2f}%)")
    df_file['Bug_class'] = (df_file['Number of bugs'] > 0).astype(int)
    print(f"\n    Bug_class derivada (0=sem bug, 1=com bug):")
    print(f"      0 (sem bug): {(df_file['Bug_class']==0).sum()} "
          f"({(df_file['Bug_class']==0).mean()*100:.2f}%)")
    print(f"      1 (com bug): {(df_file['Bug_class']==1).sum()} "
          f"({(df_file['Bug_class']==1).mean()*100:.2f}%)")

# =============================================================================
# 8. CORRELAÇÃO PRELIMINAR ENTRE VARIÁVEIS CHAVE (Class-level)
# =============================================================================
print("\n" + "=" * 80)
print("8. CORRELAÇÃO PRELIMINAR - VARIÁVEIS CHAVE (Class-level)")
print("=" * 80)

key_metrics_class = ['WMC', 'CBO', 'RFC', 'LCOM5', 'DIT', 'NOC', 'LOC', 'LLOC',
                     'NOS', 'NM', 'NL', 'NLE', 'CC', 'CD', 'CLOC', 'NA',
                     'Number of bugs']

available = [c for c in key_metrics_class if c in df_class.columns]
corr_matrix = df_class[available].corr()

print("\n  Correlações com 'Number of bugs':")
if 'Number of bugs' in available:
    corr_bugs = corr_matrix['Number of bugs'].drop('Number of bugs').sort_values(ascending=False)
    for metric, val in corr_bugs.items():
        strength = "FORTE" if abs(val) > 0.5 else "MODERADA" if abs(val) > 0.3 else "FRACA"
        print(f"    {metric:>8}: r = {val:+.4f}  [{strength}]")

# =============================================================================
# 9. CORRELAÇÃO PRELIMINAR - DATASET FILE-LEVEL
# =============================================================================
print("\n" + "=" * 80)
print("9. CORRELAÇÃO PRELIMINAR - DATASET FILE-LEVEL")
print("=" * 80)

key_metrics_file = ['McCC', 'CLOC', 'LLOC',
                    'Number of previous modifications',
                    'Number of previous fixes',
                    'Number of committers',
                    'Number of developer commits',
                    'Number of bugs']

available_file = [c for c in key_metrics_file if c in df_file.columns]
corr_file = df_file[available_file].corr()

print("\n  Correlações com 'Number of bugs':")
if 'Number of bugs' in available_file:
    corr_bugs_file = corr_file['Number of bugs'].drop('Number of bugs').sort_values(ascending=False)
    for metric, val in corr_bugs_file.items():
        strength = "FORTE" if abs(val) > 0.5 else "MODERADA" if abs(val) > 0.3 else "FRACA"
        print(f"    {metric:>40}: r = {val:+.4f}  [{strength}]")

# =============================================================================
# 10. JUSTIFICATIVA DE SELEÇÃO DE COLUNAS
# =============================================================================
print("\n" + "=" * 80)
print("10. JUSTIFICATIVA DE SELEÇÃO DE COLUNAS - DATASET CLASS-LEVEL")
print("=" * 80)

# Categorias de métricas
selection = {
    # INCLUÍDAS
    'WMC':  ('INCLUÍDA', 'Complexidade ponderada dos métodos - métrica fundamental de complexidade'),
    'CBO':  ('INCLUÍDA', 'Acoplamento entre classes - indicador de dependências'),
    'RFC':  ('INCLUÍDA', 'Resposta para a classe - indicador de complexidade de interação'),
    'LCOM5':('INCLUÍDA', 'Falta de coesão dos métodos - indicador de qualidade do design'),
    'DIT':  ('INCLUÍDA', 'Profundidade na árvore de herança - indicador de complexidade hierárquica'),
    'NOC':  ('INCLUÍDA', 'Número de filhos - indicador de reuso e acoplamento'),
    'LOC':  ('INCLUÍDA', 'Linhas de código - métrica de tamanho fundamental'),
    'LLOC': ('INCLUÍDA', 'Linhas lógicas de código - tamanho efetivo sem linhas em branco'),
    'NOS':  ('INCLUÍDA', 'Número de statements - tamanho funcional'),
    'NM':   ('INCLUÍDA', 'Número de métodos - complexidade estrutural'),
    'NL':   ('INCLUÍDA', 'Nível de aninhamento - indicador de complexidade'),
    'NLE':  ('INCLUÍDA', 'Nível de aninhamento else-if - complexidade de controle'),
    'CC':   ('INCLUÍDA', 'Cobertura de clones - indicador de código duplicado'),
    'CD':   ('INCLUÍDA', 'Densidade de comentários - indicador de documentação'),
    'CLOC': ('INCLUÍDA', 'Linhas de comentário - volume de documentação'),
    'NA':   ('INCLUÍDA', 'Número de atributos - indicador de estado da classe'),
    'Number of bugs': ('INCLUÍDA', 'Variável alvo - número de defeitos associados'),

    # EXCLUÍDAS
    'ID':       ('EXCLUÍDA', 'Identificador único - sem valor estatístico'),
    'Name':     ('EXCLUÍDA', 'Nome da classe - identificador textual'),
    'LongName': ('EXCLUÍDA', 'Nome qualificado - identificador textual'),
    'Parent':   ('EXCLUÍDA', 'Referência ao pai - identificador'),
    'Component':('EXCLUÍDA', 'Componente do projeto - identificador'),
    'Path':     ('EXCLUÍDA', 'Caminho do arquivo - identificador'),
    'Line':     ('EXCLUÍDA', 'Linha inicial - metadado de localização'),
    'Column':   ('EXCLUÍDA', 'Coluna inicial - metadado de localização'),
    'EndLine':  ('EXCLUÍDA', 'Linha final - metadado de localização'),
    'EndColumn':('EXCLUÍDA', 'Coluna final - metadado de localização'),
    'CCL':  ('EXCLUÍDA', 'Redundante com CC - clone classes'),
    'CCO':  ('EXCLUÍDA', 'Redundante com CC - clone complexity'),
    'CI':   ('EXCLUÍDA', 'Redundante com CC - clone instances'),
    'CLC':  ('EXCLUÍDA', 'Redundante com CC - clone line coverage'),
    'CLLC': ('EXCLUÍDA', 'Redundante com CC - clone logical line coverage'),
    'LDC':  ('EXCLUÍDA', 'Redundante com CC - lines of duplicated code'),
    'LLDC': ('EXCLUÍDA', 'Redundante com CC - logical lines of duplicated code'),
    'CBOI': ('EXCLUÍDA', 'Redundante com CBO - acoplamento inverso'),
    'NII':  ('EXCLUÍDA', 'Redundante com CBO/RFC - invocações de entrada'),
    'NOI':  ('EXCLUÍDA', 'Redundante com CBO/RFC - invocações de saída'),
    'AD':   ('EXCLUÍDA', 'Redundante com CD - API documentation'),
    'DLOC': ('EXCLUÍDA', 'Redundante com CLOC - documentation lines'),
    'PDA':  ('EXCLUÍDA', 'Redundante com CD - public documented API'),
    'PUA':  ('EXCLUÍDA', 'Baixa variância - public undocumented API'),
    'TCD':  ('EXCLUÍDA', 'Redundante com CD - total comment density'),
    'TCLOC':('EXCLUÍDA', 'Redundante com CLOC - total comment lines'),
    'NOA':  ('EXCLUÍDA', 'Redundante com DIT - número de ancestrais'),
    'NOD':  ('EXCLUÍDA', 'Redundante com NOC - número de descendentes'),
    'NOP':  ('EXCLUÍDA', 'Redundante com DIT - número de pais'),
}

# Total-prefix metrics (T*) - all excluded
total_metrics = [c for c in num_cols_class if c.startswith('T') and c not in ['TCD', 'TCLOC']]
for t in total_metrics:
    selection[t] = ('EXCLUÍDA', f'Métrica total redundante com versão local')

# PMD rule categories - all excluded individually
pmd_cols = [c for c in df_class.columns if 'Rules' in c]
for p in pmd_cols:
    zero_pct = (df_class[p] == 0).sum() / len(df_class) * 100
    selection[p] = ('EXCLUÍDA', f'Regra PMD individual - {zero_pct:.0f}% zeros; '
                    f'warnings agregados são suficientes')

# Warning columns - keep only aggregate
selection['WarningBlocker'] = ('EXCLUÍDA', 'Pouquíssimos blocker warnings; baixa variância')
selection['WarningCritical'] = ('EXCLUÍDA', 'Baixa variância, maioria zeros')
selection['WarningInfo'] = ('INCLUÍDA', 'Warning mais frequente - bom indicador de qualidade')
selection['WarningMajor'] = ('INCLUÍDA', 'Segundo warning mais frequente')
selection['WarningMinor'] = ('EXCLUÍDA', 'Baixa variância comparado a Info e Major')

# Size metrics redundant
for col in ['NG', 'NLG', 'NLPA', 'NLPM', 'NLS', 'NPA', 'NPM', 'NS', 'NLA', 'NLM']:
    selection[col] = ('EXCLUÍDA', 'Métrica de tamanho granular redundante com NM/NA/LOC')

print("\n  COLUNAS INCLUÍDAS:")
for col, (status, reason) in sorted(selection.items()):
    if status == 'INCLUÍDA':
        print(f"    ✅ {col:>20}: {reason}")

print("\n  COLUNAS EXCLUÍDAS (resumo por categoria):")
excluded_cats = {}
for col, (status, reason) in selection.items():
    if status == 'EXCLUÍDA':
        cat = reason.split(' - ')[0] if ' - ' in reason else reason[:30]
        excluded_cats.setdefault(cat, []).append(col)

for cat, cols in sorted(excluded_cats.items()):
    print(f"    ❌ {cat}: {', '.join(sorted(cols)[:5])}"
          f"{'...' if len(cols) > 5 else ''} ({len(cols)} colunas)")

# =============================================================================
# 11. RESUMO FINAL
# =============================================================================
print("\n" + "=" * 80)
print("11. RESUMO FINAL DA EXPLORAÇÃO")
print("=" * 80)

included_class = [c for c, (s, _) in selection.items() if s == 'INCLUÍDA']
print(f"\n  Class-level:")
print(f"    Total de colunas originais: {df_class.shape[1]}")
print(f"    Colunas selecionadas para análise: {len(included_class)}")
print(f"    Colunas: {', '.join(sorted(included_class))}")
print(f"    Instâncias: {df_class.shape[0]}")
print(f"    Valores ausentes: {df_class[included_class].isnull().sum().sum()}")

file_selected = ['McCC', 'CLOC', 'LLOC',
                 'Number of previous modifications',
                 'Number of previous fixes',
                 'Number of committers',
                 'Number of developer commits',
                 'Number of bugs']
print(f"\n  File-level:")
print(f"    Total de colunas originais: {df_file.shape[1]}")
print(f"    Colunas selecionadas para análise: {len(file_selected)}")
print(f"    Colunas: {', '.join(file_selected)}")
print(f"    Instâncias: {df_file.shape[0]}")
print(f"    Valores ausentes: {df_file[file_selected].isnull().sum().sum()}")

print("\n" + "=" * 80)
print("FIM DA EXPLORAÇÃO INICIAL")
print("=" * 80)
