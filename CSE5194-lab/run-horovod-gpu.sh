#!/bin/sh

#MPI_HOME=/fs/scratch/PAS1419/osc1012/mv2-gdr-cuda9.2
MPI_HOME=/opt/mvapich2/gnu/6.1/2.3rc2-gpu
### TODO: modify the paths 
SCRIPT_PATH=/users/PZS0622/osc1012/5194-lab/horovod/examples
NCCL_HOME=/users/PZS0622/osc1012/tools/nccl-src/build
OUT_PATH=/fs/scratch/PAS1419/osc1012/5194-lab

#comm_lib=mvapich2
comm_lib=nccl

nn=$1
#bs=128 #for ResNet50

echo "#!/bin/sh
#PBS -N pytorch-imagenet-$nn
#PBS -l walltime=05:00:00
#PBS -l nodes=$nn:ppn=1:gpus=1
#PBS -l mem=64GB
#PBS -j oe
#PBS -A PAS1419

source ~/.bashrc
module purge
module load gnu/6.1.0 mvapich2/2.3rc2-gpu cuda/9.1.85 
#module load gnu/6.1.0 cuda/9.2.88

cat \$PBS_NODEFILE

export LD_LIBRARY_PATH=$NCCL_HOME/lib:$MPI_HOME/lib:\$LD_LIBRARY_PATH
export PYTHONPATH=/users/PZS0622/osc1012/tools/miniconda2/lib/python2.7/site-packages:/users/PZS0622/osc1012/5194-lab/install-horovod-$comm_lib

for models in mobilenet #alexnet resnet50
do
    #bs=128
    bs=256
    if [ \${models} == \"alexnet\" ]
    then
        bs=2048
    fi
    mpip_outdir=$OUT_PATH/mpiP-\${models}-gpu-out/$nn-nodes-bs-$bs
    mkdir -p \$mpip_outdir
    export MPIP=\"-f \$mpip_outdir\"
    set -x
    ###MV2_USE_CUDA=1 LD_PRELOAD=/users/PZS0622/osc1012/tools/mpiP-3.4.1/libmpiP.so
    ###$MPI_HOME/bin/mpirun_rsh -export-all -np $nn --hostfile \$PBS_NODEFILE
    ###/usr/local/cuda/9.1.85/bin/nvprof
    HOROVOD_TIMELINE=$OUT_PATH/horovod-\${model}-\$bs-timeline.json MV2_USE_CUDA=1 \
    $MPI_HOME/bin/mpirun -genvall -np $nn -ppn 1 \
    python $SCRIPT_PATH/pytorch_synthetic_benchmark.py --model \$models --batch-size \$bs \
    | tee $SCRIPT_PATH/out.$nn-gpus.${comm_lib}-\${models}-\${bs}.txt
done
" > jobscript-gpu-$nn


sh jobscript-gpu-$nn
#qsub jobscript-gpu-$nn
#rm jobscript-gpu-$nn
