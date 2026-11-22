#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_gpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH -t 0-00:59:00
#SBATCH -J encoding
#SBATCH -o logs/step2_run_encoding_%j.log
#SBATCH --export=ALL

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$CONDA_ENV"

# Blackwell 10.0 unsupported by gsplat; use a safe default if missing or 10.0.
if [[ "${TORCH_CUDA_ARCH_LIST:-}" == *"10.0"* ]] || [[ -z "${TORCH_CUDA_ARCH_LIST:-}" ]]; then
    export TORCH_CUDA_ARCH_LIST="8.0;8.6"
fi

[ -x /usr/bin/gcc ] && export CC=/usr/bin/gcc CXX=/usr/bin/g++

cd "$REPO_ROOT"

# Neural encoding: predicts neural activity from Sable latents (RRR/CNN, via Ray Tune).
NEURAL_INPUT_DIR=$CHEESE3D_NEURAL_ROOT/neural_data   # root dir of neural (spike) data

EID="20250523_B1_ephys-record_awake_000"
JOB_ID="20156493"                                         
LATENT_INPUT_DIR=$CHEESE3D_NEURAL_ROOT/behavior_data
LATENT_KIND="${1:-${LATENT_KIND:-behavior}}"                  # frame | dino | combined

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Running neural encoding for eid=$EID with latent_kind=$LATENT_KIND"
echo "LATENT_INPUT_DIR=$LATENT_INPUT_DIR"

python -m beast.sable_encoding_decoding.neural.run_encoding_decoding \
    --eid "$EID" \
    --neural_input_dir "$NEURAL_INPUT_DIR" \
    --latent_input_dir "$LATENT_INPUT_DIR" \
    --eval_task encoding \
    --latent_kind "$LATENT_KIND"

conda deactivate
