library(ggplot2)
library(dplyr)
library(xtable)

source("R/helpers.R")

tbl_1 <- read.csv("output_data/fitted_params/erdos-renyi.csv")
tbl_2 <- read.csv("output_data/fitted_params/chung-lu-pl.csv")
tbl_3 <- read.csv("output_data/fitted_params/girg-1d.csv")

print(paste(nrow(tbl_1), nrow(tbl_1 %>% filter(averaging_iterations == 30))))
print(paste(nrow(tbl_2), nrow(tbl_2 %>% filter(averaging_iterations == 30))))
print(paste(nrow(tbl_3), nrow(tbl_3 %>% filter(averaging_iterations == 30))))
