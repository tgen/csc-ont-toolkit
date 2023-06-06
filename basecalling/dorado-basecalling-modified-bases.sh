#!/bin/bash

#SBATCH --tasks-per-node 1
#SBATCH --nodes 1
#SBATCH --partition=gpu
#SBATCH -C A100
#SBATCH --cpus-per-task 32
#SBATCH --gres gpu:4
#SBATCH --mem=145G
#SBATCH -t 0-24:00
#SBATCH -o dorado_modbase_%j.out
#SBATCH --job-name="dorado_modbase_basecalling"
#SBATCH --profile=ltask
#SBATCH --acctg-freq=task=1

sbatch -n1 -d$SLURM_JOB_ID --wrap="sh5util -j $SLURM_JOB_ID -o profiling_dorado_modbase_${SLURM_JOB_ID}.h5"

module load singularity/3.8.6
module load SAMtools/1.10-Container
export CUDA_MODULE_LOADING=LAZY
export SINGULARITYENV_CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES}

NAME=$1
RUNFOLDER_NAME=$2
PATH_TO_SCRIPTS=$3
OUTDIR=$4

source ${PATH_TO_SCRIPTS}/setup.conf

PATH_TO_POD5=${SEQUENCING_BASE_PATH}/${RUNFOLDER_NAME}/merged_pod5

echo
echo "FILE PREFIX=$NAME"
echo "PATH TO POD5=$PATH_TO_POD5"
echo "PATH TO MODEL=$PATH_TO_MODEL"
echo "MODIFIED BASES=$MODIFIED_BASES"
echo

# Set up directory OUT_SUBDIR
cd ${OUTDIR} || exit 1
if [ ! -d ${OUT_SUBDIR}/${RUNFOLDER_NAME} ]
then
  mkdir -p ${OUT_SUBDIR}/${RUNFOLDER_NAME}
fi
cd ${OUT_SUBDIR}/${RUNFOLDER_NAME} || exit 1

echo
echo "Simplex calling with modified bases"
echo

echo "singularity exec --bind $BIND --pwd $PWD --workdir /tmp --cleanenv --contain --nv ${DORADO_CONTAINER} dorado"
echo "    basecaller ${PATH_TO_MODEL} ${PATH_TO_POD5}"
echo "    --modified-bases ${MODIFIED_BASES} > ${NAME}.${MODBASE_EXTENSION}"

time singularity exec --bind $BIND --pwd $PWD --workdir /tmp --cleanenv --contain --nv ${DORADO_CONTAINER} dorado \
	basecaller \
	${PATH_TO_MODEL} \
	${PATH_TO_POD5} \
	--modified-bases ${MODIFIED_BASES} > ${NAME}.${MODBASE_EXTENSION}

if [ $? -eq 0 ]
then
    samtools index ${NAME}.${MODBASE_EXTENSION}
    if [ $? -eq 0 ]
    then
      md5sum ${NAME}.${MODBASE_EXTENSION} > ${NAME}.${MODBASE_EXTENSION}.md5
      md5sum ${NAME}.${MODBASE_EXTENSION}.bai > ${NAME}.${MODBASE_EXTENSION}.bai.md5
    fi
fi

echo
echo "Complete!"
