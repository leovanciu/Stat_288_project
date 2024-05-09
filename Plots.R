library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
library(ggplot2)
library(tidyverse)  
library(bayesplot) 

# Figure 3
color_limits <- c(0,17)
num_colors <- 100
color_palette <- viridis::viridis(num_colors, option = "C")

png("Figure_3.png", width=2000, height=1000)
ggplot() +
  geom_sf(data= final_data, aes(fill = pm25_ensemble), color=NA, show.legend = "point") +
  geom_sf(data = monitors_points, aes(color = pm25_monitors), size = 10, stroke = 0.2, show.legend = "point") + 
  geom_sf(data = monitors_points, aes(color = pm25_monitors), shape = 21, color = "black", size = 10, stroke =0.2, show.legend = "point") +  
  scale_fill_gradientn(colors = color_palette, limits = color_limits, name = "PM2.5",
                       guide = guide_colorbar(title.position = "top", barwidth = 4, barheight = 10)) +
  scale_color_gradientn(colors = color_palette, limits = color_limits, name = "PM2.5",
                        guide = "none") + 
  labs(title = "Observed/predicted PM2.5 levels") +
  theme_minimal() +
  theme(legend.position = "right",
        text = element_text(size = 20),  
        plot.title = element_text(size = 30, face = "bold"),  
        plot.subtitle = element_text(size = 20),  
        axis.title = element_text(size = 20),  
        legend.title = element_text(size = 20), 
        legend.text = element_text(size = 20))  
dev.off()

# Figure 4
df <- data.frame(pm25_ensemble = final_data$pm25_ensemble, pm25_monitors = final_data$pm25_monitors)
png("Figure_4.png", width=1000, height=500)
ggplot(df, aes(x = pm25_ensemble, y = pm25_monitors)) +
  geom_point() +  
  labs(title = "Observed vs. Predicted PM2.5",
       x = "Observed PM2.5",
       y = "Predicted PM2.5") +
  theme_minimal() +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +
  theme(text = element_text(size = 12)) 
dev.off()

# Figure 5
png("Figure_5.png", width=1000, height=500)
ggplot(deaths_shp_overall) +
  geom_sf(aes(fill = mu_x), color = NA) +
  scale_fill_viridis(option = "C", name = "PM2.5 sd", guide = guide_legend(title.position = "top")) +
  labs(title = "Posterior PM2.5 mean") +
  theme_minimal()
dev.off()

# Figure 6
png("Figure_6.png", width=1000, height=500)
ggplot(deaths_shp_overall) +
  geom_sf(aes(fill = sigma_x), color = NA) +
  scale_fill_viridis(option = "C", name = "PM2.5 sd", guide = guide_legend(title.position = "top")) +
  labs(title = "Posterior PM2.5 sd") +
  theme_minimal()
dev.off()

# Figure 7
png("Figure_7.png", width=1000, height=500)
ggplot(MA) +
  geom_sf(aes(fill = mu_x), color = NA) +
  scale_fill_viridis(option = "C", name = "PM2.5 sd", guide = guide_legend(title.position = "top")) +
  labs(title = "Posterior PM2.5 mean") +
  theme_minimal()
dev.off()

# Figure 8
png("Figure_8.png", width=1000, height=500)
ggplot(MA) +
  geom_sf(aes(fill = sigma_x), color = NA) +
  scale_fill_viridis(option = "C", name = "PM2.5 sd", guide = guide_legend(title.position = "top")) +
  labs(title = "Posterior PM2.5 sd") +
  theme_minimal()
dev.off()


# Figure 9
model_no_measurement <- readRDS("no_measurement.rds")
covariate_names <- c("pm25", "poverty", "popdensity",
                     "medhousevalue", "pct_black", "medhouseincome", "pct_owner_occ",
                     "pct_hispanic", "education", "amb_visit_pct", "a1c_exm_pct")
names(model_no_measurement)[2:12] <- covariate_names
pdf("Figure_9.pdf")
plot(model_measurement, pars = covariate_names)
dev.off()

# Figure 10
model_measurement <- readRDS("measuremen_modelt.rds")
names(model_measurement)[2:12] <- covariate_names
pdf("Figure_10.pdf")
plot(model_measurement, pars = covariate_names)
dev.off()

# Convergence
color_scheme_set("viridis")
pdf("Figure_11.pdf")
mcmc_trace(model_measurement, pars = c("beta1"))
dev.off()
pdf("Figure_12.pdf")
mcmc_trace(model_no_measurement, pars = c("beta[1]"))
dev.off()