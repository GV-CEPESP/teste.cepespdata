
teste_cepespdata <- function(anos, cargo){
  
  agregacao <- c(1,2,4,5,6,7,8)
  
  banco_ls <- vector(mode = "list", length = length(agregacao))
  
  for(i in seq_along(agregacao)){
    
    args <- expand.grid(year     = anos,
                        position = cargo)
    
    banco_ls[[i]] <- purrr::pmap(args, cepespR::get_votes, regional_aggregation = agregacao[[i]])
  }
  
  for(i in seq_along(banco_ls)){
    for(j in seq_along(banco_ls[[1]])){
      banco_ls[[i]][[j]] <- banco_ls[[i]][[j]] %>% 
        select(ANO_ELEICAO,
               SIGLA_UE,
               NUM_TURNO,
               DESCRICAO_ELEICAO,
               CODIGO_CARGO,
               DESCRICAO_CARGO,
               NUMERO_CANDIDATO,
               QTDE_VOTOS)
    }
  }
  
  banco_ls <- map(banco_ls, bind_rows)
  
  teste_repeticoes(banco_ls)
  
  teste_votos(banco_ls)
  
  teste_total_votos(banco_ls)
  
  return(banco_ls)
}

teste_repeticoes <- function(lista){
  for(i in seq_along(lista)){
    repeticoes <- tibble()
    repeticoes <- lista[[i]] %>% 
      count(ANO_ELEICAO, SIGLA_UE, NUM_TURNO, DESCRICAO_ELEICAO, NUMERO_CANDIDATO) %>% 
      filter(n > 1)
    
    message("A lista na posição ", i, " possui ", nrow(repeticoes), " linhas com repetições.")
  }
}

teste_votos <- function(lista){
  for(i in seq_along(lista)){
    lista[[i]] <- lista[[i]] %>%
      group_by(ANO_ELEICAO, SIGLA_UE, NUM_TURNO, DESCRICAO_ELEICAO, NUMERO_CANDIDATO) %>% 
      summarise(VOTOS = sum(QTDE_VOTOS, na.rm = T)) %>% 
      ungroup()
  }
  
  if(length(unique(lista)) == 1){
    message("Os bancos de dados possuem a mesma soma de quantidade de votos.")
  } else {
    message("Os bancos não possuem a mesma soma de quantidade de votos.")
  }
}

teste_total_votos <- function(lista){
  anos <- sort(unique(lista[[1]][["ANO_ELEICAO"]]))
  for(i in seq_along(anos)){
    for(j in seq_along(lista)){
      sum_votos <- sum(lista[[j]]$QTDE_VOTOS[lista[[j]]$ANO_ELEICAO == anos[[i]]])
      
      message("Em ", anos[[i]], " a posição ", j, " da lista possui ", sum_votos, " votos.")
    }
  }
}

