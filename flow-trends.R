library(dataRetrieval)
library(arrow)
library(tidyverse)
library(mgcv)
library(gratia)
library(twriTemplates)
library(patchwork)
library(ragg)
library(ggrepel)
## plot discharge trends over time

download_Q_data <- function(usgs_dir = "data/USGS",
                            twdb_dir = "data/twdb") {
  ## download or read USGS data
  if(!file.exists(paste0(usgs_dir, "/usgs_flows.csv"))) {
    q <- dataRetrieval::readNWISdv(
      siteNumbers = c("08164000"), 
      parameterCd = "00060", #discharge
      startDate = "1972-01-01",
      endDate = "2020-12-31"
    )
    q <- dataRetrieval::renameNWISColumns(q)
    
    arrow::write_csv_arrow(q, paste0(usgs_dir,"/usgs_flows.csv"))
    
  } else {
    q <- arrow::read_csv_arrow(paste0(usgs_dir,"/usgs_flows.csv"))
  }
  q <- q |> 
    mutate(site_no = as.character(site_no))
  ## agency_cd, site_no, Date, Flow, Flow_cd
  
  ## read TWDB data
  
  # texana is gaged flow and can be used as is.
  # need to convert from acre-feet per day to cubic feet per second!
  texana <- read_table("data/TWDB/lktexanag", col_types = "nnnn_") |> 
    pivot_longer(cols = lktexana_g, names_to = "site_no", values_to = "Flow") |> 
    mutate(Date = lubridate::ymd(paste0(year,"-", month,"-", day)),
           agency_cd = "TWDB") |> 
    select(-c(year, month, day)) |> 
    #convert to cubic feet per second
    mutate(Flow = (Flow * (43560/86400)))
  
  q |> 
    bind_rows(texana)
  
}



df <- download_Q_data()


df |> 
  filter(site_no == "8164000") |> 
  mutate(year = lubridate::year(Date),
         month = lubridate::month(Date),
         doy = lubridate::yday(Date),
         ddate = lubridate::decimal_date(Date),
         Flow = case_when(
           Flow == 0 ~ 0.001,
           .default = as.numeric(Flow)),
         norm_flow = Flow/mean(Flow)) -> lv_df

hist(lv_df$norm_flow)
hist(log(lv_df$norm_flow))

ctrl <- list(niterEM = 0, msVerbose = TRUE, optimMethod="L-BFGS-B")

m1_lv <- gamm(log(Flow) ~ s(ddate, k = 30, bs = "cr") + s(doy, k = 6, bs = "cc"),
             data = lv_df,
             family = gaussian(link = "identity"),
             control = ctrl)

m2_lv <- gamm(log(Flow) ~ s(ddate, k = 30, bs = "cr") + s(doy, k = 6, bs = "cc"),
                  correlation = corARMA(form = ~ 1|year, p = 1, q = 2),
                  data = lv_df,
                  control = ctrl,
                  family = gaussian(link = "identity"))


m3_lv <- gamm(log(Flow) ~ s(ddate, k = 30, bs = "cr") + s(doy, k = 6, bs = "cc"),
              correlation = corARMA(form = ~ 1|year, p = 2, q = 2),
              data = lv_df,
              control = ctrl,
              family = gaussian(link = "identity"))


anova(m1_lv$lme, m2_lv$lme, m3_lv$lme)

acf(resid(m1_lv$lme, type = "normalized"))
pacf(resid(m1_lv$lme, type = "normalized"))

acf(resid(m2_lv$lme, type = "normalized"))
pacf(resid(m2_lv$lme, type = "normalized"))

acf(resid(m3_lv$lme, type = "normalized"))
pacf(resid(m3_lv$lme, type = "normalized"))

summary(m3_lv$gam)
gratia::appraise(m3_lv$gam)
gratia::draw(m3_lv$gam)



## probably better to use predict and use gratia's data slice to develop predictions.
#lv_preds <- gratia::data_slice(m3_lv, ddate = evenly(ddate, n = 1000))

lv_preds_m3 <- predict(m3_lv$gam, newdata = lv_df, type = "terms", se.fit = TRUE)

