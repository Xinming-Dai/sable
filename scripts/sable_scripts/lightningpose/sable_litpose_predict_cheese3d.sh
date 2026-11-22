#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_gpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G
#SBATCH -t 0-24:00:00
#SBATCH -J litpose
#SBATCH -o logs/litpose_predict_sable_%j.log
#SBATCH --export=ALL

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$LP_CONDA_ENV"

# lp env has no ffmpeg binary on PATH (only the pip imageio-ffmpeg package); append (not
# prepend) the base anaconda env's bin dir so `ffmpeg` resolves without shadowing lp's python
# (set EXTRA_BIN_DIR in env.sh to that dir)
[ -n "$EXTRA_BIN_DIR" ] && export PATH="${PATH}:${EXTRA_BIN_DIR}"

BEAST_REPO=$REPO_ROOT
ROOT=$CHEESE3D_ROOT/videos
LIGHTNING_POSE_MODEL_DIR=$CKPT_ROOT/lightning_pose/outputs_cheese-3d_test_450_LP3D/mvt_3d_loss_450_0
SCRIPT=$REPO_ROOT/beast/preprocess/sable/cheese3d/run_litpose_predict_cheese3d.py

SESSION_IDS=(
    # "20231031_B20_chew_bl_000",
    # "20231031_B20_chew_temperature_000",
    # "20231031_B21_chew_bl_000",
    # "20231031_B21_chew_temperature_000",
    # "20231031_B26_chew_bl_000",
    # "20231031_B26_chew_temperature_000",
    # "20231031_B31_chew_bl_000",
    # "20231031_B31_chew_temperature_000",
    # "20231031_B6_chew_bl_000",
    # "20231031_B6_chew_temperature_000",
    "20250523_B1_ephys-record_awake_000"
)

# to skip labeled overlay videos, append: --skip-viz

PYTHONPATH="${BEAST_REPO}:${PYTHONPATH}" python -u "${SCRIPT}" \
  --root "${ROOT}" \
  --model-dir "${LIGHTNING_POSE_MODEL_DIR}" \
  --litpose-repo "${LIGHTNING_POSE_REPO}" \
  --session-ids "${SESSION_IDS[@]}" \
  --skip-existing

conda deactivate
