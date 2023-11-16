params.trunclen = 0
params.minreads = 100
params.refseqs = "$projectDir/unite.qza"
params.reftax =  "$projectDir/unite-taxonomy.qza"
params.maxaccepts = 1
params.artifacts = "$projectDir/artifacts"
params.outdir = "s3://mp-bioinfo/scratch/results"
params.logo = "$projectDir/assets/logo.png"
params.input = "$projectDir/samples.csv"

include { INPUT_CHECK  } from './subworkflows/local/input_check'
include { SEQTK_SAMPLE } from './modules/local/seqtk/sample'

log.info """\
    MP - Q I I M E   P I P E L I N E
    ===================================
    Reads        : ${params.reads}
    Trunc Len    : ${params.trunclen}
    Min Reads    : ${params.minreads}
    """
    .stripIndent(true)

println "reads: $params.reads"

process IMPORT {
    tag "Importing sequences ${sample_id}"
    container "andrewatmp/testf"
    publishDir "$projectDir/results/results_${sample_id}"

    input:
    tuple val(sample_id), path(reads)

    output:
    path("${sample_id}.demux.qza"), emit: demux
    path("${sample_id}.demux.qzv"), emit: demuxvis
    val("${sample_id}"), emit: id

    script:
    """
    qiime tools import \
    --type 'SampleData[SequencesWithQuality]' \
    --input-path ${reads} \
    --input-format CasavaOneEightSingleLanePerSampleDirFmt \
    --output-path ${sample_id}.demux.qza

    qiime demux summarize \
    --i-data ${sample_id}.demux.qza \
    --o-visualization ${sample_id}.demux.qzv

    """
}

process ITSXPRESS {
    tag "Trim ITS region from ${sample_id}"
    container "itsxpress"

    input:
    tuple val(sample_id), path(reads)

    output:
    val(sample_id), emit: reads
    path("${sample_id}.seqs"), emit: dir
    // path("${sample_id}trimmed.seqs"), emit: seqsDir
    // val("${sample_id}"), emit: id

    script:
    """
    itsxpress --fastq ${reads} --single_end --outfile ${sample_id}_trimmed_L001_R1_001.fastq.gz --region ITS2 --taxa Fungi --threads 5
    mkdir ${sample_id}.seqs
    mv ${sample_id}_trimmed_L001_R1_001.fastq.gz ${sample_id}.seqs
    """
}

process DADA {

    tag "Dada2 Error Correction"
    container "andrewatmp/testf"


    input:
    path(qza)
    val(sample_id)
    
    output:
    path("${sample_id}.rep-seqs.qza"), emit: repseqs
    path("${sample_id}.table.qza"), emit: table
    path("${sample_id}.stats.qza"), emit: stats
    val("${sample_id}"), emit: ids

    script:

    """
    qiime dada2 denoise-pyro \
    --i-demultiplexed-seqs $qza \
    --p-trunc-len ${params.trunclen} \
    --p-trim-left 15 \
    --p-trunc-q 3 \
    --p-max-ee 1 \
    --o-representative-sequences ${sample_id}.rep-seqs.qza \
    --o-table ${sample_id}.table.qza \
    --o-denoising-stats ${sample_id}.stats.qza \
    --verbose
    """

}

process MINREADS {

    tag "Filtering for min reads"
    container "andrewatmp/testf"

    input:
    path(table)
    val(sample_id)


    output:
    tuple val(sample_id), path("filtered-table.qza"), emit: filtered


    script:

    """
    qiime feature-table filter-features \
    --i-table ${table} \
    --p-min-frequency ${params.minreads} \
    --o-filtered-table filtered-table.qza
    """
}

process DADARESULTS {

    tag "Generate dada visualizations"
    container "andrewatmp/testf"


    input:
    path(repseqs)
    path(table)
    path(stats)
    val(foo)
    tuple val(sample_id), path(filtered)

  

    output:
    path("rep-seqs.qzv"), emit: repseqsvis
    path("table.qzv"), emit: tablevis
    path("stats.qzv"), emit: statsvis
    path("filtered-table.qzv"), emit: filteredtablevis


    script:

    """
    qiime feature-table tabulate-seqs \
    --i-data $repseqs \
    --o-visualization rep-seqs.qzv

    qiime feature-table summarize \
    --i-table $table \
    --o-visualization table.qzv

    qiime feature-table summarize \
    --i-table $filtered \
    --o-visualization filtered-table.qzv

    qiime metadata tabulate \
    --m-input-file $stats \
    --o-visualization stats.qzv
    """
}

