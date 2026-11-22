#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_gpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=15G
#SBATCH -t 0-01:29:00
#SBATCH -J patch_tcn
#SBATCH -o logs/step2_run_patch_tcn_%j.log
#SBATCH --export=ALL

# Neural encoding with a TCN on PCA-compressed patch embeddings (one model, one session).
# Usage: sbatch step2_run_patch_tcn.sh <MODEL> <SESSION>
#   MODEL:   full | nogeom | dino
#   SESSION: 78 | 72 | 4b
# Env overrides: FOLD (default 0), NUM_PCS (default 6), NUM_SAMPLES (default 30).
# Use submit_patch_tcn.sh to submit every model/session pair.

exec 2>&1
export PYTHONUNBUFFERED=1  # flush print output to the slurm log as it happens
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

MODEL="${1:?usage: step2_run_patch_tcn.sh <full|nogeom|dino> <78|72|4b>}"
SESSION="${2:?usage: step2_run_patch_tcn.sh <full|nogeom|dino> <78|72|4b>}"
FOLD="${FOLD:-0}"
NUM_PCS="${NUM_PCS:-6}"
NUM_SAMPLES="${NUM_SAMPLES:-30}"

NEURAL_INPUT_DIR=$IBL_DATA_ROOT/extracted_frames/neural_data

case "$SESSION" in
    78)
        EID="781b35fd-e1f0-4d14-b2bb-95b7263082bb"
        PCA_ROOT=$PCA_ROOT_BASE/session_78
        ;;
    72)
        EID="72cb5550-43b4-4ef0-add5-e4adfdfb5e02"
        PCA_ROOT=$PCA_ROOT_BASE/session_72
        ;;
    4b)
        EID="4b00df29-3769-43be-bb40-128b1cba6d35"
        PCA_ROOT=$PCA_ROOT_BASE/session_4b
        ;;
    *)
        echo "unknown SESSION=$SESSION (expected 78, 72 or 4b)"
        exit 1
        ;;
esac

case "$MODEL" in
    full)
        OUT_DIR=$CKPT_ROOT/beast_sable/ibl_pretrain_restricted_sessions/21047248/latents/patch_TCN
        ;;
    nogeom)
        OUT_DIR=$CKPT_ROOT/beast_sable/ibl_pretrain_restricted_sessions/22359987_disable_geom/latents/patch_TCN
        ;;
    dino)
        OUT_DIR=$CKPT_ROOT/dino_baseline/latents/patch_TCN
        ;;
    *)
        echo "unknown MODEL=$MODEL (expected full, nogeom or dino)"
        exit 1
        ;;
esac

echo "[$(date +'%Y-%m-%d %H:%M:%S')] patch TCN: model=$MODEL session=$SESSION eid=$EID fold=$FOLD num_pcs=$NUM_PCS"
echo "PCA_DIR=$PCA_ROOT/$MODEL OUT_DIR=$OUT_DIR"

python -m beast.sable_encoding_decoding.neural.patch_tcn \
    --eid "$EID" \
    --neural_input_dir "$NEURAL_INPUT_DIR" \
    --pca_dir "$PCA_ROOT/$MODEL" \
    --out_dir "$OUT_DIR" \
    --num_pcs "$NUM_PCS" \
    --fold "$FOLD" \
    --num_samples "$NUM_SAMPLES"

conda deactivate
