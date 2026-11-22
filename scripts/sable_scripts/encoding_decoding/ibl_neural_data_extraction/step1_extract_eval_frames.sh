#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_cpu_partition>
#SBATCH -c 2
#SBATCH --mem 7G
#SBATCH -t 0-04:00:00
#SBATCH -J extract_sable_eval_frames
#SBATCH -o logs/step1_extract_eval_frames_%j.log
#SBATCH --export=ALL

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$CONDA_ENV"

cd "$REPO_ROOT"

# Extracts the exact eval-layout frames (left/right cameras by default) for the trials chosen
# by step0, from the raw IBL two-view session videos, via a single sequential OpenCV decode
# pass per camera.
# Fill these in (or export before sbatch, e.g.:
#   sbatch --export=ALL,EID=... \
#     scripts/sable_scripts/encoding_decoding/ibl_neural_data_extraction/step1_extract_eval_frames.sh
EID="${EID:-3e6a97d3-3991-49e2-b346-6948cb4580fb}"
NEURAL_DATA_DIR="${NEURAL_DATA_DIR:-$IBL_DATA_ROOT/extracted_frames/neural_data}"
RAW_VIDEO_DIR="${RAW_VIDEO_DIR:-$IBL_VIDEO_ROOT}"
EVAL_FRAMES_OUTPUT_DIR="${EVAL_FRAMES_OUTPUT_DIR:-$IBL_DATA_ROOT/extracted_frames/eval}"
CAMERAS="${CAMERAS:-left right}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Extracting IBL eval frames for eid=$EID"

python -m beast.preprocess.sable.ibl.extract_sable_eval_frames \
    --eid "$EID" \
    --neural-data-dir "$NEURAL_DATA_DIR" \
    --raw-video-dir "$RAW_VIDEO_DIR" \
    --output-dir "$EVAL_FRAMES_OUTPUT_DIR" \
    --cameras $CAMERAS

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Job Done."
conda deactivate
