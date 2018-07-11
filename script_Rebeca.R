library(dplyr)
library(rvest)
library(stringr)
library(readr)
library(tidyverse)


url_secao <- "http://agencia.tse.jus.br/estatistica/sead/odsele/detalhe_votacao_secao/detalhe_votacao_secao_2016.zip"


url_vagas <- "http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_vagas/consulta_vagas_1998.zip"


# 1. Loop para Download ---------------------------------------------------


## 1.1.Faz o download dos arquivos do TSE sobre secao_eleitoral ------------


url_secao <- "http://agencia.tse.jus.br/estatistica/sead/odsele/detalhe_votacao_secao/detalhe_votacao_secao_ANO.zip" 
for(i in seq(1998,2014, by= 4)){
  url_secao1 <- stringr::str_replace(url_secao, "ANO", as.character(i)) 
  print(url_secao1)
  download.file(url_secao1, str_c("arquivo_secao", i, ".zip"))
}


## 1.2.Faz o download dos arquivos do TSE sobre vagas ----------------------


url_vagas <- "http://agencia.tse.jus.br/estatistica/sead/odsele/consulta_vagas/consulta_vagas_ANO.zip"
for(i in seq(1998,2014, by= 4)){
  url_vagas1 <- stringr::str_replace(url_vagas, "ANO", as.character(i))
  print(url_vagas1)
  download.file(url_vagas1, str_c("arquivo_vagas", i ,".zip"))
}


# 2. Unzip dos arquivos ---------------------------------------------------

## 2.1.Dados_secao_eleitoral ----------------------------------------------


dir.create("all_files_secao")##cria uma pasta vazia 

list_sec <- list.files(pattern = "arquivo_secao")##cria uma lista com os arquivos com nomes correspondentes a "arquivo_secao" 

for(i in seq_along(list_sec)){ 
  unzip(list_sec[i], exdir = "all_files_secao")##loop para unzipar todos os arquivos contidos dentro da lista 
} 

for(i in seq_along(all_files_secao)){
  br_files_secao <- list.files(path = "all_files_secao", pattern = "BR",full.names = T)##remove os arquivos com sigla "BR" da pasta criada anteriormente
  file.remove(br_files_secao)
}


## 2.2.Dados_vagas --------------------------------------------------------


dir.create("all_files_vagas")##cria uma pasta vazia

list_vag <- list.files(pattern = "arquivo_vagas")##cria uma lista com os arquivos com nomes correspondentes a "arquivo_vagas"  

for(i in seq_along(list_vag)){ 
  unzip(list_vag [i], exdir = "all_files_vagas") ##loop para unzipar todos os arquivos contidos dentro da lista
} 

for(i in seq_along(all_file)){
  br_files_vagas <- list.files(path = "all_files_vagas", pattern = "BR",full.names = T)##remove os arquivos com sigla "BR" da pasta criada anteriormente
  file.remove(br_files_vagas)
}

# 3. Empilhando os arquivos -----------------------------------------------

## 3.1. Dados_secao_eleitoral ----------------------------------------------

arq_secs <- list.files(path = "all_files_secao", pattern = ".txt")##cria uma lista com todos os arquivos ".txt" da pasta "all_files_secao"

arq_secs_teste <- list()

for (i in seq_along(arq_secs)) {
  cat("lendo", arq_secs[i], "\n")
  arq_secs_teste[[i]] <- read.table(file = paste0("all_files_secao/",arq_secs[i]),header=F,sep=";", stringsAsFactors = FALSE)##loop para
  cat(ncol(arq_secs_teste[[i]]), "\n")
}


### 3.1.1 Problemas na variável 7 do banco da seção eleitoral ----------------


for(i in seq_along(arq_secs_teste)){
  var7 <- arq_secs_teste[[i]][["V7"]]
  if(!is.character(var7)){
    cat("na posição ", i, "V7 é",typeof(var7),"\n")
  }
}

for(i in seq_along(arq_secs_teste)){
  arq_secs_teste[[i]][["V7"]] <- arq_secs_teste[[i]][["V6"]]
}

dados_teste_secao <- bind_rows(arq_secs_teste)



## 3.2.Dados_vagas ---------------------------------------------------------

arq_vags <- list.files(path = "all_files_vagas", pattern = ".txt")

arq_vags_teste <- list()

for (i in seq_along(arq_vags)) {
  cat("lendo", arq_vags[i], "\n")
  arq_vags_teste[[i]] <- read.table(file = paste0("all_files_vagas/",arq_vags[i]),header=F,sep=";", stringsAsFactors = FALSE)
}

dados_teste_vagas <- bind_rows(arq_vags_teste)


# 4. Renomeando as variaveis ----------------------------------------------


## 4.1. Renomeia as variaveis dos dados_secao_eleitoral--------------------


names(dados_teste_secao)<- c("DATA_GERACAO", "HORA_GERACAO", "ANO_ELEICAO", "NUM_TURNO", 
                             "DESCRICAO_ELEICAO", "SIGLA_UF", "SIGLA_UE", "CODIGO_MUNICIPIO", "NOME_MUNICIPIO",
                             "NUM_ZONA", "NUM_SECAO", "CODIGO_CARGO", "QTD_APTOS", "QTD_COMPARECIMENTO", "QTD_ABSTENCOES", 
                             "QT_VOTOS_NOMINAIS", "QT_VOTOS_BRANCOS", "QT_VOTOS_NULOS", "QT_VOTOS_LEGENDA", "QT_VOTOS_ANULADOS_APU_SEP")


# 4.2.Renomeia as variaveis dos dados_vagas -------------------------------


names(dados_teste_vagas) <- c("DATA_GERACAO", "HORA_GERACAO", "ANO_ELEICAO","DESCRICAO_ELEICAO", "SIGLA_UF",
                              "SIGLA_UE", "NOME_UE", "CODIGO_CARGO", "DESCRICAO_CARGO", "QTDE_VAGAS")

