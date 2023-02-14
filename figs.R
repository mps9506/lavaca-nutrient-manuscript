library(targets)
#library(unitar)
library(knitr)
library(tidyverse)
library(kableExtra)
library(patchwork)
library(ggrepel)
library(rcartocolor)
library(twriTemplates)
library(ggspatial)
library(ragg)
library(flextable)
library(modelsummary)
library(scico)
library(ggridges)
library(ggtext)
library(lubridate)
library(units)
library(gratia)
store <- "C:/Data-Analysis-Projects/lavaca-nutrients/_targets"


draw_smoothed_years <- function(model1, model2, model3,
                                ylab, subtitle) {
  
  `Upper Bay` <- model1
  `Causeway` <- model2
  `Lower Bay` <- model3
  
  comp <- gratia::compare_smooths(
    `Upper Bay`,
    `Causeway`,
    `Lower Bay`,
    smooths = "s(ddate)") 
  
  crit <- gratia:::coverage_normal(0.90)
  
  comp |> 
    unnest(data) |> 
    mutate(model = as_factor(model)) |> 
    mutate(lower_ci = est + (crit * se),
           upper_ci = est - (crit * se),
           label = if_else(ddate == max(ddate),
                           as.character(model),
                           NA_character_)) |> 
    ggplot(aes(x = ddate, y = est, group = model)) +
    geom_ribbon(aes(ymin = lower_ci,
                    ymax = upper_ci,
                    fill = model),
                alpha = 0.15) +
    geom_line(aes(color = model)) +
    geom_hline(yintercept = 0, linetype = 2, alpha = 0.25) +
    # geom_text_repel(aes(label = label,
    #                     color = model), 
    #                 nudge_x = 5,
    #                 hjust = "left",
    #                 size = 2) +
    scale_x_continuous(breaks = c(2005, 2010, 2015, 2020),
                       expand = expansion(mult = c(0.05,0.05))) +
    colorspace::scale_fill_discrete_qualitative(name = "") +
    colorspace::scale_color_discrete_qualitative(name = "") +
    labs(x = "Year", y = ylab,
         subtitle = subtitle) +
    theme_TWRI_pres(base_family = "OpenSansCondensed_TWRI") +
    theme(axis.title.y = element_markdown(),
          axis.title.x = element_markdown(),
          plot.subtitle = element_markdown(),
          legend.direction = "vertical")
  
  
} 


p_tp <- draw_smoothed_years(tar_read(tp_lavaca_13563_temporal, store = store),
                            tar_read(tp_lavaca_13383_temporal, store = store),
                            tar_read(tp_lavaca_13384_temporal, store = store),
                            ylab = "TP Smooth<br>Estimate [mg/L]", 
                            subtitle = "A: TP Trend")
p_tp

p_no3 <- draw_smoothed_years(tar_read(no3_lavaca_13563_temporal, store = store),
                             tar_read(no3_lavaca_13383_temporal, store = store),
                             tar_read(no3_lavaca_13384_temporal, store = store),
                             ylab = "NO*<sub>x</sub>* Smooth<br>Estimate [mg/L]", 
                             subtitle = "B: NO*<sub>x</sub>* Trend")

p_tkn <- draw_smoothed_years(tar_read(tkn_lavaca_13563_temporal, store = store),
                             tar_read(tkn_lavaca_13383_temporal, store = store),
                             tar_read(tkn_lavaca_13384_temporal, store = store),
                             ylab = "TKN Smooth<br>Estimate [mg/L]", 
                             subtitle = "C: TKN Trend")

p_chla <- draw_smoothed_years(tar_read(chla_lavaca_13563_temporal, store = store),
                              tar_read(chla_lavaca_13383_temporal, store = store),
                              tar_read(chla_lavaca_13384_temporal, store = store),
                              ylab = "Chlorophyll-*a*\nSmooth<br>Estimate [µg/L]", 
                              subtitle = "D: Chlorophyll-*a* Trend")

p_do <- draw_smoothed_years(tar_read(do_lavaca_13563_temporal, store = store),
                            tar_read(do_lavaca_13383_temporal, store = store),
                            tar_read(do_lavaca_13384_temporal, store = store),
                            ylab = "DO\nSmooth<br>Estimate [mg/L]", 
                            subtitle = "E: DO Trend")

design <- "
112266
334455
"

#(p_tp + p_no3) / (p_chla + p_tkn) / (p_do)
ragg::agg_png("temporal.png", width = 12, height = 8, units = "in", res = 180)
p_tp + p_no3 + p_chla + p_tkn + p_do + guide_area() + plot_layout(guides = "collect",
                                                                  design = design)
dev.off()





