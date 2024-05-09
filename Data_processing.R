library(dplyr)
library(lubridate)
library(fst)
library(ggplot2)
library(data.table)
library(sfdep)
library(sf)
sf::sf_use_s2(FALSE)
library(sp)
library(spdep)
library(spatialreg)
library(MASS)
library(gridExtra)
library(sfdep)
library(mapview)
devtools::install_github("czigler/zipcode")
devtools::install_github("czigler/arepa")
library(arepa)

# Get EPA monitor data
get_AQS_data_annual(year = 2016)
data <- load_annual_average(year = 2016)
x <- filter(data, Parameter.Code == 88101,  Pollutant.Standard == "PM25 Annual 2012") %>%
  group_by(Address) %>%
  slice_max(order_by = Observation.Percent, n = 1, with_ties = FALSE) %>%
  ungroup()
state_names <- c("Maryland", "California", "Alabama", "Wisconsin", "Oklahoma", "Rhode Island", "Connecticut", "Colorado", "Massachusetts", "Minnesota", "Ohio", "Louisiana", "Tennessee", "Florida", "Arkansas", "New Jersey", "Indiana", "Pennsylvania", "Vermont", "Arizona", "Washington", "Iowa", "North Dakota", "Michigan", "South Dakota", "South Carolina", "North Carolina", "Oregon", "Wyoming", "Texas", "Kansas", "Illinois", "Utah", "Nevada", "Kentucky", "Montana", "New Hampshire", "Georgia", "Virginia", "New York", "New Mexico", "Mississippi", "Nebraska", "District Of Columbia", "Maine", "Delaware", "Idaho", "Missouri")
x <- filter(x, State.Name %in% state_names)
df <- data.frame(latitude = x$Latitude, longitude = x$Longitude, pm25_monitors = x$Arithmetic.Mean, sd = x$Arithmetic.Standard.Dev)
write.csv(df, file = "pm_monitor.csv")


# deaths data set 2016
deaths <- read.fst("/n/dominici_nsaph_l3/Lab/projects/analytic/denom_by_year/confounder_exposure_merged_nodups_health_2016.fst")

# Filter data by state
state_codes <- c("AL", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI",
                 "WY")
deaths <- filter(deaths, statecode %in% state_codes)
deaths_m65 <- filter(deaths, age >= 65 & age < 75, sex == 1)
deaths_m75 <- filter(deaths, age >= 75 & age < 85, sex == 1)
deaths_m85 <- filter(deaths, age >= 85, sex == 1)
deaths_f65 <- filter(deaths, age >= 65 & age < 75, sex == 2)
deaths_f75 <- filter(deaths, age >= 75 & age < 85, sex == 2)
deaths_f85 <- filter(deaths, age >= 85, sex == 2)

# Sum deaths within zipcode
deathssum <- deaths %>% group_by(zip) %>% 
  summarise(sum_deaths=sum(dead),
            .groups = 'drop') %>%
  as.data.frame()
deathssum_m65 <- deaths_m65 %>% group_by(zip) %>% 
  summarise(sum_deaths=sum(dead),
            .groups = 'drop') %>%
  as.data.frame()
deathssum_m75 <- deaths_m75 %>% group_by(zip) %>% 
  summarise(sum_deaths=sum(dead),
            .groups = 'drop') %>%
  as.data.frame()
deathssum_m85 <- deaths_m85 %>% group_by(zip) %>% 
  summarise(sum_deaths=sum(dead),
            .groups = 'drop') %>%
  as.data.frame()
deathssum_f65 <- deaths_f65 %>% group_by(zip) %>% 
  summarise(sum_deaths=sum(dead),
            .groups = 'drop') %>%
  as.data.frame()
deathssum_f75 <- deaths_f75 %>% group_by(zip) %>% 
  summarise(sum_deaths=sum(dead),
            .groups = 'drop') %>%
  as.data.frame()
deathssum_f85 <- deaths_f85 %>% group_by(zip) %>% 
  summarise(sum_deaths=sum(dead),
            .groups = 'drop') %>%
  as.data.frame()

#Aggregate deaths
deaths_zip <- deaths[!duplicated(deaths$zip), ][,c(1,22:64)]
deaths_sums <- data.frame(zip=deaths[!duplicated(deaths$zip), ]$zip, 
                          sum_deaths=deathssum$sum_deaths, 
                          people=as.numeric(table(deaths$zip)))
deaths_m65_sums <- data.frame(zip=deaths_m65[!duplicated(deaths_m65$zip), ]$zip, 
                              sum_deathsm65=deathssum_m65$sum_deaths, 
                              peoplem65=as.numeric(table(deaths_m65$zip)))
