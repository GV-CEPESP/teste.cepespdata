rm(list = ls())

library(tidyverse)
library(cepespR)
source("FUN.R")

anos_munic <- seq(2000, 2016, by = 4)

anos_gerais <- seq(1998,2014, by = 4)

# 1. Vereador -------------------------------------------------------------

cargo <- 13

banco <- teste_cepespdata(anos_munic, cargo)

# Aparentemente, tudo ok.

# 2. Prefeito -------------------------------------------------------------

cargo <- 11

banco <- teste_cepespdata(anos_munic, cargo)

# Aparentemente, tudo ok.

# 3. Deputado Estadual ----------------------------------------------------

cargo <- 7

banco <- teste_cepespdata(anos_gerais, cargo)

# Aparentemente, tudo ok.

# 4. Governador -----------------------------------------------------------

cargo <- 3

banco <- teste_cepespdata(anos_gerais, cargo)

# Aparentemente, tudo ok.
