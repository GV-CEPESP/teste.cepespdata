library(magrittr)

# Requisição do Banco -----------------------------------------------------

get_cepespdata <- function(year, position, regional_aggregation = NULL, agregacao_politica = NULL, endpoint){
  url <- "http://cepesp.io/api/consulta/"
  
  url <- paste0(url,endpoint)
  
  if(endpoint == "votos"){
    colunas <- list("ANO_ELEICAO", "NUM_TURNO", "SIGLA_UE", "NUMERO_CANDIDATO", "DESCRICAO_CARGO","QTDE_VOTOS")
  } else if (endpoint == "tse"){
    colunas <- list("ANO_ELEICAO", "NUM_TURNO", "SIGLA_UE", "NUMERO_CANDIDATO", "DESCRICAO_CARGO","QTDE_VOTOS")
  } else {
    colunas <- list()
  }
  
  if(endpoint == 'tse'){
    data <- cepespR::get_elections(year = year, position = position,
                           regional_aggregation  = regional_aggregation,
                           political_aggregation = agregacao_politica,
                           columns_list = list("ANO_ELEICAO",
                                               "NUM_TURNO",
                                               "SIGLA_UE",
                                               "DESCRICAO_CARGO",
                                               "QTDE_VOTOS")) %>% 
      dplyr::mutate(con_ano      = year,
                    con_pos      = position,
                    con_agre_reg = !!regional_aggregation,
                    con_agre_pol = !!agregacao_politica)
    cat("download ok\n")
    print(data)
    return(data)
      
  }
  
  names(colunas) <- rep("selected_columns[]",length(colunas))
  consulta <- append(list(cached = TRUE,
                          anos               = year,
                          cargo              = position,
                          agregacao_regional = regional_aggregation,
                          agregacao_politica = agregacao_politica),
                     colunas)
  
  mun_temp <- httr::GET(url, query = consulta) %>% 
    httr::content(type="text/csv", encoding = "UTF-8") %>% 
    dplyr::mutate(con_ano      = year,
                  con_pos      = position,
                  con_agre_reg = !!regional_aggregation,
                  con_agre_pol = !!agregacao_politica)
}

make_query <- function(anos, cargos, agregacao_regional = NULL, agregacao_politica = NULL, endpoint){
  
    ### Args ###
  if(endpoint == "candidatos"){
    args <- expand.grid(year                 = anos,
                        position             = cargos)
  } else if(endpoint == "votos"){
    args <- expand.grid(year                 = anos,
                        position             = cargos,
                        regional_aggregation = agregacao_regional)
  } else if(endpoint == "tse"){
    args <- expand.grid(year                 = anos,
                        position             = cargos,
                        regional_aggregation = agregacao_regional,
                        agregacao_politica   = agregacao_politica)
  }
 
  ### Query ###
  banco_ls <- vector(mode = "list", length = dim(args)[1])
  
  banco_ls <- purrr::pmap(args, get_cepespdata, endpoint = endpoint)
  
  return(banco_ls)
}


# Detalhando os Erros -----------------------------------------------------

write_errors <- function(banco_df, logfile, endpoint){
  
  consolidado <- dplyr::filter(banco_df, PROBLEMAS)
  
  cat("\nQuantidade de Erros: ",
      length(consolidado[[1]]), "\n\n",
      "======================\n",
      file = logfile, append = TRUE, sep = "")

  if(endpoint == "candidatos"){
    descrever_detalhes_vagas(consolidado, logfile)
  } else if (endpoint == "votos"){
    descrever_detalhes_votos(consolidado, logfile)
  }
}

