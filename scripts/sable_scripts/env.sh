#!/bin/bash
# Machine-specific settings shared by the scripts in scripts/sable_scripts; sourced (not run).
#
# Edit the defaults below once for your machine, or override any variable from the shell
# (e.g. `IBL_DATA_ROOT=/data/ibl sbatch scripts/...`; sbatch exports the environment by default).
# REPO_ROOT is set by each script (the directory you submit from) before sourcing this file.

# conda environments
CONDA_ENV="${CONDA_ENV:-beast}"            # env with beast installed
LP_CONDA_ENV="${LP_CONDA_ENV:-lp}"         # env with lightning-pose installed

# code outside this repo
LIGHTNING_POSE_REPO="${LIGHTNING_POSE_REPO:-/path/to/lightning-pose}"

# IBL data: <IBL_DATA_ROOT>/extracted_frames/{pretrain,eval,neural_data} and
# <IBL_DATA_ROOT>/extracted_frames_for_eyz/{pretrain,eval} (depth, masks, correspondences)
IBL_DATA_ROOT="${IBL_DATA_ROOT:-/path/to/IBL_data/synchronized}"
IBL_VIDEO_ROOT="${IBL_VIDEO_ROOT:-/path/to/IBL-2view}"            # raw videos and timestamps
ONE_CACHE_PATH="${ONE_CACHE_PATH:-/path/to/IBL_data/ONE}"         # ONE API cache

# cheese3d data
CHEESE3D_ROOT="${CHEESE3D_ROOT:-/path/to/cheese3d}"               # contains videos/ and spike/
CHEESE3D_CAM_ROOT="${CHEESE3D_CAM_ROOT:-/path/to/cheese3d_cam}"   # camera calibrations
CHEESE3D_NEURAL_ROOT="${CHEESE3D_NEURAL_ROOT:-/path/to/cheese3d_neural}"  # extracted outputs

# checkpoints and latents, e.g. $CKPT_ROOT/beast_sable/<run>/ and $CKPT_ROOT/lightning_pose/
CKPT_ROOT="${CKPT_ROOT:-/path/to/checkpoints}"

# cross-validated patch-PCA outputs, one session_<id> subdirectory per session (patch-TCN scripts)
PCA_ROOT_BASE="${PCA_ROOT_BASE:-/path/to/patch_pca_cv5}"

# optional extra directory appended to PATH (e.g. one that provides ffmpeg); empty to skip
EXTRA_BIN_DIR="${EXTRA_BIN_DIR:-}"
