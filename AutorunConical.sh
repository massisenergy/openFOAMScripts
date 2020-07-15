#!/usr/bin/env bash
###### Read `FC_blunted_nozzle.py` (from FreeCAD) & `sHMD.csv`. Start a bash while loop #########
###### 1. Create folders using bash while loop. ################################
###### 2. In each loop, modify and keep the updated `DP*.py` files in ##########
###### corresponding folders using awk. ########################################
###### 3. Run `FreeCADCmd` to generate `*.brep` or `*.stl`######################
###### 4. Copy/relocate all necessary folders for running openFOAM
###### 5. Pass onto a) blockMesh, b) snappyHexMesh c) relocate d) autoPatch ####
###### e) #############################################
################################################################################
STUDYNAME=Alg340kPa200DPsConical
INPUTCSV=$STUDYNAME.csv
MASTERSCRIPTSPATH=/home/msr/autoMount/Data_Documents/Dox_ownCloud/\
openFoamDataSR/Scripts_back-up
MODELDIRECTORYPATH=$MASTERSCRIPTSPATH/modelOFDirectoryConicalBMD
INPUTBLOCKMESHDICT=$MODELDIRECTORYPATH/system/blockMeshDictX0.001Y0.03
BUPFORMATTERSCRIPT=$MASTERSCRIPTSPATH/bUpFormatterConical.sh
INPUTCONTROLDICT=$MODELDIRECTORYPATH/system/controlDict
INPUTFVSOLUTION=$MODELDIRECTORYPATH/system/fvSolution_relaxationFactors0.95
INPUTDECOMPOSEPARDICT=$MODELDIRECTORYPATH/system/decomposeParDict
INPUTTRANSPORTPROPERTIES=$MODELDIRECTORYPATH/constant/transportProperties_K_n
# FOAMINSTDIR=/opt/openfoam7;#oF7 in UBUNTU
FOAMINSTDIR=/opt/OpenFOAM/OpenFOAM-7;#of7 in MANJARO
OFPOSTPROCESSINGDIR=$FOAMINSTDIR/etc/caseDicts/postProcessing
################################################################################

mkdir -p $STUDYNAME;
cp -uv $INPUTCSV $STUDYNAME/ #|| exit && echo "problem" ;
cd $STUDYNAME #|| exit && echo "didn't change directory";

exec 3</dev/tty || exec 3<&0 #make FD 3 point to the TTY or stdin (as fallback)
#https://stackoverflow.com/questions/41650892/why-redirect-stdin-inside-a-while-read-loop-in-bash/41652573#41652573

awk -F, 'NR >= 204' $INPUTCSV | #choose rows
while IFS="," read -r \
directory Rb Rs Rm Lu Ll p_inlet K n deltaX deltaY; do
    mkdir "$directory"; #`directory` is parsed from previous command
    cd "$directory" && touch "$directory".foam;
    rm -rf logs/;
    mkdir -p logs/ 0/ constant/ system/;