descrever_detalhes_vagas <- function(consolidado, logfile){
  translate_cargos <- c("1" = "Presidente",
                        "3" = "Governador",
                        "5" = "Senador",
                        "6" = "Deputado Federal",
                        "7" = "Deputado Estadual",
                        "8" = "Deputado Distrital")
  
  
  translate_reg_agre <- c("1" = "Macro",
                          "2" = "UF",
                          "4" = "Meso",
                          "5" = "Micro",
                          "6" = "Município")
  for(i in seq_along(nrow(consolidado))){
    cat("#", i, "\n",
        file = logfile, append = TRUE, sep = "")
    cat("Ano:"                , consolidado$con_ano[[i]],                                "\n",
          "Cargo:"              , unname(translate_cargos[as.character(consolidado$con_pos[[i]])]),      "\n",
          "Unidade Eleitoral: " , consolidado$SIGLA_UE[[i]],                               "\n",
          "Vagas: "             , consolidado$QTDE_VAGAS[[i]],                             "\n",
          "Eleitos: "           , consolidado$ELEITOS[[i]],                                "\n",
          "Nomes dos Eleitos: " , paste0(consolidado$ELEITOS_NOMES[[i]], collapse = "; "), "\n\n",
          file = logfile, append = TRUE, sep = "")
    }
}

descrever_detalhes_votos <- function(consolidado, logfile){
  translate_cargos <- c("1" = "Presidente",
                        "3" = "Governador",
                        "5" = "Senador",
                        "6" = "Deputado Federal",
                        "7" = "Deputado Estadual",
                        "8" = "Deputado Distrital")
  
  
  translate_reg_agre <- c("1" = "Macro",
                          "2" = "UF",
                          "4" = "Meso",
                          "5" = "Micro",
                          "6" = "Município")
  for(i in seq_along(consolidado[[1]])){
    cat("#", i, "\n",
        file = logfile, append = TRUE, sep = "")
    cat("Ano: "                , consolidado$con_ano[[i]],                                   "\n",
        "Cargo: "              , unname(translate_cargos[as.character(consolidado$con_pos[[i]])]),         "\n",
        "Unidade Eleitoral: "  , consolidado$SIGLA_UE[[i]],                                  "\n",
        "Agregação Regional: " , unname(translate_reg_agre[as.character(consolidado$con_agre_reg[[i]])]),  "\n",
        "Turno: "              , consolidado$NUM_TURNO[[i]],                                 "\n",
        "Votos: "              , consolidado$VOTOS[[i]],                                     "\n",
        "Comparecimento: "     , consolidado$COMPARECIMENTO[[i]],                            "\n",
        "Aptos: "              , consolidado$APTOS[[i]],                                     "\n",
        "Taxa entre Votos e Comparecimento: ", consolidado$PROP_E[[i]],                      "\n\n",
        file = logfile, append = TRUE, sep = "")
  }
}

# Teste Candidatos --------------------------------------------------------

# anos <- seq(1998, 2014, by = 4)
# cargos <- c(1,3,5,6,7,8)
# agregacao_regional <- c(1,2,4,5,6)
# vagas_molde <- readr::read_csv("molde_vagas.csv")
# votos_molde <- readr::read_csv("molde_secao.csv")

teste_candidatos <- function(anos, cargos, vagas_molde, logfile = "candidatos.log"){
  cat("Teste das Requisições de Candidatos (",
      as.character(Sys.time()),
      ")\n\n========================================================\n",
      file = logfile,sep = "")  
  
  endpoint = "candidatos"
  
  banco_ls <- make_query(anos, cargos, endpoint = endpoint) %>% 
    purrr::map(dplyr::mutate, RESULTADO = ifelse(DESC_SIT_TOT_TURNO %in% c("ELEITO", "MÉDIA", "ELEITO POR MÉDIA", "ELEITO POR QP"),
                                                 "Eleito",
                                                 "Não Eleito")) %>% 
    purrr::map(dplyr::group_by, ANO_ELEICAO, SIGLA_UE, DESCRICAO_CARGO, RESULTADO, con_ano, con_pos) %>% 
    purrr::map(dplyr::summarise,
               ELEITOS       = sum(RESULTADO == "Eleito"),
               ELEITOS_NOMES = list(NOME_CANDIDATO)) %>% 
    purrr::map(dplyr::filter, RESULTADO == "Eleito") %>% 
    purrr::map(dplyr::left_join, y = vagas_molde, by = c("ANO_ELEICAO", "SIGLA_UE", "DESCRICAO_CARGO")) %>% 
    purrr::map(dplyr::mutate, PROBLEMAS = ifelse(QTDE_VAGAS >= ELEITOS, F, T))
  
  banco_df <- dplyr::bind_rows(banco_ls)

  write_errors(banco_df, logfile = logfile, endpoint = endpoint)
}

