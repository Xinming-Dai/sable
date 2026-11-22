# SABLE scripts

Slurm job scripts for training, inference, preprocessing and encoding/decoding. Run everything from
the repository root.

## One-time setup

1. Edit [`env.sh`](env.sh): set the data, checkpoint and conda settings for your machine. Every
   variable can also be overridden from the shell, e.g.
   `IBL_DATA_ROOT=/data/ibl sbatch scripts/sable_scripts/inference/infer_sable_ibl3d.sh`.
2. Fill in the Slurm placeholders at the top of each script: `#SBATCH -A <your_account>` and
   `#SBATCH -p <your_gpu_partition>` / `<your_cpu_partition>`. (`#SBATCH` lines cannot read
   environment variables.) Alternatively delete those lines and export `SBATCH_ACCOUNT` and
   `SBATCH_PARTITION`, or pass `-A` / `-p` on the `sbatch` command line.
3. Job logs go to `logs/` in the directory you submit from (git-ignored). Slurm fails a job whose
   log directory does not exist, so submit from the repo root, where `logs/` is already present.

## Running

```bash
sbatch scripts/sable_scripts/training/train_sable_ibl3d.sh
bash scripts/sable_scripts/encoding_decoding/encoding/submit_patch_tcn.sh --dry-run
```

Scripts take `REPO_ROOT` from `$SLURM_SUBMIT_DIR`, so submit from the repo root (or export
`REPO_ROOT`). The `submit_*.sh` launchers locate the repo from their own path.

## Layout

| Directory | Contents |
|---|---|
| `training/` | SABLE pretraining |
| `inference/` | latent / image-token extraction |
| `lightningpose/`, `segmentation_masks/` | correspondence and mask precompute |
| `encoding_decoding/ibl_neural_data_extraction/`, `encoding_decoding/cheese3d/` | neural data and eval-frame extraction (`step*` run in order) |
| `encoding_decoding/encoding/`, `encoding_decoding/img_token/` | neural encoding / decoding and image reconstruction (`step*` run in order) |
| `utils/` | helpers |
