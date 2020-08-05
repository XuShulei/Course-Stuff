#!/bin/sh

source ~/.bashrc
module purge
module load gnu/6.1.0 mvapich2/2.3rc2-gpu cuda/9.1.85 
#module load  gnu/4.8.5 cuda/9.2.88
#cudnn/7.0

### TODO: modify the path 
MY_PIP=/users/PZS0622/osc1012/tools/miniconda2/bin/pip

#MPI_HOME=/opt/mvapich2/gnu/6.1/2.3rc2-gpu
MPI_HOME=/fs/scratch/PAS1419/osc1012/mv2-gdr-cuda9.2

#NCCL_HOME=/users/PZS0622/osc1012/tools/nccl-src/build
NCCL_HOME=/fs/scratch/PAS1419/osc1012/lab3/nccl_2.3.7-1+cuda9.2_x86_64

### TODO: modify the path 
INSTALL_PREFIX=/fs/scratch/PAS1419/osc1012/lab3
#INSTALL_PREFIX=/users/PZS0622/osc1012/5194-lab

export PATH=$MPI_HOME/bin:$PATH
export LD_LIBRARY_PATH=$MPI_HOME/lib:$NCCL_HOME/lib:$LD_LIBRARY_PATH

echo $PATH
echo $LD_LIBRARY_PATH

CUDA_HOME=/usr/local/cuda/9.1.85
#/usr/local/cuda/9.2.88

### Default Baidu version

$MY_PIP install --no-cache-dir -t $INSTALL_PREFIX/install-horovod-default --upgrade horovod

#FIXME: somehow PyTorch cannot correctly locate cuda.h, just added it to include path
export C_INCLUDE_PATH=$CUDA_HOME/include:${C_INCLUDE_PATH}

### NCCL version

HOROVOD_CUDA_HOME=$CUDA_HOME HOROVOD_NCCL_HOME=$NCCL_HOME HOROVOD_GPU_ALLREDUCE=NCCL $MY_PIP install --no-cache-dir -t $INSTALL_PREFIX/install-horovod-nccl --upgrade horovod

### MPI version - basic MVAPICH2

HOROVOD_CUDA_HOME=$CUDA_HOME HOROVOD_GPU_ALLREDUCE=MPI HOROVOD_GPU_ALLGATHER=MPI HOROVOD_GPU_BROADCAST=MPI $MY_PIP install --no-cache-dir -t $INSTALL_PREFIX/install-horovod-mvapich2 --upgrade horovod

#git clone https://github.com/uber/horovod.git
