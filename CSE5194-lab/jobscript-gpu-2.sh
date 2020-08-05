#!/bin/sh
#PBS -N pytorch-imagenet-2
#PBS -l walltime=05:00:00
#PBS -l nodes=2:ppn=1:gpus=1
#PBS -l mem=64GB
#PBS -j oe
#PBS -A PAS1419

source ~/.bashrc
module purge
module load gnu/6.1.0 mvapich2/2.3rc2-gpu cuda/9.1.85 
#module load gnu/6.1.0 cuda/9.2.88

cat $PBS_NODEFILE

export LD_LIBRARY_PATH=/users/PZS0622/osc1012/tools/nccl-src/build/lib:/opt/mvapich2/gnu/6.1/2.3rc2-gpu/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/users/PZS0622/osc1012/tools/miniconda2/lib/python2.7/site-packages:/users/PZS0622/osc1012/5194-lab/install-horovod-nccl

for models in mobilenet #alexnet resnet50
do
    #bs=128
    bs=256
    if [ ${models} == "alexnet" ]
    then
        bs=2048
    fi
    mpip_outdir=/fs/scratch/PAS1419/osc1012/5194-lab/mpiP-${models}-gpu-out/2-nodes-bs-
    mkdir -p $mpip_outdir
    export MPIP="-f $mpip_outdir"
    set -x
    ###MV2_USE_CUDA=1 LD_PRELOAD=/users/PZS0622/osc1012/tools/mpiP-3.4.1/libmpiP.so
    ###/opt/mvapich2/gnu/6.1/2.3rc2-gpu/bin/mpirun_rsh -export-all -np 2 --hostfile $PBS_NODEFILE
    ###/usr/local/cuda/9.1.85/bin/nvprof
    HOROVOD_TIMELINE=/fs/scratch/PAS1419/osc1012/5194-lab/horovod-${model}-$bs-timeline.json MV2_USE_CUDA=1     /opt/mvapich2/gnu/6.1/2.3rc2-gpu/bin/mpirun -genvall -np 2 -ppn 1     python /users/PZS0622/osc1012/5194-lab/horovod/examples/pytorch_synthetic_benchmark.py --model $models --batch-size $bs     | tee /users/PZS0622/osc1012/5194-lab/horovod/examples/out.2-gpus.nccl-${models}-${bs}.txt
done

