#!/bin/bash -ue
qiime tools import     --type 'SampleData[SequencesWithQuality]'     --input-path F2-16s_T1_dir     --input-format CasavaOneEightSingleLanePerSampleDirFmt     --output-path F2-16s_T1_dir.demux.qza

qiime demux summarize     --i-data F2-16s_T1_dir.demux.qza     --o-visualization F2-16s_T1_dir.demux.qzv
