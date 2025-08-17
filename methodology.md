## Methodology

### 1. Data Preprocessing
**Input Datasets:**
- **Landsat 8/9** (Thermal + Visible)
  - Cloud/Shadow Masking:  
    ```r
    cloud_mask <- bitwAnd(bitwShiftR(QA_PIXEL, 3), 1)
    shadow_mask <- bitwAnd(bitwShiftR(QA_PIXEL, 4), 1)
    ```
  - Normalization:  
    ```r
    normalize <- function(x) (x - min(x)) / (max(x) - min(x))
    ```

- **Sentinel-1** (Microwave)
  - dB Conversion:  
    ```r
    s1_db <- 10 * log10(s1)
    ```
  - Sigmoid Normalization:  
    ```r
    s1_norm <- 1 / (1 + exp(-0.1 * s1_db))
    ```

### 2. Fusion Techniques
#### A. Weighted Average Fusion
```r
fused_weighted <- 0.5*tir + 0.3*visible_composite + 0.2*micro_composite
```
- **Weights**: Thermal (50%), Visible (30%), Microwave (20%)
- **Visible Composite**: Mean of Red, Green, Blue bands  
- **Microwave Composite**: Mean of VV and VH polarizations

#### B. Laplacian Pyramid Fusion
**Steps:**
1. Build Gaussian pyramids (3 levels):
   ```r
   downsample <- function(r) aggregate(r, fact=2, fun=mean)
   ```
2. Generate Laplacian pyramids:
   ```r
   lap_level <- gauss_level - upsample(next_gauss_level)
   ```
3. Fuse pyramids level-wise:
   ```r
   fused_lap <- 0.6*tir_lap + 0.4*red_lap
   ```
4. Reconstruct final image:
   ```r
   fused_image <- sum(upsampled_levels) + residual
   ```

### 3. Evaluation Metrics
#### Quantitative
- **Standard Deviation (SD)**: Spatial variability
  ```r
  cellStats(fused, sd)
  ```
- **Shannon Entropy**: Information content
  ```r
  entropy <- -sum(p * log2(p)) # p = histogram probabilities
  ```
- **Edge Preservation Index (EPI)**:
  ```r
  sobel_orig <- focal(orig, sobel_kernel)
  sobel_fused <- focal(fused, sobel_kernel)
  EPI <- cor(sobel_orig, sobel_fused)
  ```

#### Visual
- RGB composites of fused results
- Side-by-side comparisons with original bands

### 4. Computational Setup
- **Software**: R 4.3+
- **Key Packages**:  
  ```r
  library(raster)    # Core processing
  library(EBImage)   # SSIM (if used)
  library(bitops)    # QA masking
  ```
