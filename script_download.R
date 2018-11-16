rm(list = ls())

# Pacotes
library(tidyverse)
library(rvest)

# Diretórios
dir.create("raw_data_secao")
dir.create("raw_data_vagas")
dir.create("data_secao")
dir.create("data_vagas")

# 1. Loop para Download ---------------------------------------------------

## 1.1. Download dos arquivos do TSE sobre secao_eleitoral ------------

url_secao <- "http://agencia.tse.jus.br/estatistica/sead/odsele/detalhe_votacao_secao/detalhe_votacao_secao_ANO.zip" 

anos <- seq(1998,2014, by= 4)

for(i in seq(anos)){
  url_uso <- stringr::str_replace(url_secao, "ANO", as.character(anos[[i]])) 
  cat(url_uso,"\n")
  download.file(url_uso, str_c("raw_data_secao/arquivo_secao", anos[[i]], ".zip"))
}

## 1.2. Download dos arquivos do TSE sobre vagas ----------------------

url_vagas <- "http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_vagas/consulta_vagas_ANO.zip"

for(i in seq(anos)){
  url_uso <- stringr::str_replace(url_vagas, "ANO", as.character(anos[[i]]))
  cat(url_uso,"\n")
  download.file(url_uso, str_c("raw_data_vagas/arquivo_vagas", anos[[i]] ,".zip"))
}

# 2. Unzip dos arquivos ---------------------------------------------------

## 2.1.Dados_secao_eleitoral ----------------------------------------------

##cria uma lista com os arquivos com nomes correspondentes a "arquivo_secao"
list_sec <- list.files(path = "raw_data_secao", pattern = "arquivo_secao", full.names = T)

for(i in seq_along(list_sec)){
  ##loop para unzipar todos os arquivos contidos dentro da lista 
  unzip(list_sec[i], exdir = "data_secao")
} 

##remove os arquivos com sigla "BR" da pasta criada anteriormente
br_files_secao <- list.files(path = "data_secao", pattern = "BR",full.names = T)
file.remove(br_files_secao)

## 2.2.Dados_vagas --------------------------------------------------------

##cria uma lista com os arquivos com nomes correspondentes a "arquivo_vagas"  
list_vag <- list.files(path = "raw_data_vagas", pattern = "arquivo_vagas", full.names = T)

for(i in seq_along(list_vag)){ 
  ##loop para unzipar todos os arquivos contidos dentro da lista
  unzip(list_vag[i], exdir = "data_vagas") 
} 

# 3. Empilhando os arquivos -----------------------------------------------

## 3.1. Dados_secao_eleitoral ----------------------------------------------

##cria uma lista com todos os arquivos ".txt" da pasta "all_files_secao"
arq_secs <- list.files(path = "data_secao/", pattern = ".txt", full.names = T)

secao_ls <- vector(mode = "list", length = length(arq_secs))

for (i in seq_along(arq_secs)) {
  cat("lendo", arq_secs[i], "\n")
  secao_ls[[i]] <- readr::read_delim(file = arq_secs[i], col_names = F, delim = ";", locale = readr::locale(encoding = "ISO-8859-1"))
  cat(ncol(secao_ls[[i]]), "\n")
}

### 3.1.1 Problemas na variável 7 do banco da seção eleitoral ----------------

for(i in seq_along(secao_ls)){
  var7 <- secao_ls[[i]][["X7"]]
  if(!is.character(var7)){
    cat("Na posição ", i, ", X7 é ",typeof(var7),"\n", sep = "")
  }
}

for(i in seq_along(secao_ls)){
  var8 <- secao_ls[[i]][["X8"]]
  if(!is.character(var8)){
    cat("Na posição ", i, ", X8 é ",typeof(var8),"\n", sep = "")
  }
}

# Substituição de X7 pela X6 nos casos com problemas
# já que SIGLA_UE deveria ser a unidade federativa nesses casos.

secao_ls <- purrr::map(secao_ls, dplyr::mutate, X7 = X6)
secao_ls <- purrr::map(secao_ls, purrr::modify_at, .at = "X8", as.character)

secao_df <- dplyr::bind_rows(secao_ls)

## 3.2.Dados_vagas ---------------------------------------------------------

arq_vagas <- list.files(path = "data_vagas", pattern = ".txt", full.names = T)

vagas_ls <- vector(mode = "list", length = length(arq_vagas))

for (i in seq_along(arq_vagas)){
  cat("lendo", arq_vagas[i], "\n")
  vagas_ls[[i]] <- readr::read_delim(file = arq_vagas[i], col_names = F, delim = ";")
}

vagas_df <- dplyr::bind_rows(vagas_ls)

rm(secao_ls, vagas_ls)

# 4. Renomeando as variaveis ----------------------------------------------

## 4.1. Renomeia as variaveis dos dados_secao_eleitoral--------------------

