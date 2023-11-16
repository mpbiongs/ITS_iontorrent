#!/bin/bash -ue
itsxpress --fastq F2-16s_T1_L001_R1_001.fastq.gz --single_end --outfile F2-16s_T1_trimmed_L001_R1_001.fastq.gz --region ITS2 --taxa Fungi --threads 5
mkdir F2-16s_T1_dir
mv F2-16s_T1_trimmed_L001_R1_001.fastq.gz F2-16s_T1_dir
