#!/bin/sh

wget https://cran.r-project.org/src/base/R-3/R-3.2.2.tar.gz

tar zxvf R-3.2.2.tar.gz

rm -f R-3.2.2.tar.gz

cd R-3.2.2

./configure --prefix=$PWD/install

make

make install

echo "============================================="
echo "R is installed, plase add the path as follow"
echo "export PATH=$PWD/install/bin:\$PATH"
