# bacterial_genomes_workflow
Nextflow workflow to quality control, trim, assemble multiple paired-end Illumina samples and compute all their pairwise ANIs.

## Installation
Install [nextflow](https://www.nextflow.io/docs/latest/install.html). Also Install python=2.7 and biopython (to filter contigs)
```bash
CONDA_SUBDIR=osx-64 conda create -n py27 python=2.7 biopython
conda activate py27
```
## Test run
Concatenate test data file with your current directory.
```bash
awk -v prefix="$(pwd)/" '{   
  for (i=1; i<=NF; i++) $i = prefix $i;
  print
}' test_data/test_data.txt > tmp && mv tmp test_data/test_data.txt
```
Run the workflow on the mini test data. Note that an absolute path has to be specified for `--wd`, which will store all the output files.
```bash
nextflow run assembly.nf --read_file test_data/test_data.txt --wd ~/test_run/
```
```bash
 N E X T F L O W   ~  version 24.10.5

Launching `assembly.nf` [adoring_hawking] DSL2 - revision: 5a14df97db

executor >  local (6)
[7b/474e22] FASTP_QC_TRIM (1)   [100%] 3 of 3, cached: 3 ✔
[c2/d35f18] SPADES_ASSEMBLE (2) [100%] 3 of 3, cached: 1 ✔
[49/08327f] FILTER_ASSEMBLY (3) [100%] 3 of 3 ✔
[ec/8ebe53] PAIRWISE_FASTANI    [100%] 1 of 1 ✔
``` 
## Versions of software used
* nextflow 24.10.5.5935
* python 2.7.15
* fastp 0.24.0
* spades 4.1.0
* fastani 1.33
