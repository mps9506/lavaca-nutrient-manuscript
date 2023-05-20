library(targets)
library(tidyverse)
library(ragg)
library(magick)
library(sf)
library(ggrepel)
library(patchwork)
library(dataRetrieval)
#library(FedData)
library(ggspatial)
library(rcartocolor)
library(twriTemplates)

download_usgs_sites <- function() {
  site_numbers <- c("08164000", #lavaca
                    "08164525")
  sites <- readNWISsite(site_numbers)
  sites
}

download_tceq_sites <-function() {
  site_numbers <- c("TCEQMAIN-13563",
                    "TCEQMAIN-13383",
                    "TCEQMAIN-13384")
  sites <- whatWQPsites(siteid = site_numbers)
  sites
}


## usgs sites
df_sites <- download_usgs_sites() |> 
  filter(site_no == "08164000" | site_no == "08164525")

df_sites <- st_as_sf(df_sites, coords = c("dec_long_va", "dec_lat_va"),
                     crs = 4326)  

## tceq sites
tceq_sites <- download_tceq_sites()
tceq_sites <- st_as_sf(tceq_sites, coords = c("LongitudeMeasure", "LatitudeMeasure"),
                       crs = 4326)

tceq_sites$MonitoringLocationIdentifier <- stringr::str_replace_all(tceq_sites$MonitoringLocationIdentifier, "MAIN", "")

## read rivers spatial data
rivers <- read_sf("data/Spatial/lavaca.gpkg",
                  layer = "rivers")

## read lake texana polygon
waterbody <- read_sf("data/Spatial/lavaca.gpkg",
                     layer = "waterbody")

## read watershed polygons
lavaca_ws <- read_sf("data/Spatial/lavaca.gpkg",
                     layer = "lavaca_ws")

navidad_ws <- read_sf("data/Spatial/lavaca.gpkg",
                      layer = "navidad_ws")
ds_ws <- read_sf("data/Spatial/lavaca.gpkg",
                 layer = "ds_ws")

## read counties polygons
counties <- read_sf("data/Spatial/lavaca.gpkg",
                    layer = "counties")

## combine watersheds into one sf
ws <- bind_rows(lavaca_ws, navidad_ws, ds_ws)

## subset counties to just the ones near our porjec area
counties_sub <- counties |> st_transform(crs = st_crs(lavaca_ws))

counties_sub <- counties_sub[ws,]

ws |> 
  mutate(label = c("Lavaca River\nWatershed", "Navidad River\nWatershed", "Garcitas Creek,\nPlacedo Creek\nand Cox Bay\nWatersheds")) -> ws

## read urbanized areas polygons
urban <- read_sf("data/Spatial/lavaca.gpkg",
                 layer = "urban")
## download nhd data
bounds <- st_as_sfc(st_bbox(counties_sub))
bounds <- st_buffer(bounds, dist = 5000)


# 
# nhd_stuff <- get_nhd(bounds,
#                      "lavaca_plus",
#                      extraction.dir = "data/nhd/",
#                      force.redo = TRUE)

st_layers("C:/NHDPLUS/NHDPlusV21_National_Seamless_Flattened_Lower48.gdb")
Flowlines <-  sf::st_read("C:/NHDPLUS/NHDPlusV21_National_Seamless_Flattened_Lower48.gdb", layer = "NHDFlowline_Network")
Flowlines <- Flowlines |> 
  st_zm() |> 
  st_transform(crs = st_crs(lavaca_ws)) |> 
  st_intersection(bounds) |> 
  filter(FTYPE == "StreamRiver")
  



## melt the waterbodies to remove subunit lines
waterbody <- waterbody |> 
  summarise()

Area <- sf::st_read("C:/NHDPLUS/NHDPlusV21_National_Seamless_Flattened_Lower48.gdb", layer = "NHDArea") |> 
  st_zm() |> 
  st_transform(crs = st_crs(lavaca_ws)) |> 
  st_intersection(bounds) |> 
  summarise()


waterbody_labs <- tibble(lab = c("Lake\nTexana", "Lavaca Bay", "Matagorda Bay"),
                         x = c(-96.54, -96.6, -96.4),
                         y = c(28.95, 28.65, 28.55)) |> 
  st_as_sf(coords = c("x", "y"),
           crs = 4326)

