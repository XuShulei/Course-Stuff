#!/bin/sh
#PBS -N pytorch-imagenet
#PBS -l walltime=01:00:00
#PBS -l nodes=2:ppn=28
#PBS -j oe
#PBS -A PAS1419

source ~/.bashrc
module purge
module load gnu/6.1.0 mvapich2/2.3rc2-gpu cuda/9.1.85 

export LD_LIBRARY_PATH=/users/PZS0622/osc1012/tools/nccl-src/build/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/users/PZS0622/osc1012/tools/miniconda2/lib/python2.7/site-packages:/users/PZS0622/osc1012/5194-lab/install-horovod-mvapich2

for models in mobilenet #resnet50 alexnet
do
    #bs=32
    bs=512
    if [ ${models} == "alexnet" ]
    then
        bs=2048
    fi
    mpip_outdir=/users/PZS0622/osc1012/5194-lab/horovod/examples/mpiP-${models}-cpu-out
    mkdir -p $mpip_outdir
    export MPIP="-f $mpip_outdir"
    set -x
    MV2_USE_CUDA=0 LD_PRELOAD=/users/PZS0622/osc1012/tools/mpiP-3.4.1/libmpiP.so     /opt/mvapich2/gnu/6.1/2.3rc2-gpu/bin/mpirun_rsh -export-all -np 2 --hostfile $PBS_NODEFILE     python /users/PZS0622/osc1012/5194-lab/horovod/examples/pytorch_synthetic_benchmark.py --model $models --batch-size $bs --no-cuda --num-warmup-batches 1 --num-batches-per-iter 2 --num-iters 3     | tee /users/PZS0622/osc1012/5194-lab/horovod/examples/out.2-cpu-procs.mvapich2-${models}-${bs}.txt
done

