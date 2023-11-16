#!/bin/bash -ue
seqtk sample subseq_its_L001_R1_001.fastq.gz 10000 > F1-16s_T1_L001_R1_001.fastq
gzip *.fastq
