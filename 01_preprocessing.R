# Libraries
library(terra)
library(raster)
library(rasterVis)
library(entropy)
library(bitops)

# Set Working Directory
setwd("C:/User/location")

# Load Rasters
landsat <- brick("landsat.tif")   # brick for multiband loading 
sent1   <- brick("sentinel1.tif") 
qa_rast <- raster("landsat_QA.tif") # raster loads single band raster

# Resample Sentinel to Landsat
s1 <- resample(sent1, landsat, method="bilinear")

# Cloud/Shadow Mask
extract_bit <- function(r, bit_pos) calc(r, function(x) bitwAnd(bitwShiftR(as.integer(x), bit_pos), 1))
cloud_mask <- extract_bit(qa_rast, 3)
shadow_mask <- extract_bit(qa_rast, 4)
combined_mask <- cloud_mask + shadow_mask
combined_mask[combined_mask > 0] <- NA
landsat_masked <- mask(landsat, combined_mask)

# Sentinel-1 Preprocessing
s1_db <- calc(s1, fun = function(x) 10 * log10(x))
sigmoid_normalize <- function(x,a=0.1) 1 / (1 + exp(-a * x))
s1_n <- calc(s1_db, sigmoid_normalize)

# Extract & Normalize Landsat Bands
bands <- list(
  red   = landsat_masked$SR_B4,
  green = landsat_masked$SR_B3,
  blue  = landsat_masked$SR_B2,
  tir   = landsat_masked$ST_B10
)
normalize <- function(x) (x - cellStats(x,"min")) / (cellStats(x,"max") - cellStats(x,"min"))
bands_n <- lapply(bands, normalize)
vv_n <- normalize(s1_n[[1]])
vh_n <- normalize(s1_n[[2]])
