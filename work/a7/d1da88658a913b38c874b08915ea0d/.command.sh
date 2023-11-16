#!/bin/bash -ue
qiime dada2 denoise-pyro     --i-demultiplexed-seqs F1-16s_T1_dir.demux.qza     --p-trunc-len 0     --p-trim-left 15     --p-trunc-q 3     --p-max-ee 1     --o-representative-sequences F1-16s_T1_dir.rep-seqs.qza     --o-table F1-16s_T1_dir.table.qza     --o-denoising-stats F1-16s_T1_dir.stats.qza     --verbose
