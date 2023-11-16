#!/bin/bash -ue
qiime feature-table tabulate-seqs     --i-data F2-16s_T1_dir.rep-seqs.qza     --o-visualization rep-seqs.qzv

qiime feature-table summarize     --i-table F2-16s_T1_dir.table.qza     --o-visualization table.qzv

qiime feature-table summarize     --i-table filtered-table.qza     --o-visualization filtered-table.qzv

qiime metadata tabulate     --m-input-file F2-16s_T1_dir.stats.qza     --o-visualization stats.qzv
