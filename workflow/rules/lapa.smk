rule lapa:
    input:
        samples_csv = config["lapa_samples_csv"],
        fasta = config["genome_fasta"],
        gtf = config["gtf"],
        chrom_sizes = config["chrom_sizes"]
    output:
        os.path.join(config["main_output_dir"], "lapa", "polyA_clusters.bed")

    params:
        output_dir = os.path.join(config["main_output_dir"], "lapa"),
        counting_method = config["lapa_counting_method"],
        min_tail_len = config["lapa_min_tail_len"],
        min_percent_a = config["lapa_min_percent_a"],
        mapq = config["lapa_mapq"],
        cluster_extent_cutoff = config["lapa_cluster_extent_cutoff"],
        cluster_ratio_cutoff = config["lapa_cluster_ratio_cutoff"],
        cluster_window = config["lapa_cluster_window"],
        min_replication_rate = config["lapa_min_replication_rate"],
        replication_rolling_size = config["lapa_replication_rolling_size"],
        replication_min_count = config["lapa_replication_min_count"],
        replication_num_sample = config["lapa_replication_num_sample"],
        non_replicates_read_threshold = config["lapa_non_replicates_read_threshold"],
        disable_internal_priming_filter = "--disable_internal_priming_filter" if config["lapa_disable_internal_priming_filter"] else "",
        sample_subdir = os.path.join(config["main_output_dir"], "lapa", "sample")

    conda:
        "../envs/lapa_fork.yaml"

    log:
        stdout = os.path.join(config["main_output_dir"], "logs", "lapa", "lapa.stdout.log"),
        stderr = os.path.join(config["main_output_dir"], "logs", "lapa", "lapa.stderr.log")

    benchmark:
        os.path.join(config["main_output_dir"], "benchmarks", "lapa", "lapa.benchmark.txt")

    shell:
        # LAPA subdirectories cannot exist before running LAPA
        """
        [ -d {params.sample_subdir} ] && rm -r {params.output_dir}/*
        lapa \
        --alignment {input.samples_csv} \
        --fasta {input.fasta} \
        --annotation {input.gtf} \
        --chrom_sizes {input.chrom_sizes} \
        --output_dir {params.output_dir} \
        --counting_method {params.counting_method} \
        --min_tail_len {params.min_tail_len} \
        --min_percent_a {params.min_percent_a} \
        --mapq {params.mapq} \
        --cluster_extent_cutoff {params.cluster_extent_cutoff} \
        --cluster_ratio_cutoff {params.cluster_ratio_cutoff} \
        --cluster_window {params.cluster_window} \
        --min_replication_rate {params.min_replication_rate} \
        --replication_rolling_size {params.replication_rolling_size} \
        --replication_num_sample {params.replication_num_sample} \
        --replication_min_count {params.replication_min_count} \
        --non_replicates_read_threhold {params.non_replicates_read_threshold} \
        {params.disable_internal_priming_filter} \
        1> {log.stdout} \
        2> {log.stderr}
        """