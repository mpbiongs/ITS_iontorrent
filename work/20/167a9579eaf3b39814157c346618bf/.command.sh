#!/bin/bash -ue
seqtk sample subseq2_its_L001_R1_001.fastq.gz 10000 > F2-16s_T1_L001_R1_001.fastq
gzip *.fastq