deaths_m75_sums <- data.frame(zip=deaths_m75[!duplicated(deaths_m75$zip), ]$zip, 
                              sum_deathsm75=deathssum_m75$sum_deaths, 
                              peoplem75=as.numeric(table(deaths_m75$zip)))
deaths_m85_sums <- data.frame(zip=deaths_m85[!duplicated(deaths_m85$zip), ]$zip, 
                              sum_deathsm85=deathssum_m85$sum_deaths, 
                              peoplem85=as.numeric(table(deaths_m85$zip)))
deaths_f65_sums <- data.frame(zip=deaths_f65[!duplicated(deaths_f65$zip), ]$zip, 
                              sum_deathsf65=deathssum_f65$sum_deaths, 
                              peoplef65=as.numeric(table(deaths_f65$zip)))
deaths_f75_sums <- data.frame(zip=deaths_f75[!duplicated(deaths_f75$zip), ]$zip, 
                              sum_deathsf75=deathssum_f75$sum_deaths, 
                              peoplef75=as.numeric(table(deaths_f75$zip)))
deaths_f85_sums <- data.frame(zip=deaths_f85[!duplicated(deaths_f85$zip), ]$zip, 
                              sum_deathsf85=deathssum_f85$sum_deaths, 
                              peoplef85=as.numeric(table(deaths_f85$zip)))

deaths_merged <- plyr::join_all(list(deaths_zip,deaths_sums,deaths_m65_sums,deaths_m75_sums,deaths_m85_sums,
                                     deaths_f65_sums,deaths_f75_sums,deaths_f85_sums), by='zip', type='left')

### Shapefile
USA <- st_read("/n/dominici_nsaph_l3/Lab/data/shapefiles/zip_shape_files/Zipcode_Info/polygon/ESRI16USZIP5_POLY_WGS84.shp")
names(USA)[names(USA) == "ZIP"] <- "zip"
USA$zip <- as.numeric(USA$zip)
region <- filter(USA, STATE %in% state_codes)

### merge shapefile with deaths
deaths_shp <- left_join(region, deaths_merged, by = "zip")

# Define the variable indicating NA values in any variable
sf::sf_use_s2(FALSE)
na_regions_zips <- deaths_shp[which(rowSums(is.na(deaths_shp)) > 0), ]
n_na_zips <- length(na_regions_zips)
touches <- st_touches(deaths_shp)
touches_zip <- list()
for (i in 1:n_na_zips) {
  touches_zip[i][[1]] <- deaths_shp$zip[touches[deaths_shp$zip %in% na_regions_zips][i][[1]]]
} 

# Function to find the adjacent region with the largest population
find_adjacent_max_population <- function(region_zip) {
  # region <- deaths_shp[region_index, ]
  adjacent_zips <- touches_zip[which(na_regions_zips == region_zip)][[1]]
  valid_zips <- adjacent_zips[adjacent_zips %in% deaths_shp$zip]
  adjacent_populations <- deaths_shp$population[deaths_shp$zip  %in% valid_zips]
  if (length(adjacent_populations) == 0){
    return(find_adjacent_max_population(adjacent_zips[1]))
  }
  if (sum(is.na(adjacent_populations)) == length(adjacent_populations)) {
    return(valid_zips[1])  # No adjacent regions
  }
  
  max_adjacent_zip <- valid_zips[which.max(adjacent_populations)]
  return(max_adjacent_zip)
}

# Loop through NA regions and merge them with adjacent region having largest population
for (i in 1:n_na_zips) {
  print(i)
  na_region_zip <- na_regions_zips[i]
  max_adjacent_zip <- find_adjacent_max_population(na_region_zip)
  merged_region <- st_union(deaths_shp[deaths_shp$zip == max_adjacent_zip, ], deaths_shp[deaths_shp$zip == na_region_zip, ])[,1:26]
  # if (!is.null(max_adjacent_index)) {
  # Merge the NA region with the adjacent region having the largest population
  if (dim(merged_region)[1]==0){
    deaths_shp <- deaths_shp[!deaths_shp$zip == na_region_zip, ]
  } else {
    deaths_shp[deaths_shp$zip == max_adjacent_zip, ] <- merged_region
    
    # Remove the adjacent region
    deaths_shp <- deaths_shp[!deaths_shp$zip == na_region_zip, ]
  }
  # }
}

saveRDS(deaths_shp, file = "deaths_shp.rds")