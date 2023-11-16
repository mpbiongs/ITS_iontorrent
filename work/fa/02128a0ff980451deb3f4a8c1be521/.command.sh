#!/bin/bash -ue
qiime tools import     --type 'SampleData[SequencesWithQuality]'     --input-path F1-16s_T1_dir     --input-format CasavaOneEightSingleLanePerSampleDirFmt     --output-path F1-16s_T1_dir.demux.qza

qiime demux summarize     --i-data F1-16s_T1_dir.demux.qza     --o-visualization F1-16s_T1_dir.demux.qzv
