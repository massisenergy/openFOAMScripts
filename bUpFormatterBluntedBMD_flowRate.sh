#!/usr/bin/env bash
# ################################# Description ################################
# this awk script takes two `U` file needed for openFOAM, found in `0`
# directory of every project and formats a new U file, with input from
# a suitable `constant/polyMesh/boundary` file for assignement of
# patches (boundary conditions)
# NOTE: works with `blockMeshDict`
# ##############################################################################
#
mv constant/polyMesh/boundary constant/polyMesh/boundary_backup;
awk '$0!~"inGroups" {print;}
' constant/polyMesh/boundary_backup > constant/polyMesh/boundary_backup_1;

awk '#NR<=19 {print;}

    # $0~"inlet" {gsub("inlet","inlet//inlet")}
    NR==22 && $0~"type" {gsub("patch;","patch;//inlet"); print;}
    # $0~"outlet" {print $0"//outlet";}
    NR==28 && $0~"type" {gsub("patch;","patch;//outlet"); print;}
    # $0~"nozzleWall" {print $0"//wall";}
    NR==34 && $0~"type" {gsub("wall;","wall;//wall"); print;}
    NR==40 && $0~"type" {gsub("wall;","wall;//wall"); print;}
    NR==46 && $0~"type" {gsub("wall;","wall;//wall"); print;}
    # $0~"back" {print $0"//wedgeBack";}
    NR==52 && $0~"type" {gsub("wedge;","wedge;//wedgeBack"); print;}
    # $0~"front" {print $0"//wedgeFront";}
    NR==58 && $0~"type" {gsub("wedge;","wedge;//wedgeFront"); print;}

    $0~"type" && NR>=21 {next;}
    $0!~"inlet" || $0!~"outlet" || $0!~"nozzleWall" || $0!~"back" \
    $0!~"front" && NR>=21  {print;}
    # $0!~"inlet" && NR>=21 {print;}
' constant/polyMesh/boundary_backup_1 > constant/polyMesh/boundary;
# cat constant/polyMesh/boundary
################################################################################
#
#     # NR>19 && NR<41 {next;}
#
################################################################################
# next two AWK scripts formats `U` & `p` respectively, using `boundary`.
# this is for fromatting the U file
awk 'BEGIN{
    print \
    "/*--------------------------------*- C++ -*----------------------------------*\\"\
    "\n  =========                 |"\
    "\n  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox"\
    "\n   \\    /   O peration     | Website:  https://openfoam.org"\
    "\n    \\  /    A nd           | Version:  7"\
    "\n     \\/     M anipulation  |"\
    "\n\\*---------------------------------------------------------------------------*/"\
    "\nFoamFile"\
    "\n{"\
    "\n    version     2.0;"\
    "\n    format      ascii;"\
    "\n    class       volVectorField;"\
    "\n    object      U;"\
    "\n}"\
    "\n// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"\
    "\n"\
    "\ndimensions      [0 1 -1 0 0 0 0];"\
    "\n"\
    "\ninternalField   uniform (0 0 0);"\
    "\n"\
    "\nboundaryField"\
    "\n{"
}' > 0/U

awk 'BEGIN{FS=" "; flowRate = "1"}{
    if (NR <=19) {
        next;
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "inlet")) {
        print "\t\t"$1"\t\t\t""flowRateInletVelocity;"
        print "\t\t""volumetricFlowRate""\t\t\t""constant "flowRate";"
        print "\t\t""value""\t\t\t""uniform (0 0 0);"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "outlet")) {
        print "\t\t"$1"\t\t\t""zeroGradient;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "wall;")) {
        print "\t\t"$1"\t\t\t""noSlip;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "wedge")) {
        gsub("empty;","wedge;"); print;
    } else if ((NF == 2) && ($1 == "physicalType" || "nFaces" || "startFace")) {
        next;
    } else if ((NF == 3) && ($1 == "inGroups")) {
        next;
    } else if ((NF == 1) && ($0 == ")")) {
        print "}";
    } else {
        print;
    }
}' constant/polyMesh/boundary >> 0/U
################################################################################

################################################################################
#this is for fromatting the p file
awk 'BEGIN{
    print \
    "/*--------------------------------*- C++ -*----------------------------------*\\"\
    "\n  =========                 |"\
    "\n  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox"\
    "\n   \\    /   O peration     | Website:  https://openfoam.org"\
    "\n    \\  /    A nd           | Version:  7"\
    "\n     \\/     M anipulation  |"\
    "\n\\*---------------------------------------------------------------------------*/"\
    "\nFoamFile"\
    "\n{"\
    "\n    version     2.0;"\
    "\n    format      ascii;"\
    "\n    class       volScalarField;"\
    "\n    object      p;"\
    "\n}"\
    "\n// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //"\
    "\n"\
    "\ndimensions      [0 2 -2 0 0 0 0];"\
    "\n"\
    "\ninternalField   uniform 0;"\
    "\n"\
    "\nboundaryField"\
    "\n{"
}' > 0/p

awk 'BEGIN{FS=" "}{
    if (NR <=19) {
        next;
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "inlet")) {
        print "\t\t"$1"\t\t\t""zeroGradient;"

    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "outlet")) {
        print "\t\t"$1"\t\t\t""fixedValue;"
        print "\t\t""value""\t\t\t""uniform 0;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "wall;")) {
        print "\t\t"$1"\t\t\t""zeroGradient;"
    } else if ((NF == 2) && ($1 == "type") && ($2 ~ "wedge")) {
        gsub("empty;","wedge;"); print;
    } else if ((NF == 2) && ($1 == "physicalType" || "nFaces" || "startFace")) {
        next;
    } else if ((NF == 3) && ($1 == "inGroups")) {
        next;
    } else if ((NF == 1) && ($0 == ")")) {
        print "}";
    } else {
        print;
    }
}' constant/polyMesh/boundary >> 0/p
##############################################################################
