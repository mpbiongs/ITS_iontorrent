#!/bin/bash -ue
qiime dada2 denoise-pyro     --i-demultiplexed-seqs F2-16s_T1_dir.demux.qza     --p-trunc-len 450     --p-trim-left 15     --p-trunc-q 3     --p-max-ee 1     --o-representative-sequences F2-16s_T1_dir.rep-seqs.qza     --o-table F2-16s_T1_dir.table.qza     --o-denoising-stats F2-16s_T1_dir.stats.qza     --verbose
