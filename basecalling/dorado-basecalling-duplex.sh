#!/bin/bash

#SBATCH --tasks-per-node 1
#SBATCH --nodes 1
#SBATCH --partition=gpu
#SBATCH -C A100
#SBATCH --cpus-per-task 20
#SBATCH --gres gpu:4
#SBATCH --mem=32G
#SBATCH -t 0-48:00
#SBATCH --job-name="dorado_duplex_basecalling"
#SBATCH -o dorado_duplex_%j.out

module load singularity/3.8.6
module load SAMtools/1.10-Container
export SINGULARITYENV_CUDA_MODULE_LOADING=LAZY
export SINGULARITYENV_PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:4096

export SINGULARITYENV_CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES}

NAME=$1
RUNFOLDER_NAME=$2
PATH_TO_SCRIPTS=$3
OUTDIR=$4
THREADS=19

source ${PATH_TO_SCRIPTS}/setup.conf

PATH_TO_POD5=${SEQUENCING_BASE_PATH}/${RUNFOLDER_NAME}/merged_pod5

echo
echo "NAME=$NAME"
echo "PATH_TO_POD5=$PATH_TO_POD5"
echo "PATH_TO_MODEL=$PATH_TO_MODEL"
echo

# Set up directory OUT_SUBDIR
cd ${OUTDIR} || exit 1
if [ ! -d ${OUT_SUBDIR}/${RUNFOLDER_NAME} ]
then
  mkdir -p ${OUT_SUBDIR}/${RUNFOLDER_NAME}
fi
cd ${OUT_SUBDIR}/${RUNFOLDER_NAME} || exit 1

echo
echo "Starting Duplex Basecalling"
echo
time singularity exec --bind $BIND --pwd $PWD --workdir /tmp --cleanenv --contain --nv ${DORADO_CONTAINER} dorado \
	duplex \
	--threads ${THREADS} \
	-v \
	${PATH_TO_MODEL} \
	${PATH_TO_POD5}  > ${NAME}.${DUPLEX_EXTENSION}

if [ $? -eq 0 ]
then
    samtools index ${NAME}.${DUPLEX_EXTENSION}
    if [ $? -ne 0 ]
    then
      exit 1
    fi
    md5sum ${NAME}.${DUPLEX_EXTENSION} > ${NAME}.${DUPLEX_EXTENSION}.md5
    md5sum ${NAME}.${DUPLEX_EXTENSION}.bai > ${NAME}.${DUPLEX_EXTENSION}.bai.md5
fi

echo
echo "Complete!"

