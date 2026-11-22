#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_cpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=5G
#SBATCH -t 0-00:15:00
#SBATCH -J generate_vids
#SBATCH -o logs/step5_generate_video_%j.log
#SBATCH --export=ALL

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$CONDA_ENV"

cd "$REPO_ROOT"

# Stage 5 stitch a folder of rendered frames (from step4_decode_and_render.sh) into an MP4.
# Fill these in (or export before sbatch, e.g.:
#   sbatch --export=ALL,INPUT_DIR=...,OUTPUT=... \
#     scripts/sable_scripts/encoding_decoding/img_token/step5_generate_video.sh
INPUT_DIR="${INPUT_DIR:-<PATH_TO_RENDERED_FRAMES_DIR>}"
OUTPUT="${OUTPUT:-$INPUT_DIR/video.mp4}"
FPS="${FPS:-24}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Generating video from frames in $INPUT_DIR"

python -m beast.sable_encoding_decoding.video.video_generator \
    --input-dir "$INPUT_DIR" \
    --output "$OUTPUT" \
    --fps "$FPS"

conda deactivate
