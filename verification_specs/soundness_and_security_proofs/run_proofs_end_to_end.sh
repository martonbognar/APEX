# exit when any command fails
set -e

chmod +x *.ltl
./proof_theorem1.ltl
./proof_theorem2_1.ltl
./proof_theorem2_2.ltl
