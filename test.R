# Teste de Requisições para o CEPESPData
# Autor: Rafael de Castro Coelho Silva

rm(list = ls())
library(tidyverse)
source("FUN.R")
colunas_pol <- c("ANO_ELEICAO",
             "NUM_TURNO",
             "DESCRICAO_ELEICAO",
             "SIGLA_UE",
             "DESCRICAO_UE",
             "CODIGO_CARGO",
             "DESCRICAO_CARGO",
             "NOME_CANDIDATO",
             "NUMERO_CANDIDATO","CPF_CANDIDATO",
             "NOME_URNA_CANDIDATO","COD_SITUACAO_CANDIDATURA",
             "DES_SITUACAO_CANDIDATURA","NUMERO_PARTIDO",
             "SIGLA_PARTIDO","NOME_PARTIDO",
             "CODIGO_LEGENDA","SIGLA_LEGENDA",
             "COMPOSICAO_LEGENDA","NOME_LEGENDA",
             "CODIGO_OCUPACAO","DESCRICAO_OCUPACAO",
             "DATA_NASCIMENTO","NUM_TITULO_ELEITORAL_CANDIDATO",
             "IDADE_DATA_ELEICAO","CODIGO_SEXO",
             "DESCRICAO_SEXO","COD_GRAU_INSTRUCAO",
             "DESCRICAO_GRAU_INSTRUCAO","CODIGO_ESTADO_CIVIL","DESCRICAO_ESTADO_CIVIL",
             "CODIGO_COR_RACA","DESCRICAO_COR_RACA",
             "CODIGO_NACIONALIDADE","DESCRICAO_NACIONALIDADE",
             "SIGLA_UF_NASCIMENTO",
             "COD_MUN_TSE_NASCIMENTO",
             "NOME_MUNICIPIO_NASCIMENTO",
             "DESPESA_MAX_CAMPANHA",
             "COD_SIT_TOT_TURNO",
             "DESC_SIT_TOT_TURNO",
             "NM_EMAIL",
             "TIPO_LEGENDA",
             "SIGLA_COLIGACAO",
             "NOME_COLIGACAO",
             "COMPOSICAO_COLIGACAO",
             "QTDE_VOTOS")

colunas_reg <- c("CODIGO_MACRO",
                 "NOME_MACRO",
                 "UF",
                 "NOME_UF")

colunas <- append(colunas_pol, colunas_reg)

log <- test_cepespdata(2014, 6, colunas)

