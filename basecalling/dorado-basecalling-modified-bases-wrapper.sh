#!/bin/bash

###
# Prerequisites:
#    Download models
#    > singularity exec --bind /scratch/denriquez --pwd $(pwd) --workdir /tmp --cleanenv --contain --nv /home/tgenref/containers/dorado_0.2.4.sif dorado download --model dna_r10.4.1_e8.2_400bps_sup@v4.1.0_5mCG_5hmCG@v2 --directory $(pwd)
#    > singularity exec --bind /scratch/denriquez --pwd $(pwd) --workdir /tmp --cleanenv --contain --nv /home/tgenref/containers/dorado_0.2.4.sif dorado download --model dna_r10.4.1_e8.2_400bps_sup@v4.1.0 --directory $(pwd)
###

name=$1
path_to_pod5=$2
path_to_scripts=$3
path_to_basecalling_model=/scratch/denriquez/ont/dna_r10.4.1_e8.2_400bps_sup@v4.1.0
dorado_container="/home/denriquez/dorado_0.3.0.sif"
modified_bases="5mCG_5hmCG"
#==============================================================================
# Modification Model
#E.g. /scratch/denriquez/ont/dna_r10.4.1_e8.2_400bps_sup@v4.1.0_5mCG_5hmCG@v2
# This modification model MUST EXIST EVEN THOUGH IT IS NOT REFERENCED ANYWHERE HERE OR IN THE ACTUAL DORADO SCRIPT
modified_bases_model=/scratch/denriquez/ont/dna_r10.4.1_e8.2_400bps_sup@v4.1.0_5mCG_5hmCG@v2
#==============================================================================


#sbatch ${path_to_scripts}/dorado-basecalling-simplex-modified-bases.sh \
#  $name \
#  $path_to_pod5 \
#  $path_to_basecalling_model \
#  $dorado_container \
#  $modified_bases

sbatch ${path_to_scripts}/dorado-basecalling-modified-bases.sh \
	$path_to_scripts \
	$name \
	$path_to_pod5