process CLASSIFY {

    tag "Classify using BLAST"
    container "andrewatmp/testf"


    input:
    path(refseqs)
    path(reftax)
    path(repseqs)
    val(sample_id)

    output:
    path("blastresults.qza"), emit: blastresults
    tuple val("${sample_id}"), path("classification.qza"), emit: classification

    script:

    """
    qiime feature-classifier classify-consensus-blast \
    --i-query $repseqs \
    --i-reference-reads $refseqs \
    --i-reference-taxonomy $reftax \
    --p-maxaccepts ${params.maxaccepts} \
    --p-perc-identity 0.99 \
    --o-classification classification.qza \
    --o-search-results blastresults.qza 
    """
}

process TABULATE {

    tag "Tabulate Classify Results"
    container "andrewatmp/testf"
    input:
    path(classification)
    path(blastresults)
    val(sample_id)

    output:
    path("classification.qzv"), emit: classificationvis
    path("blastresults.qzv"), emit: blastresultsvis
    
    script:
    """
    qiime metadata tabulate \
    --m-input-file $blastresults \
    --o-visualization blastresults.qzv

    qiime metadata tabulate \
    --m-input-file $classification \
    --o-visualization classification.qzv
  """
}

process BARPLOT {

    tag "Generate barplot"
    container "andrewatmp/qiime_unzip"
    publishDir "$projectDir/results/results_${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(filtered), path(classification)
    
    output:
    path("taxa-bar-plots.qzv"), emit: barplot
    path("*"), emit: data
    tuple path("${sample_id}.level-7.csv"), val("${sample_id}"), emit: species
    

    script:

    """
    qiime taxa barplot \
    --i-table $filtered \
    --i-taxonomy $classification \
    --o-visualization "taxa-bar-plots.qzv"

    mkdir extracted
    unzip taxa-bar-plots.qzv '*/data/*' -d extracted
    mv extracted/*/data/* .
    mv index.html Taxonomy_mqc.html
    for file in *.csv; do mv "\$file" "${sample_id}.\$file"; done
    rm -rf extracted
    """

}

process MAKETABLE {
    tag 'Make Table'
    container 'andrewatmp/plot2'
    stageInMode 'copy'
    stageOutMode 'copy'
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple path(species_csv), val(sample_id)
    path(logo)


    output:
    path("${sample_id}_report.html")
    path(logo)
    path("${sample_id}.csv")

    shell:
    """
    writehtml2.py $species_csv --sample_name "${sample_id}" $logo "${sample_id}_report.html"
    """
}

process MULTIQC {

    tag "MultiQC"
    container "andrewatmp/multiqc"
    stageInMode 'copy'
    stageOutMode 'copy'
    publishDir params.outdir, mode: 'copy'

    input:
    path(fastqc)

    output:
    path "."

    script:
    """
    multiqc .
    """
}


workflow {

    ch_input = file(params.input)
    INPUT_CHECK (
        ch_input
    )
    INPUT_CHECK.out.reads.view()

    SEQTK_SAMPLE(
        INPUT_CHECK.out.reads
    )

    SEQTK_SAMPLE.out.reads.view()

    ITSXPRESS(
        SEQTK_SAMPLE.out.reads
    )

    ITSXPRESS.out.dir
        .map {file -> 
            def sampleName = file.name.replaceAll(/\.seqs$/, '')
            return [sampleName, file]
        }
        .set{samples_ch}

    samples_ch.view()

    IMPORT(samples_ch)

    dada_ch = DADA(IMPORT.out.demux, IMPORT.out.id)
    filtered_ch = MINREADS(DADA.out.table, DADA.out.ids)
    DADARESULTS(dada_ch, MINREADS.out.filtered)

    classification_ch = CLASSIFY(params.refseqs, params.reftax, DADA.out.repseqs, DADA.out.ids)
    // TABULATE(classification_ch)

    ch1 = MINREADS.out.filtered
    ch2 = CLASSIFY.out.classification
    joined_ch = ch1.join(ch2, by :[0])


    BARPLOT(joined_ch)
    
    species_ch = (BARPLOT.out.species)
    MAKETABLE(species_ch, params.logo)

    multiqc_files = Channel.empty()
    // multiqc_files = multiqc_files.mix(FASTQC.out.fastqc_results)
    // multiqc_files = multiqc_files.mix(BARPLOT.out.data)
    // multiqc_files = multiqc_files.mix(MAKETABLE.out.table)
    // MULTIQC(multiqc_files.collect())
    BARPLOT.out.data.view()
}
