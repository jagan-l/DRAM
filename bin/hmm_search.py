#!/usr/bin/env python
import time
import pyhmmer
import click
from pathlib import Path

alphabet = pyhmmer.easel.Alphabet.amino()

@click.command()
@click.option(
    "--hmm",
    type=str,
    help="Path glob to the HMM db.",
)
@click.option(
    "--input_file",
    type=click.Path(exists=True),
    help="Path to the input fasta to search against",
)
@click.option(
    "--e_value",
    type=float,
    help="e value cutoff for filtering"
)
@click.option(
    "--output_file",
    type=click.Path(),
    help="Path to output file",
)
@click.option("--cpus", type=int, help="number of cpu core to run HMMER with")
def main(hmm, input_file, e_value, output_file, cpus):
    t1 = time.time()

    hmm = Path(hmm)

    hmm_paths = hmm.parent.glob(hmm.name)

    hmms = []
    for path in hmm_paths:
        with pyhmmer.plan7.HMMFile(path) as hmm_file:
            hmms.extend(hmm_file)

    print(hmms)

    with open(output_file, "wb") as out_fh:

        with pyhmmer.easel.SequenceFile(input_file, digital=True, alphabet=alphabet) as sf:
            seqs = pyhmmer.easel.DigitalSequenceBlock(alphabet)
            seqs.extend(sf)
            first = True
            for hits in pyhmmer.hmmer.hmmsearch(hmms, seqs, cpus=cpus, E=e_value):
                hits.write(out_fh, format="domains", header=first)
                first=False
            #total = sum(len(hits) for hits in pyhmmer.hmmer.hmmsearch(hmms, seqs, cpus=8, E=1e-15))
            print(f"pyhmmer search completed in {time.time() - t1:.3} seconds")


if __name__ == "__main__":
    main()
