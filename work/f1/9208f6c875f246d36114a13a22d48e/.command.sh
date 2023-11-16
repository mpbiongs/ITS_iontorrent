#!/bin/bash -ue
itsxpress --fastq F1-16s_T1_L001_R1_001.fastq.gz --single_end --outfile F1-16s_T1trimmed_L001_R1_001.fastq.gz --region ITS2 --taxa Fungi --threads 5
