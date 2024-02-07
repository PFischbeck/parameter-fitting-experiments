library(ggplot2)
library(dplyr)
library(xtable)

source("R/helpers.R")

tbl_fitted <- read.csv("output_data/fitted_features_ablation_threshold/girg-1d.csv")
tbl_fitting_process <- read.csv("output_data/fitted_params_ablation_threshold/girg-1d.csv")

tbl <- left_join(tbl_fitted, tbl_fitting_process, by = c("graph"), suffix = c("", "_fitting"))

tbl <- tbl %>%
    mutate(graph = sub("_threshold=[0-9\\.]*$", "", graph))

tbl <- tbl %>%
    group_by(graph, threshold) %>%
    summarise(across(where(is.numeric), mean)) %>%
    ungroup()

tbl_true <- read.csv("output_data/target_params/girg-1d.csv")

tbl <- left_join(tbl, tbl_true, by = c("graph"), suffix = c("_fitted", "_true"))

tbl_csv <- tbl %>%
    group_by(threshold) %>%
    summarise(
        n_pearson = cor(n_true, n_fitted, method = "pearson"),
        d_pearson = cor(d_true, d_fitted, method = "pearson"),
        heterogeneity_pearson = cor(heterogeneity_true, heterogeneity_fitted, method = "pearson"),
        cc_pearson = cor(cc_true, cc_fitted, method = "pearson"),
        mean_iterations = mean(total_iterations),
        n_diff = mean(abs(n_true - n_fitted)),
        d_diff = mean(abs(d_true - d_fitted)),
        heterogeneity_diff = mean(abs(heterogeneity_true - heterogeneity_fitted)),
        cc_diff = mean(abs(cc_true - cc_fitted))
    ) %>%
    ungroup()
write.csv(tbl_csv, "output_data/figures/tables/girg-1d_ablation_threshold.csv", row.names = FALSE)


tbl_print <- tbl %>%
    group_by(threshold) %>%
    summarise(
        # n_pearson = cor(n_true, n_fitted, method = "pearson"),
        # d_pearson = cor(d_true, d_fitted, method = "pearson"),
        # heterogeneity_pearson = cor(heterogeneity_true, heterogeneity_fitted, method = "pearson"),
        # cc_pearson = cor(cc_true, cc_fitted, method = "pearson"),
        "$n$ MAE" = mean(abs(n_true - n_fitted)),
        "$d$ MAE" = mean(abs(d_true - d_fitted)),
        "Het. MAE" = mean(abs(heterogeneity_true - heterogeneity_fitted)),
        "Clu. MAE" = mean(abs(cc_true - cc_fitted)),
        "Iterations" = mean(total_iterations),
    ) %>%
    ungroup() %>%
    as.data.frame() %>%
    rename("Thrsh." = threshold) %>%
    sanitize_table(c(
        sanitize_number(0.001),
        sanitize_number(0.1),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.001),
        sanitize_number(0.1)
    ))

addtorow <- list()
addtorow$pos <- list(0, 0)
addtorow$command <- c(
    "Thrsh. & \\multicolumn{4}{c}{Mean absolute error} & Iterations \\\\\n",
    " & Vertices & Avg. deg. & Het. & Clu. & \\\\\n"
)

xtbl <- xtable(tbl_print, align = "lrrrrrr")
print(xtbl,
    include.rownames = FALSE,
    include.colnames = FALSE,
    add.to.row = addtorow,
    booktabs = TRUE,
    floating = FALSE,
    sanitize.colnames.function = function(str) str,
    sanitize.text.function = function(str) str,
    file = "output_data/figures/tables/girg-1d_ablation_threshold.tex"
)
