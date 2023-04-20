## manuscript figs


library(targets)
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
library(gt)
library(extrafont)
library(systemfonts)

store <- "C:/Data-Analysis-Projects/lavaca-nutrients/_targets"
# Fig 2 -----------------------------------------------------------------------

## some functions to overide scales in facets via dewey dunnington
#https://dewey.dunnington.ca/post/2018/modifying-facet-scales-in-ggplot2/
scale_override <- function(which, scale) {
  if(!is.numeric(which) || (length(which) != 1) || (which %% 1 != 0)) {
    stop("which must be an integer of length 1")
  }
  
  if(is.null(scale$aesthetics) || !any(c("x", "y") %in% scale$aesthetics)) {
    stop("scale must be an x or y position scale")
  }
  
  structure(list(which = which, scale = scale), class = "scale_override")
}

CustomFacetWrap <- ggproto(
  "CustomFacetWrap", FacetWrap,
  init_scales = function(self, layout, x_scale = NULL, y_scale = NULL, params) {
    # make the initial x, y scales list
    scales <- ggproto_parent(FacetWrap, self)$init_scales(layout, x_scale, y_scale, params)
    
    if(is.null(params$scale_overrides)) return(scales)
    
    max_scale_x <- length(scales$x)
    max_scale_y <- length(scales$y)
    
    # ... do some modification of the scales$x and scales$y here based on params$scale_overrides
    for(scale_override in params$scale_overrides) {
      which <- scale_override$which
      scale <- scale_override$scale
      
      if("x" %in% scale$aesthetics) {
        if(!is.null(scales$x)) {
          if(which < 0 || which > max_scale_x) stop("Invalid index of x scale: ", which)
          scales$x[[which]] <- scale$clone()
        }
      } else if("y" %in% scale$aesthetics) {
        if(!is.null(scales$y)) {
          if(which < 0 || which > max_scale_y) stop("Invalid index of y scale: ", which)
          scales$y[[which]] <- scale$clone()
        }
      } else {
        stop("Invalid scale")
      }
    }
    
    # return scales
    scales
  }
)

facet_wrap_custom <- function(..., scale_overrides = NULL) {
  # take advantage of the sanitizing that happens in facet_wrap
  facet_super <- facet_wrap(...)
  
  # sanitize scale overrides
  if(inherits(scale_overrides, "scale_override")) {
    scale_overrides <- list(scale_overrides)
  } else if(!is.list(scale_overrides) || 
            !all(vapply(scale_overrides, inherits, "scale_override", FUN.VALUE = logical(1)))) {
    stop("scale_overrides must be a scale_override object or a list of scale_override objects")
  }
  
  facet_super$params$scale_overrides <- scale_overrides
  
  ggproto(NULL, CustomFacetWrap,
          shrink = facet_super$shrink,
          params = facet_super$params
  )
}

df <- tar_read(cv_no3_08164000, store = store) |> 
  mutate(site = "USGS-08164000",
         parameter = "NO <sub>3</sub>") |> 
  bind_rows(
    tar_read(cv_tp_08164000, store = store) |> 
      mutate(site = "USGS-08164000",
             parameter = "TP")
  ) |> 
  bind_rows(
    tar_read(cv_no3_texana, store = store) |> 
      mutate(site = "USGS-08164525",
             parameter = "NO <sub>3</sub>")
  ) |> 
  bind_rows(
    tar_read(cv_tp_texana, store = store) |> 
      mutate(site = "USGS-08164525",
             parameter = "TP")
  ) |> 
  mutate(site = case_when(
    site == "USGS-08164525" ~ "Navidad",
    site == "USGS-08164000" ~ "Lavaca"
  ))

df_long <- df |> 
  ungroup() |> 
  select(NSE, r2, pbias, site, parameter) |> 
  pivot_longer(cols = c(NSE, r2, pbias),
               names_to = "metric")

