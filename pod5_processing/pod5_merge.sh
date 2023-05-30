#!/bin/bash

#SBATCH --job-name=pod5_merge
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 0-8:00
#SBATCH --cpus-per-task 24
#SBATCH --mem=34G

module load singularity/3.8.4

pod5_path="$1"
prefix="$2"
container="/home/tgenref/containers/pod5-0.1.20.sif"
binders="/scratch/denriquez,/home/denriquez,/illumina_run_folders"
output_path=$(dirname ${pod5_path})/merged_pod5

if [ ! -d ${output_path} ]
then
  mkdir ${output_path} || exit 1
fi

cd ${pod5_path} || exit 1

# Pick one file to parse for prefix
# tmp_file=$(ls | grep ".pod5" | head -n 1)

# Get delimiter count
# delimiter_count=$(echo ${tmp_file} | tr -c -d '_' | wc -c)

# Get prefix
# if [ ${delimiter_count} -eq 5 ]
# then
#     prefix=$(echo ${tmp_file} | cut -d"_" -f1-5)
# elif [ ${delimiter_count} -eq 4 ]
# then
#     prefix=$(echo ${tmp_file} | cut -d"_" -f1-4)
# else
#     echo "Error: Underscore delimiter count of ${delimiter_count} is not supported right now!"
#     exit 1
# fi

if [ -e ${output_path}/${prefix}.pod5 ]
then
  echo "${output_path}/${prefix}.pod5 Already Exists!"
  exit 1
fi

singularity exec --bind ${binders} --pwd $PWD --workdir /tmp --cleanenv --contain --nv ${container} pod5 \
	merge \
	*.pod5 \
	${output_path}/${prefix}.pod5

if [ $? -eq 0 ]
then
    cd ${output_path}
    md5sum ${prefix}.pod5 > ${prefix}.pod5.md5
fi

