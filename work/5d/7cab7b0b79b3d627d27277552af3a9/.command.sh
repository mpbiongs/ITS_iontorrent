#!/bin/bash -ue
qiime tools import     --type 'SampleData[SequencesWithQuality]'     --input-path F1-16s_T1.seqs     --input-format CasavaOneEightSingleLanePerSampleDirFmt     --output-path F1-16s_T1.demux.qza

qiime demux summarize     --i-data F1-16s_T1.demux.qza     --o-visualization F1-16s_T1.demux.qzv
