library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Process data for Stan model for MA analysis
deaths_shp <- readRDS("deaths_shp.rds")
MA_shp <- filter(deaths_shp, STATE == "MA")
data_overall <- cbind(MA_shp$sum_deaths, MA_shp$people,
                      MA_shp$zip, MA_shp$pm25_ensemble, MA_shp$poverty,
                      MA_shp$popdensity,MA_shp$medianhousevalue,MA_shp$pct_blk,
                      MA_shp$medhouseholdincome,MA_shp$pct_owner_occ,MA_shp$hispanic,
                      MA_shp$education,
                      MA_shp$amb_visit_pct,MA_shp$a1c_exm_pct
)
data.model_overall <- model.matrix(~data_overall-1)
X_overall <- scale(data.model_overall[,-(1:3)])
colnames(X_overall) <- c("pm25_ensemble","poverty","popdensity",
                         "medianhousevalue","pct_blk","medhouseholdincome","pct_owner_occ",
                         "hispanic","education","amb_visit_pct","a1c_exm_pct"
)
y_deaths <-  data.model_overall[,1]
E <-  data.model_overall[,2]
mu_x = final_data$mu_x
sigma_x = final_data$sigma_x

# Measurement error model
fitSimple_deaths_overall1 = stan("no_measurement.stan",
                                 data=list(N=N,y=y_deaths,E=E, X=X_overall, p=p),
                                 iter=1e4, chains=4, thin=1, verbose=TRUE)
saveRDS(fitSimple_deaths_overall1, "Simple_no_measurement_cali.rds")

# No measurement error model
fitSimple_deaths_overall_long = stan("measurement_model.stan",
                                     data=list(N=N,y=y_deaths,E=E, X=X_overall[,-1], mu_x=mu_x,
                                               sigma_x=sigma_x,p=p-1),
                                     iter=1e4, chains=4, thin=1, verbose=TRUE)
saveRDS(fitSimple_deaths_overall_long, "Simple_measurement_cali.rds")