#!/bin/bash
#SBATCH -A <your_account>
#SBATCH --job-name="correspondences"
#SBATCH --partition=<your_cpu_partition>
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH --mem=10G
#SBATCH --export=ALL
#SBATCH -o logs/precompute_litpose_correspondences_%j.log

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$CONDA_ENV"
cd "$REPO_ROOT"

CONFIG=$REPO_ROOT/configs/multiview/extraction_pipeline_sable.yaml
SCRIPT=$REPO_ROOT/beast/preprocess/sable/ibl/sable_extract_litpose_correspondences.py

SESSION_IDS=(
    "3e6a97d3-3991-49e2-b346-6948cb4580fb",
    "5dcee0eb-b34d-4652-acc3-d10afc6eae68"
)

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Extracting litpose correspondences for sessions: ${SESSION_IDS[*]}"

echo "=== executing ==="
python "${SCRIPT}" \
    --config "${CONFIG}" \
    --layout eval \
    --input-dir $IBL_DATA_ROOT/extracted_frames/eval \
    --litpose-root $IBL_DATA_ROOT/extracted_frames_for_eyz/eval/litpose_correspondences \
    --output-root $IBL_DATA_ROOT/extracted_frames_for_eyz/eval \
    --eids "${SESSION_IDS[@]}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Job Done."