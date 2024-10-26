#!/usr/bin/env python3

from lapa import read_polyA_cluster
import argparse
import sys


"""
Script to convert LAPA clusters BED-like output to a BED6 file of single nucleotide PAS coordinates (representative coordinate)
LAPA columns: Chromosome Start End polyA_site count Strand Feature gene_id tpm gene_count usage fracA signal annotated_site
BED6 columns: Chromosome polyA_site (polyA_site + 1) gene_id|signal|Feature|Chromosome:Start:End:Strand score_col Strand

where score_col is a command line option (default: tpm)
"""


def main():
    parser = argparse.ArgumentParser(
        description="Process lapa clusters to BED6 format."
    )
    parser.add_argument("input_file", type=str, help="Input lapa clusters file")
    parser.add_argument("output_file", type=str, help="Output BED6 file")
    parser.add_argument(
        "--score_col",
        type=str,
        default=None,
        choices=["tpm", "usage", "fracA", "count"],
        help="Column from clusters file to populate score field of BED6 file (otherwise placeholder . is used)",
    )

    if len(sys.argv) == 1:
        parser.print_help()
        parser.exit()

    args = parser.parse_args()

    # Read the input file
    df = read_polyA_cluster(args.input_file)

    # Generate the 'Name' column - gene_id|Feature|signal|Chromosome:Start:End:Strand
    # (concatenated coord string = the cluster coordinates)
    df["coord_string"] = (
        df[["Chromosome", "Start", "End", "Strand"]].astype(str).agg(":".join, axis=1)
    )
    df["Name"] = (
        df[["gene_id", "Feature", "signal", "coord_string"]]
        .astype(str)
        .agg("|".join, axis=1)
    )

    # Create ouptut Start and End columns (representative PAS coordinates for cluster - polyA_site)
    # Start = polyA_site
    # End = (polyA_site + 1)
    df["Start"] = df["polyA_site"]
    df["End"] = df["polyA_site"] + 1

    # Select columns for BED6 format
    bed6_columns = ["Chromosome", "Start", "End", "Name", "Score", "Strand"]

    # Set score column
    if args.score_col and args.score_col in df.columns:
        df["Score"] = df[args.score_col]
    else:
        df["Score"] = "."

    # Ensure the columns are in the correct order
    bed6_df = df[bed6_columns]

    # Save to output file
    bed6_df.to_csv(args.output_file, sep="\t", header=False, index=False)


if __name__ == "__main__":
    main()
