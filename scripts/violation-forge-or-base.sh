#!/bin/bash

unbuffer make violation_forge_OR_sim | tee output.txt
grep "Final check (exec 0): Success!" output.txt
