#!/usr/bin/env bash
decomposePar -force </dev/null && \
mpirun -np 8 renumberMesh -parallel -overwrite;
rm -rf logs/foamlog && \
mpirun -np 8 simpleFoam -parallel > logs/foamlog &
# wait $BACK_PID;
BACK_PID=$!

while kill -0 $BACK_PID ; do
    echo "Process is still active..."
    sleep 1
    # You can add a timeout here if you want
done
# source $MASTERSCRIPTSPATH/scriptPlottingResidualsMagWSS.sh;
# source $MASTERSCRIPTSPATH/scriptPlottingResiduals.sh;
