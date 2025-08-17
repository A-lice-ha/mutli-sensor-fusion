# Multisensor Image Fusion

## Project Overview
Fusion of Landsat (thermal/visible) and Sentinel-1 (microwave) data using:
- Weighted average fusion
- Laplacian pyramid decomposition

## Methodology Summary
| Step               | Key Operations                          |
|--------------------|-----------------------------------------|
| Preprocessing      | Cloud masking, dB conversion, scaling   |
| Weighted Fusion    | 50% TIR + 30% VIS + 20% SAR             |
| Laplacian Fusion   | 3-level pyramid + edge-optimized blending |
