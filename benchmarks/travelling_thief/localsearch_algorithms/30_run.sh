data_file=(
  "minizinc_n10_k3_c5000_l10000_u10100_r46.ttp"
  "minizinc_n10_k15_c5000_l10000_u11000_r49.ttp"
  "minizinc_n20_k3_c10000_l100_u200_r81.ttp"
  "minizinc_n20_k15_c5000_l100_u200_r32.ttp"
  "minizinc_n20_k20_c1000_l1000_u2000_r46.ttp"
)

# Loop through the array
for f in "${data_file[@]}"; do
  echo Data File: $f
  java -cp "build/classes" Driver instances $f 30 10000000 600000 321 >> 30_output.txt 2>> 30_error.txt
done
