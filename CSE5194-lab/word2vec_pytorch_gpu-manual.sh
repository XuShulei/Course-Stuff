#!/bin/sh
source ~/.bashrc
#cd $PBS_O_WORKDIR
#source activate py36

pt=1
#input_file_name=/users/PZS0622/osc1012/5194-lab/pytorch-word2vec/news_mono_lithic.txt
#input_file_name=/users/PZS0622/osc1012/5194-lab/pytorch-word2vec/news_mono_lithic_${pt}percent.txt
input_file_name=/fs/scratch/PAS1419/osc1012/word2vec/1-billion-word-language-modeling-benchmark-r13output/training-monolingual.tokenized.shuffled/news.en-00001-of-00100

modl=(0 1)
batch_sze=(10 100 1000 10000)

model=1
bs=10000
output_file_name=$input_file_name-$model-${bs}.out
logfile=/users/PZS0622/osc1012/5194-lab/pytorch-word2vec/logs/gpu-${pt}percent-$model-${bs}.log.txt
set -x
time ./main_simple.py --cuda --train ${input_file_name}  --output ${output_file_name}  --cbow ${model} --size 300 --window 5 --sample 1e-4 --negative 5 --iter 1 --batch_size ${bs} | tee $logfile