lv_preds <- transform(lv_df,
                      preds = lv_preds_m3$fit[,1],
                      se = lv_preds_m3$se.fit[,1])
lv_int <- m3_lv$gam$coefficients[1]


lv_preds <- lv_preds |> 
  mutate(preds = preds + lv_int) |> 
  mutate(ci_low = preds - (1.96 * se),
         ci_hi = preds + (1.96 * se))

p1 <- ggplot() +
  geom_line(data = lv_preds,
            aes(x = ddate, y = log(Flow),
                color = "Mean Daily Discharge",
                alpha = "Mean Daily Discharge",
                linetype = "Mean Daily Discharge")) +
  geom_ribbon(data = lv_preds,
              aes(x = ddate,
                  ymin = ci_low,
                  ymax = ci_hi),
              alpha = 0.5) +
  geom_line(data = lv_preds,
            aes(x = ddate, y = preds,
                color = "Smoothed Long-term Trend",
                alpha = "Smoothed Long-term Trend",
                linetype = "Smoothed Long-term Trend")) +
  geom_hline(data = as.data.frame(lv_int),
             aes(yintercept = lv_int,
                 color = "Mean log(Discharge)",
                 alpha = "Mean log(Discharge)",
                 linetype = "Mean log(Discharge)")) +
  scale_color_manual(name = "", values = c("steelblue", "black", "black")) +
  scale_alpha_manual(name = "", values = c(0.2, 0.5, 1)) +
  scale_linetype_manual(name = "", values = c(1, 2, 1)) +
  coord_cartesian(xlim = c(1972,
                           2021),
                  expand = FALSE) +
  labs(x = "", y = "log(Discharge) [cfs]",
       subtitle = "A") +
  theme_TWRI_print(base_family = "Arial")



df |> 
  filter(site_no == "lktexana_g") |> 
  mutate(year = lubridate::year(Date),
         month = lubridate::month(Date),
         doy = lubridate::yday(Date),
         ddate = lubridate::decimal_date(Date),
         Flow = case_when(
           Flow == 0 ~ 0.001,
           .default = as.numeric(Flow)
         )) -> lt_df

m1_lt <- gamm(log(Flow) ~ s(ddate, k = 30, bs = "cr") + s(doy, k = 6, bs = "cc"),
              data = lt_df,
              family = gaussian(link = "identity"),
              control = ctrl)

m2_lt <- gamm(log(Flow) ~ s(ddate, k = 30, bs = "cr") + s(doy, k = 6, bs = "cc"),
              correlation = corARMA(form = ~ 1|year, p = 1, q = 2),
              data = lt_df,
              control = ctrl,
              family = gaussian(link = "identity"))


m3_lt <- gamm(log(Flow) ~ s(ddate, k = 30, bs = "cr") + s(doy, k = 6, bs = "cc"),
              correlation = corARMA(form = ~ 1|year, p = 2, q = 2),
              data = lt_df,
              control = ctrl,
              family = gaussian(link = "identity"))


anova(m1_lt$lme, m2_lt$lme, m3_lt$lme)

acf(resid(m1_lt$lme, type = "normalized"))
pacf(resid(m1_lt$lme, type = "normalized"))

acf(resid(m2_lt$lme, type = "normalized"))
pacf(resid(m2_lt$lme, type = "normalized"))

acf(resid(m3_lt$lme, type = "normalized"))
pacf(resid(m3_lt$lme, type = "normalized"))

summary(m3_lt$gam)
gratia::appraise(m3_lt$gam)
gratia::draw(m3_lt$gam)

#lt_preds <- gratia::data_slice(m3_lt, ddate = evenly(ddate, n = 1000))

lt_preds_m3 <- predict(m3_lt$gam, newdata = lt_df, type = "terms", se.fit = TRUE)

lt_preds <- transform(lt_df,
                      preds = lt_preds_m3$fit[,1],
                      se = lt_preds_m3$se.fit[,1])
lt_int <- m3_lt$gam$coefficients[1]