## plots the density estimates of the repeated 5-fold cross-validation goodness-of-fit metric results,
## color indicates the tail probability calculated from the empirical cumulitive distribution of the goodness-of-fit metric values 
p1 <- ggplot(df, aes(y = site, x = NSE,
                     fill = 0.5 - abs(0.5 - after_stat(ecdf)))) +
  stat_density_ridges(geom = "density_ridges_gradient",
                      calc_ecdf = TRUE,
                      n = 10000) +
  scale_fill_scico("Tail Probability", palette = "hawaii", direction = -1,
                   limit = c(0, 0.5), breaks = c(0, 0.1, 0.2, 0.3, 0.4)) +
  guides(fill = guide_colorbar(barwidth = unit(100L, "pt"),
                               title.position = "top")) +
  facet_wrap_custom(~parameter, scales = "free_x",
                    ncol = 2,
                    scale_overrides = list(
                      scale_override(1, scale_x_continuous(limits = c(-1,1),
                                                           expand = c(0,0),
                                                           breaks = c(-1,0,1))),
                      scale_override(2, scale_x_continuous(limits = c(0,1),
                                                           expand = c(0,0),
                                                           breaks = c(0,0.5,1)))
                    )) +
  labs(x = "NSE", y = "") +
  theme_TWRI_print(base_family = "Arial") +
  theme(axis.text = element_text(size = 8),
        axis.title.x = element_markdown(size = 8),
        strip.text.x = element_markdown(size = 8),
        strip.background = element_rect(fill = "white"),
        panel.spacing.x = unit(15L, "pt"),
        legend.direction = "horizontal",
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8),
        plot.margin = unit(c(1L,0L,1L,0L), "pt"))



p2 <- ggplot(df, aes(y = site, x = r2,
                     fill = 0.5 - abs(0.5 - after_stat(ecdf)))) +
  stat_density_ridges(geom = "density_ridges_gradient",
                      calc_ecdf = TRUE,
                      n = 10000) +
  scale_fill_scico("Tail Probability", palette = "hawaii", direction = -1,
                   limit = c(0, 0.5), breaks = c(0, 0.1, 0.2, 0.3, 0.4)) +
  guides(fill = guide_colorbar(barwidth = unit(100L, "pt"),
                               title.position = "top")) +
  facet_wrap_custom(~parameter, scales = "free_x",
                    ncol = 2,
                    scale_overrides = list(
                      scale_override(1, scale_x_continuous(limits = c(0,1),
                                                           expand = c(0,0),
                                                           breaks = c(0,0.5,1))),
                      scale_override(2, scale_x_continuous(limits = c(0,1),
                                                           expand = c(0,0),
                                                           breaks = c(0,0.5,1)))
                    )) +
  labs(x = "r<sup>2</sup>", y = "") +
  theme_TWRI_print(base_family = "Arial") +
  theme(axis.text = element_text(size = 8),
        axis.title.x = element_markdown(size = 8),
        strip.text.x = element_markdown(size = 8),
        strip.background = element_rect(fill = "white"),
        panel.spacing.x = unit(15L, "pt"),
        legend.direction = "horizontal",
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8),
        plot.margin = unit(c(0L,0L,1L,0L), "pt"))



p3 <- ggplot(df, aes(y = site, x = pbias,
                     fill = 0.5 - abs(0.5 - after_stat(ecdf)))) +
  stat_density_ridges(geom = "density_ridges_gradient",
                      calc_ecdf = TRUE,
                      n = 10000) +
  scale_fill_scico("Tail Probability", palette = "hawaii", direction = -1,
                   limit = c(0, 0.5), breaks = c(0, 0.1, 0.2, 0.3, 0.4)) +
  guides(fill = guide_colorbar(barwidth = unit(100L, "pt"),
                               title.position = "top")) +
  facet_wrap_custom(~parameter, scales = "free_x",
                    ncol = 2,
                    scale_overrides = list(
                      scale_override(1, scale_x_continuous(limits = c(-150,200),
                                                           expand = c(0,0))),
                      scale_override(2, scale_x_continuous(limits = c(-75,75),
                                                           expand = c(0,0)))
                    )) +
  labs(x = "PBIAS", y = "") +
  theme_TWRI_print(base_family = "Arial") +
  theme(axis.text = element_text(size = 8),
        axis.title.x = element_markdown(size = 8),
        strip.text.x = element_markdown(size = 8),
        strip.background = element_rect(fill = "white"),
        panel.spacing.x = unit(15L, "pt"),
        legend.direction = "horizontal",
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8),
        axis.text.y = element_blank(),
        plot.margin = unit(c(0L,0.25,1L,0L), "pt"))

layout <- "
AAAA####
AAAA#DD#
AAAA####
BBBBCCCC
BBBBCCCC
BBBBCCCC
"

p4 <- p1 / p2 / p3 / guide_area() + plot_layout(guides = 'collect',
                                                design = layout)



# setEPS()
# cairo_ps("fig2.eps", width = 5.2, height = 5.2*0.65, fallback_resolution = 600, family = "Arial")
# p4
# dev.off()

ragg::agg_tiff("fig2.tif",  width = 5.2, height = 5.2*0.65,
               units = "in", res = 600, compression = "lzw")
p4
dev.off()

# Fig 3 ------------------------------------------------------------------------