# Teste Votos -------------------------------------------------------------
teste_votos <- function(anos, cargos, agregacao_regional, votos_molde, logfile = "votos.log"){
  cat("Teste das Requisições de Voto (",
      as.character(Sys.time()),
      ")\n\n========================================================\n",
      file = logfile,sep = "")
  
  endpoint = "votos"
  # banco_ls <- readr::read_rds("banco_votos_teste.rds")
  banco_ls <- make_query(anos, cargos, agregacao_regional, endpoint = endpoint) %>% 
    purrr::map(dplyr::group_by, ANO_ELEICAO, NUM_TURNO, SIGLA_UE, DESCRICAO_CARGO, con_ano, con_pos, con_agre_reg) %>% 
    purrr::map(dplyr::summarise, VOTOS = sum(QTDE_VOTOS)) %>% 
    purrr::map(dplyr::left_join, y = votos_molde, by = c("ANO_ELEICAO", "NUM_TURNO", "SIGLA_UE", "DESCRICAO_CARGO")) %>% 
    purrr::map(dplyr::mutate, PROBLEMAS = ifelse(COMPARECIMENTO >= VOTOS, F, T))
  
  # banco_ls <- readr::write_rds(banco_ls, "banco_votos_teste.rds")
  
  banco_df <- dplyr::bind_rows(banco_ls) %>% 
    dplyr::arrange(dplyr::desc(VOTOS/COMPARECIMENTO)) %>% 
    dplyr::mutate(PROP_E = paste0(round((VOTOS/COMPARECIMENTO) * 100, 2),"%"))
    
  
  write_errors(banco_df, logfile = logfile, endpoint = endpoint)
}

# Teste Elections (BETA) --------------------------------------------------

teste_elections <- function(anos, cargos, agregacao_regional, agregacao_politica, votos_molde, vagas_molde, logfile = "elections.log"){
  cat("Teste das Requisições de Voto (",as.character(Sys.time()),")\n\n========================================================\n",
      file = logfile,sep = "")

  endpoint = "tse"

  # banco_ls <- readr::read_rds("banco_votos_teste.rds")
  banco_ls <- make_query(anos, cargos, agregacao_regional, agregacao_politica, endpoint = endpoint) %>% 
    purrr::map(dplyr::group_by, ANO_ELEICAO, NUM_TURNO, SIGLA_UE, DESCRICAO_CARGO, con_ano, con_pos, con_agre_reg) %>% 
    purrr::map(dplyr::summarise, VOTOS = sum(QTDE_VOTOS)) %>% 
    purrr::map(dplyr::left_join, y = votos_molde, by = c("ANO_ELEICAO", "NUM_TURNO", "SIGLA_UE", "DESCRICAO_CARGO")) %>% 
    purrr::map(dplyr::mutate, PROBLEMAS = ifelse(COMPARECIMENTO >= VOTOS, F, T))
  
  # banco_ls <- readr::write_rds(banco_ls, "banco_votos_teste.rds")
  
  banco_df <- dplyr::bind_rows(banco_ls) %>% 
    dplyr::arrange(dplyr::desc(VOTOS/COMPARECIMENTO)) %>% 
    dplyr::mutate(PROP_E = paste0(round((VOTOS/COMPARECIMENTO) * 100, 2),"%"))
  
  
  write_errors(banco_df, logfile = logfile, endpoint = endpoint)
}

