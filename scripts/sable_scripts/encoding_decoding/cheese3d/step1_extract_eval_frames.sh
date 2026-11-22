#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_cpu_partition>
#SBATCH -c 2
#SBATCH --mem 16G
#SBATCH -t 0-02:00:00
#SBATCH -J extract_cheese3d_eval_frames
#SBATCH -o logs/step1_extract_eval_frames_%j.log
#SBATCH --export=ALL

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$CONDA_ENV"
module load ffmpeg/7.1

cd "$REPO_ROOT"

# Extracts the exact eval-layout frames (all six cameras by default) for the trials chosen by
# step0, from the raw Cheese3D session videos, via a single ffmpeg decode pass per camera.
# Fill these in (or export before sbatch, e.g.:
#   sbatch --export=ALL,EID=...,LEFT_CAMERA=...,RIGHT_CAMERA=... \
#     scripts/sable_scripts/encoding_decoding/cheese3d/step1_extract_eval_frames.sh
EID="${EID:-20250523_B1_ephys-record_awake_000}"
NEURAL_OUTPUT_DIR="${NEURAL_OUTPUT_DIR:-$CHEESE3D_NEURAL_ROOT/neural_data}"
FRAME_MANIFEST="${FRAME_MANIFEST:-$NEURAL_OUTPUT_DIR/$EID/frame_manifest.json}"
# Note: videos_ephys/ has a corrupted TR file for this session (missing moov atom); videos/
# holds an intact copy of all six cameras for this session, hence the different default here.
RAW_VIDEO_DIR="${RAW_VIDEO_DIR:-$CHEESE3D_ROOT/videos}"
CALIBRATION_DIR="${CALIBRATION_DIR:-$CHEESE3D_CAM_ROOT}"
EVAL_FRAMES_OUTPUT_DIR="${EVAL_FRAMES_OUTPUT_DIR:-$CHEESE3D_NEURAL_ROOT/eval_frames}"
CAMERAS="${CAMERAS:-BC L R TC TL TR}"
LEFT_CAMERA="${LEFT_CAMERA:-TL}"
RIGHT_CAMERA="${RIGHT_CAMERA:-TR}"
CENTER_CAMERA="${CENTER_CAMERA:-}"

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Extracting Cheese3D eval frames for eid=$EID"

ARGS=(
    --frame-manifest "$FRAME_MANIFEST"
    --raw-video-dir "$RAW_VIDEO_DIR"
    --calibration-dir "$CALIBRATION_DIR"
    --output-dir "$EVAL_FRAMES_OUTPUT_DIR"
    --cameras $CAMERAS
    --left-camera "$LEFT_CAMERA"
    --right-camera "$RIGHT_CAMERA"
)
[ -n "$CENTER_CAMERA" ] && ARGS+=(--center-camera "$CENTER_CAMERA")

python -m beast.preprocess.sable.cheese3d.extract_cheese3d_eval_frames "${ARGS[@]}"

conda deactivate