load <- tar_read(daily_no3_08164000, store = store)
fn_load <- tar_read(daily_no3_08164000_fn, store = store)

load_lav_tp <- tar_read(daily_tp_08164000, store = store)
load_nav_tp <- tar_read(daily_tp_texana, store = store)

a <- ggplot() +
  geom_point(data = load$annually, aes(year, NO3_Estimate,
                                       color = "Total Annual Load + 90% CI",
                                       shape = "Total Annual Load + 90% CI")) +
  geom_line(data = load$annually, aes(x = year, y = NO3_Estimate,
                                      color = "Total Annual Load + 90% CI",
                                      linetype = "Total Annual Load + 90% CI"),
            alpha = 0.5) +
  geom_linerange(data = load$annually, aes(x = year, ymin = NO3_Lower, ymax = NO3_Upper,
                                           color = "Total Annual Load + 90% CI")) +
  geom_point(data = fn_load$annually, aes(year, NO3_Estimate,
                                          color = "Flow-Normalized Annual Load + 90% CI",
                                          shape = "Flow-Normalized Annual Load + 90% CI")) +
  geom_line(data = fn_load$annually,
            aes(x = year, y = NO3_Estimate,
                color = "Flow-Normalized Annual Load + 90% CI",
                linetype = "Flow-Normalized Annual Load + 90% CI"),
            alpha = 0.5) +
  geom_linerange(data = fn_load$annually,
                 aes(x = year, ymin = NO3_Lower, ymax = NO3_Upper,
                     color = "Flow-Normalized Annual Load + 90% CI")) +
  labs(x = "", 
       y = expression(Annual~NO[3]~Load~"[kg]"), 
       subtitle = "Lavaca River") +
  scale_shape_manual(name = "values",
                     values = c(21, 19)) +
  scale_color_manual(name = "values",
                     values = c("#7E1900", "#1A3399")) +
  scale_linetype_manual(name = "values",
                        values = c(1, 2)) +
  scale_y_continuous(trans = "pseudo_log",
                     breaks = c(0,1E1, 1E2, 1E3, 1E4, 1E5, 1E6, 1E7),
                     labels = scales::label_log()) +
  coord_cartesian(ylim = c(1000, 1E7)) +
  theme_TWRI_print(base_family = "sans") +
  theme(axis.title.y = element_text(size = 8),
        axis.text.x = element_blank(),
        plot.subtitle = element_text(size = 8, hjust = 0.5, face = "bold"),
        panel.grid.major.x = element_line(color = "#d9d9d9",
                                          linetype = "dotted"),
        legend.title = element_blank(),
        legend.text = element_text(size = 8),
        plot.margin = unit(c(0L,3L,0L,0L), "pt"))



load <- tar_read(daily_no3_texana, store = store)
fn_load <- tar_read(daily_no3_texana_fn, store = store)

b <- ggplot() +
  geom_point(data = load$annually, aes(year, NO3_Estimate,
                                       color = "Total Annual Load + 90% CI",
                                       shape = "Total Annual Load + 90% CI")) +
  geom_line(data = load$annually, aes(x = year, y = NO3_Estimate,
                                      color = "Total Annual Load + 90% CI",
                                      linetype = "Total Annual Load + 90% CI"),
            alpha = 0.5) +
  geom_linerange(data = load$annually, aes(x = year, ymin = NO3_Lower, ymax = NO3_Upper,
                                           color = "Total Annual Load + 90% CI")) +
  geom_point(data = fn_load$annually, aes(year, NO3_Estimate,
                                          color = "Flow-Normalized Annual Load + 90% CI",
                                          shape = "Flow-Normalized Annual Load + 90% CI")) +
  geom_line(data = fn_load$annually,
            aes(x = year, y = NO3_Estimate,
                color = "Flow-Normalized Annual Load + 90% CI",
                linetype = "Flow-Normalized Annual Load + 90% CI"),
            alpha = 0.5) +
  geom_linerange(data = fn_load$annually,
                 aes(x = year, ymin = NO3_Lower, ymax = NO3_Upper,
                     color = "Flow-Normalized Annual Load + 90% CI")) +
  labs(x = "", 
       y = expression(Annual~NO[3]~Load~"[kg]"), 
       subtitle = "Navidad River") +
  scale_shape_manual(name = "values",
                     values = c(21, 19)) +
  scale_color_manual(name = "values",
                     values = c("#7E1900", "#1A3399")) +
  scale_linetype_manual(name = "values",
                        values = c(1, 2)) +
  scale_y_continuous(trans = "pseudo_log",
                     breaks = c(0,1E1, 1E2, 1E3, 1E4, 1E5, 1E6, 1E7),
                     labels = scales::label_log()) +
  coord_cartesian(ylim = c(1000, 1E7)) +
  theme_TWRI_print(base_family = "sans") +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        plot.subtitle = element_text(size = 8, hjust = 0.5, face = "bold"),
        panel.grid.major.x = element_line(color = "#d9d9d9",
                                          linetype = "dotted"),
        legend.title = element_blank(),
        legend.text = element_text(size = 8),
        plot.margin = unit(c(0L,0L,0L,3L), "pt"))