p1 <- ggplot() +
  ## watersheds
  geom_sf(data = ws, aes(fill = label, color = label), alpha = 0.2, linewidth = 0.2, show.legend = FALSE) +
  ## colorado, wharton, dewit, calhoun county label
  geom_sf_text(data = counties_sub |> 
                 filter(CNTY_NM == "Colorado"|CNTY_NM == "Lavaca"| 
                          CNTY_NM == "Wharton"|CNTY_NM == "Calhoun"|
                          CNTY_NM == "De Witt"), 
               aes(label = glue::glue("{CNTY_NM}\nCounty")), 
               size = 2, family = "Atkinson Hyperlegible", 
               alpha = 0.5, fontface = "bold") +
  ## Jackson county label
  geom_sf_text(data = counties_sub |> 
                 filter(CNTY_NM == "Jackson"), 
               aes(label = glue::glue("{CNTY_NM}\nCounty")), 
               size = 2, family = "Atkinson Hyperlegible", 
               alpha = 0.5, fontface = "bold",
               nudge_x = 10000) +
  ## victoria county label
  geom_sf_text(data = counties_sub |> 
                 filter(CNTY_NM == "Victoria"), 
               aes(label = glue::glue("{CNTY_NM}\nCounty")), 
               size = 2, family = "Atkinson Hyperlegible", 
               alpha = 0.5, fontface = "bold",
               nudge_x = -10000, nudge_y = -10000) +
  geom_sf(data = urban, fill = "azure4", linewidth = 0.2, alpha = 0.5) +
  geom_sf(data = Area, color = alpha("steelblue",0.25), alpha = 0.25, fill = "steelblue", linewidth = 0.15) +
  geom_sf(data = counties_sub, fill = "transparent", linetype = 3, linewidth = 0.15, show.legend = FALSE) +
  geom_sf(data = Flowlines, alpha = 0.25, linewidth = 0.15, color = "steelblue") +
  geom_sf(data = rivers, color = "steelblue", linewidth = 0.15) +
  geom_sf(data = waterbody, alpha = 1, fill = "slategray3",color = alpha("slategray3",1), linewidth = 0.15) +
  geom_sf(data = df_sites, aes(shape = "Freshwater Sites")) +
  geom_sf(data = tceq_sites, aes(shape = "Lavaca Bay Sites")) +
  ## city labels
  geom_text_repel(data = urban |> filter(NAME10 != "Schulenburg", NAME10 != "Yoakum, TX", NAME10 != "Wharton", NAME10 != "Cuero",
                                         NAME10 != "El Campo"), 
                  aes(label = NAME10, geometry = Shape), size = 2, family = "Atkinson Hyperlegible",
                  stat = "sf_coordinates",
                  hjust = 0,
                  nudge_x = -100,
                  box.padding = 0.5,
                  nudge_y = 8,
                  segment.curvature = -0.1,
                  segment.ncp = 3,
                  segment.angle = 20,
                  color = "grey30",
                  bg.color = "white",
                  bg.r = 0.15
  ) +
  ## el campo label
  geom_text_repel(data = urban |> filter(NAME10 == "El Campo"), 
                  aes(label = NAME10, geometry = Shape), size = 2, family = "Atkinson Hyperlegible",
                  stat = "sf_coordinates",
                  # hjust = 0.5,
                  # vjust = 0,
                  # nudge_x = -10,
                  nudge_y = 10000,
                  direction = "x",
                  box.padding = 0.5,
                  segment.curvature = -0.1,
                  segment.ncp = 3,
                  segment.angle = 20,
                  color = "grey30",
                  bg.color = "white",
                  bg.r = 0.15
  ) +
  ##lavaca and navidad labs
  geom_sf_text(data = ws |> filter(label != "Garcitas Creek,\nPlacedo Creek\nand Cox Bay\nWatersheds"), 
                aes(label = label, geometry = Shape, color = label), 
                size = 3, 
                family = "Arial",
                fontface = "bold",
                stat = "sf_coordinates",
                show.legend = FALSE) +
  ##garcitas labs
  geom_text_repel(data = ws |> filter(label == "Garcitas Creek,\nPlacedo Creek\nand Cox Bay\nWatersheds"),
                  aes(label = label, geometry = Shape, color = label),
                  size = 2.5,
                  family = "Arial",
                  fontface = "plain",
                  stat = "sf_coordinates",
                  min.segment.length = 10000,
                  vjust = 0,
                  # nudge_x = -3000,
                  # nudge_y = -25000,
                  show.legend = FALSE) +
  ## Matagorda Bay Label
  geom_text_repel(data = waterbody_labs |> filter(lab == "Matagorda Bay"), 
                  aes(label = lab, geometry = geometry), 
                  size = 2, 
                  family = "Arial",
                  fontface = "bold",
                  stat = "sf_coordinates",
                  hjust = 1,
                  min.segment.length = 10000,
                  color = "grey30",
                  bg.color = "white") +
  ## Lavaca Bay Label
  geom_text_repel(data = waterbody_labs |> filter(lab == "Lavaca Bay"), 
                  aes(label = lab, geometry = geometry), 
                  size = 2, 
                  family = "Arial",
                  fontface = "bold",
                  stat = "sf_coordinates",
                  angle = -45,
                  vjust = 0,
                  min.segment.length = 10000,
                  color = "grey30",
                  bg.color = "white") +
  ## Lk Texana Label
  geom_text_repel(data = waterbody_labs |> filter(lab == "Lake\nTexana"), 
                  aes(label = lab, geometry = geometry), 
                  size = 2, 
                  family = "Arial",
                  fontface = "bold",
                  stat = "sf_coordinates",
                  # angle = 70,
                  # vjust = 0.7,
                  # hjust = 0.7,
                  nudge_x = -500,
                  nudge_y = -500,
                  min.segment.length = 10000,
                  color = "grey30",
                  bg.color = "white", alpha = 0.85) +
  ## western site labels
  geom_text_repel(data = df_sites |> filter(site_no == "08164000" |
                                              site_no == "08164390"),
                  aes(label = glue::glue("USGS-{site_no}"),
                      geometry = geometry),
                  family = "Atkinson Hyperlegible",
                  stat = "sf_coordinates",
                  size = 2.5,
                  direction = "y",
                  min.segment.length = 0,
                  nudge_x = -200000,
                  hjust = 1,
                  segment.curvature = -0.1,
                  segment.ncp = 3,
                  segment.angle = 20,
                  color = "grey30",
                  bg.color = "white") +
  ## eastern site labels
  geom_text_repel(data = df_sites |> filter(site_no == "08164450" |
                                              site_no == "08164504" |
                                              site_no == "08164503" |
                                              site_no == "08164525"),
                  aes(label = glue::glue("USGS-{site_no}"),
                      geometry = geometry),
                  family = "Atkinson Hyperlegible",
                  stat = "sf_coordinates",
                  size = 2.5,
                  direction = "y",
                  min.segment.length = 0,
                  nudge_x = 200000,
                  hjust = 0,
                  segment.curvature = -0.1,
                  segment.ncp = 3,
                  segment.angle = 20,
                  color = "grey30",
                  bg.color = "white") +
  ## estuary sites
  geom_text_repel(data = tceq_sites,
                  aes(label = MonitoringLocationIdentifier,
                      geometry = geometry),
                  family = "Atkinson Hyperlegible",
                  stat = "sf_coordinates",
                  size = 2.5,
                  direction = "y",
                  min.segment.length = 0,
                  nudge_x = 200000,
                  hjust = 0,
                  segment.curvature = -0.1,
                  segment.ncp = 3,
                  segment.angle = 20,
                  color = "grey30",
                  bg.color = "white") +
  ## scale bar
  annotation_scale(location = "bl", text_family = "Arial") +
  coord_sf(xlim = c(1266631.4, 
                    #1363148.7
                    1374000), 
           ylim = c(715099.2, 855290.5 ),
           crs = st_crs(counties_sub)) +
  scale_fill_carto_d(type = "qualitative", palette = "Vivid", direction = -1) +
  scale_color_carto_d(type = "qualitative", palette = "Vivid", direction = -1) +
  scale_shape_manual("", values = c(21, 22)) +
  labs(x = "", y = "") +
  theme_TWRI_print() +
  theme(panel.grid = element_blank(),
        #panel.grid = element_line(color = "grey80", linewidth = 0.1),
        panel.background = element_rect(fill = "ivory1"),
        axis.text = element_text(size = 8, family = "arial"),
        legend.text = element_text(family = "arial", size = 8))

## inset map
project <- st_as_sfc(st_bbox(ws))

p2 <- ggplot() +
  geom_sf(data = counties, fill = "white", size = 0.1) +
  geom_sf(data = project, fill = "transparent", color = "firebrick", linewidth = 1) +
  theme_void()


p3 <-p1 + inset_element(p2, left = 0.7, bottom = 0.7, right = 1, top = 1,
                   align_to = "full")


# ragg::agg_tiff("map.tif", width = 5.2, height = 6.75, units = "in", res = 600,
#                compression = "lzw")
# p3
# dev.off()

ragg::agg_png("fig1.png", width = 5.2, height = 6.75, units = "in", res = 600)
p3
dev.off()

