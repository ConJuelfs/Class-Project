
library(tidyverse)
library(elevatr)
library(raster)
library(sp)
library(sf)

d <- 
  read_csv("pbdb_data with LL.csv", skip = 19) %>%  # just ignore all the warnings
  select(lng, lat, cc) %>% 
  rename(x = lng, y = lat)

# how many points per country?
count(d, cc) %>% 
  arrange(-n)

d_us <- filter(d, cc == "US")

# use elevatr to get elevation data for points

# or download SRTM data for US (maybe getData() in raster package)

elev <- getData()
# elev should be a raster

d_us_sp <- 
  d_us %>% 
  st_as_sf(coords = c("x", "y"),
           crs = "+proj=longlat +datum=WGS84") %>% 
  st_tranform(projection(elev)) %>% 
  as("Spatial")

raster::extract(elev, d_us_sp)