#!/bin/bash -ue
check_samplesheet.py \
    samples.csv \
    samplesheet.valid.csv

cat <<-END_VERSIONS > versions.yml
"INPUT_CHECK:SAMPLESHEET_CHECK":
    python: $(python --version | sed 's/Python //g')
END_VERSIONS
