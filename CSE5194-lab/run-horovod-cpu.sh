#!/bin/sh

MPI_HOME=/opt/mvapich2/gnu/6.1/2.3rc2-gpu
### TODO: modify the paths 
SCRIPT_PATH=/users/PZS0622/osc1012/5194-lab/horovod/examples
NCCL_HOME=/users/PZS0622/osc1012/tools/nccl-src/build
OUT_PATH=/fs/scratch/PAS1419/osc1012/5194-lab

comm_lib=mvapich2
#comm_lib=nccl

nn=$1
ppn=28

#bs=128 # 128 for AlexNet
bs=16 # 128 for ResNet50

#nps=`expr $nn \* $ppn`
nps=$nn

echo "#!/bin/sh
#PBS -N pytorch-imagenet
#PBS -l walltime=01:00:00
#PBS -l nodes=$nn:ppn=$ppn
#PBS -j oe
#PBS -A PAS1419

source ~/.bashrc
module purge
module load gnu/6.1.0 mvapich2/2.3rc2-gpu cuda/9.1.85 

export LD_LIBRARY_PATH=$NCCL_HOME/lib:\$LD_LIBRARY_PATH
export PYTHONPATH=/users/PZS0622/osc1012/tools/miniconda2/lib/python2.7/site-packages:/users/PZS0622/osc1012/5194-lab/install-horovod-$comm_lib

for models in mobilenet #resnet50 alexnet
do
    #bs=32
    bs=64
    if [ \${models} == \"alexnet\" ]
    then
        bs=2048
    fi
    mpip_outdir=$OUT_PATH/mpiP-\${models}-cpu-out/$nn-nodes-bs-${bs}/
    mkdir -p \$mpip_outdir
    export MPIP=\"-f \$mpip_outdir\"
    set -x
    MV2_USE_CUDA=0 LD_PRELOAD=/users/PZS0622/osc1012/tools/mpiP-3.4.1/libmpiP.so \
    $MPI_HOME/bin/mpirun -genvall -np $nps -ppn 1 \
    python $SCRIPT_PATH/pytorch_synthetic_benchmark.py --model \$models --batch-size \$bs --no-cuda --num-warmup-batches 1 --num-batches-per-iter 2 --num-iters 3 \
    | tee $SCRIPT_PATH/out.$nps-cpu-procs.${comm_lib}-\${models}-\${bs}.txt
done
" > jobscript-cpu-$nn-$ppn

qsub jobscript-cpu-$nn-$ppn
rm jobscript-cpu-$nn-$ppn