load <- tar_read(daily_tp_08164000, store = store)
fn_load <- tar_read(daily_tp_08164000_fn, store = store)

load$annually <- load$annually |> 
  filter(year >= 2005)

fn_load$annually <- fn_load$annually |> 
  filter(year >= 2005)

c <- ggplot() +
  geom_point(data = load$annually, aes(year, TP_Estimate,
                                       color = "Total Annual Load + 90% CI",
                                       shape = "Total Annual Load + 90% CI")) +
  geom_line(data = load$annually, aes(x = year, y = TP_Estimate,
                                      color = "Total Annual Load + 90% CI",
                                      linetype = "Total Annual Load + 90% CI"),
            alpha = 0.5) +
  geom_linerange(data = load$annually, aes(x = year, ymin = TP_Lower, ymax = TP_Upper,
                                           color = "Total Annual Load + 90% CI")) +
  geom_point(data = fn_load$annually, aes(year, TP_Estimate,
                                          color = "Flow-Normalized Annual Load + 90% CI",
                                          shape = "Flow-Normalized Annual Load + 90% CI")) +
  geom_line(data = fn_load$annually,
            aes(x = year, y = TP_Estimate,
                color = "Flow-Normalized Annual Load + 90% CI",
                linetype = "Flow-Normalized Annual Load + 90% CI"),
            alpha = 0.5) +
  geom_linerange(data = fn_load$annually,
                 aes(x = year, ymin = TP_Lower, ymax = TP_Upper,
                     color = "Flow-Normalized Annual Load + 90% CI")) +
  labs(x = "", y = "Annual TP Load [kg]", subtitle = "Lavaca River") +
  scale_shape_manual(name = "values",
                     values = c(21, 19)) +
  scale_color_manual(name = "values",
                     values = c("#7E1900", "#1A3399")) +
  scale_linetype_manual(name = "values",
                        values = c(1, 2)) +
  scale_y_continuous(trans = "pseudo_log",
                     breaks = c(0,1E1, 1E2, 1E3, 1E4, 1E5, 1E6, 1E7),
                     labels = scales::label_log()) +
  coord_cartesian(ylim = c(1000, 1E6)) +
  theme_TWRI_print(base_family = "sans") +
  theme(axis.title.y = element_text(size = 8),
        panel.grid.major.x = element_line(color = "#d9d9d9",
                                          linetype = "dotted"),
        legend.title = element_blank(),
        legend.text = element_text(size = 8),
        plot.margin = unit(c(0L,3L,0L,0L), "pt"),
        plot.subtitle = element_blank())


load <- tar_read(daily_tp_texana, store = store) 
fn_load <- tar_read(daily_tp_texana_fn, store = store)

load$annually <- load$annually |> 
  filter(year >= 2005)

fn_load$annually <- fn_load$annually |> 
  filter(year >= 2005)

d <- ggplot() +
  geom_point(data = load$annually, aes(year, TP_Estimate,
                                       color = "Total Annual Load + 90% CI",
                                       shape = "Total Annual Load + 90% CI")) +
  geom_line(data = load$annually, aes(x = year, y = TP_Estimate,
                                      color = "Total Annual Load + 90% CI",
                                      linetype = "Total Annual Load + 90% CI"),
            alpha = 0.5) +
  geom_linerange(data = load$annually, aes(x = year, ymin = TP_Lower, ymax = TP_Upper,
                                           color = "Total Annual Load + 90% CI")) +
  geom_point(data = fn_load$annually, aes(year, TP_Estimate,
                                          color = "Flow-Normalized Annual Load + 90% CI",
                                          shape = "Flow-Normalized Annual Load + 90% CI")) +
  geom_line(data = fn_load$annually,
            aes(x = year, y = TP_Estimate,
                color = "Flow-Normalized Annual Load + 90% CI",
                linetype = "Flow-Normalized Annual Load + 90% CI"),
            alpha = 0.5) +
  geom_linerange(data = fn_load$annually,
                 aes(x = year, ymin = TP_Lower, ymax = TP_Upper,
                     color = "Flow-Normalized Annual Load + 90% CI")) +
  labs(x = "", y = "Annual TP Load [kg]", subtitle = "Navidad River") +
  scale_shape_manual(name = "values",
                     values = c(21, 19)) +
  scale_color_manual(name = "values",
                     values = c("#7E1900", "#1A3399")) +
  scale_linetype_manual(name = "values",
                        values = c(1, 2)) +
  scale_y_continuous(trans = "pseudo_log",
                     breaks = c(0,1E1, 1E2, 1E3, 1E4, 1E5, 1E6, 1E7),
                     labels = scales::label_log()) +
  coord_cartesian(ylim = c(1000, 1E6)) +
  theme_TWRI_print(base_family = "sans") +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        panel.grid.major.x = element_line(color = "#d9d9d9",
                                          linetype = "dotted"),
        legend.title = element_blank(),
        legend.text = element_text(size = 8),
        plot.margin = unit(c(0L,1L,0L,3L), "pt"),
        plot.subtitle = element_blank())

