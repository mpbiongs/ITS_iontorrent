#!/bin/bash -ue
qiime feature-table filter-features     --i-table F1-16s_T1_dir.table.qza     --p-min-frequency 100     --o-filtered-table filtered-table.qza
