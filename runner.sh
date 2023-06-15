#!/bin/bash

###
# Prerequisites:
#    Download models
#    > singularity exec --bind /scratch/denriquez --pwd $(pwd) --workdir /tmp --cleanenv --contain --nv /home/tgenref/containers/dorado_0.2.4.sif dorado download --model dna_r10.4.1_e8.2_400bps_sup@v4.1.0_5mCG_5hmCG@v2 --directory $(pwd)
#    > singularity exec --bind /scratch/denriquez --pwd $(pwd) --workdir /tmp --cleanenv --contain --nv /home/tgenref/containers/dorado_0.2.4.sif dorado download --model dna_r10.4.1_e8.2_400bps_sup@v4.1.0 --directory $(pwd)
###

name=$1
runfolder_name=$2
path_to_scripts=$3
outdir=$4

#echo "Submitting Chunked POD5 File Merge Task"
#sbatch ${path_to_scripts}/pod5_processing/pod5_merge.sh \
#  $name \
#  $runfolder_name \
#  $path_to_scripts


echo "Submitting Simplex Basecalling with Modified Bases Task"
sbatch ${path_to_scripts}/basecalling/dorado-basecalling-modified-bases.sh \
	$name \
	$runfolder_name \
	$path_to_scripts \
	$outdir

echo "Submitting Duplex Basecalling Task"
sbatch ${path_to_scripts}/basecalling/dorado-basecalling-duplex.sh \
	$name \
	$runfolder_name \
	$path_to_scripts \
	$outdir

