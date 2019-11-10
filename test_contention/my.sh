#!/usr/bin/env bash
#SBATCH --job-name=xhc_attack_tesla
#SBATCH --partition=wacc
#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --time=0-00:02:00
#SBATCH --output="my.stdout"
#SBATCH --gres=gpu:gtx1080:1
nvprof --print-gpu-trace --metrics l1_cache_global_hit_rate,l1_cache_local_hit_rate ./test_contention
#./test_contention
