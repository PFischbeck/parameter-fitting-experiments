library(ggplot2)
library(dplyr)
library(xtable)

source("R/helpers.R")

tbl_scalefree <- read.csv("input_data/konect-scalefree-undirected-data.csv")
# tbl_fitted <- tbl_fitted %>%
#     mutate(graph = sub("_seed=[0-9]*$", "", graph))
tbl_fitting_process <- read.csv("output_data/fitted_params/real-world-girg-1d.csv")

# tbl_fitted <- tbl_fitted %>%
#     group_by(graph) %>%
#     summarise(across(c("n"), list(sd = sd)), across(where(is.numeric), mean)) %>%
#     #    summarise(across(where(is.numeric), list(var = var))) %>%
#     ungroup()
# head(tbl_fitted)

tbl_fitted <- read.csv("output_data/fitted_features/real-world-girg-1d.csv")

tbl_fitted <- tbl_fitted %>%
    group_by(graph) %>%
    summarise(across(where(is.numeric), mean)) %>%
    ungroup()

tbl <- left_join(tbl_scalefree, tbl_fitting_process, join_by(konect_name == graph))

tbl <- left_join(tbl, tbl_fitted, join_by(konect_name == graph), suffix = c("", "_actual"))

head(tbl)


# tbl <- filter(tbl, ple_type == "strong")
tbl_plot <- tbl %>%
    select(graph, ple_type, ple_hill, ple_mom, ple_kern, beta) %>%
    rowwise() %>%
    mutate(
        ple_min = min(c_across(c(ple_hill, ple_mom, ple_kern))),
        ple_max = max(c_across(c(ple_hill, ple_mom, ple_kern)))
    ) %>%
    filter(ple_type == "strong" | ple_type == "weak")

p <- ggplot(tbl_plot, aes(y = beta, color = ple_type)) +
    geom_linerange(aes(xmin = ple_min, xmax = ple_max), linewidth = 0.1) +
    geom_point(aes(x = ple_hill), size = 1, stroke = 0, shape = 19) +
    geom_point(aes(x = ple_mom), size = 1, stroke = 0, shape = 19) +
    geom_point(aes(x = ple_kern), size = 1, stroke = 0, shape = 19) +
    geom_abline(linewidth = 0.1) +
    xlim(c(1.9, 4.1)) +
    ylim(c(1.9, 4.1)) +
    labs(
        x = "Range of estimated PLEs", y = "Fitted Beta value"
    ) +
    theme(legend.position = "none")

create_pdf("output_data/figures/konect-scalefree.pdf", p, width = 0.45, height = 0.4)

write.csv(tbl, "output_data/figures/tables/konect-scalefree.csv", row.names = FALSE)


tbl_print <- tbl %>%
    as.data.frame() %>%
    select(graph, target_n, n_actual, n, target_d, d_actual, d, target_heterogeneity, heterogeneity, beta, target_cc, cc, t, total_iterations) %>%
    # rename(
    #     "Graph" = graph,
    #     "$n$" = target_n,
    #     "$k$" = target_d,
    #     "Clustering" = target_cc,
    #     "Heterogeneity" = target_heterogeneity,
    #     "Fitted $n$" = n,
    #     "Fitted $k$" = d,
    #     "Fitted $T$" = t,
    #     "Fitted $\\beta$" = beta,
    #     "Iterations" = total_iterations,
    #     "Mean $n$" = n_actual,
    #     "Mean $k$" = d_actual,
    #     "Mean cl." = cc,
    #     "Mean het." = heterogeneity
    # ) %>%
    sanitize_table(c(
        sanitize_text,
        sanitize_number(1),
        sanitize_number(1),
        sanitize_number(1),
        sanitize_number(0.1),
        sanitize_number(0.1),
        sanitize_number(0.1),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(1)
    ))

addtorow <- list()
addtorow$pos <- list(0, 0)
addtorow$command <- c(
    "Graph & \\multicolumn{2}{c}{Number of Vertices} & $n$ & \\multicolumn{2}{c}{Average degree} & $k$ & \\multicolumn{2}{c}{Heterogeneity} & $\\beta$ & \\multicolumn{2}{c}{Clustering} & $T$ & Iterations \\\\\n",
    " & Actual & Measured & & Actual & Measured & & Actual & Measured & & Actual & Measured & & \\\\\n"
)

head(tbl_print)
xtbl <- xtable(tbl_print, align = "llrrrrrrrrrrrrr")
print(xtbl,
    include.rownames = FALSE,
    include.colnames = FALSE,
    add.to.row = addtorow,
    booktabs = TRUE,
    floating = FALSE,
    sanitize.colnames.function = function(str) str,
    sanitize.text.function = function(str) str,
    file = "output_data/figures/tables/girg-1d_real-world.tex",
    scalebox = 0.8
)
