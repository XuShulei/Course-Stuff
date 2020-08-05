#!/bin/sh

module purge
module load cuda/9.0.176 gnu/4.8.5

export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

# Install basic dependencies
conda install numpy pyyaml mkl mkl-include setuptools cmake cffi typing
conda install -c mingfeima mkldnn

# Add LAPACK support for the GPU
conda install -c pytorch magma-cuda90 # or magma-cuda90 if CUDA 9

rm -fr python

git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
python setup.py install
