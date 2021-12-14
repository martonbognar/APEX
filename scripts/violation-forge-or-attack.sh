#!/bin/bash

unbuffer make ATTACK=1 violation_forge_OR_sim | tee output.txt
grep "Final check (exec 1): Fail!" output.txt
