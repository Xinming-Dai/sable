#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_gpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH -t 0-00:59:00
#SBATCH -J decoding
#SBATCH -o logs/step2_run_decoding_%j.log
#SBATCH --export=ALL

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$CONDA_ENV"

cd "$REPO_ROOT"

# Stage 3 neural decoding, predicts (e.g. PCA-compressed) img tokens / other latents from neural activity. 
# Requires step1's img_tokens_compressed_trials.npz as LATENT_INPUT_DIR (with LATENT_KIND=img_tokens_compressed*);
# produces decoding_results_img_tokens_compressed.npy, consumed by step3_unproject.sh.
# Fill these in (or export before sbatch, e.g.:
#   sbatch --export=ALL,EID=<session-id>,... \
#     scripts/sable_scripts/encoding_decoding/img_token/step2_run_decoding.sh
EID="${EID:-781b35fd-e1f0-4d14-b2bb-95b7263082bb}"
NEURAL_INPUT_DIR=$IBL_DATA_ROOT/extracted_frames/neural_data
JOB_ID="${JOB_ID:-21047248}"
LATENT_INPUT_DIR="${LATENT_INPUT_DIR:-$CKPT_ROOT/beast_sable/ibl_pretrain_restricted_sessions/$JOB_ID/latents}"   # root dir of latent data
LATENT_KIND=img_tokens_compressed

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Running neural decoding for eid=$EID"

python -m beast.sable_encoding_decoding.neural.run_encoding_decoding \
    --eid "$EID" \
    --neural_input_dir "$NEURAL_INPUT_DIR" \
    --latent_input_dir "$LATENT_INPUT_DIR" \
    --eval_task decoding \
    --latent_kind "$LATENT_KIND"

conda deactivate
