#!/bin/bash -ue
qiime taxa barplot     --i-table filtered-table.qza     --i-taxonomy classification.qza     --o-visualization "taxa-bar-plots.qzv"

mkdir extracted
unzip taxa-bar-plots.qzv '*/data/*' -d extracted
mv extracted/*/data/* .
mv index.html Taxonomy_mqc.html
for file in *.csv; do mv "$file" "F2-16s_T1.$file"; done
rm -rf extracted
