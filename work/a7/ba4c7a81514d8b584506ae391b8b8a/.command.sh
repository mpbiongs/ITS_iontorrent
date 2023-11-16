#!/bin/bash -ue
itsxpress --fastq F1-16s_T1_L001_R1_001.fastq.gz --single_end --outfile F1-16s_T1_trimmed_L001_R1_001.fastq.gz --region ITS2 --taxa Fungi --threads 5
mkdir F1-16s_T1_dir
mv F1-16s_T1_trimmed_L001_R1_001.fastq.gz F1-16s_T1_dir
