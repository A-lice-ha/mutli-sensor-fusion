# ENHANCED WEIGHTED FUSION
# Define fusion weights
weights <- list(thermal=0.5, visible=0.3, micro=0.2)

# Create visible composite (RGB average)
visible_composite <- (bands_n$red + bands_n$green + bands_n$blue) / 3

# Create microwave composite (VV + VH average)
micro_composite <- (vv_n + vh_n) / 2

# Weighted fusion
fused_weighted <- overlay(
  bands_n$tir, visible_composite, micro_composite,
  fun = function(t, v, m) {
    vals <- c(t,v,m)
    if(all(is.na(vals))) return(NA)
    weights$thermal*t + weights$visible*v + weights$micro*m
  }
)
names(fused_weighted) <- "Fused_Enhanced"

# LAPLACIAN PYRAMID FUSION
downsample <- function(r) aggregate(r, fact=2, fun=mean)
upsample <- function(r, template) resample(r, template, method="bilinear")
build_gaussian <- function(r, levels){ pyr <- list(r); for(i in 2:levels) pyr[[i]] <- downsample(pyr[[i-1]]); pyr }
build_laplacian <- function(gauss_pyr){
  n <- length(gauss_pyr); lap <- list()
  for(i in 1:(n-1)) lap[[i]] <- gauss_pyr[[i]] - upsample(gauss_pyr[[i+1]], gauss_pyr[[i]])
  lap[[n]] <- gauss_pyr[[n]]; lap
}
reconstruct_laplacian <- function(lap){
  img <- lap[[length(lap)]]
  for(i in (length(lap)-1):1) img <- upsample(img, lap[[i]]) + lap[[i]]
  img
}

levels <- 3
tir_gauss <- build_gaussian(bands_n$tir, levels)
red_gauss <- build_gaussian(bands_n$red, levels)
tir_lap <- build_laplacian(tir_gauss)
red_lap <- build_laplacian(red_gauss)
fused_lap <- lapply(1:levels, function(i) 0.6*tir_lap[[i]] + 0.4*red_lap[[i]])
fused_TR_Lap <- reconstruct_laplacian(fused_lap)
extent(fused_TR_Lap) <- extent(bands_n$tir); crs(fused_TR_Lap) <- crs(bands_n$tir)
