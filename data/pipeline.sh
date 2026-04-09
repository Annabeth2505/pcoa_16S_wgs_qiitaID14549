#!/bin/bash
# Combined 16S + WGS PCoA pipeline
# Study: QIITA 14549 - Shotgun versus 16S - Museum and Fresh Leopard Frog Guts
# Author: Ananya Kharya
# References: 

# Step 1 - add new ID columns to metadata
awk 'NR==1 {print $0"\tnew_16S_id\tnew_WGS_id"; next} {print $0"\t"$1"_16S\t"$1"_WGS"}' data/frog_metadata.txt > data/metadata_added_cols.tsv

# Step 2 - rename sample IDs in feature tables
qiime feature-table rename-ids \
  --i-table data/16s_feature_table.qza \
  --m-metadata-file data/metadata_added_cols.tsv \
  --m-metadata-column new_16S_id \
  --p-axis sample \
  --o-renamed-table data/16s_renamed.qza

qiime feature-table rename-ids \
  --i-table data/wgs_feature_table.qza \
  --m-metadata-file data/metadata_added_cols.tsv \
  --m-metadata-column new_WGS_id \
  --p-axis sample \
  --o-renamed-table data/wgs_renamed.qza

# Step 3 - create separate metadata files with sequencing_type column
awk 'BEGIN{FS=OFS="\t"}
NR==1 {
  printf "sample-id";
  for(i=2; i<=NF-2; i++) printf OFS $i;
  print OFS "sequencing_type"
}
NR>1 {
  n=NF-1;
  printf $n;
  for(i=2; i<=NF-2; i++) printf OFS $i;
  print OFS "16S"
}' data/metadata_added_cols.tsv > data/metadata_16s.tsv

awk 'BEGIN{FS=OFS="\t"}
NR==1 {
  printf "sample-id";
  for(i=2; i<=NF-2; i++) printf OFS $i;
  print OFS "sequencing_type"
}
NR>1 {
  printf $NF;
  for(i=2; i<=NF-2; i++) printf OFS $i;
  print OFS "WGS"
}' data/metadata_added_cols.tsv > data/metadata_wgs.tsv

cat data/metadata_16s.tsv > data/metadata_combined.tsv
tail -n +2 data/metadata_wgs.tsv >> data/metadata_combined.tsv

# Step 4 - filter features against GG2 tree
qiime greengenes2 filter-features \
  --i-feature-table data/16s_renamed.qza \
  --i-reference data/2024.09.phylogeny.asv.nwk.qza \
  --o-filtered-feature-table data/16s_filtered.qza \
  --verbose

qiime greengenes2 filter-features \
  --i-feature-table data/wgs_renamed.qza \
  --i-reference data/2024.09.phylogeny.asv.nwk.qza \
  --o-filtered-feature-table data/wgs_filtered.qza \
  --verbose

# Step 5 - assign taxonomy
qiime greengenes2 taxonomy-from-table \
  --i-reference-taxonomy data/2024.09.taxonomy.asv.nwk.qza \
  --i-table data/16s_filtered.qza \
  --o-classification data/16s_taxonomy.qza \
  --verbose

qiime greengenes2 taxonomy-from-table \
  --i-reference-taxonomy data/2024.09.taxonomy.asv.nwk.qza \
  --i-table data/wgs_filtered.qza \
  --o-classification data/wgs_taxonomy.qza \
  --verbose

# Step 6 - merge filtered tables and taxonomies
qiime feature-table merge \
  --i-tables data/16s_filtered.qza \
  --i-tables data/wgs_filtered.qza \
  --o-merged-table data/merged_filtered_table.qza

qiime feature-table merge-taxa \
  --i-data data/16s_taxonomy.qza \
  --i-data data/wgs_taxonomy.qza \
  --o-merged-data data/merged_taxonomy.qza

# Step 7 - compute weighted UniFrac distance matrix
qiime diversity beta-phylogenetic \
  --i-table data/merged_filtered_table.qza \
  --i-phylogeny data/2024.09.phylogeny.asv.nwk.qza \
  --p-metric weighted_unifrac \
  --o-distance-matrix data/weighted_unifrac.qza \
  --verbose

# Step 8 - run PCoA
qiime diversity pcoa \
  --i-distance-matrix data/weighted_unifrac.qza \
  --o-pcoa data/weighted_unifrac_pcoa.qza

# Step 9 - generate Emperor plot
qiime emperor plot \
  --i-pcoa data/weighted_unifrac_pcoa.qza \
  --m-metadata-file data/metadata_combined.tsv \
  --o-visualization data/weighted_unifrac_emperor.qzv
