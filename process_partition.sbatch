#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH -p small
#SBATCH -t 72:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --account=Project_2002026
#SBATCH -o logs/%j.out
#SBATCH -e logs/%j.err

BATCH_NAME=$1
WORK_DIR=$2
OUTPUT_DIR=$3

ln -s logs/$SLURM_JOBID.err $WORK_DIR/slurm.current.err
ln -s logs/$SLURM_JOBID.out $WORK_DIR/slurm.current.out

module purge
module load python-data/3.7.3-1
source VENV/bin/activate

srun sh process_partition.sh $1 $2 $3

seff $SLURM_JOBID

