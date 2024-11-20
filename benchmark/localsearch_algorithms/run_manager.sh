#!/bin/bash
#SBATCH --job-name=algorithm_benchmark      # Job name
#SBATCH --output=%x_%A_%a.out               # Standard output file with job name and array indices
#SBATCH --error=%x_%A_%a.err                # Standard error file with job name and array indices
#SBATCH --array=0-4                         # Job array range (adjust based on the number of files in data_file array)
#SBATCH --time=01:00:00                     # Adjust the time limit as needed
#SBATCH --mem=1G                            # Adjust memory requirements as needed
#SBATCH --nodelist=critical001

# Define data files
data_file=(
  "minizinc_n10_k3_c5000_l10000_u10100_r46.ttp"
  "minizinc_n10_k15_c5000_l10000_u11000_r49.ttp"
  "minizinc_n20_k3_c10000_l100_u200_r81.ttp"
  "minizinc_n20_k15_c5000_l100_u200_r32.ttp"
  "minizinc_n20_k20_c1000_l1000_u2000_r46.ttp"
)

# Ensure SLURM_ARRAY_TASK_ID is within bounds
if [ "$SLURM_ARRAY_TASK_ID" -ge "${#data_file[@]}" ]; then
  echo "Error: SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID is out of range for data_file array."
  exit 1
fi

# Select the file based on the array index
f=${data_file[$SLURM_ARRAY_TASK_ID]}

# Set the algorithm value
ALGORITHM=${ALGORITHM:-21}

# Run the command with the selected data file
echo "Processing Data File: $f with Algorithm $ALGORITHM"
java -cp "build/classes" Driver instances "$f" "$ALGORITHM" 10000000 600000 321