draw_smoothed_surface <- function(comp,
                                  x = flw_res,
                                  xlab,
                                  ylab, 
                                  subtitle) {
  
  crit <- gratia:::coverage_normal(0.90)
  
  comp |>
    unnest(data) |>
    mutate(model = as_factor(model)) |>
    mutate(model = lvls_reorder(model, c(3,1,2))) |> 
    mutate(lower_ci = est + (crit * se),
           upper_ci = est - (crit * se)) |>
    group_by(model) |> 
    mutate(label = if_else(
      {{ x }} == max( {{ x }} ),
      as.character(model),
      NA_character_)) |> 
    ggplot(aes(x = {{ x }}, y = est, group = model)) +
    geom_ribbon(aes(ymin = lower_ci,
                    ymax = upper_ci,
                    fill = model),
                alpha = 0.15) +
    geom_line(aes(color = model)) +
    geom_hline(yintercept = 0, linetype = 2, alpha = 0.5) +
    # geom_text_repel(aes(label = label,
    #                     color = model),
    #                 nudge_x = 5,
    #                 hjust = "left",
    #                 size = 2) +
    scale_x_continuous(expand = expansion(mult = c(0.05,0.05))) +
    colorspace::scale_fill_discrete_qualitative(name = "") +
    colorspace::scale_color_discrete_qualitative(name = "") +
    labs(x = xlab, y = ylab,
         subtitle = subtitle) +
    theme_TWRI_pres(base_family = "OpenSansCondensed_TWRI") +
    theme(axis.title.y = element_markdown(),
          axis.title.x = element_markdown(),
          plot.subtitle = element_markdown(),
          legend.direction = "vertical")
  
}


`Causeway` <- tar_read(tp_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `Causeway`,
                        `Lower Bay` = tar_read(tp_lavaca_13384_flow, store = store),
                        `Upper Bay` = tar_read(tp_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_tp <- draw_smoothed_surface(comp,
                              x = flw_res,
                              xlab = "Residuals log(Inflow) [cfs]",
                              ylab =  "TP Smooth<br>Estimate [mg/L]",
                              subtitle = "A: TP")


`Causeway` <- tar_read(no3_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `Causeway`,
                        `Lower Bay`  = tar_read(no3_lavaca_13384_flow, store = store),
                        `Upper Bay` = tar_read(no3_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_no3 <- draw_smoothed_surface(comp,
                               x = flw_res,
                               xlab = "Residuals log(Inflow) [cfs]",
                               ylab = "NO*<sub>x</sub>* Smooth<br>Estimate [mg/L]",
                               subtitle = "B: NO*<sub>x</sub>*")

`Causeway` <- tar_read(chla_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `Causeway`,
                        `Lower Bay`  = tar_read(chla_lavaca_13384_flow, store = store),
                        `Upper Bay` = tar_read(chla_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_chla <- draw_smoothed_surface(comp,
                                x = flw_res,
                                xlab = "Residuals log(Inflow) [cfs]",
                                ylab = "Chlorophyll-*a* Smooth<br>Estimate [µg/L]",
                                subtitle = "C: Chlorophyll-*a*")


`Causeway` <- tar_read(tkn_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `Causeway`,
                        `Lower Bay`  = tar_read(tkn_lavaca_13384_flow, store = store),
                        `Upper Bay` = tar_read(tkn_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_tkn <- draw_smoothed_surface(comp,
                               x = flw_res,
                               xlab = "Residuals log(Inflow) [cfs]",
                               ylab = "TKN Smooth<br>Estimate [mg/L]",
                               subtitle = "D: TKN")

`Causeway` <- tar_read(do_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `Causeway`,
                        `Lower Bay`  = tar_read(do_lavaca_13384_flow, store = store),
                        `Upper Bay` = tar_read(do_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_do <- draw_smoothed_surface(comp,
                              x = flw_res,
                              xlab = "Residuals log(Inflow) [cfs]",
                              ylab = "DO Smooth<br>Estimate [mg/L]",
                              subtitle = "E: DO")

design <- "
112266
334455
"
ragg::agg_png("flow.png", width = 12, height = 8, units = "in", res = 180)
p_tp + p_no3 + p_chla + p_tkn + p_do + guide_area() + plot_layout(guides = "collect",
                                                                  design = design)
dev.off()






`Causeway` <- tar_read(tp_lavaca_13383_full, store = store)

comp <- compare_smooths(model = `Causeway`,
                        `Lower Bay` = tar_read(tp_lavaca_13384_full, store = store),
                        `Upper Bay` = tar_read(tp_lavaca_13563_full, store = store),
                        smooths = c("s(TP_resid)"))
p_tp <- draw_smoothed_surface(comp,
                              x = TP_resid,
                              xlab = "Residuals log(TP) Load [kg]",
                              ylab = "TP [mg/L]",
                              subtitle = "A: TP")

`Causeway` <- tar_read(no3_lavaca_13383_full, store = store)

comp <- compare_smooths(model = `Causeway`,
                        `Lower Bay` = tar_read(no3_lavaca_13384_full, store = store),
                        `Upper Bay` = tar_read(no3_lavaca_13563_full, store = store),
                        smooths = c("s(NO3_resid)"))
p_no3 <- draw_smoothed_surface(comp,
                               x = NO3_resid,
                               xlab = "Residuals log(NO<sub>3</sub>) Load [kg]",
                               ylab = "NO*<sub>x</sub>* [mg/L]",
                               subtitle = "B: NO*<sub>x</sub>*")

design <- "
11223
"
ragg::agg_png("load.png", width = 9, height = 4, units = "in", res = 180)
p_tp + p_no3 + guide_area() + plot_layout(guides = "collect",
                                          design = design)
dev.off()
