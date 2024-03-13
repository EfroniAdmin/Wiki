#!/bin/sh

WORK_PATH='/home/ls/linoym' # Were you input files exsit
SRR_ID=$1

# Check the number of arguments is equal to one
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one argument."
    echo "Usage: $0 <SRR_ID>"
    exit 1  # Exit with a non-zero status to indicate an error
fi

mkdir -p ${WORK_PATH}/fasqc_quality_check
cd ${WORK_PATH}/fasqc_quality_check
mkdir -p $SRR_ID

echo 'start with "${SRR_ID}" sample 1'
docker run --rm -v ${WORK_PATH}:/data staphb/fastqc:latest fastqc /data/sra_files/${SRR_ID}_1.fastq
mv ${WORK_PATH}/${SRR_ID}_1_fastqc.* ${WORK_PATH}/fasqc_quality_check/${SRR_ID}

echo 'start with "${SRR_ID}" sample 2'
docker run --rm -v ${WORK_PATH}:/data staphb/fastqc:latest fastqc /data/sra_files/${SRR_ID}_2.fastq
mv ${WORK_PATH}/${SRR_ID}_2_fastqc.* ${WORK_PATH}/fasqc_quality_check/${SRR_ID}

echo '~ finish fastqc script ~'
