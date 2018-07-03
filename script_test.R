rm(list = ls())

library(tidyverse)
library(cepespR)
source("FUN.R")

# 1. Carregando os Bancos -------------------------------------------------

anos <- seq(2000, 2016, by = 4)

cargo <- 11

banco <- teste_cepespdata(anos, cargo)