layout <- "
11112222
11112222
11112222
11112222
33334444
33334444
33334444
33334444
55555555
"

# 
# setEPS()
# cairo_ps("fig3.eps", width = 5.2, height = 5.2*0.7, fallback_resolution = 600, family = "Arial")
# a + b + c + d + guide_area() + plot_layout(guides = 'collect', design = layout)
# dev.off()


ragg::agg_tiff("fig3.tif",  width = 5.2, height = 5.2*0.7,
               units = "in", res = 600, compression = "lzw")
a + b + c + d + guide_area() + plot_layout(guides = 'collect', design = layout)
dev.off()

# Fig 4 ------------------------------------------------------------------------

load_lav_no3 <- tar_read(daily_no3_08164000, store = store)
load_nav_no3 <- tar_read(daily_no3_texana, store = store)

load_lav_no3$annually |> 
  mutate(site = "Lavaca River") -> lavaca_no3_annually

load_nav_no3$annually |> 
  mutate(site = "Navidad River") -> navidad_no3_annually


no3_annual <- bind_rows(lavaca_no3_annually, navidad_no3_annually) |> 
  mutate(x = as.Date(paste0(year, "-01-01"), "%Y-%m-%d"))

# b <- ggplot(no3_annual) +
#   geom_col(aes(year, NO3_Estimate, fill = site), width = 0.8) +
#   scale_x_continuous(expand = expansion(mult = c(0.05, 0.05)), 
#                      breaks = c(2005, 2010, 2015, 2020)) +
#   scale_y_continuous(labels = scales::comma) +
#   scale_fill_carto_d(palette = "Vivid", direction = -1) +
#   labs(x = "", 
#        y = "Predicted Annual<br>NO <sub>3</sub> Load [kg]") +
#   theme_TWRI_print(base_family = "Arial") +
#   theme(axis.title.y = element_text(size = 8),
#         axis.text = element_text(size = 8),
#         panel.grid.major.x = element_line(color = "#d9d9d9",
#                                           linetype = "dotted"),
#         legend.title = element_blank(),
#         legend.text = element_text(size = 8))


prop <- no3_annual |> 
  mutate(proportion = NO3_Estimate/sum(NO3_Estimate))

ylab1 <- expression(Annual~NO[3]~Load)
ylab2 <- expression("[Proportion]")
c <- ggplot() +
  geom_col(data = prop, aes(year, proportion, fill  = site)) +
  scale_fill_carto_d(palette = "Vivid", direction = -1) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2020),
                     expand = expansion(mult = c(0.05, 0.05))) +
  scale_y_continuous(expand = c(0,0)) +
  labs(x = "",
       y = "")  +
  coord_cartesian(clip = "off") +
  annotation_custom(grid::textGrob(ylab1,
                                   x = unit(-0.23, "npc"),
                                   rot = 90,
                                   gp = grid::gpar(fontfamily = "sans",
                                                   fontsize = 8))) +
  annotation_custom(grid::textGrob(ylab2,
                                   x = unit(-0.18, "npc"),
                                   rot = 90,
                                   gp = grid::gpar(fontfamily = "sans",
                                                   fontsize = 8))) +
  theme_TWRI_print(base_family = "sans") +
  theme(axis.title.y = element_text(size = 8),
        axis.text = element_text(size = 8),
        panel.grid.major.x = element_line(color = "#d9d9d9",
                                          linetype = "dotted"),
        legend.title = element_blank(),
        legend.text = element_text(size = 8))