### BLOCKMESHDICT ###### ####################################################
    cp -r $INPUTBLOCKMESHDICT ./system/BMD &&
    awk -v deltaX="$deltaX" -v deltaY="$deltaY" \
    -v Rb="$Rb" -v Rs="$Rs" -v Rm="$Rm" -v Lu="$Lu" -v Ll="$Ll" '{
        if ($1 ~ /(deltax_block0)/)
            {print $1"\t"deltaX";"}
        else if($1 ~ /(deltay_block0)/)
            {print $1"\t"deltaY";"}
        else if($0 ~ "//set Rbig here")
            {print $1"\t"Rb";";//set Rbig here}
        else if($0 ~ "//set Rsmall here")
            {print $1"\t"Rs";";//set Rsmall here}
        else if($0 ~ "//set Rmiddle here")
            {print $1"\t"Rm";";//set Rmiddle here}
        else if($0 ~ "//set Lupper here")
            {print $1"\t"Lu";";//set Lupper here}
        else if($0 ~ "//set Llower here")
            {print $1"\t"Ll";";//set Lupper here}
        else {print $0}}' system/BMD >| system/blockMeshDict  || exit;

    cp -ru $INPUTCONTROLDICT ./system/controlDict;
    cp -r $INPUTFVSOLUTION ./system/fvSolution;
    cp -r $INPUTDECOMPOSEPARDICT ./system/decomposeParDict;
    cp -r $MODELDIRECTORYPATH/system/createPatchDict ./system/;
    cp -r $MODELDIRECTORYPATH/system/extrudeMeshDict ./system/;
    cp -r $MODELDIRECTORYPATH/system/fvSchemes ./system/;
    cp -r $MODELDIRECTORYPATH/system/meshQualityDict ./system/;
    cp -r $MODELDIRECTORYPATH/constant/turbulenceProperties ./constant/;
#### TRANSPORTPROPERTIES #####################################################
    cp -ru $INPUTTRANSPORTPROPERTIES ./constant/transportProperties_K_n &&
    awk -v K="$K" -v n="$n" '{gsub(/K\;\/\//, K";//"); gsub(/n\;\/\//, n";//");
          print $0;}' constant/transportProperties_K_n > constant/\
transportProperties && rm -f transportProperties_K_n  || exit;

    # openFOAM commands start here
    # source $foamInstDir/etc/bashrc </dev/null;#^---------------------^ SC1090:
#Can't follow non-constant source. Use a directive to specify location.

    blockMesh | tee logs/blockMesh.log || exit;
    extrudeMesh | tee logs/"${PWD##*/}"_extrudeMesh.log || exit;#takes a 2D
#mesh and converts into wedge Mesh
    createPatch -overwrite | tee logs/"${PWD##*/}"_createPatch.log || exit;#uses
#createPatchDict and removes patches having `0` faces.
    # checkMesh -allTopology -allGeometry | tee \
    # logs/"${PWD##*/}"_checkMesh.log || exit;
    # making a `U` & `p` in `0` from `constant/polyMesh/boundary`
    awk -v p_inlet="$p_inlet" '{
          gsub("p_inlet=\"200\"","p_inlet = "p_inlet);
          print $0}' $BUPFORMATTERSCRIPT > \
    bUpFormatterConical.sh && source bUpFormatterConical.sh </dev/null || exit;

    transformPoints -scale '(0.001 0.001 0.001)' || exit;# scales the polyMesh,
# `p` or`U` is not affected; not needed if the `*.csv` is coded in millimeter.

    #Running openFOAM solvers and plot residuals using `gnuplot`
    # source $MASTERSCRIPTSPATH/mpirunOF.sh;#as mpirun devours the whole `stdin`
    decomposePar -force </dev/null && \
    mpirun -np 8 renumberMesh -parallel -overwrite <&3;
    rm -rf logs/foamlog && \
    mpirun -np 8 simpleFoam -parallel > logs/foamlog <&3;
    # pyFoamPlotWatcher.py logs/foamlog;
    reconstructPar <&3;

    # source $MASTERSCRIPTSPATH/scriptPlottingResidualsMagWSS.sh
    # source $MASTERSCRIPTSPATH/scriptPlottingResiduals.sh;

    #postProcessing #################
#     cp -v $OFPOSTPROCESSINGDIR/fields/CourantNo system/ && \
# postProcess -func CourantNo || exit;# -latestTiPme;
    # simpleFoam -postProcess -func wallShearStress || exit;# | tee \
# logs/"${PWD##*/}"_WSS.log </dev/null
    cp -r $OFPOSTPROCESSINGDIR/flowRate/flowRatePatch ./system/ && \
postProcess -func "flowRatePatch(name=outlet)" || exit;# | \
# tee logs/"${PWD##*/}"_flowrate.log
#     postProcess -func "flowRatePatch(name=inlet)" > logs/\
# "${PWD##*/}"inlet_flowrate.log </dev/null || exit;
    cp -v $OFPOSTPROCESSINGDIR/surfaceFieldValue/patchAverage ./system/ && \
postProcess -func "patchAverage(name=outlet,U,nu)" || exit;

    cd ..;#has to exit to the upper level to be able to run the next case
done;

exec 3<&- ## close FD 3 when done.
#Cleaning blockMeshDict Generated stuffs
cd .. && find $STUDYNAME -type d -name "dynamicCode" -exec rm -rf '{}' \;
# find $STUDYNAME -type d -name "processor*" -exec rm -r '{}' \;
