library(spdep)
library(sf)
library(sp)
library(INLA)
library(ggplot2)
library(viridis)
library(dplyr)

# Combine ML predictions with monitoring data
monitors <- read.csv("pm_monitor.csv")
zips_shp <- readRDS("deaths_shp.rds")
monitors_points <- st_as_sf(monitors, coords = c("longitude", "latitude"), crs = st_crs(zips_shp))
joined_data <- st_join(monitors_points, zips_shp)
joined_data$diff <- joined_data$pm25_ensemble-joined_data$pm25_monitors
aggregated_data <- joined_data %>%
  group_by(zip) %>%
  summarise(pm25_monitors = mean(pm25_monitors, na.rm = TRUE), pm25_ensemble = mean(pm25_ensemble, na.rm = TRUE)) 
final_data <- zips_shp %>%
  left_join(as.data.frame(aggregated_data)[,1:2], by = "zip") 
area_neighbors <- poly2nb(final_data)
adjacency_matrix <- nb2mat(final_data, style = "B", zero.policy = TRUE)
final_data$area_id <- seq_len(nrow(final_data))


# Run spatial regression with INLA
formula <- pm25_monitors ~ pm25_ensemble + f(area_id, model = "besag", graph = adjacency_matrix)
result <- inla(formula, family = "gaussian", data = as.data.frame(final_data),
               control.predictor = list(compute = TRUE), verbose = TRUE)
final_data$mu_x <- result$summary.fitted.values$mean
final_data$sigma_x <- result$summary.fitted.values$sd