ylab1 <- expression("Annual Discharge")
ylab2 <- expression("[Million Gallons]")
d <- tar_read(qdata, store = store) |>
  filter(site_no %in% c("8164000", "lktexana_g")) |>
  filter(Date >= as.Date("2005-01-01")) |>
  mutate(site = case_when(
    site_no == "8164000" ~ "Lavaca River",
    site_no == "lktexana_g" ~ "Navidad River"
  )) |>
  mutate(year = year(Date)) |>
  
  mutate(Flow = as_units(Flow, "ft^3/s")) |>
  mutate(Flow = set_units(Flow, "ft^3/day")) |>
  mutate(Flow = set_units(Flow, "1E6gallons/day")) |>
  group_by(year, site) |>
  summarise(Flow = sum(Flow, na.rm = TRUE)) |>
  mutate(Flow = drop_units(Flow)) |>
  ggplot() +
  geom_col(aes(year, Flow, fill = site)) +
  scale_fill_carto_d(palette = "Vivid", direction = -1) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2020),
                     expand = expansion(mult = c(0.05, 0.05))) +
  scale_y_continuous(expand = c(0,0)) +
  labs(x = "",
       y = "") +
  coord_cartesian(clip = "off") +
  annotation_custom(grid::textGrob(ylab1,
                                   x = unit(-0.25, "npc"),
                                   rot = 90,
                                   gp = grid::gpar(fontfamily = "sans",
                                                   fontsize = 8))) +
  annotation_custom(grid::textGrob(ylab2,
                                   x = unit(-0.20, "npc"),
                                   rot = 90,
                                   gp = grid::gpar(fontfamily = "sans",
                                                   fontsize = 8))) +
  theme_TWRI_print(base_family = "Arial") +
  theme(axis.title.y = element_text(size = 8),
        axis.text = element_text(size = 8),
        panel.grid.major.x = element_line(color = "#d9d9d9",
                                          linetype = "dotted"),
        legend.title = element_blank(),
        legend.text = element_text(size = 8),
        legend.position = "none",
        plot.margin = unit(c(1L,1L,1L,2L), "pt"))


load_lav_tp$annually |>
  mutate(site = "Lavaca River") -> lavaca_tp_annually

load_nav_tp$annually |>
  mutate(site = "Navidad River") -> navidad_tp_annually


tp_annual <- bind_rows(lavaca_tp_annually, navidad_tp_annually) |>
  filter(year >= 2005) |>
  mutate(x = as.Date(paste0(year, "-01-01"), "%Y-%m-%d"))
# 
# e <- ggplot(tp_annual) +
#   geom_col(aes(year, TP_Estimate, fill = site), width = 0.8) +
#   scale_x_continuous(expand = expansion(mult = c(0.05, 0.05)), 
#                      breaks = c(2005, 2010, 2015, 2020)) +
#   scale_y_continuous(labels = scales::comma) +
#   scale_fill_carto_d(palette = "Vivid", direction = -1) +
#   labs(x = "", y = "Predicted Annual<br>TP Load [kg]") +
#   theme_TWRI_print(base_family = "Arial") +
#   theme(axis.title.y = element_text(size = 8),
#         axis.text = element_text(size = 8),
#         panel.grid.major.x = element_line(color = "#d9d9d9",
#                                           linetype = "dotted"),
#         legend.title = element_blank(),
#         legend.text = element_text(size = 8))
# 
# 
prop <- tp_annual |>
  mutate(proportion = TP_Estimate/sum(TP_Estimate))

ylab1 <- expression("Annual TP Load")
ylab2 <- expression("[Proportion]")
f <- ggplot() +
  geom_col(data = prop, aes(year, proportion, fill  = site)) +
  scale_fill_carto_d(palette = "Vivid", direction = -1) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2020),
                     expand = expansion(mult = c(0.05, 0.05))) +
  scale_y_continuous(expand = c(0,0)) +
  labs(x = "",
       y = "") +
  coord_cartesian(clip = "off") +
  annotation_custom(grid::textGrob(ylab1,
                                   x = unit(-0.23, "npc"),
                                   rot = 90,
                                   gp = grid::gpar(fontfamily = "sans",
                                                   fontsize = 8))) +
  annotation_custom(grid::textGrob(ylab2,
                                   x = unit(-0.18, "npc"),
                                   rot = 90,
                                   gp = grid::gpar(fontfamily = "sans",
                                                   fontsize = 8))) +
  theme_TWRI_print(base_family = "Arial") +
  theme(axis.title.y = element_text(size = 8),
        axis.text = element_text(size = 8),
        panel.grid.major.x = element_line(color = "#d9d9d9",
                                          linetype = "dotted"),
        legend.title = element_blank(),
        legend.text = element_text(size = 8),
        legend.position = "none")



