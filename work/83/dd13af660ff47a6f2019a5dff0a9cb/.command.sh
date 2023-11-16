#!/bin/bash -ue
qiime feature-classifier classify-consensus-blast     --i-query F1-16s_T1.rep-seqs.qza     --i-reference-reads unite.qza     --i-reference-taxonomy unite-taxonomy.qza     --p-maxaccepts 1     --p-perc-identity 0.99     --o-classification classification.qza     --o-search-results blastresults.qza
