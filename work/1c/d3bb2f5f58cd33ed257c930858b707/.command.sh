#!/bin/bash -ue
qiime dada2 denoise-pyro     --i-demultiplexed-seqs F2-16s_T1.demux.qza     --p-trunc-len 0     --p-trim-left 15     --p-trunc-q 3     --p-max-ee 1     --o-representative-sequences F2-16s_T1.rep-seqs.qza     --o-table F2-16s_T1.table.qza     --o-denoising-stats F2-16s_T1.stats.qza     --verbose
