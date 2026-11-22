#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_gpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH -t 0-03:00:00
#SBATCH -J dino_patch_tokens
#SBATCH -o logs/step1_dino_patch_tokens_%j.log
#SBATCH --export=ALL

# Frozen DINOv3 patch tokens (rebuttal baseline). Runs only the DINO featurizer, never builds the
# Sable model or loads its checkpoint; MODEL_DIR is read for config.yaml only.
# Output layout matches img_tokens: $OUTPUT_DIR/dino_patch_tokens/<session>/<split>/*.npz

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$CONDA_ENV"

export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

cd "$REPO_ROOT"

EIDS="${EIDS:-4b00df29-3769-43be-bb40-128b1cba6d35 72cb5550-43b4-4ef0-add5-e4adfdfb5e02 781b35fd-e1f0-4d14-b2bb-95b7263082bb}"
MODEL_DIR="${MODEL_DIR:-$CKPT_ROOT/beast_sable/ibl_pretrain_restricted_sessions/21047248}"
DATASET_BASE=$IBL_DATA_ROOT
DATASET_PATH="${DATASET_PATH:-$DATASET_BASE/extracted_frames/eval}"
VDA_CACHE_ROOT=$DATASET_BASE/extracted_frames_for_eyz/eval/depth_map                                # the dataset class requires it to be set
CORRESPONDENCE_CACHE_ROOT=$DATASET_BASE/extracted_frames_for_eyz/eval/litpose_correspondences/processed_correspondences
OUTPUT_DIR="${OUTPUT_DIR:-$CKPT_ROOT/dino_baseline/latents}"
RESUME="${RESUME:-true}"                                             # set to "false" to force recompute
BATCH_SIZE="${BATCH_SIZE:-64}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Extracting DINO patch tokens -> $OUTPUT_DIR"

ARGS=(
    --model "$MODEL_DIR"
    --input "$DATASET_PATH"
    --output "$OUTPUT_DIR"
    --extract-dino-patches
    --session-names $EIDS
    --vda-cache-root "$VDA_CACHE_ROOT"
    --correspondence-cache-root "$CORRESPONDENCE_CACHE_ROOT"
    --latent-batch-size "$BATCH_SIZE"
)
[ "$RESUME" = "false" ] && ARGS+=(--no-resume)

beast predict "${ARGS[@]}"

conda deactivate
