
library(elevatr)
library(raster)
library(sp)
library(sf)
library(ggplot2)
library(tiff)
library(tidyverse)

d <- 
  read.csv("pbdb_data with LL.csv", skip = 19) %>%  # just ignore all the warnings
  select(lng, lat, cc) %>% 
  rename(x = lng, y = lat)

# how many points per country?
count(d, cc) %>% 
  arrange(-n)

d_us <- filter(d, cc == "US")

# use elevatr to get elevation data for points

# or download SRTM data for US (maybe getData() in raster package)

elev <- getData('alt', country = 'US', mask = TRUE)
# elev should be a raster

plot(elev[[4]])

plot(elev[[3]])

plot(elev[[2]])

plot(elev[[1]])

elev_2 <- merge(elev[[1]], elev[[2]])

plot(elev_2)

# elevation parameters

d_us_sp <- 
  d_us %>% 
  st_as_sf(coords = c("x", "y"),
           crs = "+proj=longlat +datum=WGS84") %>% 
#  st_transform(projection(elev[[1]])) %>% 
  as("Spatial")

# OGR error? something wrong with shapefile? Not shapefile though

ED <- tibble(elev = raster::extract(elev_2, d_us_sp))

ED #Extracted data table, LL and elevation

bind_cols(d_us, ED)


#Histogram stuff
ggplot(ED, aes(x = elev)) +
  geom_histogram()

#changing binwidth to 50 -- Way too big, changed to 1 so that 90% of data wasn't at zero

ggplot(ED, aes(x = elev)) +
  geom_histogram(binwidth = 1)
# a lot of 0's?  -- Just low elevations/filtered out below

#Making prettier

ggplot(ED, aes(x = elev)) +
  geom_histogram(binwidth = 25) +
    xlab("Elevation (m)") +
      ylab("Number of fossil occurences") +
        theme_bw()
#Filtering out zeros



ggplot(filter(ED, elev != 0), aes(x = elev)) +
  geom_histogram(binwidth = 25) +
  xlab("Elevation (m)") +
  ylab("Number of fossil occurences") +
  theme_bw()

#Saved above plot
ggsave("Elevation binwidth25 no zero.png")
            
ggplot(ED, aes(x = elev)) +
  geom_histogram(binwidth = 25) +
  xlab("Elevation (m)") +
  ylab("Number of fossil occurences") +
  theme_bw()

ggsave("elevation binwidth50 no zero.png")

ggsave("Elevation binwidth50 with zeros.png")

ggsave("Elevation binwidth25 with zeros.png")

readTIFF("wc2.0_2.5m_prec_01.tif", native = TRUE, convert = FALSE,
         info = FALSE, indexed = FALSE, as.is = TRUE)

tiff(filename = "wc2.0_2.5m_prec_01.tif", 
     )