#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_gpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH -t 0-02:00:00
#SBATCH -J patch_tcn_eval
#SBATCH -o logs/step2_eval_patch_tcn_%j.log
#SBATCH --export=ALL

# Evaluate the patch TCN with a locked config on one session, for several PCA dimensions.
# The config comes from step2_tune_patch_tcn.sh (<patch_TCN dir>/tuned/locked_config.json) and
# is applied unchanged: trained on the train trials, evaluated on the fold's test trials.
# Usage: sbatch step2_eval_patch_tcn.sh <MODEL> <SESSION>
#   MODEL:   full | nogeom | dino
#   SESSION: 78 | 72 | 4b
# Env overrides: FOLD (default 0), NUM_PCS_LIST (default "6 12 24").
# Use submit_patch_tcn_tuned.sh to submit the tune and eval jobs for every model/session.

REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/encoding_decoding/encoding/patch_tcn_common.sh"
setup_env

MODEL="${1:?usage: step2_eval_patch_tcn.sh <full|nogeom|dino> <78|72|4b>}"
SESSION="${2:?usage: step2_eval_patch_tcn.sh <full|nogeom|dino> <78|72|4b>}"
FOLD="${FOLD:-0}"
NUM_PCS_LIST="${NUM_PCS_LIST:-6 12 24}"

resolve_session "$SESSION"
resolve_model "$MODEL"

if [ ! -f "$LOCKED_JSON" ]; then
    echo "locked config not found: $LOCKED_JSON (run step2_tune_patch_tcn.sh $MODEL first)"
    exit 1
fi

for NUM_PCS in $NUM_PCS_LIST; do
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] eval patch TCN: model=$MODEL session=$SESSION eid=$EID fold=$FOLD num_pcs=$NUM_PCS"
    echo "PCA_DIR=$PCA_ROOT/$MODEL TUNED_DIR=$TUNED_DIR LOCKED_JSON=$LOCKED_JSON"

    python -m beast.sable_encoding_decoding.neural.patch_tcn \
        --mode eval \
        --eid "$EID" \
        --neural_input_dir "$NEURAL_INPUT_DIR" \
        --pca_dir "$PCA_ROOT/$MODEL" \
        --out_dir "$TUNED_DIR" \
        --config_json "$LOCKED_JSON" \
        --num_pcs "$NUM_PCS" \
        --fold "$FOLD"
done

conda deactivate