layout <- "
CC
CC
CC
CC
FF
FF
FF
FF
DD
DD
DD
DD
GG
"
# 
# setEPS()
# cairo_ps("fig4.eps", width = 3, height = 6, fallback_resolution = 600, family = "Arial")
# c + d + f + guide_area() +
#   plot_layout(guides = 'collect', design  = layout)
# dev.off()


ragg::agg_tiff("fig4.tif",  width = 3, height = 6,
               units = "in", res = 600, compression = "lzw")
c + d + f + guide_area() +
  plot_layout(guides = 'collect', design  = layout)
dev.off()


# Fig 5 ------------------------------------------------------------------------
draw_smoothed_years <- function(model1, model2, model3,
                                ylab, subtitle) {
  
  `TCEQ-13563` <- model1
  `TCEQ-13383` <- model2
  `TCEQ-13384` <- model3
  
  newdata <- data_slice(model1, ddate = evenly(2005:2020, n = 200))
  
  comp <- gratia::compare_smooths(
    `TCEQ-13563`,
    `TCEQ-13383`,
    `TCEQ-13384`,
    smooths = "s(ddate)",
    data = newdata) 
  
  crit <- gratia:::coverage_normal(0.90)
  
  comp |> 
    unnest(data) |> 
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
    theme_TWRI_print(base_family = "sans") +
    theme(axis.title.y = element_text(size = 8),
          axis.title.x = element_text(size = 8),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          plot.subtitle = element_text(size = 8),
          legend.direction = "vertical",
          legend.text = element_text(size = 8))
  
  
} 


p_tp <- draw_smoothed_years(tar_read(tp_lavaca_13563_temporal, store = store),
                            tar_read(tp_lavaca_13383_temporal, store = store),
                            tar_read(tp_lavaca_13384_temporal, store = store),
                            ylab = "TP [mg/L]", 
                            subtitle = "A")

p_no3 <- draw_smoothed_years(tar_read(no3_lavaca_13563_temporal, store = store),
                             tar_read(no3_lavaca_13383_temporal, store = store),
                             tar_read(no3_lavaca_13384_temporal, store = store),
                             ylab = expression(NO[italic(x)]~group("[",mg/L,"]")), 
                             subtitle = "B")

p_tkn <- draw_smoothed_years(tar_read(tkn_lavaca_13563_temporal, store = store),
                             tar_read(tkn_lavaca_13383_temporal, store = store),
                             tar_read(tkn_lavaca_13384_temporal, store = store),
                             ylab = "TKN [mg/L]", 
                             subtitle = "C")

p_chla <- draw_smoothed_years(tar_read(chla_lavaca_13563_temporal, store = store),
                              tar_read(chla_lavaca_13383_temporal, store = store),
                              tar_read(chla_lavaca_13384_temporal, store = store),
                              ylab = expression(Chlorophyll-italic(a)~group("[",mu*g/L,"]")), 
                              subtitle = "D")

p_do <- draw_smoothed_years(tar_read(do_lavaca_13563_temporal, store = store),
                            tar_read(do_lavaca_13383_temporal, store = store),
                            tar_read(do_lavaca_13384_temporal, store = store),
                            ylab = "DO [mg/L]", 
                            subtitle = "E")

design <- "
112266
334455
"

# setEPS()
# cairo_ps("fig5.eps", width = 5.2, height = 5.2*0.7, fallback_resolution = 600, family = "Arial")
# p_tp + p_no3 + p_chla + p_tkn + p_do + guide_area() + plot_layout(guides = "collect",
#                                                                   design = design)
# dev.off()


ragg::agg_tiff("fig5.tif",  width = 5.2, height = 5.2*0.7,
               units = "in", res = 600, compression = "lzw")
p_tp + p_no3 + p_chla + p_tkn + p_do + guide_area() + plot_layout(guides = "collect",
                                                                  design = design)
dev.off()

# Fig 6 -----------------------------------------------------------------------

draw_smoothed_surface <- function(comp,
                                  x = flw_res,
                                  xlab,
                                  ylab, 
                                  subtitle) {
  
  crit <- gratia:::coverage_normal(0.90)
  
  comp |>
    unnest(data) |>
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
    theme_TWRI_print(base_family = "sans") +
    theme(axis.title.y = element_text(size = 8),
          axis.title.x = element_text(size = 8),
          plot.subtitle = element_text(size = 8),
          legend.direction = "vertical",
          legend.text = element_text(size = 8))
  
}

