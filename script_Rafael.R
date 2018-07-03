library(tidyverse)

data <- read_csv2("DATA_Rafael/consulta_vagas_2014_AC.txt", col_names = F, locale = locale(encoding = "ISO-8859-1"))
data2 <- read_csv2("DATA_Rafael/detalhe_votacao_secao_2014_AC.txt", col_names = F, locale = locale(encoding = "ISO-8859-1"))

anos_gerais <- seq(1998,2014, by = 4)

cargo <- 7

banco <- teste_cepespdata(anos_gerais, cargo)

# 1. Teste de Vagas -------------------------------------------------------
for(i in seq_along(anos)){
  lista[[i]] <- lista[[i]] %>% 
    group_by(ANO_ELEICAO, DESCRICAO_ELEICAO, SIGLA_UE, CODIGO_CARGO) %>% 
    summarise(ELEITOS = sum(DESC_SIT_TOT_TURNO %in% c("ELEITO POR MÉDIA", "ELEITO POR QP", "ELEITO"), na.rm = T),
              VOTOS   = sum(QTDE_VOTOS, na.rm = T))
}

lista[[i]]
teste_vagas <- function(lista, vagas){
  anos <- sort(unique(lista[[1]]$ANO_ELEICAO))
  
  
}

# 2. Teste de Votos -------------------------------------------------------

teste_votos <- function(lista, vagas){
  
}

