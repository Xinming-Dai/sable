#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_gpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH -t 0-03:59:00
#SBATCH -J sam3_segment_eval
#SBATCH -o logs/sam3_segment_eval_%j.log
#SBATCH --export=ALL

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
cd "$REPO_ROOT"
export PYTHONPATH="$REPO_ROOT:${PYTHONPATH:-}"
conda activate "$CONDA_ENV"

BEAST_REPO=$REPO_ROOT
CONFIG=$REPO_ROOT/configs/multiview/extraction_pipeline_sable.yaml
SCRIPT=$REPO_ROOT/beast/preprocess/sable/ibl/precompute_sam3_masks_eval.py

FRAMES_DIR=$IBL_DATA_ROOT/extracted_frames/eval
OUTPUT_ROOT=$IBL_DATA_ROOT/extracted_frames_for_eyz/eval


SESSION_IDS=(
    "3e6a97d3-3991-49e2-b346-6948cb4580fb"
    "5dcee0eb-b34d-4652-acc3-d10afc6eae68"
)
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Starting SAM3 segmentation mask evaluation for sessions: ${SESSION_IDS[*]}"
PYTHONPATH="${BEAST_REPO}:${PYTHONPATH}" python -u "${SCRIPT}" \
  --config "${CONFIG}" \
  --frames-dir "${FRAMES_DIR}" \
  --output-root "${OUTPUT_ROOT}" \
  --eids "${SESSION_IDS[@]}" \
  --split test

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Finished SAM3 segmentation mask evaluation."
conda deactivate
