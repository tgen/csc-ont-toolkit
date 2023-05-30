#!/bin/bash

#SBATCH --tasks-per-node 1
#SBATCH --nodes 1
#SBATCH --partition=gpu
#SBATCH -C A100
#SBATCH --cpus-per-task 32
#SBATCH --gres gpu:4
#SBATCH --mem=140G
#SBATCH -t 0-24:00
#SBATCH --job-name="dorado_modbase_basecalling"
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=denriquez@tgen.org
#SBATCH --profile=ltask
#SBATCH --acctg-freq=task=1

sbatch -n1 -d$SLURM_JOB_ID --wrap="sh5util -j $SLURM_JOB_ID"

module load singularity
module load SAMtools
export CUDA_MODULE_LOADING=LAZY
export SINGULARITYENV_CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES}

PATH_TO_SCRIPTS=$1
NAME=$2
PATH_TO_POD5=$3

source ${PATH_TO_SCRIPTS}/setup.conf

PATH_TO_POD5_PARENT=$(dirname $PATH_TO_POD5)
MODEL_BASE_TMP=$(basename ${PATH_TO_MODEL})
MODEL_BASE=${MODEL_BASE_TMP//@/_}
extension="unmap.simplex.mod.${MODIFIED_BASES}.bam"

echo "############################################"
echo "The following arguments were provided or predicted:"
echo "NAME=$NAME"
echo "PATH_TO_POD5=$PATH_TO_POD5"
echo "PATH_TO_MODEL=$PATH_TO_MODEL"
echo "MODIFIED_BASES=${MODIFIED_BASES}"
echo "############################################"

# Set up directory OUT_SUBDIR
cd $(dirname ${PATH_TO_POD5}) || exit 1
if [ ! -d ${OUT_SUBDIR} ]
then
  mkdir -p ${OUT_SUBDIR}
fi
cd ${OUT_SUBDIR} || exit 1

## Step 1 - Simplex calling
echo
echo "Simplex calling with modified bases"
echo "############################################"

echo "singularity exec --bind $BIND --pwd $PWD --workdir /tmp --cleanenv --contain --nv ${DORADO_CONTAINER} dorado"
echo "    basecaller ${PATH_TO_MODEL} ${PATH_TO_POD5}"
echo "    --modified-bases ${MODIFIED_BASES} > ${NAME}.${extension}"

time singularity exec --bind $BIND --pwd $PWD --workdir /tmp --cleanenv --contain --nv ${DORADO_CONTAINER} dorado \
	basecaller \
	${PATH_TO_MODEL} \
	${PATH_TO_POD5} \
	--modified-bases ${MODIFIED_BASES} > ${NAME}.${extension}

if [ $? -eq 0 ]
then
    samtools index ${NAME}.${extension}
    if [ $? -eq 0 ]
    then
      md5sum ${NAME}.${extension} > ${NAME}.${extension}.md5
      md5sum ${NAME}.${extension}.bai > ${NAME}.${extension}.bai.md5
    fi
fi

echo
echo "################# Done! #################"
