## Removendo os arquivos
rm(list = ls())

## Pacotes
library(tidyverse)
source("FUN.R")

# 1. Carregando Moldes ----------------------------------------------------

votos_molde <- readr::read_csv("molde_secao.csv")

vagas_molde <- readr::read_csv("molde_vagas.csv")

# 2. Testes ---------------------------------------------------------------

anos <- seq(1998, 2014, by = 4)

cargos <- c(1,3,5,6,7,8)

agregacao_regional <- c(1,2,4,5,6)

agregacao_politica <- c(2)
# 3. Votos ----------------------------------------------------------------

teste_votos(anos, cargos, agregacao_regional, votos_molde)

# 4. Candidatos -----------------------------------------------------------

teste_candidatos(anos, cargos, vagas_molde)

# 5. Elections (BETA) -----------------------------------------------------

# teste_elections(anos, cargos, agregacao_regional, agregacao_politica, votos_molde, vagas_molde)