lt_preds <- lt_preds |> 
  mutate(preds = preds + lt_int) |> 
  mutate(ci_low = preds - (1.96 * se),
         ci_hi = preds + (1.96 * se))



p2 <- ggplot() +
  geom_line(data = lt_preds,
            aes(x = ddate, y = log(Flow),
                color = "Mean Daily Discharge",
                alpha = "Mean Daily Discharge",
                linetype = "Mean Daily Discharge")) +
  geom_ribbon(data = lt_preds,
              aes(x = ddate,
                  ymin = ci_low,
                  ymax = ci_hi),
              alpha = 0.5) +
  geom_line(data = lt_preds,
            aes(x = ddate, y = preds,
                color = "Smoothed Long-term Trend",
                alpha = "Smoothed Long-term Trend",
                linetype = "Smoothed Long-term Trend")) +
  geom_hline(data = as.data.frame(lt_int),
             aes(yintercept = lt_int,
                 color = "Mean log(Discharge)",
                 alpha = "Mean log(Discharge)",
                 linetype = "Mean log(Discharge)")) +
  scale_color_manual(name = "", values = c("steelblue", "black", "black")) +
  scale_alpha_manual(name = "", values = c(0.2, 0.5, 1)) +
  scale_linetype_manual(name = "", values = c(1, 2, 1)) +
  coord_cartesian(xlim = c(1972,
                           2021),
                  expand = FALSE) +
  labs(x = "", y = "log(Discharge) [cfs]",
       subtitle = "A") +
  theme_TWRI_print(base_family = "Arial")



p1 / p2

intercepts_df <- data.frame(intercept = lt_int) |> 
  bind_rows(data.frame(intercept = lv_int)) |> 
  mutate(site_no = c("Navidad River", "Lavaca River"))


p1 <- bind_rows(lv_preds, lt_preds) |> 
  mutate(site_no = case_when(
    site_no == "8164000" ~ "Lavaca River",
    site_no == "lktexana_g" ~ "Navidad River"
  )) |> 
  ggplot() +
  geom_line(aes(x = ddate,
                y = log(Flow),
                color = "Measured Discharge",
                alpha = "Measured Discharge",
                linetype = "Measured Discharge"),
            linewidth = 0.25) +
  geom_ribbon(aes(x = ddate,
                  ymin = ci_low,
                  ymax = ci_hi),
              alpha = 0.25) +
  geom_line(aes(x = ddate, y = preds,
                color = "Smoothed Long-term Trend",
                alpha = "Smoothed Long-term Trend",
                linetype = "Smoothed Long-term Trend"),
            linewidth = 0.25) +
  geom_hline(data = intercepts_df,
             aes(yintercept = intercept,
                 color = "Intercept",
                 alpha = "Intercept",
                 linetype = "Intercept"),
             linewidth = 0.25) +
  scale_color_manual(name = "", values = c("black", "steelblue", "black")) +
  scale_alpha_manual(name = "", values = c(0.5, 0.2, 1)) +
  scale_linetype_manual(name = "", values = c(2, 1, 1)) +
  facet_wrap(~site_no, ncol = 1) +
  labs(x = "", y = "log(Discharge) [cfs]") +
  theme_TWRI_print(base_family = "Arial") +
  theme(axis.title.y = element_text(size = 8),
        axis.title.x = element_text(size = 8),
        axis.text.x = element_text(size = 8),
        axis.text.y = element_text(size = 8),
        panel.grid = element_blank(),
        plot.subtitle = element_text(size = 8),
        legend.text = element_text(size = 8),
        legend.key.width = unit(25, "points"),
        strip.background = element_rect(fill = "white", color = NULL),
        strip.text = element_text(size = 8))

p1
# ragg::agg_png(filename = "fig8.png",
#               width = 6.85,
#               height = 6.85*0.65,
#               units = "in",
#               res = 600)
# Cairo::CairoPDF(file = "fig8.pdf",
#                 width = 6.85*0.65,
#                 height = 3,
#                 pointsize = 8,
#                 family = "Arial")
cairo_pdf(file = "fig8.pdf",
    width = 6.85,
    height = 6.85*0.65,
    family = "Arial")

p1

dev.off()
