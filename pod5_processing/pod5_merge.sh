#!/bin/bash

#SBATCH --job-name=pod5_merge
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 0-8:00
#SBATCH --cpus-per-task 24
#SBATCH --mem=34G

module load singularity/3.8.6

PREFIX=$1
RUNFOLDER_NAME=$2
PATH_TO_SCRIPTS=$3

source ${PATH_TO_SCRIPTS}/setup.conf

pod5_path=${SEQUENCING_BASE_PATH}/${RUNFOLDER_NAME}/pod5_pass
output_path=$(dirname ${pod5_path})/merged_pod5

if [ ! -d ${output_path} ]
then
  mkdir ${output_path} || exit 1
fi
cd ${pod5_path} || exit 1

if [ -e ${output_path}/${PREFIX}.pod5 ]
then
  echo "${output_path}/${PREFIX}.pod5 Already Exists!"
  exit 1
fi

singularity exec --bind ${BIND} --pwd $PWD --workdir /tmp --cleanenv --contain --nv ${POD5_CONTAINER} pod5 \
	merge \
	*.pod5 \
	${output_path}/${PREFIX}.pod5

if [ $? -eq 0 ]
then
    cd ${output_path}
    md5sum ${PREFIX}.pod5 > ${PREFIX}.pod5.md5
fi