names(secao_df)<- c("DATA_GERACAO", "HORA_GERACAO", "ANO_ELEICAO", "NUM_TURNO", "DESCRICAO_ELEICAO",
                    "SIGLA_UF", "SIGLA_UE", "CODIGO_MUNICIPIO", "NOME_MUNICIPIO","NUM_ZONA",
                    "NUM_SECAO", "CODIGO_CARGO", "DESCRICAO_CARGO", "QTD_APTOS", "QTD_COMPARECIMENTO", "QTD_ABSTENCOES", 
                    "QT_VOTOS_NOMINAIS", "QT_VOTOS_BRANCOS", "QT_VOTOS_NULOS", "QT_VOTOS_LEGENDA", "QT_VOTOS_ANULADOS_APU_SEP")

### 4.2.Renomeia as variaveis dos dados_vagas -------------------------------

names(vagas_df) <- c("DATA_GERACAO", "HORA_GERACAO", "ANO_ELEICAO","DESCRICAO_ELEICAO", "SIGLA_UF",
                     "SIGLA_UE", "NOME_UE", "CODIGO_CARGO", "DESCRICAO_CARGO", "QTDE_VAGAS")

# 5. Observação do Presidente ---------------------------------------------

## 5.1. Dados Secao

molde_secao <- secao_df %>% 
  dplyr::group_by(ANO_ELEICAO, NUM_TURNO, SIGLA_UE, DESCRICAO_CARGO) %>% 
  dplyr::summarise(APTOS          = sum(QTD_APTOS),
                   COMPARECIMENTO = sum(QTD_COMPARECIMENTO)) %>% 
  dplyr::mutate(APTOS          = ifelse(ANO_ELEICAO %in% seq(2010, 1998, by = -8) & DESCRICAO_CARGO == "SENADOR",
                                        APTOS * 2,
                                        APTOS),
                COMPARECIMENTO = ifelse(ANO_ELEICAO %in% seq(2010, 1998, by = -8) & DESCRICAO_CARGO == "SENADOR",
                                        COMPARECIMENTO * 2,
                                        COMPARECIMENTO)) %>% 
  dplyr::ungroup()

molde_secao_presidente1 <- molde_secao %>% 
  dplyr::filter(NUM_TURNO == 1,
                DESCRICAO_CARGO == "GOVERNADOR") %>% 
  dplyr::mutate(DESCRICAO_CARGO = "PRESIDENTE")

molde_secao_presidente2 <- molde_secao %>% 
  dplyr::filter(NUM_TURNO == 1,
                DESCRICAO_CARGO == "GOVERNADOR") %>% 
  dplyr::mutate(DESCRICAO_CARGO = "PRESIDENTE",
                NUM_TURNO       = 2)

molde_secao_presidente3 <- molde_secao_presidente1%>% 
  dplyr::group_by(ANO_ELEICAO, NUM_TURNO, DESCRICAO_CARGO) %>% 
  dplyr::summarise(APTOS          = sum(APTOS),
                   COMPARECIMENTO = sum(COMPARECIMENTO)) %>% 
  dplyr::mutate(SIGLA_UE = "BR")

molde_secao_presidente4 <- molde_secao_presidente1%>% 
  dplyr::group_by(ANO_ELEICAO, NUM_TURNO, DESCRICAO_CARGO) %>% 
  dplyr::summarise(APTOS          = sum(APTOS),
                   COMPARECIMENTO = sum(COMPARECIMENTO)) %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(SIGLA_UE  = "BR",
                NUM_TURNO = 2)

molde_secao <- dplyr::bind_rows(molde_secao, 
                                molde_secao_presidente1,
                                molde_secao_presidente2,
                                molde_secao_presidente3,
                                molde_secao_presidente4)

molde_secao <- molde_secao %>% 
  dplyr::filter(!(SIGLA_UE %in% c("VT", "ZZ")))

## 5.2. Dados Vagas

molde_vagas <- vagas_df %>% 
  dplyr::mutate(DESCRICAO_CARGO = stringr::str_to_upper(DESCRICAO_CARGO)) %>% 
  filter(DESCRICAO_CARGO %in% c("DEPUTADO DISTRITAL",
                                "DEPUTADO ESTADUAL",
                                "DEPUTADO FEDERAL",
                                "GOVERNADOR",
                                "SENADOR")) %>% 
  dplyr::select(ANO_ELEICAO, SIGLA_UE, DESCRICAO_CARGO, QTDE_VAGAS) %>% 
  dplyr::mutate(DESCRICAO_CARGO = stringr::str_to_upper(DESCRICAO_CARGO))

molde_vagas_presidente <- tibble::tribble(
  ~ANO_ELEICAO, ~SIGLA_UE, ~DESCRICAO_CARGO, ~QTDE_VAGAS,
  1998        , "BR"     , "PRESIDENTE"    , 1,
  2002        , "BR"     , "PRESIDENTE"    , 1,
  2006        , "BR"     , "PRESIDENTE"    , 1,
  2010        , "BR"     , "PRESIDENTE"    , 1,
  2014        , "BR"     , "PRESIDENTE"    , 1
)

molde_vagas <- dplyr::bind_rows(molde_vagas, molde_vagas_presidente)

# 6. Salvando Arquivos ----------------------------------------------------

readr::write_csv(molde_secao, "molde_secao.csv")

readr::write_csv(molde_vagas, "molde_vagas.csv")
