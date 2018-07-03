rm(list = ls())

library(tidyverse)
library(cepespR)
source("FUN.R")

anos_munic <- seq(2000, 2016, by = 4)

# 1. Vereador -------------------------------------------------------------

cargo <- 13

banco <- teste_cepespdata(anos_munic, cargo)


# 2. Prefeito -------------------------------------------------------------

cargo <- 11

banco <- teste_cepespdata(anos_munic, cargo)

