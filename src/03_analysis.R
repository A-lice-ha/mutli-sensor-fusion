# METRICS: SD & ENTROPY
calc_metrics <- function(r,name){
  vals <- getValues(r); vals <- vals[!is.na(vals)]
  SD <- sd(vals)
  probs <- hist(vals, breaks=256, plot=FALSE)$counts / sum(hist(vals, breaks=256, plot=FALSE)$counts)
  Entropy <- -sum(probs * log2(probs + 1e-12))
  data.frame(Raster=name, SD=SD, Entropy=Entropy)
}

all_rasters <- c(bands_n, list(Fused_Enhanced=fused_weighted, Fused_TR_Lap=fused_TR_Lap))
metrics_df <- do.call(rbind, lapply(names(all_rasters), function(n) calc_metrics(all_rasters[[n]], n)))
print(metrics_df)

# CORRELATION ANALYSIS
inputs <- c(bands_n, list(VV=vv_n, VH=vh_n))
fused_list <- list(Fused_Enhanced=fused_weighted, Fused_TR_Lap=fused_TR_Lap)

cor_results <- do.call(rbind, lapply(names(fused_list), function(f_name){
  r <- fused_list[[f_name]]
  do.call(rbind, lapply(names(inputs), function(i_name){
    data.frame(Fused=f_name, Input=i_name, Correlation=cor(values(r), values(inputs[[i_name]]), use="complete.obs"))
  }))
}))
print(cor_results)
