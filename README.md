# Combined 16S + WGS PCoA using Greengenes2

A pipeline for generating combined PCoA visualizations from paired 
16S amplicon and shotgun metagenomic sequencing data using the 
Greengenes2 unified phylogenetic tree.

## Study
- QIITA Study ID: 14549 
- Title: Shotgun versus 16S - Museum and Fresh Leopard Frog Guts
- Host: Rana pipiens (northern leopard frog)
- BioProject: PRJNA836960

## Approach
Uses GG2's unified phylogenetic tree to place both 16S ASVs and 
WGS genome features on the same reference, enabling UniFrac 
distance computation across sequencing types.

## Requirements
- QIIME2 amplicon environment (2024.09)
- Greengenes2 plugin
- GG2 reference files (2024.09) --available for public access at the official Greengenes2 website

## Usage
See data/pipeline.sh for the full workflow.

## Reference
McDonald et al. 2023, Nature Biotechnology - Greengenes2
