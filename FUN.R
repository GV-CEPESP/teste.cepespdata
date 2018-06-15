library(httr)

get_elections <- function(ano, cargo, colunas, agre_reg, agre_pol){
  url_base <- "http://cepesp.io/api/consulta/tse"
  
  params <- lst(
    `cargo`              = cargo,
    `ano`                = ano,
    `agregacao_regional` = agre_reg,
    `agregacao_politica` = agre_pol,
    `brancos`            = 1,
    `nulos`              = 1
  )
  
  params <- get_params(params, colunas)
  
  data <- GET(url_base, query = params) %>% 
    content(type = "text/csv")
}

get_params <- function(params, colunas){
  
  for(coluna in colunas){
    params <- append(params, c("selected_columns[]" = coluna))
  }
  
  return(params)
}

test_cepespdata <- function(anos, cargos, colunas){
  # A função testa todas as combinações de anos, cargos e colunas fornecidas.
  # Ela retorna um tibble com as requisições realizadas e o número de linhas
  # recebidas. 
  # Ela também imprime na tela requiseições que obtenham um número de linhas
  # diferentes de outras realizadas para o MESMO ANO e MESMO CARGO.
  
  args <- expand.grid(ano = gerais_anos, cargo = gerais_cargos, colunas = colunas) %>% 
    arrange(ano, cargo)
  
  full_log <- tibble(ano      = vector(mode = "numeric"),
                     cargo    = vector(mode = "numeric"),
                     coluna   = vector(mode = "character"),
                     n_linhas = vector(mode = "numeric"))
  
  query_log <- purrr::pmap(args, test_query, colunas)
  
  full_log <- bind_rows(full_log,query_log)
  
  return(full_log)
}

test_query <- function(ano, cargo, colunas){
  partial_log <- tibble(ano      = vector(mode = "numeric"),
                        cargo    = vector(mode = "numeric"),
                        coluna   = vector(mode = "character"),
                        n_linhas = vector(mode = "numeric"))
  
  for(i in seq_along(colunas)){
    data <- get_elections(ano, cargo, colunas[i])
    n_linhas <- nrow(data)
    
    log <- tibble(ano      = ano,
                  cargo    = cargo,
                  coluna   = colunas[[i]],
                  n_linhas = n_linhas)
    
    partial_log <- bind_rows(partial_log, log)
  }
  return(partial_log)
}