`TCEQ-13383` <- tar_read(tp_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `TCEQ-13383`,
                        `TCEQ-13384` = tar_read(tp_lavaca_13384_flow, store = store),
                        `TCEQ-13563` = tar_read(tp_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_tp <- draw_smoothed_surface(comp,
                              x = flw_res,
                              xlab = "Residuals log(Inflow) [cfs]",
                              ylab =  "TP [mg/L]",
                              subtitle = "A")

`TCEQ-13383` <- tar_read(no3_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `TCEQ-13383`,
                        `TCEQ-13384` = tar_read(no3_lavaca_13384_flow, store = store),
                        `TCEQ-13563` = tar_read(no3_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_no3 <- draw_smoothed_surface(comp,
                               x = flw_res,
                               xlab = "Residuals log(Inflow) [cfs]",
                               ylab = expression(NO[italic(x)]~group("[",mg/L,"]")), 
                               subtitle = "B")

`TCEQ-13383` <- tar_read(chla_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `TCEQ-13383`,
                        `TCEQ-13384` = tar_read(chla_lavaca_13384_flow, store = store),
                        `TCEQ-13563` = tar_read(chla_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_chla <- draw_smoothed_surface(comp,
                                x = flw_res,
                                xlab = "Residuals log(Inflow) [cfs]",
                                ylab = expression(Chlorophyll-italic(a)~group("[",mu*g/L,"]")), 
                                subtitle = "C")


`TCEQ-13383` <- tar_read(tkn_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `TCEQ-13383`,
                        `TCEQ-13384` = tar_read(tkn_lavaca_13384_flow, store = store),
                        `TCEQ-13563` = tar_read(tkn_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_tkn <- draw_smoothed_surface(comp,
                               x = flw_res,
                               xlab = "Residuals log(Inflow) [cfs]",
                               ylab = "TKN [mg/L]",
                               subtitle = "D")

`TCEQ-13383` <- tar_read(do_lavaca_13383_flow, store = store)

comp <- compare_smooths(model = `TCEQ-13383`,
                        `TCEQ-13384` = tar_read(do_lavaca_13384_flow, store = store),
                        `TCEQ-13563` = tar_read(do_lavaca_13563_flow, store = store),
                        smooths = c("s(flw_res)"))
p_do <- draw_smoothed_surface(comp,
                              x = flw_res,
                              xlab = "Residuals log(Inflow) [cfs]",
                              ylab = "DO [mg/L]",
                              subtitle = "E")

design <- "
112266
334455
"
# setEPS()
# cairo_ps("fig6.eps", width = 5.2, height = 5.2*0.7, fallback_resolution = 600, family = "Arial")
# p_tp + p_no3 + p_chla + p_tkn + p_do + guide_area() + plot_layout(guides = "collect",
#                                                                   design = design)
# dev.off()

ragg::agg_tiff("fig6.tif",  width = 5.2, height = 5.2*0.7,
               units = "in", res = 600, compression = "lzw")
p_tp + p_no3 + p_chla + p_tkn + p_do + guide_area() + plot_layout(guides = "collect",
                                                                  design = design)
dev.off()

# Fig 7 ------------------------------------------------------------------------
`TCEQ-13383` <- tar_read(tp_lavaca_13383_full, store = store)

comp <- compare_smooths(model = `TCEQ-13383`,
                        `TCEQ-13384` = tar_read(tp_lavaca_13384_full, store = store),
                        `TCEQ-13563` = tar_read(tp_lavaca_13563_full, store = store),
                        smooths = c("s(TP_resid)"))
p_tp <- draw_smoothed_surface(comp,
                              x = TP_resid,
                              xlab = "Residuals log(TP) Load [kg]",
                              ylab = "TP [mg/L]",
                              subtitle = "A")

`TCEQ-13383` <- tar_read(no3_lavaca_13383_full, store = store)

comp <- compare_smooths(model = `TCEQ-13383`,
                        `TCEQ-13384` = tar_read(no3_lavaca_13384_full, store = store),
                        `TCEQ-13563` = tar_read(no3_lavaca_13563_full, store = store),
                        smooths = c("s(NO3_resid)"))
p_no3 <- draw_smoothed_surface(comp,
                               x = NO3_resid,
                               xlab = expression(Residuals~log*group("(",NO[italic(3)],")")~Load~group("[",kg,"]")),
                               ylab = expression(NO[italic(x)]~group("[",mg/L,"]")),
                               subtitle = "B")

design <- "
11223
"


ragg::agg_tiff("fig7.tif",  width = 5.2, height = 5.2*0.45,
               units = "in", res = 600, compression = "lzw")
p_tp + p_no3 + guide_area() + plot_layout(guides = "collect",
                                          design = design)
dev.off()
