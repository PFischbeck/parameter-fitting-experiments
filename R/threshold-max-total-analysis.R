library(ggplot2)
library(dplyr)
library(xtable)

source("R/helpers.R")

tbl_1 <- read.csv("output_data/fitted_params_ablation_threshold/erdos-renyi.csv")
tbl_2 <- read.csv("output_data/fitted_params_ablation_threshold/chung-lu-pl.csv")
tbl_3 <- read.csv("output_data/fitted_params_ablation_threshold/girg-1d.csv")

print(paste(nrow(tbl_1), nrow(tbl_1 %>% filter(smoothing_iterations == 200))))
print(paste(nrow(tbl_2), nrow(tbl_2 %>% filter(smoothing_iterations == 200))))
print(paste(nrow(tbl_3), nrow(tbl_3 %>% filter(smoothing_iterations == 200))))
