#!/bin/bash
#SBATCH -A <your_account>
#SBATCH --partition=<your_cpu_partition>
#SBATCH -c 1
#SBATCH --mem 1G
#SBATCH -t 0-08:00:00
#SBATCH --job-name="access_cheese3d_cam"
#SBATCH -o logs/chmod_%j.log
#SBATCH --export=ALL

exec 2>&1

TARGET_DIR="${TARGET_DIR:?set TARGET_DIR to the directory to open up to the group}"

echo "---------------------------------------"
echo "Job name: ${SLURM_JOB_NAME:-local}"
echo "Job ID: ${SLURM_JOB_ID:-local}"
echo "Running on node(s): ${SLURM_NODELIST:-$(hostname)}"
echo "Target dir: $TARGET_DIR"
echo "---------------------------------------"

[ -d "$TARGET_DIR" ] || { echo "ERROR: Target dir not found: $TARGET_DIR"; exit 1; }

echo "[$(date +'%Y-%m-%d %H:%M:%S')] START chmod -R u+rwX,g+rwX,o-rwx $TARGET_DIR"

chmod -R u+rwX,g+rwX,o-rwx "$TARGET_DIR"
status=$?

if [ $status -eq 0 ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] DONE chmod succeeded"
else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] DONE chmod FAILED (exit $status)"
fi

exit $status
