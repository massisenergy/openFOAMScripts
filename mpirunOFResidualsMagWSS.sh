#!/usr/bin/env bash
# decomposePar -force </dev/null && \


read -p "Enter the number of processors for parallelRun: " NUMPROC
if [[ $NUMPROC=0 ]]; then
    foamListTimes ;
else if [[ $NUMPROC=1 ]]; then
    echo "Will run with single core";
else exit;
fi;



# mpirun -np 8 renumberMesh -parallel -overwrite && \
# mpirun -np 8 simpleFoam -parallel > logs/foamlog;
# # wait $BACK_PID;
# BACK_PID=$!
# source $MASTERSCRIPTSPATH/scriptPlottingResidualsMagWSS.sh;
# source $MASTERSCRIPTSPATH/scriptPlottingResiduals.sh;
