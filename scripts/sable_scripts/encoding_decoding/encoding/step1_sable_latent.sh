#!/bin/bash
#SBATCH -A <your_account>
#SBATCH -p <your_gpu_partition>
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH -t 0-05:59:00
#SBATCH -J extraction
#SBATCH -o logs/step1_sable_latent_%j.log
#SBATCH --export=ALL

exec 2>&1
source ~/.bashrc
REPO_ROOT="${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$PWD}}"  # submit from the repo root
source "$REPO_ROOT/scripts/sable_scripts/env.sh"
conda activate "$CONDA_ENV"

# Blackwell 10.0 unsupported by gsplat; use a safe default if missing or 10.0.
if [[ "${TORCH_CUDA_ARCH_LIST:-}" == *"10.0"* ]] || [[ -z "${TORCH_CUDA_ARCH_LIST:-}" ]]; then
    export TORCH_CUDA_ARCH_LIST="8.0;8.6"
fi

[ -x /usr/bin/gcc ] && export CC=/usr/bin/gcc CXX=/usr/bin/g++

export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

cd "$REPO_ROOT"

JOB_ID="20503395"
EIDS="${EIDS:-f312aaec-3b6f-44b3-86b4-3a0c119c0438 4b00df29-3769-43be-bb40-128b1cba6d35}"                                           # space-separated session IDs (eids); default: use training config's session_names
MODEL_DIR="${MODEL_DIR:-$CKPT_ROOT/beast_sable/ibl_multisession/$JOB_ID}"
DATASET_BASE=$IBL_DATA_ROOT
DATASET_PATH="${DATASET_PATH:-$DATASET_BASE/extracted_frames/eval}"
VDA_CACHE_ROOT=$DATASET_BASE/extracted_frames_for_eyz/eval/depth_map
CORRESPONDENCE_CACHE_ROOT=$DATASET_BASE/extracted_frames_for_eyz/eval/litpose_correspondences/processed_correspondences                      # dir with config.yaml + *best.ckpt
OUTPUT_DIR=$MODEL_DIR/latents
LATENT_FLAGS="${LATENT_FLAGS:---return-all-z --return-img-tokens}"   # or e.g. "--return-frame-z"
RESUME="${RESUME:-true}"                                             # set to "false" to force recompute
BATCH_SIZE="${BATCH_SIZE:-64}"                                       # override training.batch_size_per_gpu

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Extracting Sable latents -> $OUTPUT_DIR"

ARGS=(
    --model "$MODEL_DIR"
    --input "$DATASET_PATH"
    --output "$OUTPUT_DIR"
    --extract-latents
)
[ -n "$EIDS" ] && ARGS+=(--session-names $EIDS)
[ -n "$VDA_CACHE_ROOT" ] && ARGS+=(--vda-cache-root "$VDA_CACHE_ROOT")
[ -n "$CORRESPONDENCE_CACHE_ROOT" ] && ARGS+=(--correspondence-cache-root "$CORRESPONDENCE_CACHE_ROOT")
[ "$RESUME" = "false" ] && ARGS+=(--no-resume)
[ -n "$BATCH_SIZE" ] && ARGS+=(--latent-batch-size "$BATCH_SIZE")

beast predict "${ARGS[@]}" $LATENT_FLAGS

conda deactivate
